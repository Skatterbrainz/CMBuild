# CMBuild
CMBuild and CMSiteConfig PowerShell Module

# Functions

## Copy-CMBuildTemplate

* Purpose: Copies source templates for custom use. 

### Parameter: -Source1
  * String / Optional
  * Path/Name for cmbuild source XML template
  * Default: GitHub location: 
  
## Invoke-CMBuild

### Parameter: -XmlFile 

  * String / Required
  * Path/Name for runtime XML template
  * Local, HTTP, Drive-Letter or UNC path

### Parameter: -NoCheck 

  * Switch / Optional

### Parameter: -NoReboot

  * Switch / Optional

### Parameter: -Detailed 

  * Switch / Optional

## Invoke-CMSiteConfig

### Parameter: XmlFile

  * String / Required
