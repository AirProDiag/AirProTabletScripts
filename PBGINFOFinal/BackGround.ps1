# Check if PowerBGInfo module is installed
if (-not (Get-Module -ListAvailable -Name PowerBGInfo)) {
    Install-Module -Name PowerBGInfo -Force > $null 2>&1
}

# Import PowerBGInfo module
Import-Module PowerBGInfo > $null 2>&1

# Initialize previous statuses
$previousTexaStatus = ""
$previousHaspKeyStatus = ""
$previousJ2534Status = ""
$previousJlrStatus = ""

while ($true) {
    try {
        $deviceName = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Name
        $devices = Get-PnpDevice

        # Check for Bosch VCI
        $jlrDevice = $devices | Where-Object { $_.Name -like "*Bosch VCI*" -and $_.Status -eq 'OK' }

        if ($deviceName -like "*JLR*") {
            if ($jlrDevice) {
                # Show Bosch VCI info only if device is connected
                if ($previousJlrStatus -ne "Connected") {
                    New-BGInfo -MonitorIndex 0 -PositionY 095 {
                        New-BGInfoValue -Name "Tool Number" -Value $env:COMPUTERNAME -Color White -FontSize 40 -FontFamilyName 'Calibri'
                        New-BGInfoValue -Name "JLR VCI" -Value "Connected" -Color White -FontSize 35 -FontFamilyName 'Calibri'
                    } -FilePath "C:\Users\AirPro\Desktop\Utilities\pbginfo\airprowp.jpg" -ConfigurationDirectory "C:\Users\AirPro\Desktop\Utilities\pbginfo\Output" -PositionX 600 -WallpaperFit Stretch

                    $previousJlrStatus = "Connected"
                    $previousTexaStatus = ""
                    $previousHaspKeyStatus = ""
                    $previousJ2534Status = ""
                }
            } else {
                # Show "Disconnected" if JLR system is present but Bosch VCI is not connected
                if ($previousJlrStatus -ne "Disconnected") {
                    New-BGInfo -MonitorIndex 0 -PositionY 095 {
                        New-BGInfoValue -Name "Tool Number" -Value $env:COMPUTERNAME -Color White -FontSize 40 -FontFamilyName 'Calibri'
                        New-BGInfoValue -Name "JLR VCI" -Value "Disconnected" -Color Red -FontSize 35 -FontFamilyName 'Calibri'
                    } -FilePath "C:\Users\AirPro\Desktop\Utilities\pbginfo\airprowp.jpg" -ConfigurationDirectory "C:\Users\AirPro\Desktop\Utilities\pbginfo\Output" -PositionX 600 -WallpaperFit Stretch

                    $previousJlrStatus = "Disconnected"
                    $previousTexaStatus = ""
                    $previousHaspKeyStatus = ""
                    $previousJ2534Status = ""
                }
            }
            Start-Sleep -Seconds 30
            continue
        }

        # TEXA Multihub check
        $texaMultihubDevice = $devices | Where-Object { $_.Name -like "*TEXA Multihub Serial Gadget (COM5)*" -and $_.Status -eq 'OK' }
        $texaDevice = $devices | Where-Object { $_.Name -like "*TEXA Navigator Nano*" }

        if ($texaMultihubDevice) {
            $texaDeviceStatus = "Texa Multihub Connected"
        } elseif ($texaDevice -and $texaDevice.Status -eq 'OK') {
            $texaDeviceStatus = "Connected"
        } else {
            $texaDeviceStatus = "Disconnected"
        }

        # J2534 check (skip if TEXA Multihub is connected)
        $j2534Status = ""
        if (-not $texaMultihubDevice) {
            $cardaqDevice = $devices | Where-Object { $_.Name -like "*CarDAQ-Plus 3 J2534*" -and $_.Status -eq 'OK' }
            $dgDevice = $devices | Where-Object { $_.Name -like "*VSI-NxGen USB VCom*" -and $_.Status -eq 'OK' }

            $j2534Status = if ($dgDevice) {
                "DG Connected"
            } elseif ($cardaqDevice) {
                "Connected"
            } else {
                "Disconnected"
            }
        }

        # HASP Key check
        $haspKeyDevice = $devices | Where-Object { $_.Name -like "*HASP Key*" }
        $haspKeyDeviceStatus = if ($haspKeyDevice -and $haspKeyDevice.Status -eq 'OK') {
            "Connected"
        } else {
            "Disconnected"
        }

        # Update wallpaper only if something changed
        if ($texaDeviceStatus -ne $previousTexaStatus -or 
            $haspKeyDeviceStatus -ne $previousHaspKeyStatus -or 
            $j2534Status -ne $previousJ2534Status) {

            New-BGInfo -MonitorIndex 0 -PositionY 095 {
                New-BGInfoValue -Name "Tool Number" -Value $env:COMPUTERNAME -Color White -FontSize 40 -FontFamilyName 'Calibri'

                $texaColor = if ($texaDeviceStatus -like "*Disconnected*") { "Red" } else { "White" }
                New-BGInfoValue -Name "Texa" -Value $texaDeviceStatus -Color $texaColor -FontSize 35 -FontFamilyName 'Calibri'

                $haspKeyColor = if ($haspKeyDeviceStatus -like "*Disconnected*") { "Red" } else { "White" }
                New-BGInfoValue -Name "Hasp Key" -Value $haspKeyDeviceStatus -Color $haspKeyColor -FontSize 35 -FontFamilyName 'Calibri'

                if ($j2534Status) {
                    $j2534Color = if ($j2534Status -like "*Disconnected*") { "Red" } else { "White" }
                    New-BGInfoValue -Name "J2534" -Value $j2534Status -Color $j2534Color -FontSize 35 -FontFamilyName 'Calibri'
                }
            } -FilePath "C:\Users\AirPro\Desktop\Utilities\pbginfo\airprowp.jpg" -ConfigurationDirectory "C:\Users\AirPro\Desktop\Utilities\pbginfo\Output" -PositionX 600 -WallpaperFit Stretch

            $previousTexaStatus = $texaDeviceStatus
            $previousHaspKeyStatus = $haspKeyDeviceStatus
            $previousJ2534Status = $j2534Status
        }

        Start-Sleep -Seconds 30
    } catch {
        continue
    }
}
