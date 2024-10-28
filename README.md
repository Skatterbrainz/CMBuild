# CMBuild
CMBuild and CMSiteConfig PowerShell Module

# Functions

## Copy-CMBuildTemplate

  * Purpose: Copies source templates for custom use. 

## Invoke-CMBuild

  * Purpose: Configures Windows Server to install ConfigMgr (SQL, MDT, ADK, etc.)
  
## Invoke-CMSiteConfig

  * Purpose: Configures SCCM site after Invoke-CMBuild

## Updates

- 1.0.8
  - Updated to support MDT 6.3.8456.1000
  - Updated to support SQL Server Management Studio 20.2
  - Updated cmbuild.xml
    - Revised SQL version from 2016 to 2022
    - Added Key "PRODUCTCOVEREDBYSA" to SQL Server installation config XML
    - Detections: Updated SQL key to support 2022
    - Section 6, SAExpiration date
  - Public folder: General formatting and syntax updates
  - Private folder: General formatting and syntax updates
