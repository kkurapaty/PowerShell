#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
<#
    .SYNOPSIS
        List out installed software on a computer (local / remote)
    .AUTHOR
        Kiran Kurapaty - kkurapaty@gmail.com
    .VERSION
        1.0
    .PARAMETERS
        ComputerName:  Checks for installed software on given computer
        FullDetails:   If true, gives full details otherwsie Software, Version, Publisher
    .REVISIONS
        Initial Version
#>
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

## MAKE SURE TO ADD BELOW TO YOUR SCRIPT ##
. "$PSScriptRoot\fileIOUtil.ps1" -Force
#END OF USAGE


[int]$global:count = 0;
Function Get-SoftwareInstalled  {
  [OutputType('System.Software.Inventory')]
  [Cmdletbinding()] 
  Param( 
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
        [String[]]$ComputerName=$env:COMPUTERNAME,
        [bool] $FullDetails = $true,
        [bool] $ShowGrid = $false
        )         

    Begin { }

    Process  
    { 
        $local:Result = [System.Collections.ArrayList] @();
        $local:Lookup = [System.Collections.ArrayList] @();
        $local:Result.Clear();
        $local:Lookup.Clear();
        ForEach  ($Computer in  $ComputerName) 
        { 
            If  (Test-Connection -ComputerName $Computer -Count  1 -Quiet) 
            {
                $Paths  = @("SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall","SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall")         
                ForEach($Path in $Paths) 
                { 
                    Write-Verbose  "Checking Path: $Path"
                    #  Create an instance of the Registry Object and open the HKLM base key 
                    Try  
                    { 
                        $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$Computer,'Registry64') 
                    } 
                    Catch  
                    { 
                        Write-Error $_ 
                        Continue 
                    } 

                    #  Drill down into the Uninstall key using the OpenSubKey Method 
                    Try  
                    {
                        $regkey=$reg.OpenSubKey($Path)  
                        # Retrieve an array of string that contain all the subkey names 
                        $subkeys=$regkey.GetSubKeyNames()      
                        # Open each Subkey and use GetValue Method to return the required  values for each 
                        ForEach ($key in $subkeys)
                        {   
                            Write-Verbose "Key: $Key"
                            $thisKey=$Path+"\\"+$key 
                            Try 
                            {  
                                $thisSubKey=$reg.OpenSubKey($thisKey)   
                                # Prevent Objects with empty DisplayName 
                                $DisplayName = $thisSubKey.getValue("DisplayName")
                                If ($DisplayName -AND $DisplayName -notmatch '^Update for|rollup|^Security Update|^Service Pack|^HotFix') 
                                {
                                    $Date = $thisSubKey.GetValue('InstallDate')
                                    If ($Date) 
                                    {
                                        Try 
                                        {
                                            $Date = [datetime]::ParseExact($Date, 'yyyyMMdd', $Null)
                                        } 
                                        Catch
                                        { 
                                            Try 
                                            {
                                                $Date = [datetime]::ParseExact($Date, 'dd/MM/yyyy', $Null)
                                            } 
                                            Catch
                                            { 
                                                Write-Warning "InstallDate - $($Computer): $_ <$($Date)> for $($DisplayName)"
                                                $Date = $Null
                                            }
                                        }
                                    } 
                                    
                                    # Create New Object with empty Properties 
                                    $Publisher =  Try {
                                      $thisSubKey.GetValue('Publisher').Trim()
                                    } 
                                    Catch {
                                        $thisSubKey.GetValue('Publisher')
                                    }
                                    
                                    $Version = Try {
                                        #Some weirdness with trailing [char]0 on some strings
                                        $thisSubKey.GetValue('DisplayVersion').TrimEnd(([char[]](32,0)))
                                    } 
                                    Catch {
                                        $thisSubKey.GetValue('DisplayVersion')
                                    }
                                    
                                    $UninstallString =  Try {
                                        $thisSubKey.GetValue('UninstallString').Trim()
                                    } 
                                    Catch {
                                        $thisSubKey.GetValue('UninstallString')
                                    }

                                    $InstallLocation =  Try {
                                        $thisSubKey.GetValue('InstallLocation').Trim()
                                    } 
                                    Catch {
                                        $thisSubKey.GetValue('InstallLocation')
                                    }

                                    $InstallSource =  Try {
                                        $thisSubKey.GetValue('InstallSource').Trim()
                                    } 
                                    Catch {
                                        $thisSubKey.GetValue('InstallSource')
                                    }

                                    $HelpLink = Try {
                                        $thisSubKey.GetValue('HelpLink').Trim()
                                    } 
                                    Catch {
                                        $thisSubKey.GetValue('HelpLink')
                                    }
                                    
                                    # Store Object in Results array
                                    $Object = [PSCustomObject] @{
                                      ComputerName = $Computer
                                      DisplayName = $DisplayName
                                      Version  = $Version
                                      InstallDate = $Date
                                      Publisher =  $Publisher
                                      UninstallString = $UninstallString
                                      InstallLocation = $InstallLocation
                                      InstallSource  = $InstallSource
                                      HelpLink = $thisSubKey.GetValue('HelpLink')
                                      EstimatedSizeMB = [decimal]([math]::Round(($thisSubKey.GetValue('EstimatedSize')*1024)/1MB,2))
                                    };
                                    
                                    $keyObj = "{0}-{1}-{2}" -f $Computer, $DisplayName, $Version;               
                                    
                                    if ($local:Lookup.Contains($keyObj) -eq $false) {
                                        [void] $local:Lookup.Add($keyObj);
                                        [void] $local:Result.Add($Object);
                                        $global:count = $global:count + 1;
                                    }
                               }
                          } 
                          Catch {
                            Write-Warning "$Key : $_"
                          }   
                     }
                } 
                    Catch  {}   

                    $reg.Close() 
                }                  
            } 
            Else  
            {
                Write-Error  "$($Computer): unable to reach remote system!"
            }

        } 

        #Display Results
        if ($local:Result -ne $null) 
        {
            #$Object.pstypenames.insert(0,'System.Software.Inventory')
            #Write-Output $Object
            
            if ($FullDetails)
            {
                if ($ShowGrid) {
                    $local:Result | Sort-Object -Property DisplayName | Out-GridView -Title "Installed Software"
                } else {
                    $local:Result | Sort-Object -Property DisplayName | Format-Table -AutoSize #-GroupBy 'Publisher' 
                }
            }
            Else {
                if ($ShowGrid) {
                    $local:Result | Sort-Object -Property DisplayName | Select -Property ComputerName, DisplayName, Version, Publisher | Out-GridView -Title "Installed Software"
                } else {
                    $local:Result | Sort-Object -Property DisplayName | Select -Property ComputerName, DisplayName, Version, Publisher | Format-Table -AutoSize # -GroupBy 'Publisher'
                }
            }           
        }         
    }    
}

