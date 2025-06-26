# PowerShell script to enable drivers

# Start PowerShell with Admin rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!" -ForegroundColor Red
    exit
}

# Define device name patterns
$driverName1 = "TEXA Navigator Nano  TCXE01"
$driverName2 = "Sentinel USB Key"
$driverName3 = "USB Serial Device"
$driverName4 = "TEXA Multihub Serial Gadget"

# Get TEXA/USB/MultiHub devices (non-exact match for some)
$driver = Get-PnpDevice | Where-Object {
    $_.FriendlyName -eq $driverName1 -or
    $_.FriendlyName -like "*$driverName3*" -or
    $_.FriendlyName -like "*$driverName4*"
}

# Get Sentinel device separately
$driver2 = Get-PnpDevice | Where-Object { $_.FriendlyName -eq $driverName2 }

# Enable TEXA / USB / Multihub
if ($driver) {
    foreach ($d in $driver) {
        try {
            Enable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction Stop
            Write-Host "$($d.FriendlyName) enabled successfully." -ForegroundColor Green
        } catch {
            Write-Warning "Failed to enable $($d.FriendlyName): $_"
        }
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
