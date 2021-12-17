############################################################################## 
## Check Log Files for specific keywords
## FileName : CheckLogFiles.ps1
## Author   : Kiran Kurapaty
## Created  : Tue, 10th Dec 2019
## Version  : 1.0 
## Revisions: Initial Version
############################################################################## 

CLS
## MAKE SURE TO ADD BELOW TO YOUR SCRIPT ##
. "$PSScriptRoot\fileIOUtil.ps1" -Force
#END OF USAGE

$gps_app_servers = [ORDERED] @{ 
                  "UAT01" = "hostname1";                           
                  "PRD1" = "hostname2" 
                };

$folder_paths = [ORDERED] @{
        "ARCHIVE" = "\\{0}\Deploy\Logs\Archive";
        "LOGS" = "\\{0}\Deploy\Logs\{1}\Enterprise\";
        };

function Print-ScriptTitle() {
    Clear
    Write-Host "" -ForegroundColor Cyan
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#* " -ForegroundColor Cyan
    Write-Host "* " -ForegroundColor Cyan -NoNewLine
    Write-Host "   CheckLogFiles     "  -NoNewline
    Write-Host " -PowerShell script by " -ForegroundColor Gray -NoNewline
    Write-Host "KIRAN KURAPATY " -ForegroundColor Green -NoNewline
    Write-Host "     * " -ForegroundColor Cyan
    Write-Host "* " -ForegroundColor Cyan -NoNewLine
    Write-Host "Hello " -ForegroundColor DarkYellow -NoNewline
    Write-Host $env:USERNAME -NoNewline
    Write-Host ", this script checks for specific keywords only." -ForegroundColor DarkYellow -NoNewline
    Write-Host "  * " -ForegroundColor Cyan
    Write-Host "* " -ForegroundColor Cyan -NoNewLine
    Write-Host "   Make sure to update keywords if you need enhance the script." -ForegroundColor Yellow -NoNewline
    Write-Host " * " -ForegroundColor Cyan  
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#* " -ForegroundColor Cyan 
    Write-Host ""
    Write-Host ""
}

Start-Logging;
Print-ScriptTitle;

$CAM_ENV = (Prompt-User -Message "Enter Environment " -Hint "UAT01 / UAT0? / PROD01" -IsRequired).ToUpper()
$FileFilter = (Prompt-User "Please enter filter Prefix" -Hint "CAM" -IsRequired).ToString();
$Keywordsr = (Prompt-User "Please enter keyword" -Hint "FlowNetId" -IsRequired).ToString();
$dateFrom = (Prompt-User "Please enter date you wish to check from" -Hint "30-Oct-2019" -Default:"01-Feb-2020" -IsRequired).ToString();

Write-Host "";

$htmlOutput = "";

if ([string]::IsNullOrEmpty($CAM_ENV)) { WriteLine "You need to provide valid Environment and try again." 3 }
if ([string]::IsNullOrEmpty($FileFilter))  { $FileFilter = "*"; }

