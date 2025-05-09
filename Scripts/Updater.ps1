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
Invoke-Script -Name "AccentColorizer" -Folder "Update" -RegHive "HKLM" -Version 3 {

    Get-RepositoryFile -Path "Setup\Accent.exe"
    Get-RepositoryFile -Path "Tasks\Accent.xml"
    
    If (Test-Path "C:\Startup\Setup\Accent.exe") {

        Get-Process "Accent" -ErrorAction Ignore | Stop-Process -Force -ErrorAction Ignore; Start-Sleep -Seconds 3
        Copy-Item -Path "C:\Startup\Setup\Accent.exe" -Destination "C:\Windows\Accent.exe" -Force -ErrorAction Ignore
    
    }

    If (Test-Path "C:\Startup\Tasks\Accent.xml") {

        Stop-ScheduledTask -TaskName "Accent" -TaskPath "Startup" -ErrorAction Ignore
        Get-ScheduledTask -TaskName "Accent" -TaskPath "*Startup*" -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$False
        Register-ScheduledTask -TaskName "Accent" -TaskPath "Startup" -Xml (Get-Content "C:\Startup\Tasks\Accent.xml" | Out-String) -Force | Out-Null
        If (Test-Path "C:\Program Files\StartAllBack") { Get-ScheduledTask -TaskName "Accent" -TaskPath "*Startup*" -ErrorAction Ignore | Disable-ScheduledTask | Out-Null } Else { Start-ScheduledTask -TaskName "Accent" -TaskPath "Startup" -ErrorAction Ignore }

    }

    If (Test-Path "C:\Windows\AccentColorizer.exe") {

        Get-Process "AccentColorizer" -ErrorAction Ignore | Stop-Process -Force -ErrorAction Ignore; Start-Sleep -Seconds 3    
        Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AccentColorizer" -Force -ErrorAction Ignore | Out-Null
        Remove-Item "C:\Windows\AccentColorizer.exe" -Force -ErrorAction Ignore

    }
    
}

# GlyphsColorizer
Invoke-Script -Name "GlyphsColorizer" -Folder "Update" -RegHive "HKLM" -Version 3 {

    Get-RepositoryFile -Path "Setup\Glyphs.exe"
    Get-RepositoryFile -Path "Tasks\Glyphs.xml"

    If (Test-Path "C:\Startup\Setup\Glyphs.exe") {

        Get-Process "Glyphs" -ErrorAction Ignore | Stop-Process -Force -ErrorAction Ignore; Start-Sleep -Seconds 3
        Copy-Item -Path "C:\Startup\Setup\Glyphs.exe" -Destination "C:\Windows\Glyphs.exe" -Force -ErrorAction Ignore
    
    }
    
    If (Test-Path "C:\Startup\Tasks\Glyphs.xml") {

        Stop-ScheduledTask -TaskName "Glyphs" -TaskPath "Startup" -ErrorAction Ignore
        Get-ScheduledTask -TaskName "Glyphs" -TaskPath "*Startup*" -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$False
        Register-ScheduledTask -TaskName "Glyphs" -TaskPath "Startup" -Xml (Get-Content "C:\Startup\Tasks\Glyphs.xml" | Out-String) -Force | Out-Null
        Start-ScheduledTask -TaskName "Glyphs" -TaskPath "Startup" -ErrorAction Ignore

    }

    If (Test-Path "C:\Windows\AccentColorizer-E11.exe") {

        Get-Process "AccentColorizer-E11" -ErrorAction Ignore | Stop-Process -Force -ErrorAction Ignore; Start-Sleep -Seconds 3    
        Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AccentColorizer-E11" -Force -ErrorAction Ignore | Out-Null
        Remove-Item "C:\Windows\AccentColorizer-E11.exe" -Force -ErrorAction Ignore

    }
    
}

# Clean Up
Remove-Item "C:\Startup\Setup" -Recurse -Force -ErrorAction Ignore
