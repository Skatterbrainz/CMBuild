---
external help file: CMBuild-help.xml
Module Name: CMBuild
online version:
schema: 2.0.0
---

# Invoke-CMBuild

## SYNOPSIS
SCCM site server installation script

## SYNTAX

```
Invoke-CMBuild [-XmlFile] <String> [-NoCheck] [-NoReboot] [-Detailed] [-ShowMenu] [-Resume] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Yeah, what he said.

## EXAMPLES

### EXAMPLE 1
```
Invoke-CMBuild -XmlFile .\cmbuild.xml -Verbose
```

### EXAMPLE 2
```
Invoke-CMBuild -XmlFile .\cmbuild.xml -NoCheck -NoReboot -Detailed
```

### EXAMPLE 3
```
Invoke-CMBuild -XmlFile .\cmbuild.xml -ShowMenu -Verbose
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

### -NoCheck
Skip platform validation restrictions

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

### -NoReboot
Suppress reboots until very end

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

### -Detailed
Show verbose output

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
Choose package items to execute directly from GUI menu

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

### -Resume
Indicates a resumed process request

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
1.0.7 - 01/24/2018 - David Stein

Read the associated XML to make sure the path and filename values
all match up like you need them to.

## RELATED LINKS
