function getCmxWsusUpdatesPath {
	param ($FolderSet)
	$fpath = $FolderSet | Where-Object {$_.comment -like 'WSUS*'} | Select-Object -ExpandProperty Name
	if (-not($fpath) -or ($fpath -eq "")) {
		Write-Warning "error: missing WSUS updates storage path setting in XML file. Refer to FOLDERS section."
		break
	}
	Write-Output $fpath
}