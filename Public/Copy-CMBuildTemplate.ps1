<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER
.NOTES
.EXAMPLE
#>

function Copy-CMBuildTemplate {
	param (
		[parameter(Mandatory=$False)]
		[ValidateNotNullOrEmpty()]
		[string] $Source1 = 'https://raw.githubusercontent.com/Skatterbrainz/CM_Build/master/cm_build.xml',
		[parameter(Mandatory=$False)]
		[ValidateNotNullOrEmpty()]
		[string] $Source2 = 'https://raw.githubusercontent.com/Skatterbrainz/CM_Build/master/cm_siteconfig.xml',
		[parameter(Mandatory=$True)]
			[ValidateSet('cmbuild','cmsiteconfig')]
			[string] $Type,
		[parameter(Mandatory=$True)]
			[ValidateNotNullOrEmpty()]
			[string] $NewFile
	)
	switch ($Type) {
		'cmbuild' { $source = $Source1; break }
		'cmsiteconfig' { $source = $Source2; break }
	}
	Write-Verbose "source = $source"
	if ($source.StartsWith('http')) {
		try {
			$input = Invoke-WebRequest -Uri $source -UseBasicParsing -ErrorAction SilentlyContinue
		}
		catch {
			Write-Error $_.Exception.Message
			break
		}
		Write-Verbose "source content imported"
	}
	else {
		try {
			$input = Get-Content -Path $source -ErrorAction SilentlyContinue
		}
		catch {
			Write-Error $_.Exception.Message
			break
		}
		Write-Verbose "source content imported"
	}
	try {
		$input.Content | Out-File $NewFile -NoClobber
		Write-Host "$NewFile created successfully" -ForegroundColor Cyan
	}
	catch {
		Write-Error $_.Exception.Message
	}
}

Export-ModuleMember -Function Copy-CMBuildTemplate
