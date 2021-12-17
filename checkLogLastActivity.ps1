
############################################################################## 
## Check CAM Base / Enterprise Log Files for specific keywords
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
                  "UAT01" = "CIBLDNGAPPVU133";
                  "UAT02" = "CIBLDNLAPPVU156";
                  "UAT03" = "CIBLDNLAPPVU158";
                  "UAT04" = "CIBLDNLAPPVU160";
                  "UAT05" = "CIBLDNLAPPVU162";

                  "DEV01" = "CIBLDNLAPPVD158";
                  "DEV02" = "CIBLDNLAPPVD158";
                  "DEV03" = "CIBLDNLAPPVD158";
                  "DEV04" = "CIBLDNLAPPVD159";
                  "DEV05" = "CIBLDNLAPPVD159";

                  "PROD01" = "CIBLDNLAPPVP149";
                  # OLD SERVERS
                  "DEV1" = "CIBLDNGAPPVD058"; 
                  "DEV2" = "CIBLDNGAPPVD058"; 
                  "DEV3" = "CIBLDNGAPPVD058";
                  "UAT1" = "CIBLDNGAPPVU058";
                  "UAT2" = "CIBLDNGAPPVU060";
                  "UAT3" = "CIBLDNGAPPVU062";                    
                  "PRD1" = "CIBLDNGAPPVP058" 
                };
$serviceNames = [ORDERED] @{
"AccountingEngine"               = "Enterprise\CAMAccountingEngine.log";
"AurumInterfaceService"          = "Enterprise\CAMAurumInterfaceService.log";
"AurumQuarantineFeedService"     = "Enterprise\CAMAurumQuarantineFeedService.log";
"AurumStaticFeedService"         = "Enterprise\CAMAurumStaticFeedService.log";
"CalypsoAuthorisationService"    = "Enterprise\CAMCalypsoService.log";
"CalypsoInterface" = "Enterprise\CAMCalypsoInterface.log";
"Cashflow_In" = "Enterprise\CAMCashflow_In.log";
"CurveFeedService" = "Enterprise\UpstreamExtracts\CAMCurveFeedService.log";
"DetermineLedgerService" = "Enterprise\CAMDetermineLedgerService.log"; 
"GlobusInterface" = "Enterprise\CAMPublishToGlobus.log";
"InboundInterfaceService" = "Enterprise\CAMInboundInterfaceService.log";
"InterestCalculationEngineService" = "Enterprise\CAMInterestCalculationEngineService.log";
"MeridianMessagePublisher" = "Enterprise\CAMMeridianMessagePublisher.Service.log"; 
"MessageBroker" = "Enterprise\CAMMessageBroker.log";
"NettingInterfaceService" = "Enterprise\CAMNettingInterfaceService.log";
"OSDCalendarService" = "Enterprise\CAMOSDCalendarFeedService.log";
"PaymentEngineInterfaceService" = "Enterprise\CAMPaymentEngineInterfaceService.log";
"PaysureExtractService" = "Enterprise\CAMPaysureExtractService.log"; 
"PaySureService" = "Enterprise\CAMPaySureLog.txt";
"PrismInterface" = "Enterprise\CAMPrismInterface.log";
"ReportEngineService" = "Enterprise\CAMReportEngineService.log";
"ReportJobs" = "Enterprise\CAMReportJobsService.log";
"SafeWatchInterfaceService" = "Enterprise\CAMSafeWatchInterfaceService.log";
"Static_In" = "Enterprise\CAMStatic_In.log";
"XceptorInterface" = "Enterprise\CAMXceptorInterface.log";
"MetalTradingDeliveryManager" = "Shared\MetalTradingDeliveryManager.log";
"MetalTradingReportManager" = "Shared\MetalTradingReportManager.log";
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
CLS
Start-Logging;
Print-ScriptTitle;

$CAM_ENV = (Prompt-User -Message "Enter Environment " -Hint "UAT01 / UAT0? / PROD01" -IsRequired).ToUpper()
#$FileFilter = (Prompt-User "Please enter filter Prefix" -Hint "CAMCharges" -IsRequired).ToString();


Write-Host "";

$htmlOutput = "";

if ([string]::IsNullOrEmpty($CAM_ENV)) { WriteLine "You need to provide valid Environment and try again." 3 }
if ([string]::IsNullOrEmpty($FileFilter))  { $FileFilter = "*"; }

function Check-LogFiles() 
{    
    foreach($key in ($gps_app_servers.GetEnumerator() | ? {$_.Key -like $CAM_ENV})) 
    {
        $envKey = $key.Name;
        $hostName = $key.Value;            
        Write-Host "Checking for " -NoNewline
        Write-Host "Activity" -ForegroundColor Yellow -NoNewline
        Write-Host " in " -NoNewline
        Write-Host $envKey -ForegroundColor Yellow -NoNewline
        Write-Host " ON " -ForegroundColor Gray -NoNewline
        Write-Host $hostName -ForegroundColor Cyan -NoNewline
        Write-Host " ..." 
        
        foreach($logKey in ($serviceNames.GetEnumerator())) # | ? { $_.Key -like $serviceName })) 
        {            
            $logFileName ="\\{0}\Deploy\Logs\{1}\{2}" -f $hostName, $envKey, $logKey.Value;
            If (Test-Path $logFileName) {
                $local:dateTimeStr = [DateTime] $(Get-Item $logFileName | select -Property LastWriteTime).LastWriteTime 
                $local:lastLineText = Get-Content $logFileName -Tail 1;
                if ($local:lastLineText -ne $null) {
                    $local:dateTimeStr = [String]$($lastLine).Substring(0, 19).Trim(); 
                    #$local:lastLineText= [String]$($lastLine).Remove(0, 24).Trim(); 
                    
                    if ($local:lastLineText | Select-String -Pattern @("error", "failure", "exception") -SimpleMatch) {
                        Write-Host "$($logKey.Value) => $local:dateTimeStr - $local:lastLineText" -foreground Red
                    } else {                        
                        Write-Host "$($logKey.Value) => $local:dateTimeStr $local:lastLineText"
                    }
                } else  {
                    Write-Host "$($logKey.Value) => No log entries found" -foreground Yellow
                }
            } else  {
                Write-Host "$($logKey.Value) => No log found" -foreground Yellow
            }
        }
    }
    
}

Check-LogFiles;

Print-ScriptCompleted "Log Check";

