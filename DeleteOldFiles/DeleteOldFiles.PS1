$folderPath = "C:\Users\AirPro\Documents\Scan_PDFs"

if (-not (Test-Path -Path $folderPath -PathType Container)) {
    New-Item -Path $folderPath -ItemType Directory
    Write-Host "Created directory: $folderPath"
    }

$daysOld = 30

$dateThreshold = (Get-Date).AddDays(-$daysOld)

# Get all files in the folder that are older than the threshold
Get-ChildItem -Path $folderPath -Recurse -Force | Where-Object { $_.LastWriteTime -lt $dateThreshold } | Remove-Item -Force
