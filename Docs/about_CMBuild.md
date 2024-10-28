# CMBuild
## about_CMBuild

# SHORT DESCRIPTION
CMBuild is a module with functions intended for automating lab installations of Microsoft Configuration Manager.

# LONG DESCRIPTION
CMBuild is a module with functions intended for automating lab installations of Microsoft Configuration Manager.
This includes dependencies, prerequisites, and configuration settings, including SQL Server, WSUS, MDT, ADK, SSMS, 
Active Directory container and permissions, local users and permissions, site configuration settings and more.

## Copy-CMBuildTemplate

Clones the default XML templates for cmbuild and cmsiteconfig for use offline or publishing to a different online location.

## Invoke-CMBuild

This is the main function for processing the templates to build a Configuration Manager site.

## Invoke-CMSiteConfig

This configures the SCCM site after the server platform is prepared.