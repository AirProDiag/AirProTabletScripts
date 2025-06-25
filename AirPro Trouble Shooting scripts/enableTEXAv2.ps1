# PowerShell script to enable drivers

# Start PowerShell with Admin rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!" -ForegroundColor Red
    exit
}

# Define names
$driverName = "TEXA Navigator Nano  TCXE01"
$driverName2 = "Sentinel USB Key"
$driverName3 = "USB Serial Device"

# Get either TEXA or USB Serial Device
$driver = Get-PnpDevice | Where-Object {
    $_.FriendlyName -eq $driverName -or
    $_.FriendlyName -like "*$driverName3*"
}

# Get Sentinel device separately
$driver2 = Get-PnpDevice | Where-Object { $_.FriendlyName -eq $driverName2 }

# Enable TEXA or USB Serial
if ($driver) {
    try {
        Enable-PnpDevice -InstanceId $driver.InstanceId -Confirm:$false -ErrorAction Stop
        Write-Host "$($driver.FriendlyName) enabled successfully." -ForegroundColor Green
    } catch {
        Write-Warning "Failed to enable $($driver.FriendlyName): $_"
    }
}

# Enable Sentinel USB Key
if ($driver2) {
    try {
        Enable-PnpDevice -InstanceId $driver2.InstanceId -Confirm:$false -ErrorAction Stop
        Write-Host "$($driver2.FriendlyName) enabled successfully." -ForegroundColor Green
    } catch {
        Write-Warning "Failed to enable $($driver2.FriendlyName): $_"
    }
}
