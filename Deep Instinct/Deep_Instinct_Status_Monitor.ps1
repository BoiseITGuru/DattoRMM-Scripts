# $Deep_Instinct_Status is a custom asset field

function Set-DI-Status {
    New-ItemProperty "HKLM:\SOFTWARE\CentraStage" -Name "Custom1" -PropertyType string -value $Deep_Instinct_Status -Force
}

$Deep_Instinct_Status = $env:UDF_1

if ($Deep_Instinct_Status -eq "_EXCLUDED_") {
    Write-Host "Excluded from DI"
    exit 0
} elseif (![System.IO.File]::Exists("C:\ProgramData\DeepInstinct\settings.json")) {
    $Deep_Instinct_Status = "NOT-INSTALLED"
    Write-Host 'Deep Instict not installed'
    Set-DI-Status
    exit 1
} else {
    if (fltmc | Select-String -Pattern "DeepStaticDriver" -Quiet) {
        $Deep_Instinct_Status = "INSTALLED"
        Write-Host 'Deep Instict installed'
        Set-DI-Status
        #Set-DI-Custom-AV-Status($true)
        exit 0
    } else {
        $Deep_Instinct_Status = "ORPHANED"
        Write-Host 'Deep Instict install has been orphaned'
        Set-DI-Status
        #Set-DI-Custom-AV-Status($false)
        exit 1
    }
}

#function Set-DI-Custom-AV-Status($running) {
#    if ($running) {
#        $json = {
#            "product": "Deep Instinct",
#            "running":$running,
#            "upToDate":true
#            }
#
#        $json | Out-File "%ProgramData%\CentraStage\AEMAgent\antivirus.json"
#    }
#}