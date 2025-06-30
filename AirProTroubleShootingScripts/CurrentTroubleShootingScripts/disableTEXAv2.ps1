# PowerShell script to disable drivers

# Start PowerShell with Admin rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!" -ForegroundColor Red
    exit
}

# Define device name patterns
$driverName1 = "TEXA Navigator Nano  TCXE01"
$driverName2 = "Sentinel USB Key"
$driverName2Alt = "Sentinel HASP Key"
$driverName3 = "USB Serial Device"
$driverName4 = "TEXA Multihub Serial Gadget"

# Get TEXA/USB/MultiHub devices
$driver = Get-PnpDevice | Where-Object {
    $_.FriendlyName -eq $driverName1 -or
    $_.FriendlyName -like "*$driverName3*" -or
    $_.FriendlyName -like "*$driverName4*"
}

# Get Sentinel devices (either name)
$sentinelDrivers = Get-PnpDevice | Where-Object {
    $_.FriendlyName -eq $driverName2 -or
    $_.FriendlyName -eq $driverName2Alt
}

# Disable TEXA / USB / Multihub
if ($driver) {
    foreach ($d in $driver) {
        try {
            Disable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction Stop
            Write-Host "$($d.FriendlyName) disabled successfully." -ForegroundColor Yellow
        } catch {
            Write-Warning "Failed to disable $($d.FriendlyName): $_"
        }
    }
}

# Disable Sentinel devices
if ($sentinelDrivers) {
    foreach ($s in $sentinelDrivers) {
        try {
            Disable-PnpDevice -InstanceId $s.InstanceId -Confirm:$false -ErrorAction Stop
            Write-Host "$($s.FriendlyName) disabled successfully." -ForegroundColor Yellow
        } catch {
            Write-Warning "Failed to disable $($s.FriendlyName): $_"
        }
    }
}
