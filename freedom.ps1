# Define variables
$DownloadPath = "$env:USERPROFILE\Downloads\notwindows.iso"
  
# Retrieve the list of partitions
$Partitions = Get-Partition | Select-Object DriveLetter
# Filter out partitions without a drive letter
$PartitionsWithDriveLetter = $Partitions | Where-Object { $_.DriveLetter -ne $null }
# Add an index column starting from 1
$IndexedPartitions = $PartitionsWithDriveLetter | Select-Object @{Name='Index'; Expression={[array]::IndexOf($PartitionsWithDriveLetter, $_) + 1}}, DriveLetter
# Display the drives in a formatted table with Index and DriveLetter
$IndexedPartitions | Format-Table -AutoSize
# Prompt the user to select a partition by index number
Write-Host "Please enter the index number of the partition you want to select:"
$SelectedIndex = [int](Read-Host)
# Find the selected partition based on the input index number
$SelectedPartition = $IndexedPartitions | Where-Object { $_.Index -eq $SelectedIndex }

if ($SelectedPartition) {
    # Store the selected drive letter in a variable
    $DriveLetter = $SelectedPartition.DriveLetter
    Write-Host "You selected the following drive letter: $DriveLetter"
} else {
    Write-Host "No partition found with the specified index number."
}

# Choose Distribution 
$Choices = @("Arch", "Ubuntu", "Debian", "EndavourOS", "Gentoo", "Kali Linux", "Linux Mint", "Pop!_OS", "Kubuntu", "CentOS", "Parrot Security", "Qubes OS")

# Display the Choices to the user
Write-Host "Please choose from the following options:"
for ($i = 0; $i -lt $Choices.Length; $i++) {
    Write-Host "$($i + 1). $($Choices[$i])"
}

# Prompt the user for their selection
$Selection = Read-Host "Enter the number of your choice"

# Validate the input and convert it to the corresponding option
if ($Selection -match '^[1-9]$|^10$' -and [int]$Selection -le $Choices.Length) {
    # Convert selection to zero-based index
    $Index = [int]$Selection - 1

    # Retrieve the selected option
    $SelectedOption = $Choices[$Index]
	
	#Fill variable
	$Distro = $Choices[$Index]

    # Display the selected option
    Write-Host "You have selected: $SelectedOption"
} else {
    # Handle invalid input
    Write-Host "Invalid selection. Please enter a number between 1 and $($Choices.Length)."
}

# Function to download the latest Linux ISO
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
if ( $Distro -eq 'Gentoo' )
{
	$IsoUrl = "https://distfiles.gentoo.org/releases/amd64/autobuilds/20240526T163557Z/livegui-amd64-20240526T163557Z.iso"
}
if ( $Distro -eq 'Kali Linux' )
{
	$IsoUrl = "https://cdimage.kali.org/kali-2024.2/kali-linux-2024.2-installer-amd64.iso"
}
if ( $Distro -eq 'Linux Mint' )
{
	$IsoUrl = "https://ftp.rz.uni-frankfurt.de/pub/mirrors/linux-mint/iso/stable/21.3/linuxmint-21.3-cinnamon-64bit.iso"
}
if ( $Distro -eq 'Pop!_OS' )
{
	$IsoUrl = "https://iso.pop-os.org/22.04/amd64/nvidia/41/pop-os_22.04_amd64_nvidia_41.iso"
}
if ( $Distro -eq 'Kubuntu' )
{
	$IsoUrl = "https://cdimage.ubuntu.com/kubuntu/releases/24.04/release/kubuntu-24.04-desktop-amd64.iso"
}
if ( $Distro -eq 'CentOS' )
{
	$IsoUrl = "https://mirrors.centos.org/mirrorlist?path=/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-dvd1.iso&redirect=1&protocol=https"
}
if ( $Distro -eq 'Parrot Security' )
{
	$IsoUrl = "https://deb.parrot.sh/parrot/iso/6.1/Parrot-security-6.1_amd64.iso"
}
if ( $Distro -eq 'Qubes OS' )
{
	$IsoUrl = "https://ftp.halifax.rwth-aachen.de/qubes/iso/Qubes-R4.2.1-x86_64.iso"
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
create partition primary size=8192
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

# Cleanup Files
Remove-Item $env:USERPROFILE\Downloads\diskpart_script.txt
Remove-Item $env:USERPROFILE\Downloads\notwindows.iso
