CLS
## MAKE SURE TO ADD BELOW TO YOUR SCRIPT ##
. "$PSScriptRoot\fileIOUtil.ps1" -Force
#END OF USAGE


function Print-ScriptTitle() 
{
    Write-Host "" -ForegroundColor Green
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*" -ForegroundColor Green
    Write-Host "* #                                                                             # *" -ForegroundColor Green
    Write-Host "* * *" -ForegroundColor Green -NoNewline
    Write-Host "      Start Remote Desktop to Server/PC  " -ForegroundColor Cyan -NoNewline
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

$REMOTE_HOST = (Prompt-User -Message "Enter hostname" -Hint "LOCALHOST" -IsRequired).ToString().ToUpper();

if (![string]::IsNullOrEmpty($REMOTE_HOST))
{
    WriteLine "Initialising remote desktop connection, Please wait..."
    Start-Process "MSTSC" -ArgumentList "/v:$REMOTE_HOST /console"
}

Print-ScriptCompleted "Remoting"