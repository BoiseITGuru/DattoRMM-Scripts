#Set PowerShell to acceppt SSL Connection to DI Server
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$Deep_Instinct_Status = $env:UDF_1
$Deep_Instinct_ID = $env:Deep_Instinct_ID

if ($Deep_Instinct_Status -eq "_EXCLUDED_") {
  Write-Host "Excluded from DI"
} elseif ([string]::IsNullOrEmpty($Deep_Instinct_Status)) { 
    $Deep_Instinct_Status = "NOT PROVISIONED"
    Write-Host 'Deep Instict ID not provisioned for this customer'
} else {
    $osBuild = [system.environment]::OSversion.version.build
  
    if ($osBuild -lt 7601) {
        $Deep_Instinct_Status = "OS ERROR"
    } else {
        $connect1 = Invoke-WebRequest -Uri "https://the20.customers.deepinstinctweb.com:4339/test" -UseBasicParsing
            
        if ($connect1.StatusDescription -eq "OK") {
            fltmc | ForEach-Object { 
                if ($_ -contains ".") { 
                    $Deep_Instinct_Status = "FLT ISSUE"
                } else {
                    #verify tech-adv folder exists
                    $path = "C:\tech-adv"
                    if (!(Test-Path $path)) {
                      New-Item -ItemType Directory -Force -Path $path
                    }

                    #Remove old installer if exists
                    $DI_Installer_File = "C:\tech-adv\DI_installer.exe"
                    if (Test-Path $DI_Installer_File) {
                      Remove-Item $DI_Installer_File
                    }
                    
                    #Download DI Installer
                    $url = "https://tech-advocates-downloads.s3.us-west-2.amazonaws.com/3.1.0.16_InstallerManaged_deep.exe"
                    $path_to_file = "C:\tech-adv\DI_installer.exe"
                    Invoke-WebRequest $url -OutFile $path_to_file 
                    
                    #Install DI
                    C:\tech-adv\DI_installer.exe the20.customers.deepinstinctweb.com /token $Deep_Instinct_ID
                    
                    #Check if Installed
                    if (Test-Path "C:\ProgramData\DeepInstinct\settings.json") {
                        $Deep_Instinct_Status = "INSTALLED"
                    } else {
                       $Deep_Instinct_Status = "CHK-INSTALL"
                       Write-Host 'Deep Instict Install Failed'
                       
                    }
                }
            }
        } else {
            $Deep_Instinct_Status = "NTWK ERROR"
        }
    }
    New-ItemProperty "HKLM:\SOFTWARE\CentraStage" -Name "Custom1" -PropertyType string -value $Deep_Instinct_Status -Force
} 