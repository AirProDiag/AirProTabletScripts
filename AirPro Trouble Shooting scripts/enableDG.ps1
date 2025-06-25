# PowerShell script to enable CarDaq-Plus 3 J2534 device

# Ensure script is run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!" -ForegroundColor Red
    exit
}

# Define partial name to search
$DGSearchName = "VSI-NxGen USB VCom Port"

# Search for device(s) with matching FriendlyName
$DGDevices = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*$DGSearchName*" }

# Enable each matching device
if ($DGDevices) {
    foreach ($device in $DGDevices) {
        try {
            Enable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false -ErrorAction Stop
            Write-Host "Enabled: $($device.FriendlyName)" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to enable $($device.FriendlyName): $_"
        }
    }
} else {
    Write-Host "No DG device found." -ForegroundColor Gray
}
