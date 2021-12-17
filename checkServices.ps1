CLS
## MAKE SURE TO ADD BELOW TO YOUR SCRIPT ##
. "$PSScriptRoot\fileIOUtil.ps1" -Force
. "$PSScriptRoot\CAMHosts.ps1" -Force
#END OF USAGE


function Print-ScriptTitle() 
{
    Write-Host "" -ForegroundColor Green
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*" -ForegroundColor Green
    Write-Host "* #                                                                             # *" -ForegroundColor Green
    Write-Host "* * *" -ForegroundColor Green -NoNewline
    Write-Host "      Start/Stop CAM-Enterprise Services " -ForegroundColor Cyan -NoNewline
    Write-Host "-" -NoNewline
    Write-Host "   Script by" -ForegroundColor Gray -NoNewline
    Write-Host " KIRAN KURAPATY " -ForegroundColor Yellow -NoNewline
    Write-Host "   * * *" -ForegroundColor Green
    Write-Host "* #                                                                             # *" -ForegroundColor Green
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*" -ForegroundColor Green
    Write-Host "" -ForegroundColor Green
}
  
Clear

Print-ScriptTitle;
$CAM_AppType = (Prompt-User -Message "Product Type " -Hint "CAME / CAMB / SBSA" -IsRequired -Default "CAME").ToUpper()
$CAM_ENV = (Prompt-User -Message "Enter Environment " -Hint "UAT01 / UAT? / UAT*" -IsRequired).ToUpper()
$serviceName = (Prompt-User -Message "Enter Service Name" -Hint "CAMCaly" -IsOptional)
$serviceStatus = (Prompt-User -Message "Status " -Hint "Running/Stopped" -IsOptional)
$serviceAction = (Prompt-User -Message "Servive Action" -Hint "Start/Stop/Restart" -IsOptional).ToString()
$serviceMode = (Prompt-User -Message "Servive Mode" -Hint "Auto/Enable/Disable" -IsOptional).ToString()
$restartWebsites = (Prompt-User -Message "Restart Websites" -Hint "Y/N" -IsOptional -Default "N").ToUpper();

#Clear;
Write-Host "";
if ([string]::IsNullOrEmpty($CAM_AppType)) { $CAM_AppType = "CAME"; }
if ([string]::IsNullOrEmpty($CAM_ENV)) { WriteLine "You need to provide valid Environment and try again." 3 }
#if ([string]::IsNullOrEmpty($serviceName)) { $serviceName = "*"; }   	
if ([string]::IsNullOrEmpty($serviceStatus)) { $serviceStatus = "*"; }  

#region - Service Methods -
function StartServices($services, [switch] $isWinObj = $false) 
{
    WriteLine "Starting Services...";
    foreach($s in $services) 
    { 
        if ($isWinObj) { $s.StartService() }      
        else 
        { 
            if ($($s.StartType) -ne "disabled" -and $($s.Status) -ne "running")
            { 
                #WriteLine "Starting Service $($s.DisplayName)";
                Start-Service $s
            }
        }
    }
}

function StopServices($services, [switch] $isWinObj = $false) 
{
    WriteLine "Stopping Services...";
    foreach($s in $services) 
    {
        if ($isWinObj) { $s.StopService() }
        else    
        {
            Stop-Service -InputObject $s
        }
    }    
}

function RestartServices($services, [switch] $isWinObj = $false) 
{
    WriteLine "Restarting Services...";
    foreach($s in $services)  
    {
        if ($isWinObj)
        {         
            #WriteLine "Stopping Service $($s.DisplayName)" -MessageType 1;
            $s.StopService(); 
            #WriteLine "Starting Service $($s.DisplayName)" -MessageType 1;
            $s.StartService();
            $s.Refresh();
        } 
        else 
        {
            if ($($s.StartType) -ne "disabled")
            { 
               #WriteLine "Restarting Service $($s.DisplayName)" -MessageType 1;
               Restart-Service $s
            }
        }
    }   
}

function DisplayServices($services, [switch] $isWinObj = $false) 
{
    if ($services) 
    {
        if ($isWinObj) 
        {
            $services | Select PSComputerName, StartMode, State, Name, DisplayName | Sort State, Name | Format-Table -AutoSize
        } 
        else 
        {
            $services | Select MachineName, StartType, Status, Name, DisplayName | Sort Status, Name | Format-Table -AutoSize
        } 
    } 
    else 
    {
        WriteLine "No $serviceStatus Services found.";
    }              
}

