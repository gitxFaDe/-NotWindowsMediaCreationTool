# Define variables
$DownloadPath = "$env:USERPROFILE\Downloads\notwindows.iso"
  
# Retrieve the list of partitions
$Partitions = Get-Partition | Select-Object PartitionNumber, DriveLetter

# Display the partitions in a formatted table with only PartitionNumber and DriveLetter
$Partitions | Format-Table -AutoSize

# Prompt the user to select a partition
Write-Host "Please enter the partition number you want to select:"
$SelectedNumber = Read-Host

# Find the selected partition based on the input number
$SelectedPartition = $Partitions | Where-Object { $_.PartitionNumber -eq $SelectedNumber }

if ($SelectedPartition) {
    # Store the selected drive letter in a variable
    $DriveLetter = $SelectedPartition.DriveLetter
    Write-Host "You selected the following drive letter: $selectedDriveLetter"
} else {
    Write-Host "No partition found with the specified number."
}

# Choose Distribution 
$Choices = @("Arch", "Ubuntu", "Debian", "EndavourOS")

# Display the Choices to the user
Write-Host "Please choose from the following options:"
for ($i = 0; $i -lt $Choices.Length; $i++) {
    Write-Host "$($i + 1). $($Choices[$i])"
}

# Prompt the user for their selection
$Selection = Read-Host "Enter the number of your choice"

# Validate the input and convert it to the corresponding option
if ($Selection -match '^\d+$' -and $Selection -gt 0 -and $Selection -le $Choices.Length) {
    $ChosenOption = $Choices[$Selection - 1]
    Write-Host "You selected: $ChosenOption"
    $Distro = $ChosenOption
} else {
    Write-Host "Invalid selection. Please enter a number between 1 and $($Choices.Length)."
}

# Function to download the latest Arch Linux ISO
function Download-LinuxISO {
if ( $Distro -eq 'Arch' )
{
	$IsoUrl = "https://packages.oth-regensburg.de/archlinux/iso/latest/archlinux-x86_64.iso"
}
if ( $Distro -eq 'Ubuntu' )
{
	$IsoUrl = "https://ftp.halifax.rwth-aachen.de/ubuntu-releases/noble/ubuntu-24.04-desktop-amd64.iso"
}
if ( $Distro -eq 'Debian' )
{
	$IsoUrl = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso"
}
if ( $Distro -eq 'EndavourOS' )
{
	$IsoUrl = "https://mirror.alpix.eu/endeavouros/iso/EndeavourOS_Gemini-2024.04.20.iso"
}

    Write-Output "Downloading the latest $Distro Linux ISO from $IsoUrl..."
    $wc = New-Object net.webclient
    $wc.Downloadfile($IsoUrl, $DownloadPath)
    Write-Output "Downloaded $Distro ISO to $DownloadPath"
}

# Function to prepare the USB drive
function Prepare-USBDrive {
    Write-Output "Preparing USB drive $DriveLetter..."
    $DiskPartScript = @"
select volume $DriveLetter
clean
create partition primary
active
format fs=fat32 quick
assign letter=$DriveLetter
exit
"@
    $DiskPartScript | Out-File -FilePath "$env:USERPROFILE\Downloads\diskpart_script.txt" -Encoding ASCII
    Start-Process -FilePath "diskpart.exe" -ArgumentList "/s `"$env:USERPROFILE\Downloads\diskpart_script.txt`"" -Wait -NoNewWindow
    Write-Output "USB drive $DriveLetter prepared successfully."
}

# Function to extract ISO to USB drive
function ExtractISOToUSB {
    param (
        [string]$IsoPath,
        [string]$DriveLetter
    )
    Write-Output "Extracting ISO to USB drive $DriveLetter..."
    $SevenZipPath = "C:\Program Files\7-Zip\7z.exe"
    if (-Not (Test-Path $SevenZipPath)) {
        Write-Error "7-Zip is not installed. Please install 7-Zip and try again."
        exit
    }
    & Invoke-Expression -Command ('. "{0}" x {1} -o{2}:\' -f "$SevenZipPath", $DownloadPath, $Driveletter)
    Write-Output "ISO extracted to USB drive $DriveLetter successfully."
}

# Main script execution
Download-LinuxISO
Prepare-USBDrive -driveLetter $DriveLetter
ExtractISOToUSB -isoPath $DownloadPath -driveLetter $DriveLetter

Write-Output "Bootable $Distro Linux USB drive created successfully."

#Cleanup Files
Remove-Item $env:USERPROFILE\Downloads\diskpart_script.txt
Remove-Item $env:USERPROFILE\Downloads\notwindows.iso
