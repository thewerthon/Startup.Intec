# Initialize
. "C:\Startup\Scripts\Initialize.ps1"
. "C:\Startup\Scripts\Functions.ps1"

# OneDrive Sync
Invoke-Script -Name "OneDrive Sync" -Folder "User" -RegHive "HKCU" -Version 0 {

    If ($Env:UserName -Ne "Administrador") {

        $File = "C:\Startup\OneDrive\OneDriveSync.ps1"
        If (Test-Path $File) { PowerShell $File }

    }

}