function Restart-CAMWebsite {
    Param(          
          [ValidateNotNullOrEmpty()][string] $Env=$(throw " Environment is required."), 
          [ValidateNotNullOrEmpty()][string] $ServerName=$(throw " ServerName is required"),
          [switch] $Stop, [switch] $Start, [switch] $Restart
        ) 

    $credential = $Global:UserCredential;
    $AppPoolNames = @("*-$Env.sbl.co.uk", "Default Web Site")
    if ($Restart)
    {
        WriteLine "Please wait, restarting Websites $AppPoolNames ...";
        #Restart-WebAppPool -Name $AppPoolNames
        $scriptBlock = { Import-Module WebAdministration; Stop-Website $args[0]; Stop-Website $args[1]; Start-Website $args[0]; Start-Website $args[1]; }
    } elseif ($Stop)
    {
        WriteLine "Please wait, stopping Websites $AppPoolNames ...";
        # Stop-Website -Name $AppPoolNames
        # Stop-WebAppPool -Name $AppPoolNames
        $scriptBlock = { Import-Module WebAdministration; Stop-Website $args[0]; Stop-Website $args[1] }
    } elseif ($Start)
    {
        WriteLine "Please wait, starting Websites $AppPoolNames ...";
        # Start-WebAppPool -Name $AppPoolNames
        # Start-Website -Name $AppPoolNames
        $scriptBlock = { Import-Module WebAdministration; Start-Website $args[0]; Start-Website $args[1] }
    }
    if ($Global:UserCredential -ne $null)     
    {
        $job = Invoke-Command -ComputerName $ServerName -Credential:$credential -ScriptBlock:$scriptBlock -ArgumentList:$AppPoolNames -AsJob
    }
    else
    {
        $job = Invoke-Command -ComputerName $ServerName -ScriptBlock:$scriptBlock -ArgumentList:$AppPoolNames -AsJob
    }
    $result = $job | Format-Table -Auto
    Write-Output $result
    WriteLine "WebAdministration Completed." 3
}

function Restart-IIS {
    Param([ValidateNotNullOrEmpty()] [string] $ServerName=$(throw " ServerName is required."),
          [switch] $Stop, [switch] $Start, [switch] $Restart
    )
    $credential = $Global:UserCredential;
    $StartTime= Get-Date
    WriteLine "IIS Administration process Started at $StartTime"
    if ($Stop)
    {
        WriteLine "Please wait, Stopping IIS on $ServerName ..."
        # Call IISReset
        $scriptBlock = { iisreset /STOP }
    }
    if ($Start)
    {
        WriteLine "Please wait, Starting IIS on $ServerName ..."
        # Call IISReset
        $scriptBlock = { iisreset /START }
    }
    if ($Restart)
    {
        WriteLine "Please wait, Restarting IIS on $ServerName ..."
        # Call IISReset
        $scriptBlock = { iisreset /RESTART }
    }
    
    if ($Global:UserCredential -ne $null) 
    {
       $job = Invoke-Command -ComputerName:$ServerName -Credential:$credential -ScriptBlock:$scriptBlock -AsJob
    } 
    else 
    {
        $job = Invoke-Command -ComputerName:$ServerName -ScriptBlock:$scriptBlock -AsJob
    }
    
    $result = $job | Format-Table -Auto
    Write-Output $result
    $EndTime = Get-Date
    WriteLine "IIS Administration Completed at $EndTime" 3
}

