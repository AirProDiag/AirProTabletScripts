# PowerShell script to disable a driver

# Start PowerShell with Admin rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!" -ForegroundColor Red
    exit
}


# Define names
$driverName = "TEXA Navigator Nano  TCXE01"
$driverName2 = "Sentinel USB Key"
$driverName3 = "USB Serial Device"

# Try to get TEXA or USB Serial Device
$driver = Get-PnpDevice | Where-Object {
    $_.FriendlyName -eq $driverName -or
    $_.FriendlyName -like "*$driverName3*"
}

# Sentinel USB Key b
$driver2 = Get-PnpDevice | Where-Object { $_.FriendlyName -eq $driverName2 }

# Disable if found
if ($driver) {
    Disable-PnpDevice -InstanceId $driver.InstanceId -Confirm:$false
}
if ($driver2) {
    Disable-PnpDevice -InstanceId $driver2.InstanceId -Confirm:$false
}

