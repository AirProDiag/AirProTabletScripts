# Check if PowerBGInfo module is installed
if (-not (Get-Module -ListAvailable -Name PowerBGInfo)) {
    Install-Module -Name PowerBGInfo -Force > $null 2>&1
}

# Import PowerBGInfo module
Import-Module PowerBGInfo > $null 2>&1

# Add C# type for idle time detection
Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class IdleTime {
    [DllImport("user32.dll")]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    [StructLayout(LayoutKind.Sequential)]
    public struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }

    public static uint GetIdleTime() {
        LASTINPUTINFO lii = new LASTINPUTINFO();
        lii.cbSize = (uint)Marshal.SizeOf(lii);
        GetLastInputInfo(ref lii);
        return ((uint)Environment.TickCount - lii.dwTime) / 1000;
    }
}
"@

# Initialize previous statuses
$previousTexaStatus = ""
$previousHaspKeyStatus = ""
$previousJ2534Status = ""
$previousJlrStatus = ""
$previousIdleThresholdExceeded = $false

while ($true) {
    try {
        $idleTime = [IdleTime]::GetIdleTime()
        $sessionJustBecameActive = $false

        if ($idleTime -lt 10) {
            if ($previousIdleThresholdExceeded) {
                $sessionJustBecameActive = $true
            }
            $previousIdleThresholdExceeded = $false
        } else {
            $previousIdleThresholdExceeded = $true
        }

        $deviceName = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Name
        $devices = Get-PnpDevice

        # Check for Bosch VCI
        $jlrDevice = $devices | Where-Object { $_.Name -like "*Bosch VCI*" -and $_.Status -eq 'OK' }

        if ($deviceName -like "*JLR*") {
            if ($jlrDevice) {
                if ($previousJlrStatus -ne "Connected" -or $sessionJustBecameActive) {
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
                if ($previousJlrStatus -ne "Disconnected" -or $sessionJustBecameActive) {
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
        $texaDevice = $devices | Where-Object { $_.Name -like "*TEXA Navigator Nano*" -and $_.Status -eq 'OK' }
        $usbSerialDevice = $devices | Where-Object { $_.Name -like "*USB Serial Device*" -and $_.Status -eq 'OK' }

        if ($texaMultihubDevice) {
            $texaDeviceStatus = "Texa Multihub Connected"
        } elseif ($texaDevice -or $usbSerialDevice) {
            $texaDeviceStatus = "Connected"
        } else {
            $texaDeviceStatus = "Disconnected"
        }

        # J2534 check
        $j2534Status = ""
        if (-not $texaMultihubDevice) {
            $cardaqDevice = $devices | Where-Object { $_.Name -like "*CarDAQ-Plus 3 J2534*" -and $_.Status -eq 'OK' }
            $dgDevice = $devices | Where-Object { $_.Name -like "*VSI-NxGen USB VCom*" -and $_.Status -eq 'OK' }

            $j2534Status = if ($dgDevice) {
                "DG Connected"
            } elseif ($cardaqDevice) {
                "Cardaq Connected"
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

        # Update wallpaper on status change or session unlock
        if ($texaDeviceStatus -ne $previousTexaStatus -or 
            $haspKeyDeviceStatus -ne $previousHaspKeyStatus -or 
            $j2534Status -ne $previousJ2534Status -or
            $sessionJustBecameActive) {

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
