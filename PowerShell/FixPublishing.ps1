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
	[string]$iMISAppPool,
    [Parameter()]
    [string]$InstancePath,
	[Parameter()]
	[string]$nettmpPath,
    [switch]
    $SkipClearLucene,
    [switch]
    $ClearTaskQueues,
    [switch]
    $SkipRecreatePublishing,
    [switch]
    $SkipStartScheduler
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

function Stop-Scheduler ($AsiSchedulerAppPool) {
    if((Get-WebAppPoolState -Name $AsiSchedulerAppPool).Value -ne "Stopped"){
        Stop-AppPool $AsiSchedulerAppPool 120
    }
	
	if((Get-WebAppPoolState -Name $iMISAppPool).Value -ne "Stopped"){
		Stop-AppPool $iMISAppPool 120
    }
}

function Start-Scheduler ($AsiSchedulerAppPool) {
    if((Get-WebAppPoolState -Name $AsiSchedulerAppPool).Value -ne "Started"){
        Write-Output ("Starting Application Pool: {0}" -f $AsiSchedulerAppPool)
        Start-WebAppPool -Name $AsiSchedulerAppPool
    }
	
	if((Get-WebAppPoolState -Name $iMISAppPool).Value -ne "Started"){
        Write-Output ("Starting Application Pool: {0}" -f $iMISAppPool)
		Start-WebAppPool -Name $iMISAppPool
    }
}

function Clear-Lucene ($InstancePath) {
    Write-Output ("Clearing content of lucene folder")
    $LucenePath = Join-Path -path $InstancePath -childpath "indexServiceProtected\Search\Lucene"
    Get-ChildItem -Path $LucenePath -Include *.* -File -Recurse | ForEach-Object { $_.Delete()}
	Get-ChildItem -Path $nettmpPath -Include *.* -File -Recurse | ForEach-Object { $_.Delete()}
}

function Clear-Task-Queues ($ServerInstance, $Database, $Username, $Password) {
    Write-Output ("Clearing task queues")
    Invoke-Sqlcmd -Query "DELETE FROM TaskQueuePublishDetail" -ServerInstance $ServerInstance -Database $Database -Username $Username -Password $Password
    Invoke-Sqlcmd -Query "DELETE FROM TaskQueue WHERE TaskQueueTypeId = 1 and TaskQueueId NOT IN (SELECT TaskQueueId FROM TaskQueuePublishDetail)" -ServerInstance $ServerInstance -Database $Database -Username $Username -Password $Password
    Invoke-Sqlcmd -Query "DELETE FROM TaskQueueTriggerDetail" -ServerInstance $ServerInstance -Database $Database -Username $Username -Password $Password   
    Invoke-Sqlcmd -Query "DELETE FROM PublishMessageLog" -ServerInstance $ServerInstance -Database $Database -Username $Username -Password $Password
    Invoke-Sqlcmd -Query "DELETE FROM PublishRequestDetail" -ServerInstance $ServerInstance -Database $Database -Username $Username -Password $Password
}

function Reset-Publishing-Service ($ServerInstance, $Database, $Username, $Password) {
    Write-Output ("Recreating publishing queue and service broker")
    Invoke-Sqlcmd -Query "DECLARE @name VARCHAR(MAX) DECLARE db_cursor CURSOR FOR SELECT name FROM sys.service_queues WHERE is_ms_shipped != 1 OPEN db_cursor FETCH NEXT FROM db_cursor INTO @name WHILE @@FETCH_STATUS = 0 BEGIN PRINT CONCAT('Dropping Service Broker Service & Queue: ', @name) DECLARE @cmd VARCHAR(1000) = CONCAT('DROP SERVICE [', IIF(@name = 'iMISPublishQueue', 'iMISPublishService', @name), ']', ' DROP QUEUE [', @name, ']') EXEC (@cmd) FETCH NEXT FROM db_cursor INTO @name END CLOSE db_cursor DEALLOCATE db_cursor" -ServerInstance $ServerInstance -Database $Database -Username $Username -Password $Password
    Invoke-Sqlcmd -Query "EXEC asi_EnsurePublishQueueAndServiceBroker" -ServerInstance $ServerInstance -Database $Database -Username $Username -Password $Password
    Invoke-Sqlcmd -Query "IF NOT EXISTS (SELECT * FROM sys.services WHERE name = N'iMISPublishService') BEGIN CREATE SERVICE iMISPublishService ON QUEUE iMISPublishQueue ([http://schemas.microsoft.com/SQL/Notifications/PostQueryNotification]); END" -ServerInstance $ServerInstance -Database $Database -Username $Username -Password $Password
}

# Stop AsiScheduler app pool
Stop-Scheduler $AsiSchedulerAppPool

# Clear lucene index files
if ($PSBoundParameters.ContainsKey("SkipClearLucene")) {
    Write-Output ("Skiping Clearing Lucene Folder")
} else {
    Clear-Lucene $InstancePath
}

# Clear Task Queues etc..
if($PSBoundParameters.ContainsKey("ClearTaskQueues")) {
    Clear-Task-Queues $ServerInstance $Database $Username $Password
}

# Recreate publishing queue and service broker
if($PSBoundParameters.ContainsKey("SkipRecreatePublishing")) {
    Write-Output ("Skiping Recreate publishing queue and service broker")
} else {
    Reset-Publishing-Service $ServerInstance $Database $Username $Password
}

# Start AsiScheduler app pool
if($PSBoundParameters.ContainsKey("SkipStartScheduler")) {
    Write-Output ("Skiping StartScheduler")
} else {
    Start-Scheduler $AsiSchedulerAppPool
}







