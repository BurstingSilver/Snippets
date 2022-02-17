param (
    [Parameter()]
    [string]$ServerInstance,
    [Parameter()]
    [string]$Database,
    [Parameter()]
    [string]$Username,
    [Parameter()]
    [string]$Password,
    [Parameter()]
    [string]$AsiSchedulerAppPool,
    [Parameter()]
    [string]$InstancePath
)

function Stop-AppPool ($webAppPoolName,[int]$secs) {
    $retvalue = $false
    $wsec = (get-date).AddSeconds($secs)

    Stop-WebAppPool -Name $webAppPoolName
    Write-Output "$(Get-Date) waiting up to $secs seconds for the IIS AppPool '$webAppPoolName' to stop"

    $poolNotStopped = $true

    while (((get-date) -lt $wsec) -and $poolNotStopped) {
        $pstate =  Get-WebAppPoolState -Name $webAppPoolName
        if ($pstate.Value -eq "Stopped") {
            Write-Output "$(Get-Date): IIS AppPool '$webAppPoolName' is stopped"
            $poolNotStopped = $false
            $retvalue = $true
        }
    }

    return $retvalue
}

# Stop AsiScheduler app pool
if((Get-WebAppPoolState -Name $AsiSchedulerAppPool).Value -ne "Stopped"){
    Stop-AppPool $AsiSchedulerAppPool 120
}

# Clear lucene index files
Write-Output ("Clearing content of lucene folder")
$LucenePath = Join-Path -path $InstancePath -childpath "indexServiceProtected\Search\Lucene"
Get-ChildItem -Path $LucenePath -Include *.* -File -Recurse | foreach { $_.Delete()}

# Recreate publishing queue and service broker
Write-Output ("Recreating publishing queue and service broker")
Invoke-Sqlcmd -Query "IF EXISTS(SELECT * FROM sys.services WHERE name = N'iMISPublishService') DROP SERVICE iMISPublishService; IF EXISTS (SELECT * FROM sys.service_queues WHERE name = N'iMISPublishQueue') DROP QUEUE iMISPublishQueue;" -ServerInstance $ServerInstance -Database $Database -Username $Username -Password $Password
Invoke-Sqlcmd -Query "CREATE QUEUE iMISPublishQueue; CREATE SERVICE iMISPublishService ON QUEUE iMISPublishQueue([http://schemas.microsoft.com/SQL/Notifications/PostQueryNotification]);" -ServerInstance $ServerInstance -Database $Database -Username $Username -Password $Password

# Start AsiScheduler app pool
if((Get-WebAppPoolState -Name $AsiSchedulerAppPool).Value -ne "Started"){
    Write-Output ("Starting Application Pool: {0}" -f $AsiSchedulerAppPool)
    Start-WebAppPool -Name $AsiSchedulerAppPool
}






