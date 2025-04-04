# Initialize
#Requires -RunAsAdministrator
. "C:\Startup\Scripts\Initialize.ps1"
. "C:\Startup\Scripts\Functions.ps1"

# Startup
Invoke-Script -Name "Startup" -Folder "Update" -RegHive "HKLM" -Version 1 {

    Get-RepositoryFile -Path "Commands\Startup.ps1"
    Copy-Item -Path "C:\Startup\Commands\Startup.ps1" -Destination "C:\Windows\Startup.ps1" -Force -ErrorAction Ignore
    
    Remove-Item "C:\Startup\Startup.ps1" -Force -ErrorAction Ignore
    Remove-Item "C:\Startup\Commands\Startup.ps1" -Force -ErrorAction Ignore
    
}

# AccentColorizer
Invoke-Script -Name "AccentColorizer" -Folder "Update" -RegHive "HKLM" -Version 1 {

    Get-RepositoryFile -Path "Tasks\Accent.xml"
    Get-RepositoryFile -Path "Tasks\Glyphs.xml"

    Get-RepositoryFile -Path "Setup\AccentColorizer.exe"
    Get-RepositoryFile -Path "Setup\AccentColorizer-E11.exe"

    Stop-ScheduledTask -TaskName "Accent" -TaskPath "Startup" -ErrorAction Ignore
    Stop-ScheduledTask -TaskName "Glyphs" -TaskPath "Startup" -ErrorAction Ignore

    Get-Process "AccentColorizer*" -ErrorAction Ignore | Stop-Process -Force -ErrorAction Ignore
    Start-Sleep -Seconds 3
    
    Copy-Item -Path "C:\Startup\Setup\AccentColorizer.exe" -Destination "C:\Windows\AccentColorizer.exe" -Force -ErrorAction Ignore
    Copy-Item -Path "C:\Startup\Setup\AccentColorizer-E11.exe" -Destination "C:\Windows\AccentColorizer-E11.exe" -Force -ErrorAction Ignore

    Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AccentColorizer" -Force -ErrorAction Ignore | Out-Null
    Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AccentColorizer-E11" -Force -ErrorAction Ignore | Out-Null

    If (Test-Path "C:\Startup\Tasks\Accent.xml") { Get-ScheduledTask -TaskName "Accent" -TaskPath "*Startup*" -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$False }
    If (Test-Path "C:\Startup\Tasks\Glyphs.xml") { Get-ScheduledTask -TaskName "Glyphs" -TaskPath "*Startup*" -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$False }
	
    If (Test-Path "C:\Startup\Tasks\Accent.xml") { Register-ScheduledTask -TaskName "Accent" -TaskPath "Startup" -Xml (Get-Content "C:\Startup\Tasks\Accent.xml" | Out-String) -Force | Out-Null }
    If (Test-Path "C:\Startup\Tasks\Glyphs.xml") { Register-ScheduledTask -TaskName "Glyphs" -TaskPath "Startup" -Xml (Get-Content "C:\Startup\Tasks\Glyphs.xml" | Out-String) -Force | Out-Null }
	
    Start-ScheduledTask -TaskName "Accent" -TaskPath "Startup" -ErrorAction Ignore
    Start-ScheduledTask -TaskName "Glyphs" -TaskPath "Startup" -ErrorAction Ignore

}

# Clean Up
Remove-Item "C:\Startup\Tasks" -Recurse -Force -ErrorAction Ignore
Remove-Item "C:\Startup\Setup" -Recurse -Force -ErrorAction Ignore
