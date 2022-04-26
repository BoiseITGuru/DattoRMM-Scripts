############ Force Edge Update Settings ################
# This script sets the required registry keys to force #
# Edge to check for updates on each launch. By default #
# it will set the update restart to required within 5  #
# minutes but these can be overwritten                 #
########################################################

## Set RelaunchNotification
$RelaunchNotification = $env:RelaunchNotification

## Set RelaunchNotificationPeriod and convert to Miliseconds
$RelaunchNotificationPeriod = [int]$env:RelaunchNotificationPeriod
$RelaunchNotificationPeriod = $RelaunchNotificationPeriod * 60000

## Set Edge Relaunch Notification to Required
New-ItemProperty "hklm:SOFTWARE\Policies\Microsoft\Edge" -Name "RelaunchNotification" -Value $RelaunchNotification -PropertyType "DWord" –Force

## Set Edge Relaunch Notification Period to 5 Minutes
New-ItemProperty "hklm:SOFTWARE\Policies\Microsoft\Edge" -Name "RelaunchNotificationPeriod" -Value $RelaunchNotificationPeriod -PropertyType "DWord" –Force