#Usage .\install-imis20.ps1 -DeveloperApps 'True' -SQLServer 'True' -Reinstall 'True'

<#*****************************************************************************************
Parameters
*****************************************************************************************#>
param([string]$DeveloperApps,[string]$SQLServer)

<#*****************************************************************************************
Developer Tools
*****************************************************************************************#>
function InstallDeveloperTools
{
	#Install VS 2019 Pro
	choco install visualstudio2019professional
	
	#Install Royal TS
	choco install royalts
	
	#Install Office 365
	choco install office365business
	
	#Install Slack
	choco install slack
	
	#Install WinRar
	choco install winrar
	
	#Install dbgview
	choco install dbgview
	
	#Install Green shot
	choco install greenshot
	
	#Install Autohotkey
	choco install autohotkey.portable
	
	#Install Paint.NET
	choco install paint.net
	
	#Install Google Drive File Stream
	choco install google-drive-file-stream
}

function InstallSQLServerExpress
{
	#Install SQL Server Express
	choco install sql-server-express
}

<#*****************************************************************************************
Disable IE Enhanced Security Configuration
*****************************************************************************************#>
function Disable-IEESC
{
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    Stop-Process -Name Explorer
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}

<#*****************************************************************************************
Main Program Start
*****************************************************************************************#>
set-executionpolicy remotesigned

if ($Reinstall -ne "True")
{
  # windows explorer settings show file extensions
	reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
}

#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Set Chocolatey Safe Switch
chocolatey feature enable -n allowGlobalConfirmation

#Disable IE Enhanced Security Policy
Disable-IEESC

<#*****************************************************************************************
iMIS Pre-Req Install 
*****************************************************************************************#>
# install IIS
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName WCF-NonHTTP-Activation -All

# install .NET 4.5
cinst dotnet4.5 -y

# install powershell ISE
Import-Module ServerManager 
Add-WindowsFeature PowerShell-ISE

#Install Application-initialization
$webAppInit = Get-WindowsFeature -Name "Web-AppInit"
Install-WindowsFeature $webAppInit -ErrorAction Stop

#Install Web Deploy
choco install webdeploy

#Install IIS Rewrite Module
choco install urlrewrite

#Install Nartac SSL
choco install iiscrypto-cli

#Apply nartac best practice SSL TLS Settings
iiscryptocli.exe /template default
<#*****************************************************************************************
Applications
*****************************************************************************************#>
# install java
choco install jre8

#Install Notepad++
choco install notepadplusplus.install

#Install Chrome
choco install googlechrome

#Install SSMS
choco install sql-server-management-studio

#Install SSRS/Bids
choco install ssdtbi.vs2012

#Install Microsoft Access DB Drivers 2010
choco install made2010

if ($DeveloperApps -eq "True") { InstallDeveloperTools }
if ($SQLServer -eq "True") { InstallSQLServerExpress }

	
