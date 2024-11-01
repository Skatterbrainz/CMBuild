---
external help file: CMBuild-help.xml
Module Name: CMBuild
online version:
schema: 2.0.0
---

# Invoke-CMSiteConfig

## SYNOPSIS
SCCM site configuration script

## SYNTAX

```
Invoke-CMSiteConfig [-XmlFile] <String> [-Detailed] [-ShowMenu] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Yeah, what he said.

## EXAMPLES

### EXAMPLE 1
```
Invoke-CMSiteConfig -XmlFile .\cmsiteconfig.xml -Detailed
```

### EXAMPLE 2
```
Invoke-CMSiteConfig -XmlFile .\cmsiteconfig.xml -ShowMenu
```

### EXAMPLE 3
```
Invoke-CMSiteConfig -XmlFile .\cmsiteconfig.xml -Detailed -ShowMenu
```

### EXAMPLE 4
```
Invoke-CMSiteConfig -XmlFile .\cmsiteconfig.xml -Detailed -WhatIf
```

## PARAMETERS

### -XmlFile
Path and Name of XML input file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Detailed
Verbose output without using -Verbose

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowMenu
Override XML controls using GUI (gridview) selection at runtime

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
1.0.7 - 11/21/2017 - David Stein
Read the associated XML to make sure the path and filename values
all match up like you need them to.

## RELATED LINKS
