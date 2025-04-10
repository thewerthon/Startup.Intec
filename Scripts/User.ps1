# Initialize
. "C:\Startup\Scripts\Initialize.ps1"
. "C:\Startup\Scripts\Functions.ps1"

# Appx Packages
Invoke-Script -Name "Appx" -Folder "User" -RegHive "HKCU" -Version 0 {

    # Remove Appx
    Get-AppxPackage *PlusPlus* | Remove-AppxPackage
    Get-AppxPackage *WinRAR* | Remove-AppxPackage
    
}

# OneDrive Sync
Invoke-Script -Name "OneDrive Sync" -Folder "User" -RegHive "HKCU" -Version 0 {

    If ($Env:UserName -Ne "Administrador") {

        $File = "C:\Startup\OneDrive\OneDriveSync.ps1"
        If (Test-Path $File) { PowerShell $File }

    }

}
