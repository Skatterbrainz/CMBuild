function Convert-CmxString {
	param(
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()] $DataSet,
		[parameter(Mandatory=$False)]
			[string] $StringVal = ""
	)
	$fullname  = $DataSet.configuration.project.hostname
	$shortname = $DataSet.configuration.project.host
	$sitecode  = $DataSet.configuration.project.sitecode
	if ($StringVal -ne "") {
		Write-Output $((($StringVal -replace '@HOST@', "$shortname") -replace '@HOSTNAME@', "$fullname") -replace '@SITECODE@', $sitecode)
	}
	else {
		Write-Output ""
	}
}