function Check-LogFiles() 
{    
    if ([string]::IsNullOrEmpty($LogFileFilter))  { $LogFileFilter = "CAM"; }
    $result = "";
    $local:fileCount = 0;
    $local:ErrorCount = 0; $local:WarningCount = 0;
    foreach($key in ($gps_app_servers.GetEnumerator() | ? {$_.Key -like $CAM_ENV})) 
    {
        $envKey = $key.Name;
        $hostName = $key.Value;    
        $keywords =  @("failure", "error");
        if ($keywords.IndexOf($Keywordsr.ToLower()) -eq -1) {
            $kewords.Add($keywordStr.ToLower());
        }
        Write-Host "Checking for " -NoNewline
        Write-Host "$keywords" -ForegroundColor Yellow -NoNewline
        Write-Host " in " -NoNewline
        Write-Host $envKey -ForegroundColor Yellow -NoNewline
        Write-Host " ON " -ForegroundColor Gray -NoNewline
        Write-Host $hostName -ForegroundColor Cyan -NoNewline
        Write-Host " ..." 
    
        #$excludedKeywords = @("INFO", "DEBUG" );
        $excludeKeywords = "XXX";
        foreach($folderPath in $folder_paths.GetEnumerator()) 
        {
            if ($folderPath.Name -eq "ARCHIVE") {
                $logFolder = $folderPath.Value -f $hostName
            } else {
                $logFolder = $folderPath.Value -f $hostName, $envKey
            }
            
            $items = Get-ChildItem -Path $logFolder -Recurse -Force -Filter "$FileFilter*.log*" -File | ? { $_.LastWriteTime -gt $dateFrom };
            
            foreach($item in $items) 
            {
                $local:fileCount += 1;
                $matchItem = Select-String -Path $($item.FullName) -Pattern $keywords -AllMatches | Select-String -Pattern $excludedKeywords -NotMatch | Select LineNumber, Line;
                if ($matchItem)
                {
                    Write-Host "Checking -> $($item.FullName)";
                    #$item.FullName | Out-File -FilePath $OUTPUT_LOG_FILE -Append;
                    #$matchItem | Format-Table -AutoSize | Out-File -FilePath $OUTPUT_LOG_FILE -Append;
                    $local:counter=0;
                    $local:HasBodyTag = $false;
                    foreach($mItem in $matchItem)
                    {
                        $local:counter += 1;                
                        if ($local:counter -eq 1) 
                        {
                            $local:label = "{0}T{1}L{2}" -f $envKey, $local:fileCount, $mItem.LineNumber;
                            $result += "<tbody class='header'><tr><td valign='top'><label for='$local:label'>$envKey</label><input type='checkbox' name='$local:label' id='$local:label' data-toggle='toggle'>
                            </td><td valign='top'>$($item.LastWriteTime)</td><td valign='top'>$($item.FullName)</td></tr></tbody>`r`n
                            <tbody class='hide collapsible'><tr><th class='right'>Line#</th><th colspan='2'>Content</th></tr>`r`n";
                            $local:HasBodyTag = $true;
                        }
                        if($($mItem.Line) -contains "INITIALIZATION_ERROR") { $cssClass = "failure"; $local:ErrorCount+=1; } else { $cssClass = "warning"; $local:WarningCount+=1; };            
                        $result += "<tr><td valign='top' class='numeric $cssClass'>$($mItem.LineNumber)</td><td colspan='2' valign='top'>$($mItem.Line)</td></tr>`r`n";
                    }
                    if ($local:HasBodyTag -eq $true) {
                        $result += "</tbody>`r`n";
                    }
                }
            } 
        }
    }

    if (![String]::IsNullOrEmpty($result))
    {
        $local:DotStatus = "normaldot";        
        if ($local:ErrorCount -gt 0) { $local:DotStatus = "reddot"; } elseif ($local:WarningCount -gt 0) { $local:DotStatus = "amberdot"; } else { $local:DotStatus = "greendot"; }
        $result = "<h4>$FileFilter Log File Status</h4>`r`n<table>`r`n
                   <thead><tr><th>Environment</th><th>File Date</th><th>File Path</th></tr></thead>`r`n"+ $result +
                   "<tfoot><tr><td valign='bottom' align='center'>Status <span class='$local:DotStatus'></span></td><td colspan='2'>Processed <b>$local:fileCount</b> Log files.</td></tr></tfoot></table>`r`n";
    }    
    return $result;
}
    $local:logResults = Check-LogFiles;
    $local:OUTPUT_FILE_NAME = GetTempFileEx -FileName "LogCheck" -Extension "htm";
    $htmlOutput = $HTML_TEMPLATE `
                -replace "<!--##EMAIL_HEADER##-->", "Log Report" `
                -replace "<!--##LOG_FILE_STATUS##-->", $logResults 
    $htmlOutput | out-file $local:OUTPUT_FILE_NAME; 
    Invoke-Expression $OUTPUT_FILE_NAME



Print-ScriptCompleted "Log Check";
Stop-Logging -ShowLog;