function RestartWebsites()
{
    ###  Iterate through Hosts ###    
    foreach($key in Get-CAMWebHostsByEnv -AppType:$CAM_AppType -CAMEnv:$CAM_ENV)
    {
        $envKey = $key.Name;
        $hostName = $key.Value;
        Write-Host "Checking " -NoNewline
        Write-Host $envKey -ForegroundColor Yellow -NoNewline
        Write-Host " ON " -ForegroundColor Gray -NoNewline
        Write-Host $hostName -ForegroundColor Cyan -NoNewline
        Write-Host " ..." 
        Reset-ServiceCredentials -AppType $CAM_AppType -CAMEnv $envKey -HostName $hostName -ServiceAction $serviceAction;        

        Restart-IIS -ServerName:$hostName -Restart;
        Restart-CAMWebsite -Env:$envKey -ServerName:$hostName -Restart;
    }
}
# disable:-1, enable:0, auto:1
function SetServices($services, [switch] $isWinObj = $false, [string]$disableEnableAuto=$null) 
{
    foreach($s in $services) 
    { 
        if ($disableEnableAuto -like "Disable") 
        {
            WriteLine "Disabling Service $($s.DisplayName)" -MessageType 3;
            if ($isWinObj) { $s.ChangeStartMode("Disabled") } else { Set-Service -InputObject $s -StartupType Disable }
        } 
        elseif ($disableEnableAuto -like "Enable") 
        {
            WriteLine "Enabling Service $($s.DisplayName)" -MessageType 3;
            if ($isWinObj) { $s.ChangeStartMode("Enabled") } else { Set-Service -InputObject $s -StartupType Manual }
        } 
        elseif ($disableEnableAuto -like "Auto") 
        {
            WriteLine "Auto Service $($s.DisplayName)" -MessageType 3;
            if ($isWinObj) { $s.ChangeStartMode("Automatic") } else { Set-Service -InputObject $s -StartupType Automatic }
        }                 
    }
}

function Get-CAMServices($serviceName, $envKey, $hostName, $serviceStatus)
{
    # Write-Host "$serviceName*.$envKey"
    $services=$null;
    if ($Global:UserCredential -ne $null) 
    {
        $services = Get-WmiObject Win32_Service -Credential $Global:UserCredential -ComputerName $hostName -Filter "Name Like '$serviceName%.$envKey'" 
    } 
    else 
    {
        $services = gsv -Name "$serviceName*.$envKey" -ComputerName $hostName | ? {$_.Status -like $serviceStatus }        
    }
    return $services;
}

#endregion

$winObj=$false
foreach($key in Get-CAMAppHostsByEnv -AppType $CAM_AppType -CAMEnv $CAM_ENV) 
{
    $envKey = $key.Name;
    $hostName = $key.Value;
    Write-Host "Checking " -NoNewline
    Write-Host $envKey -ForegroundColor Yellow -NoNewline
    Write-Host " ON " -ForegroundColor Gray -NoNewline
    Write-Host $hostName -ForegroundColor Cyan -NoNewline
    Write-Host " ..." 
    try 
    {
        Check-ServiceCredentials -AppType $CAM_AppType -CAMEnv $CAM_ENV -HostName $hostName -ServiceAction $serviceAction;
        $services = Get-CAMServices -serviceName $serviceName -envKey $envKey -hostName $hostName -serviceStatus $serviceStatus;
        $winObj= ($Global:UserCredential -ne $null); 
       
        # SET MODE
        if (![string]::IsNullOrEmpty($serviceMode)) 
        {
            SetServices $services -isWinObj:$winObj -disableEnableAuto $serviceMode
            # Need to reload services if we have changed the services
            $services = Get-CAMServices -serviceName $serviceName -envKey $envKey -hostName $hostName -serviceStatus $serviceStatus;
        }   

        # ACTION
        if ($serviceAction -like "Start") 
        {
           # Start Services
           StartServices $services -isWinObj:$winObj   
        } 
        elseif ($serviceAction -like "Stop") 
        {
           # Stop Services
           StopServices $services -isWinObj:$winObj
        } 
        elseif ($serviceAction -like "Restart") 
        {
           # Restart Services
           RestartServices $services -isWinObj:$winObj
        } 
            
        # Show Services
        DisplayServices $services -isWinObj:$winObj            
    }
	catch [Exception] {
        WriteLine "Could not check $serviceName.$envKey ON $hostName" -MessageType 2
        Write-Error $Error[0]
		$err = $_.Exception
		while ( $err.InnerException ) {
			$err = $err.InnerException
			Write-Host "[ERROR] $err.Message" -ForegroundColor Red
		}
	}    
}


if ($restartWebsites -eq "Y")
{    
    RestartWebsites;
}

Print-ScriptCompleted -Message "Service Check";