function Print-ScriptTitle() 
{
    Write-Host "" -ForegroundColor Green
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*" -ForegroundColor Green
    Write-Host "* #                                                                              # *" -ForegroundColor Green
    Write-Host "* * *" -ForegroundColor Green -NoNewline
    Write-Host "    List of Software Installed On $env:COMPUTERNAME " -ForegroundColor Cyan -NoNewline
    Write-Host "-" -NoNewline
    Write-Host "   Script by" -ForegroundColor Gray -NoNewline
    Write-Host " KIRAN KURAPATY " -ForegroundColor Yellow -NoNewline
    Write-Host "   * * *" -ForegroundColor Green
    Write-Host "* #                                                                               # *" -ForegroundColor Green
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*" -ForegroundColor Green
    Write-Host "" -ForegroundColor Green
}
Clear;
    Print-ScriptTitle;
    $showFullDetails = (Prompt-User -Message "Show Full details ?" -Hint "Y/N" -IsRequired).ToString().ToUpper() -like "Y";
    $showInGrid = (Prompt-User -Message "Show in grid ?" -Hint "Y/N" -IsRequired).ToString().ToUpper() -like "Y";

    Get-SoftwareInstalled -FullDetails:$showFullDetails -ShowGrid:$showInGrid;   
    Print-ScriptCompleted -Message "$global:count Softwares Installed"; 
