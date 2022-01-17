# This script can be used to version sql scripts in a given folder, it will append version numbers to scripts ex. v1_0_01_Example.sql

$folderToPrepare=$args[0]
$majorVersion=1
$minorVersion=0
$incrementalVersion=0

New-Item -ItemType Directory -Force -Path (-join($folderToPrepare, "\Output"))

Get-ChildItem $folderToPrepare -Filter *.sql |  #create list of files

ForEach-Object{
    $oldname = $_.FullName
	
	if($incrementalVersion -eq 99) {
		$incrementalVersion=0
		
		if($minorVersion -eq 9) {
			$minorVersion=0
			$majorVersion++
		} else {
			$minorVersion++
		}
	} else {
		$incrementalVersion++
	}
	
	# Handle leading zeros in incremental version
	if ($incrementalVersion -lt 10) {
		$incrementalVersionDisplay= (-join("0", $incrementalVersion))
	} else {
		$incrementalVersionDisplay= $incrementalVersion
	}
		
    $newname = (-join("v", $majorVersion, "_", $minorVersion, "_", $incrementalVersionDisplay, "_", $_.Name.Remove(0,4)))
	Write-Output (-join("Old Name: ", $oldname)) 
	Write-Output (-join("New Name: ", $newname)) 
		
    Copy-Item $oldname -Force -Destination (-join($_.Directory, "\Output\", $newname))
}