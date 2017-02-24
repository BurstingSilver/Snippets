Write-Host "Starting deployment"

$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

$serverList = @(
	"machine1"
	,"machine2"
)

#copy assemblies
foreach ($server in $serverList) {
	$binPath = "\\" + $server + "\C$\Program Files (x86)\ASI\iMIS\Net\bin\"
	Get-ChildItem -Path "$PSScriptRoot\bin\*.*" -Include "*.dll" | Copy-Item -Destination $binPath -Force -Confirm:$false
	$controlsPath = "\\" + $server + "\C$\Program Files (x86)\ASI\iMIS\Net\Custom\"
	Get-ChildItem -Path "$PSScriptRoot\Custom\*.*" | Copy-Item -Destination $controlsPath -Force -Confirm:$false
}

Write-Host "Deployment complete"