# Define variables
$isoUrl = "https://archlinux.org/releng/releases/"
$isoPattern = "archlinux-[0-9]{4}\.[0-9]{2}\.[0-9]{2}-x86_64\.iso"
$downloadPath = "$env:USERPROFILE\Downloads\archlinux.iso"
$usbDriveLetter = "E:"  # Change this to your USB drive letter

# Function to download the latest Arch Linux ISO
function Download-ArchLinuxISO {
    Write-Output "Fetching the latest Arch Linux ISO URL..."
    $isoPageContent = Invoke-WebRequest -Uri $isoUrl
    $isoMatches = [regex]::Matches($isoPageContent.Content, $isoPattern)
    if ($isoMatches.Count -eq 0) {
        Write-Error "Could not find the ISO URL."
        exit
    }
    $latestIsoUrl = "https://archlinux.org/releng/releases/" + $isoMatches[0].Value
    Write-Output "Downloading the latest Arch Linux ISO from $latestIsoUrl..."
    Invoke-WebRequest -Uri $latestIsoUrl -OutFile $downloadPath
    Write-Output "Downloaded ISO to $downloadPath"
}

# Function to create a bootable USB drive
function Create-BootableUSB {
    param (
        [string]$isoPath,
        [string]$driveLetter
    )
    Write-Output "Preparing USB drive $driveLetter..."
    # Clear the USB drive
    $diskPartScript = @"
select volume $driveLetter
clean
create partition primary
active
format fs=fat32 quick
assign letter=$driveLetter
exit
"@
    $diskPartScript | Out-File -FilePath "$env:TEMP\diskpart_script.txt" -Encoding ASCII
    Start-Process -FilePath "diskpart.exe" -ArgumentList "/s `"$env:TEMP\diskpart_script.txt`"" -Wait -NoNewWindow

    Write-Output "Writing ISO to USB drive..."
    $ddScript = @"
@echo off
SetLocal EnableDelayedExpansion

REM Change to the directory where the dd tool is located
cd /d "%~dp0"

REM Write ISO to USB drive
dd if="$isoPath" of=\\.\$driveLetter bs=4M status=progress

echo Done.
"@
    $ddScript | Out-File -FilePath "$env:TEMP\write_iso_to_usb.bat" -Encoding ASCII
    Start-Process -FilePath "$env:TEMP\write_iso_to_usb.bat" -Wait -NoNewWindow

    Write-Output "Bootable USB drive created successfully."
}

# Main script execution
Download-ArchLinuxISO
Create-BootableUSB -isoPath $downloadPath -driveLetter $usbDriveLetter
