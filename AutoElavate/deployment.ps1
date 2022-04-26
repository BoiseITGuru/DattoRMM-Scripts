# Copyright (c) 2020 AutoElevate
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the AutoElevate nor the names of its contributors
#      may be used to endorse or promote products derived from this software
#      without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL OPENDNS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
# OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

<#
.SYNOPSIS
  Installs the AutoElevate agent using the License Key, Company Name, and Location supplied below
  
.DIRECTIONS
  Insert your license key below.  Change the default agent mode if you desire
  (audit, live, policy), and set the "Company Name" & "Location Name" that will be used to
  "group" these assets.
#>

$LICENSE_KEY = $env:AutoElevate_Key
$COMPANY_NAME = $env:CS_PROFILE_NAME
$AGENT_MODE = "audit"
$LOCATION_NAME = "Main Office"

# Set $DebugPrintEnabled = 1 to enabled debug log printing to see what's going on.
$DebugPrintEnabled = 0

# You don't need to change anything below this line...

$InstallerName = "AESetup.msi"
$InstallerPath = Join-Path $Env:TMP $InstallerName
$DownloadBase = "https://autoelevate-installers.s3.us-east-2.amazonaws.com"
$DownloadURL = $DownloadBase + "/current/" + $InstallerName
$ServiceName = "AutoElevateAgent"

$ScriptFailed = "Script Failed!"

function Get-TimeStamp {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

function Confirm-ServiceExists ($service) {
    if (Get-Service $service -ErrorAction SilentlyContinue) {
        return $true
    }
    
    return $false
}

function Debug-Print ($msg) {
    if ($DebugPrintEnabled -eq 1) {
        Write-Host "$(Get-TimeStamp) [DEBUG] $msg"
    }
}

function Get-Installer {
    Debug-Print("Downloading installer...")
    $WebClient = New-Object System.Net.WebClient
    
    try {
        $WebClient.DownloadFile($DownloadURL, $InstallerPath)
    } catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$(Get-TimeStamp) $ErrorMessage"
    }
    
    if ( ! (Test-Path $InstallerPath)) {
        $DownloadError = "Failed to download the AutoElevate Installer from $DownloadURL"
        Write-Host "$(Get-TimeStamp) $DownloadError"
        throw $ScriptFailed
    }
    
    Debug-Print("Installer downloaded to $InstallerPath...")
}

function Install-Agent () {
    Debug-Print("Checking for AutoElevateAgent service...")
    
    if (Confirm-ServiceExists($ServiceName)) {
        Write-Host "$(Get-TimeStamp) Service exists. Continuing with possible upgrade..."
    }
    else {
        Write-Host "$(Get-TimeStamp) Service does not exist. Continuing with initial installation..."
    }

    Debug-Print("Checking for installer file...")
    
    if ( ! (Test-Path $InstallerPath)) {
        $InstallerError = "The installer was unexpectedly removed from $InstallerPath"
        Write-Host "$(Get-TimeStamp) $InstallerError"
        Write-Host ("$(Get-TimeStamp) A security product may have quarantined the installer. Please check " +
                               "your logs. If the issue continues to occur, please send the log to the AutoElevate " +
                               "Team for help at support@autoelevate.com")
        throw $ScriptFailed
    }

    Debug-Print("Executing installer...")
    
    $Arguments = "/i {0} /quiet LICENSE_KEY=""{1}"" COMPANY_NAME=""{2}"" LOCATION_NAME=""{3}"" AGENT_MODE=""{4}""" -f $InstallerPath, $LICENSE_KEY, $COMPANY_NAME, $LOCATION_NAME, $AGENT_MODE
    
    Start-Process C:\Windows\System32\msiexec.exe -ArgumentList $Arguments -Wait
}

function Verify-Installation () {
    Debug-Print("Verifying Installation...")
    
    if ( ! (Confirm-ServiceExists($ServiceName))) {
        $VerifiationError = "The AutoElevateAgent service is not running. Installation failed!"
        Write-Host "$(Get-TimeStamp) $VerificationError"
        
        throw $ScriptFailed
    }
}

function main () {
    Debug-Print("Checking for LICENSE_KEY...")
    
    if ($LICENSE_KEY -eq "__LICENSE_KEY_HERE__" -Or $LICENSE_KEY -eq "") {
        Write-Warning "$(Get-TimeStamp) LICENSE_KEY not set, exiting script!"
        exit 1
    }
     
    if ($COMPANY_NAME -eq "__COMPANY_NAME_HERE___" -Or $COMPANY_NAME -eq "") {
        Write-Warning "$(Get-TimeStamp) company_name not specified, exiting script!"
        exit 1
    }

    Write-Host "$(Get-TimeStamp) CompanyName: " $COMPANY_NAME
    Write-Host "$(Get-TimeStamp) LocationName: " $LOCATION_NAME
    Write-Host "$(Get-TimeStamp) AgentMode: " $AGENT_MODE
    
    Get-Installer
    Install-Agent
    Verify-Installation
    
    Write-Host "$(Get-TimeStamp) AutoElevate Agent successfully installed!"
}

try
{
    main
} catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "$(Get-TimeStamp) $ErrorMessage"
    exit 1
}