########### Monitor Edge Update Settings ###############
# This script monitors if the required registry        #
# settings are in place to force Edge to check for     #
# updates.                                             #
########################################################

## Get RelaunchNotification Value
$RelaunchNotification = Get-ItemPropertyValue -Path 'HKLM:SOFTWARE\Policies\Microsoft\Edge' -Name "RelaunchNotification"

if ($RelaunchNotification -eq 2) {
    ## Registry key set to required; Exit Safely
    exit 0
} else {
    ## Registry key NOT set to required; Exit With Error
    exit 1
}