# Self-Elevate
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {

	$CommandLine = "-File """ + $MyInvocation.MyCommand.Path + """ " + $MyInvocation.UnboundArguments
	Start-Process -FilePath ConHost -Verb Runas -ArgumentList PowerShell, $CommandLine
	exit

}

# Activate Windows
Write-Host "Activating Windows..." -ForegroundColor Green
Start-Process "C:\Windows\System32\cmd.exe" -ArgumentList "/c C:\Drivers\Ativador.cmd" -Wait
