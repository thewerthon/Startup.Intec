# Preferences
$VerbosePreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"

# Self-Elevate
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {

	$ConsoleHost = if (Get-Command WT -ErrorAction SilentlyContinue) { "WT" } else { "ConHost" }
	$CommandLine = "-File """ + $MyInvocation.MyCommand.Path + """ " + $MyInvocation.UnboundArguments
	Start-Process -FilePath $ConsoleHost -Verb Runas -ArgumentList PowerShell, $CommandLine
	exit

}

# Execution Policy
Set-ExecutionPolicy -ExecutionPolicy "Unrestricted" -Scope "LocalMachine" -Force -ErrorAction Ignore | Out-Null
Set-ExecutionPolicy -ExecutionPolicy "Unrestricted" -Scope "CurrentUser" -Force -ErrorAction Ignore | Out-Null

# Create Paths
New-Item -Path "HKLM:\Software\Startup" -ErrorAction Ignore | Out-Null
New-Item -ItemType Directory -Path "C:\Startup" -ErrorAction Ignore | Out-Null
Get-Item "C:\Startup" -ErrorAction Ignore | ForEach-Object { $_.Attributes = "Directory,System,Hidden" }

# Export Args
[String]$Args | Out-File "C:\Startup\Args.txt" -Force

# Check Args
$KeepFlag = [String]$Args -match "[-/]k"
$UpdateFlag = $Args -contains "Update"
$InstallFlag = $Args -contains "Install"
$RunUpdater = $Args -contains "Updater"
$RunSystem = $Args -contains "System"
$RunUser = $Args -contains "User"
$RunAll = -not ($RunUpdater -or $RunSystem -or $RunUser)

# Update Scripts
if ($UpdateFlag -or $InstallFlag) {

	# Message
	if ($InstallFlag) { Write-Host "Installing scripts..." -ForegroundColor Gray } else { Write-Host "Updating scripts..." -ForegroundColor Gray }

	# Get Latest Release
	$ApiUrl = "https://api.github.com/repos/thewerthon/Startup.Intec/releases/latest"
	$Release = Invoke-RestMethod -Uri $ApiUrl
	$FileUrl = $Release.assets.browser_download_url

	# Check if exists
	if ($FileUrl) {

		# Download and Extract
		Invoke-WebRequest -Uri $FileUrl -OutFile "C:\Startup\Startup.zip"
		Expand-Archive -Path "C:\Startup\Startup.zip" -DestinationPath "C:\Startup" -Force

		# Register
		New-ItemProperty -Path "HKLM:\Software\Startup" -Name "Updated" -Value (Get-Date).ToString("s") -PropertyType "String" -Force | Out-Null

	}

}

# Install Scripts
if ($InstallFlag) {

	foreach ($Task in @("Accent", "Glyphs", "Updater", "System", "User")) {

		# Install Tasks
		if (Test-Path "C:\Startup\Tasks\$Task.xml") {

			Stop-ScheduledTask -TaskName $Task -TaskPath "Startup" -ErrorAction Ignore
			Get-ScheduledTask -TaskName $Task -TaskPath "*Startup*" -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$False
			Register-ScheduledTask -TaskName $Task -TaskPath "Startup" -Xml (Get-Content "C:\Startup\Tasks\$Task.xml" | Out-String) -Force | Out-Null
			New-ItemProperty -Path "HKLM:\Software\Startup" -Name "Installed" -Value (Get-Date).ToString("s") -PropertyType "String" -Force | Out-Null

		}

	}

}

# Run Updater Script
if ($RunUpdater -or $RunAll) {

	Write-Host "Invoking updater script..." -ForegroundColor Gray
	if (Test-Path "C:\Startup\Scripts\Updater.ps1") { . "C:\Startup\Scripts\Updater.ps1" } else { Write-Host "Updater script was not found!" -ForegroundColor Gray }

}

# Run System Script
if ($RunSystem -or $RunAll) {

	Write-Host "Invoking system script..." -ForegroundColor Gray
	if (Test-Path "C:\Startup\Scripts\System.ps1") { . "C:\Startup\Scripts\System.ps1" } else { Write-Host "System script was not found!" -ForegroundColor Gray }

}

# Run User Script
if ($RunUser -or $RunAll) {

	Write-Host "Invoking user script in another window..." -ForegroundColor Gray
	if ($KeepFlag) { $UserScript = "C:\Startup\Helpers\UserKeep.vbs" } else { $UserScript = "C:\Startup\Helpers\UserView.vbs" }
	if ((Test-Path $UserScript) -and (Test-Path "C:\Startup\Scripts\User.ps1")) { Start-Process Explorer $UserScript } else { Write-Host "User script was not found!" -ForegroundColor Gray }

}

# Clean Up
Remove-Item "C:\Startup\Args.txt" -Force -ErrorAction Ignore
Remove-Item "C:\Startup\Startup.zip" -Force -ErrorAction Ignore
Remove-Item "C:\Startup\README.md" -Force -ErrorAction Ignore
Remove-Item "C:\Startup\Setup" -Recurse -Force -ErrorAction Ignore

# Terminate
if ($KeepFlag) { Read-Host "Press [Enter] to exit" } else { exit }
