#=================================================================================================
# Get hard-drive information
# Author: Kiran Kurapaty
# Copyright (c) Kiran Kurapaty
#=================================================================================================

<#
$choices = @{ 0 = "Yes"; 1= "No"; 2 = "Cancel"};
$defaultValue = 1;
$userChoice = $host.UI.PromptForChoice("Caption", "Hello there", $choices, $defaultValue)
write-host $userChoice
#gsv -ComputerName "CIBLDNGAPPVU133" -Name "CAM*" | Group Status | Sort Name | Select -Property *
#>
function Get-ComputerInfo
{
    Param([string]$computer=$env:COMPUTERNAME)
    $wmi = Get-WmiObject -Class win32_computersystem -ComputerName $computer
    $pcinfo = New-Object psobject -Property @{"host" = $wmi.DNSHostname 
    "domain" = $wmi.Domain
    "user" = $wmi.Username
    }
    $pcInfo
} #end function Get-ComputerInfo

function Get-OptimalSize {
param([Parameter(Mandatory = $true,Position = 0,valueFromPipeline=$true)]
      [int64] $sizeInBytes
) #end param
    Switch ($sizeInBytes)
    {
        {$sizeInBytes -ge 1TB} {"{0:n2}" -f ($sizeInBytes/1TB) + " TB";break}
        {$sizeInBytes -ge 1GB} {"{0:n2}" -f ($sizeInBytes/1GB) + " GB";break}
        {$sizeInBytes -ge 1MB} {"{0:n2}" -f ($sizeInBytes/1MB) + " MB";break}
        {$sizeInBytes -ge 1KB} {"{0:n2}" -f ($sizeInBytes/1KB) + " KB";break}
        Default { "{0:n2}" -f $sizeInBytes + " Bytes" }
    } #end switch
    $sizeInBytes = $null
} #end Function Get-OptimalSize

function Get-ComputerLogicalDisk([string] $computer)
{
    $FreeSpace = @{Name="FreeSpace"; Expression={Get-OptimalSize $_.FreeSpace}}
    $DiskSize = @{Name="DiskSize"; Expression={Get-OptimalSize $_.Size}}
    $DeviceName = @{Name="Drive"; Expression={$_.DeviceId}}
    return gwmi win32_logicaldisk -ComputerName $computer | ? { $_.DriveType -eq 3 } | Select $DeviceName, $FreeSpace, $DiskSize
}
cls
$compInfo = Get-ComputerLogicalDisk "localhost"
Write-Host $compInfo
