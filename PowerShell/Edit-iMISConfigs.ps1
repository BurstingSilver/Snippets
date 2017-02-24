$notepadPlusPlusPath = "C:\Program Files (x86)\Notepad++\notepad++.exe"
$serverList = @(
	"machine1"
	,"machine2"
)

foreach ($server in $serverList) {
	$netWebConfig = '\\' + $server + '\C$\Program Files (x86)\ASI\web\Net\web.config'
	iex "& `"$notepadPlusPlusPath`" `"$netWebConfig`""
	$schedulerWebConfig = '\\' + $server + '\C$\AsiPlatform\Asi.Scheduler_WEB\web.config'
	iex "& `"$notepadPlusPlusPath`" `"$schedulerWebConfig`""
}