# Ensure script is run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!" -ForegroundColor Red
    exit
}

# Define search names
$cardaqSearchName = "CarDaq-Plus 3 J2534"
$dgSearchName = "VSI-NxGen USB VCom Port"

# Try to find CarDaq first
$cardaqDevices = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*$cardaqSearchName*" }

if ($cardaqDevices) {
    foreach ($device in $cardaqDevices) {
        try {
            Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false -ErrorAction Stop
			Write-Host "Disabled CarDaq: $($device.FriendlyName)" -ForegroundColor Yellow
        } catch {
            Write-Warning "Failed to enable CarDaq: $($device.FriendlyName): $_"
        }
    }
} else {
    # If CarDaq not found, try DG
    $dgDevices = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*$dgSearchName*" }

    if ($dgDevices) {
        foreach ($device in $dgDevices) {
            try {
                Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false -ErrorAction Stop
                Write-Host "Disabled DG: $($device.FriendlyName)" -ForegroundColor Yellow
            } catch {
                Write-Warning "Failed to enable DG: $($device.FriendlyName): $_"
            }
        }
    } else {
        Write-Host "No CarDaq or DG device found." -ForegroundColor Yellow
    }
}
