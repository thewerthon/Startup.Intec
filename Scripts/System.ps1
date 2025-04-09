# Initialize
#Requires -RunAsAdministrator
. "C:\Startup\Scripts\Initialize.ps1"
. "C:\Startup\Scripts\Functions.ps1"

# Anydesk Config
Invoke-Script -Name "Anydesk Config" -Folder "System" -RegHive "HKLM" -Version 1 {

    Get-Process AnyDeskMSI -ErrorAction Ignore | Stop-Process -Force
    Remove-Item "C:\ProgramData\AnyDesk\ad_msi" -Recurse -Force | Out-Null
    New-Item "C:\ProgramData\AnyDesk\ad_msi" -ItemType Directory -Force | Out-Null
    Set-Content "ad.security.interactive_access=0" -Path "C:\ProgramData\AnyDesk\ad_msi\system.conf"
	
    cmd.exe /c '"C:\Program Files (x86)\AnyDeskMSI\AnyDeskMSI.exe" --start-service'; Start-Sleep 3
    cmd.exe /c 'echo anydesk@intec | "C:\Program Files (x86)\AnyDeskMSI\AnyDeskMSI.exe" --set-password'

}

# Hide Folders
Invoke-Script -Name "Hide Folders" -Folder "System" -RegHive "HKLM" -Version 0 {

    $Directories = @("C:\`$WINDOWS.~BT", "C:\`$WINDOWS.~LS", "C:\`$WinREAgent", "C:\Startup", "C:\Autodesk", "C:\Drivers", "C:\Intel", "C:\Recovery", "C:\Log Files", "C:\PerfLogs", "C:\OneDriveTemp")
    ForEach ($Directory In $Directories) { If (Test-Path $Directory) { (Get-Item $Directory -ErrorAction Ignore) | ForEach-Object { $_.Attributes = "System, Hidden, Directory" } } }
	
}

# Clean Disk
Invoke-Script -Name "Clean Disk" -Folder "System" -RegHive "HKLM" -Version 0 {

    $Paths = @("C:\DumpStack.log*")
    ForEach ($Path In $Paths) { If (Test-Path $Path) { Remove-Item $Path -Recurse -Force -ErrorAction Ignore } }
	
}