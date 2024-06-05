# NotWindowsMediaCreationTool

The laziest way to get rid of spyware :)

Always use at your own risk!

# Steps to Execute:

Save the Script: Save the script with the filename freedom.ps1.	

Run PowerShell as Administrator: Right-click on the PowerShell icon and select "Run as administrator".	

Navigate to the Script Location: Use the cd command in PowerShell to navigate to the directory where you saved the script.	

Set ExecutionPolicy in Powershell (Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process).

Execute the Script: Run the script by typing .\freedom.ps1 and pressing Enter.	
	
# Notes:	
	
Make sure to replace your DriveLetter with the correct letter of your USB drive. (watch out for line 51 and 56)

This script assumes 7-Zip is installed at the default path. If 7-Zip is installed in a different location, update the $sevenZipPath variable accordingly.	

Ensure no important data is on the USB drive as it will be formatted during this process.
