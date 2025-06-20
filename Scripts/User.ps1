# Initialize
. "C:\Startup\Scripts\Initialize.ps1"
. "C:\Startup\Scripts\Functions.ps1"

# StartAllBack
Invoke-Script -Name "StartAllBack" -Folder "User" -RegHive "HKCU" -Version 1 {

    If (Test-Path "C:\Program Files\StartAllBack") {

        $Keys = @{
            'AutoUpdates'        = 0
            'BottomDetails'      = 0
            'Disabled'           = 0
            'FrameStyle'         = 0
            'LegacyTaskbar'      = 0
            'NavBarGlass'        = 0
            'NoXAMLMenus'        = 0
            'RestyleControls'    = 1
            'RestyleIcons'       = 0
            'SysTrayStyle'       = 0
            'UndeadControlPanel' = 0
            'WelcomeShown'       = 3
            'WinkeyFunction'     = 1
        }

        $MainKey = "HKCU:\Software\StartIsBack"
        $SubKey = "HKCU:\Software\StartIsBack\Recolor"
        New-Item -Path $MainKey -Force -ErrorAction Ignore | Out-Null
        New-Item -Path $SubKey -Force -ErrorAction Ignore | Out-Null
        ForEach ($Key In $Keys.Keys) { New-ItemProperty -Path $MainKey -Name $Key -Value $Keys[$Key] -PropertyType Dword -Force -ErrorAction Ignore | Out-Null }

        $AclSub = Get-Acl $SubKey
        $AclSub.SetAccessRuleProtection($True, $False)
        $RuleSub = New-Object System.Security.AccessControl.RegistryAccessRule("Todos", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $AclSub.AddAccessRule($RuleSub)
        Set-Acl $SubKey $AclSub -ErrorAction Ignore

        $AclMain = Get-Acl $MainKey
        $AclMain.SetAccessRuleProtection($True, $False)
        $RuleMain = New-Object System.Security.AccessControl.RegistryAccessRule("Todos", "ReadKey", "ContainerInherit,ObjectInherit", "None", "Allow")
        $AclMain.AddAccessRule($RuleMain)
        Set-Acl $MainKey $AclMain -ErrorAction Ignore

    }

}

# Known Folders
Invoke-Script -Name "Known Folders" -Folder "User" -RegHive "HKCU" -Version 0 {

    $UserProfile = $Env:UserProfile
    $OneDrives = Get-Item "$($Env:UserProfile)\OneDrive*"

    $KnownFolders = @(
        @{
            Aliases = @("Área de Trabalho", "Desktop")
            Icon    = "%SystemRoot%\system32\imageres.dll,-183"
            Name    = "%SystemRoot%\system32\shell32.dll,-21769"
            Path    = [Environment]::GetFolderPath("Desktop")
        },
        @{
            Aliases = @("Documentos", "Documents")
            Icon    = "%SystemRoot%\system32\imageres.dll,-112"
            Name    = "%SystemRoot%\system32\windows.storage.dll,-21770"
            Path    = [Environment]::GetFolderPath("MyDocuments")
        },
        @{
            Aliases = @("Imagens", "Images", "Pictures")
            Icon    = "%SystemRoot%\system32\imageres.dll,-113"
            Name    = "%SystemRoot%\system32\windows.storage.dll,-21779"
            Path    = [Environment]::GetFolderPath("MyPictures")
        },
        @{
            Aliases = @("Música", "Músicas", "Music", "Musics")
            Icon    = "%SystemRoot%\system32\imageres.dll,-108"
            Name    = "%SystemRoot%\system32\windows.storage.dll,-21790"
            Path    = [Environment]::GetFolderPath("MyMusic")
        },
        @{
            Aliases = @("Vídeo", "Vídeos", "Video", "Videos")
            Icon    = "%SystemRoot%\system32\imageres.dll,-189"
            Name    = "%SystemRoot%\system32\windows.storage.dll,-21791"
            Path    = [Environment]::GetFolderPath("MyVideos")
        },
        @{
            Aliases = @("Downloads", "Download")
            Icon    = "%SystemRoot%\system32\imageres.dll,-184"
            Name    = "%SystemRoot%\system32\shell32.dll,-21798"
            Path    = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name '{374DE290-123F-4565-9164-39C4925E467B}'
        },
        @{
            Aliases = @("Arquivo Morto")
            Icon    = "C:\Windows\System32\imageres.dll,9"
            Name    = $Null
            Path    = $Null
        }
    )

    $HiddenFolders = @(

        ".*",
        "Apps",
        "Approvals*",
        "Anexos", "Attachments",
        "Bloco*Anotações", "Notebooks",
        "Aplicativos", "Applications",
        "Verificações", "Verifications",
        "*Arquivos*Chat*", "*Chat*Files*",
        "Postman", "Whiteboards"
	
    )
    
    ForEach ($Directory In $OneDrives) {
	
        ForEach ($Folder In (Get-ChildItem $Directory -Directory -Force)) {
		
            $Match = $KnownFolders | Where-Object { $_.Aliases -Contains $Folder.Name }
            If ($Match) { Set-FolderIcon -Path $Folder.FullName -Icon $Match.Icon -Name $Match.Name -Force }
		
            If ($HiddenFolders | Where-Object { $Folder.Name -Like $_ }) {
                attrib +h $Folder.FullName
                Continue
            }
		
        }
	
    }

    ForEach ($Directory In $UserProfile) {
	
        ForEach ($Folder In (Get-ChildItem $Directory -Directory -Force)) {
		
            $Match = $KnownFolders | Where-Object { $_.Aliases -Contains $Folder.Name }
            If ($Match) { If ($Folder.FullName -Ne $Match.Path) { attrib +h $Folder.FullName } }
		
            If ($HiddenFolders | Where-Object { $Folder.Name -Like $_ }) {
                attrib +h $Folder.FullName
                Continue
            }
		
        }
	
    }

}

# Appx Fix
Invoke-Script -Name "Appx Fix" -Folder "User" -RegHive "HKCU" -Version 1 {

    Get-AppxPackage | Sort-Object Name | ForEach-Object {
    
        $Manifest = "$($_.InstallLocation)\AppxManifest.xml"
        If (Test-Path $Manifest) { Add-AppxPackage -Register $Manifest -DisableDevelopmentMode -ErrorAction Ignore }

    }
    
}

# Appx Update Fix
Invoke-Script -Name "Appx Update Fix" -Folder "User" -RegHive "HKCU" -Version 2 {

    $Path = "HKCU:\Software\Classes"
    $Identity = New-Object System.Security.Principal.SecurityIdentifier("S-1-15-2-1")
    $AccessRights = [System.Security.AccessControl.RegistryRights]::FullControl
    $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit
    $PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None
    $AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow

    $Acl = Get-Acl -Path $Path
    $Rule = New-Object System.Security.AccessControl.RegistryAccessRule($Identity, $AccessRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
    
    $Acl.SetAccessRule($Rule)
    Set-Acl -Path $RegistryPath -AclObject $Acl

}

# Windows Fix
Invoke-Script -Name "Windows Fix" -Folder "User" -RegHive "HKCU" -Version 0 {
    
    # Appx Packages
    Get-AppxPackage *PlusPlus* | Remove-AppxPackage
    Get-AppxPackage *WinRAR* | Remove-AppxPackage

    # OneDrive Namespace
    $Preserve = '{018D5C66-4533-4307-9B53-224DE2ED1FE6}'
    Get-ChildItem "HKCU:\Software\Classes\CLSID" | Where-Object { $_.PSChildName -Ne $Preserve -And (Get-ItemProperty -Path $_.PsPath -Name '(default)' -ErrorAction Ignore).'(default)' -Eq 'OneDrive' } | Remove-Item -Recurse -Force
    Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace" | Where-Object { $_.PSChildName -Ne $Preserve -And (Get-ItemProperty -Path $_.PsPath -Name '(default)' -ErrorAction Ignore).'(default)' -Eq 'OneDrive' } | Remove-Item -Recurse -Force
    
    # StartAllBack
    Get-Item "$($Env:LocalAppData)\Microsoft\Windows\WinX\Group1\0 - Properties.lnk" -ErrorAction Ignore | Remove-Item -Recurse -Force
    Remove-ItemProperty -Path "HKCU:\Software\StartIsBack\Recolor" -Name * -ErrorAction SilentlyContinue

}

# OneDrive Icons
Invoke-Script -Name "OneDrive Icons" -Folder "User" -RegHive "HKCU" -Version 1 {

    If ($Env:UserName -Ne "Administrador") {

        Remove-Item "$($Env:UserProfile)\*\* - *\Desktop.ini" -Force -ErrorAction Ignore
        
    }

}

# OneDrive Sync
Invoke-Script -Name "OneDrive Sync" -Folder "User" -RegHive "HKCU" -Version 0 {

    If ($Env:UserName -Ne "Administrador") {

        $File = "C:\Startup\OneDrive\OneDriveSync.ps1"
        If (Test-Path $File) { PowerShell $File }

    }

}
