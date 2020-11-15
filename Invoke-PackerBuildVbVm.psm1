<#
.SYNOPSIS
Invokes packer build using a packer JSON file with a virtualbox-iso builder to create a local VirtualBox virtual machine.

.DESCRIPTION
Invokes packer build using a packer JSON file with a virtualbox-iso builder to create a local VirtualBox virtual machine.

Requires that Packer and VirtualBox are both installed and in your System PATH.

Recommended Packer JSON file settings:
* Set the communicator to none since SSH often times out.
* Configure a second NIC because using SSH to a host-only adapter is more reliable than depending on port forwarding, especially if you're in a corporate enviroment. You'll need to configure a static IP of the 192.168.56.x format.

To easily create a Packer VirtualBox file which sets the communicator to none and configures a host-only NIC, use New-PackerVbFile.

.PARAMETER PackerFile
Packer JSON file.

.PARAMETER Overwrite
Use Overwrite switch if you want to remove the VirtualBox machine if it already exists.

.PARAMETER StartLog
Switch. Use this if you want an independent log when this script runs.

.PARAMETER LogFile
Path to log file. If not specified, defaults to "logs\$ModuleName-$LogDate.log".

.EXAMPLE
Invoke-PackerBuildVbVm -File "packer-local-ubuntu.json" -Overwrite

.EXAMPLE
Invoke-PackerBuildVbVm -File "packer-local-ubuntu.json" -Overwrite -StartLog

.EXAMPLE
Invoke-PackerBuildVbVm -File "packer-local-ubuntu.json" -Overwrite -StartLog -LogFile "mylog.log"

.INPUTS
None. You cannot pipe objects to Invoke-PackerBuildVbVm

.OUTPUTS
VirtualBox virtual machine.

.NOTES
Due to bugs I encountered with the -force flag, this has an option to remove the VirtualBox machine manually.

For more information on Packer VirtualBox-ISO builder see:
https://www.packer.io/docs/builders/virtualbox/iso

.LINK
New-PackerVbFile

.LINK
https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7

.LINK
https://www.virtualbox.org/

.LINK
https://www.packer.io/

.LINK
https://www.packer.io/docs/builders/virtualbox/iso

.LINK
https://github.com/simplenotsimpler/New-Autoinstall

.LINK
https://github.com/simplenotsimpler/New-PackerVbFile

.LINK
https://github.com/simplenotsimpler/Invoke-PackerBuildVbVm

.LINK
https://github.com/simplenotsimpler/Deploy-VbVm

#>

function Invoke-PackerBuildVbVm {
  [CmdletBinding()]
  param (
    [Alias('File')]
    [System.IO.FileInfo]$PackerFile,
    [switch]$Overwrite,
    [Switch]$StartLog,
    [String]$LogFile

  )

  begin{
    $ErrorActionPreference = 'Stop'
    $VerbosePreference = "Continue"
    $ModuleName=$MyInvocation.MyCommand
    $PSDefaultParameterValues = @{"*:Verbose"=$True}
    $LogDate=(Get-Date -Format 'yyyy-MM-dd-HHmm')
    if(!$LogFile){
      $LogFile="logs\$ModuleName-$LogDate.log"
    }
    $Separator="================================"

    if($StartLog){
      Start-Transcript $LogFile -Append
    }

    Write-Verbose $Separator
    Write-Verbose "     Begin $ModuleName Log"
    Write-Verbose $Separator


    #Validate $PackerFile
    try{
      if( -Not ($PackerFile | Test-Path -PathType Leaf) ){
          throw "$PackerFile does not exist"
      }
      if (-Not ((Get-Content -Path $PackerFile -Raw) | Test-Json -ErrorAction Ignore )){
        throw "$PackerFile is not valid JSON"
      }
    }
    catch{
      Write-Error "$ModuleName::$_"
    }

    Write-Verbose "Checking for Packer and VBoxManage"
    try {
      if( -Not([bool] (Get-Command -ErrorAction Ignore -Type Application packer)) ){
        throw "Unable to find Packer executable. Please add it to your System Path."
      }

      if( -Not([bool] (Get-Command -ErrorAction Ignore -Type Application VBoxManage)) ){
        throw "Unable to find VBoxManage executable. Please add it to your System Path."
      }
    }
    catch {
      Write-Error "$ModuleName::$_"
    }



    $env:PACKER_LOG=1
    $env:PACKER_LOG_PATH="logs\packer-details-$LogDate.log"

  }

  process{
    #region get initial values from PackerFile
    #get hashtable from PackerFile so can use multiple values
    $PackerFileHash = (Get-Content -Path $PackerFile -Raw | ConvertFrom-Json -AsHashtable)

    #because this is nested, you have to use the builders array
    $VbVmName= $PackerFileHash.builders.vm_name
    $VbVmMachineFolder = $PackerFileHash.builders.output_directory

    #endregion get initial values from File

    #region check if machine exists
    Write-Verbose "$ModuleName::Checking if machine exists: $VbVmName"
    $VbVmList=(VBoxManage list vms)

    if ($VbVmList | Select-String $VbVmName -Quiet) {
        $VbVmExists=$true
    }
    else {
        $VbVmExists=$false
    }

    #check to make sure machine folder does not exist either
    #if there are errors, machine could be removed from VBox list but not from the machine location

    if (Test-Path $VbVmMachineFolder){
      $VbVmMachineFolderExists=$true
    }
    else {
      $VbVmMachineFolderExists=$false
    }
    # endregion check if machine exists

    if ($VbVmExists -or $VbVmMachineFolderExists) {
      try {
        if(!$Overwrite){

          $ErrorMessage="{0} or {0} folder already exists. Use the Overwrite switch if you want to replace it." -f $VbVmName
          throw $ErrorMessage
        }
        else {

          #manually remove VirtualBox machine due to bug with packer build -force not working
          #region check powered off
          Write-Verbose "$ModuleName::Checking if $VbVmName powered off"
          $VbVmnfo = VBoxManage showvminfo $VbVmName -machinereadable
          $VbVmProperties = @{}
          $VbVmnfo | ForEach-Object {$key, $value = $_.Split('=', 2); $VbVmProperties[$key.Trim()] = $value.Trim('" ')}

          if($VbVmProperties.VMState -ne 'poweroff'){
            Write-Error ('$ModuleName::{0} is not off. Please power machine off before proceeding.' -f $VbVmName) -ErrorAction Stop
          }
          #endregion check powered off

          #region remove machine and clean up
          Write-Verbose "$ModuleName::Removing $VbVmName"
          Start-Process VBoxManage -ArgumentList "unregistervm $VbVmName --delete" -Wait

          if ($VbVmMachineFolderExists) {
            Remove-Item -recurse "$VbVmMachineFolder\*" -force
          }
          #endregion remove machine and clean up
        }
      }
      catch {
        Write-Error "$ModuleName::$_"
      }

    }

    Write-Verbose "$ModuleName::Starting Packer Build"

    #Remember that with packer the options go before the template file!!
    packer build -only=virtualbox-iso -timestamp-ui $PackerFile| Out-Host

  }

  end{

    Write-Verbose "$ModuleName::Cleaning up"
    #region clean up and remove packer_cache folder
    if (Test-Path packer_cache) {
      Remove-Item -recurse "packer_cache" -force
    }
    #endregion clean up and remove packer_cache folder

    Write-Verbose $Separator
    Write-Verbose "      End $ModuleName"
    Write-Verbose $Separator

    if($StartLog){
      Stop-Transcript
    }
  }

}
