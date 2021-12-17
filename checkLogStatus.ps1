CLS
## MAKE SURE TO ADD BELOW TO YOUR SCRIPT ##
. "$PSScriptRoot\fileIOUtil.ps1" -Force
. "$PSScriptRoot\CAMHosts.ps1" -Force
#END OF USAGE


function Print-ScriptTitle() 
{
    Clear
    Write-Host "" -ForegroundColor Green
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*" -ForegroundColor Green
    Write-Host "* #                                                                             # *" -ForegroundColor Green
    Write-Host "* * *" -ForegroundColor Green -NoNewline
    Write-Host "      Current Log Status  " -ForegroundColor Cyan -NoNewline
    Write-Host "-" -NoNewline
    Write-Host "   Script by" -ForegroundColor Gray -NoNewline
    Write-Host " KIRAN KURAPATY " -ForegroundColor Yellow -NoNewline
    Write-Host "   * * *" -ForegroundColor Green
    Write-Host "* #                                                                             # *" -ForegroundColor Green
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*" -ForegroundColor Green
    Write-Host "" -ForegroundColor Green
}
  


Print-ScriptTitle;
$CAM_AppType = (Prompt-User -Message "Product Type " -Hint "CAME / CAMB / SBSA" -IsRequired -Default "CAME").ToUpper()
$CAM_ENV = (Prompt-User -Message "Enter Environment " -Hint "UAT01 / UAT? / UAT*" -IsRequired).ToUpper();
$testStartDate = Get-Date;

Write-Host "";
if ([string]::IsNullOrEmpty($CAM_AppType)) { $CAM_AppType = "CAME"; }
if ([string]::IsNullOrEmpty($CAM_ENV)) { WriteLine "You need to provide valid Environment and try again." 3 }

function Get-CurrentLogStatus($logFileName) 
{
    $local:activity = @{
        FileName = $logFileName;
        LastUpdated = $null; 
        LastUpdatedStr = $null; 
        Status = "Log Not Found!";
        LastError = "-";        
        ErrorCount = 0;
        WarnCount = 0;
        TimeTaken = "";
    };    
    [DateTime]$dateStarted= Get-Date;
    
    If (Test-Path $logFileName) 
    {
        $logEntry = Get-Item $logFileName | select -Property CreationTime, LastAccessTime, LastWriteTime;        
        $FileContent= Get-Content $logFileName
        $($local:activity).ErrorCount = $($(Select-String -InputObject $FileContent -Pattern "ERROR" -AllMatches -CaseSensitive).Matches).Count
        $($local:activity).WarnCount  = $($(Select-String -InputObject $FileContent -Pattern "WARN" -AllMatches -CaseSensitive).Matches).Count
        
        $lastLine = [String] (Get-Content $logFileName -Tail 1);
        $lastError = [String] ($FileContent | Select-String -Pattern "ERROR" | Select-Object -Last 1)        
        
        if ($lastLine -ne $null -and $lastLine.Length -gt 19) 
        {
           $dateTimeStr = [String]$($lastLine).Substring(0, 19).Trim(); 
           if ($dateTimeStr -match "\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}") 
           {
            try {
                  $logDateTime = [DateTime]::ParseExact($dateTimeStr, 'yyyy-MM-dd HH:mm:ss', [CultureInfo]::InvariantCulture);
                  if ($logDateTime -gt $logEntry.LastAccessTime)  
                  { 
                     $logEntry.LastWriteTime = $logDateTime; 
                  }
              } 
              catch [Exception]
              { 
                 WriteLine $_.Exception 2; 
                 WriteLine "[EXCEPTION] $StackTrace" 2
              }
           }
        }

        $($local:activity).LastUpdated = $($logEntry.LastWriteTime); 
        $($local:activity).LastUpdatedStr = $($($logEntry.LastWriteTime).ToString('dd/MM/yyyy HH:mm:ss'));

        if (($lastLine).Length -gt 24) 
        {
             $($local:activity).Status = $lastLine.Substring(24, $($lastLine).Length - 24).Trim();
        }        
        
        if (($lastError).Length -gt 24) 
        {
            $dateTimeStr = [String]$($lastError).Substring(0, 19).Trim(); 
            if ($dateTimeStr -match "\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}") 
            {
                $($local:activity).LastError = [String]$($lastError).SubString(24, $($lastError).Length - 24).Trim();
            }
            else  
            {
                $($local:activity).LastError = [String]$($lastError).Trim();
            }
        }
        
        $dateNow = Get-Date; 
        if ($dateNow.AddMinutes(-10) -gt $($logEntry.LastWriteTime)) 
        {
            $tempStr = Get-AsDuration -FromDate $($logEntry.LastWriteTime) -ToDate $dateNow;
            $($local:activity).Status = "Log hasn't updated since $tempStr";        
        }         
        $($local:activity).TimeTaken = Get-AsDuration -FromDate $dateStarted -ToDate $dateNow            
    } 
    
    return $local:activity;
}

function Check-LogFiles() 
{
    $Items = [System.Collections.ArrayList] @();
    foreach($key in Get-CAMAppHostsByEnv $CAM_AppType $CAM_ENV) 
    {
        $envKey = $key.Name;
        $hostName = $key.Value;
        Write-Host "Checking -> Log Status " -NoNewline
        Write-Host $envKey -ForegroundColor Yellow -NoNewline
        Write-Host " ON " -ForegroundColor Gray -NoNewline
        Write-Host $hostName -ForegroundColor Cyan -NoNewline
        Write-Host " ..." 
        
        $logFiles =  Get-ChildItem -Path "\\$hostName\Deploy\Logs\$envKey\Enterprise\" -Filter "*.log" -File;
        foreach($file in $logFiles)
        {
            #UpdateStatus-Until-ProcessExits -logFileName $logFileName -Title "EOD Process" ;
            $logFileName = ExtractFileName($($file.FullName));
            Write-Host "  -> Analysing : " -ForegroundColor Gray -NoNewline
            Write-Host $logFileName -NoNewline
            Write-Host " ..." -ForegroundColor DarkGray -NoNewline

            $activity = Get-CurrentLogStatus $($file.FullName);
            
            [void] $Items.Add([PSCustomObject] @{ 
                FileName = $logFileName; 
                ErrorCount = $activity.ErrorCount;
                WarnCount = $activity.WarnCount;                
                Status = $activity.Status;
                LastError = $activity.LastError;                        
                LastUpdated = $activity.LastUpdated;                
                TimeTaken = $activity.TimeTaken;
            });             
            Write-Host " DONE" -ForegroundColor Green
        }
        Write-Host ""
        #foreach($item in $Items) {     }
    }
    Print-ScriptTitle;
    $Items | ? { $_.ErrorCount -gt 0 -or  $_.WarnCount -gt 0 } | Format-Table -AutoSize;
}

Clear
Print-ScriptTitle;
Check-LogFiles;
Print-ScriptCompleted -Message "Log Status";