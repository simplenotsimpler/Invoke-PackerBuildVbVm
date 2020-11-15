# Invoke-PackerBuildVbVm

## SYNOPSIS
Invokes packer build using a packer JSON file with a virtualbox-iso builder to create a local VirtualBox virtual machine.

## SYNTAX

```
Invoke-PackerBuildVbVm [[-PackerFile] <FileInfo>] [-Overwrite] [-StartLog] [[-LogFile] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Invokes packer build using a packer JSON file with a virtualbox-iso builder to create a local VirtualBox virtual machine.

Requires that Packer and VirtualBox are both installed and in your System PATH.

Recommended Packer JSON file settings:
* Set the communicator to none since SSH often times out.
* Configure a second NIC because using SSH to a host-only adapter is more reliable than depending on port forwarding, especially if you're in a corporate enviroment.
You'll need to configure a static IP of the 192.168.56.x format.

To easily create a Packer VirtualBox file which sets the communicator to none and configures a host-only NIC, use New-PackerVbFile.

## EXAMPLES

### EXAMPLE 1
```
Invoke-PackerBuildVbVm -File "packer-local-ubuntu.json" -Overwrite
```

### EXAMPLE 2
```
Invoke-PackerBuildVbVm -File "packer-local-ubuntu.json" -Overwrite -StartLog
```

### EXAMPLE 3
```
Invoke-PackerBuildVbVm -File "packer-local-ubuntu.json" -Overwrite -StartLog -LogFile "mylog.log"
```

## PARAMETERS

### -PackerFile
Packer JSON file.

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Overwrite
Use Overwrite switch if you want to remove the VirtualBox machine if it already exists.

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

### -StartLog
Switch.
Use this if you want an independent log when this script runs.

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

### -LogFile
Path to log file.
If not specified, defaults to "logs\$ModuleName-$LogDate.log".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Invoke-PackerBuildVbVm
## OUTPUTS

### VirtualBox virtual machine.
## NOTES
Due to bugs I encountered with the -force flag, this has an option to remove the VirtualBox machine manually.

For more information on Packer VirtualBox-ISO builder see:
https://www.packer.io/docs/builders/virtualbox/iso

## RELATED LINKS

[New-PackerVbFile]()

[https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7)

[https://www.virtualbox.org/](https://www.virtualbox.org/)

[https://www.packer.io/](https://www.packer.io/)

[https://www.packer.io/docs/builders/virtualbox/iso](https://www.packer.io/docs/builders/virtualbox/iso)

[https://github.com/simplenotsimpler/New-Autoinstall](https://github.com/simplenotsimpler/New-Autoinstall)

[https://github.com/simplenotsimpler/New-PackerVbFile](https://github.com/simplenotsimpler/New-PackerVbFile)

[https://github.com/simplenotsimpler/Invoke-PackerBuildVbVm](https://github.com/simplenotsimpler/Invoke-PackerBuildVbVm)

[https://github.com/simplenotsimpler/Deploy-VbVm](https://github.com/simplenotsimpler/Deploy-VbVm)

