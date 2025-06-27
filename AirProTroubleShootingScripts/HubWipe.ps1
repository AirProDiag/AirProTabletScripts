$confirmation = Read-Host -Prompt "WARNING: This script will immediately remove USB devices and REBOOT the system. Press 'Y' then Enter to continue"

if ($confirmation -ne 'Y') {
    Write-Host "Operation cancelled by user."
    exit
}

$devcon = "C:\Program Files (x86)\Windows Kits\10\Tools\10.0.26100.0\x64\devcon.exe"

function Remove-USBDevicesAndControllers {
    Write-Host "Removing USB Root Hubs (USB 3.0)..."
    $rootHubs = Get-PnpDevice | Where-Object { $_.FriendlyName -eq "USB Root Hub (USB 3.0)" }

    foreach ($hub in $rootHubs) {
        Write-Host "Found Root Hub: $($hub.InstanceId)"

        $query = "Associators of {Win32_PnPEntity.DeviceID='" + $hub.InstanceId.Replace('\','\\') + "'} Where AssocClass=Win32_PnPEntity"
        $children = Get-WmiObject -Query $query

        foreach ($child in $children) {
            try {
                Write-Host "Removing child device: $($child.Name)"
                & $devcon remove "@$($child.DeviceID)"
            } catch {
                Write-Warning "Failed to remove child device: $_"
            }
        }

        try {
            Write-Host "Removing root hub: $($hub.FriendlyName)"
            & $devcon remove "@$($hub.InstanceId)"
        } catch {
            Write-Warning "Failed to remove root hub: $_"
        }
    }

    Write-Host "Removing Intel USB 3.1 Host Controllers..."
    $intelUSBControllers = Get-PnpDevice | Where-Object { $_.FriendlyName -like "Intel(R) USB 3.1*Host Controller*" }

    foreach ($controller in $intelUSBControllers) {
        try {
            Write-Host "Removing Intel controller: $($controller.FriendlyName)"
            & $devcon remove "@$($controller.InstanceId)"
        } catch {
            Write-Warning "Failed to remove Intel controller: $_"
        }
    }

    Write-Host "Removing known diagnostic tools (Texa, CarDAQ, DG, HASP)..."
    $patterns = @("*TEXA Navigator Nano*", "*TEXA Multihub Serial Gadget*", "*USB Serial Device*", "*CarDAQ-Plus 3 J2534*", "*VSI-NxGen USB VCom*", "*HASP Key*", "*Bosch VCI*")

    foreach ($pattern in $patterns) {
        $matches = Get-PnpDevice | Where-Object { $_.Name -like $pattern }
        foreach ($match in $matches) {
            try {
                Write-Host "Removing matched device: $($match.Name)"
                & $devcon remove "@$($match.InstanceId)"
            } catch {
                Write-Warning "Failed to remove $($match.Name): $_"
            }
        }
    }
}

# First and second pass
Remove-USBDevicesAndControllers
Start-Sleep -Seconds 4
Remove-USBDevicesAndControllers

# Optional reboot
Start-Sleep -Seconds 10
Restart-Computer -Force
