# PowerShell script to disable drivers

# Start PowerShell with Admin rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!" -ForegroundColor Red
    exit
}

# Define device name patterns
$driverName1 = "TEXA Navigator Nano"
$driverName2 = "Sentinel USB Key"
$driverName3 = "USB Serial Device"
$driverName4 = "TEXA Multihub Serial Gadget"

# Get TEXA/USB/MultiHub devices (non-exact match for some)
$driver = Get-PnpDevice | Where-Object {
    $_.FriendlyName -like $driverName1 -or
    $_.FriendlyName -like "*$driverName3*" -or
    $_.FriendlyName -like "*$driverName4*"
}

# Get Sentinel device separately
$driver2 = Get-PnpDevice | Where-Object { $_.FriendlyName -eq $driverName2 }

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

# Disable Sentinel USB Key
if ($driver2) {
    try {
        Disable-PnpDevice -InstanceId $driver2.InstanceId -Confirm:$false -ErrorAction Stop
        Write-Host "$($driver2.FriendlyName) disabled successfully." -ForegroundColor Yellow
    } catch {
        Write-Warning "Failed to disable $($driver2.FriendlyName): $_"
    }
}
