# CMBuild
CMBuild and CMSiteConfig PowerShell Module

# Functions

## Copy-CMBuildTemplate

  * Purpose: Copies source templates for custom use. 

### Parameter: -Source1
  * String / Optional
  * Path/Name for cmbuild source XML template
  * Default: GitHub location: 
  * Example: -Source1 "\\server\share\templates\cmbuild.xml"

### Parameter: -Source2
  * String / Optional
  * Path/Name for cmsiteconfig source XML template
  * Default: GitHub location: 
  * Example: -Source2 "\\server\share\templates\cmsiteconfig.xml"

### Parameter: -Type
  * String / Required (list) 
  * Options: "cmbuild", "cmsiteconfig", "both"
  * Default: "both"
  * Example: -Type both

### Parameter: -OutputFolder
  * String / Optional
  * Path/Name for saving the destination XML files
  * Default: current working directory
  * Example: -OutputFolder "c:\users\sccmadmin\documents"

## Invoke-CMBuild

  * Purpose: Runs process to build Windows Server features, install prerequisites and all products up to ConfigMgr.

### Parameter: -XmlFile 

  * String / Required
  * Path/Name for runtime XML template
  * Local, HTTP, Drive-Letter or UNC path

### Parameter: -NoCheck 

  * Switch / Optional
  * Skips checking system minimum requirements (intended for lab setups)

### Parameter: -NoReboot

  * Switch / Optional
  * Suppresses reboots when indicated by a given step in the process
  * If not specified, a pending reboot forces an actual reboot, which triggers a 
    resume task upon restart to continue the process.

### Parameter: -Detailed 

  * Switch / Optional
  * Displays additional verbose output

### Parameter: (other)

  * Supports -WhatIf and -Verbose
  
## Invoke-CMSiteConfig

  * Purpose: 
  
### Parameter: XmlFile

  * String / Required
  * Path/Name for runtime XML template
  * Local, HTTP, Drive-Letter or UNC path
