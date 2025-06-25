# PowerShell script to disable CarDaq-Plus 3 J2534 device

# Ensure script is run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!" -ForegroundColor Red
    exit
}

# Define partial name to search
$cardaqSearchName = "CarDaq-Plus 3 J2534"

# Search for device(s) with matching FriendlyName
$cardaqDevices = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*$cardaqSearchName*" }

# Disable each matching device
if ($cardaqDevices) {
    foreach ($device in $cardaqDevices) {
        try {
            Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false -ErrorAction Stop
            Write-Host "Disabled: $($device.FriendlyName)" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to disable $($device.FriendlyName): $_"
        }
    }
} else {
    Write-Host "No CarDaq-Plus 3 device found." -ForegroundColor Gray
}
