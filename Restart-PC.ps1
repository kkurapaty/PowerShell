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
    Write-Host "      Restart My Computer (local machine)" -ForegroundColor Cyan -NoNewline
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

$USER_ACTION = (Prompt-User -Message "Are you sure want to RESTART your computer " -Hint "Y/N" -IsRequired).ToUpper();
If ($USER_ACTION -eq "Y")
{
    WriteLine "Initialising Restart, Please wait..."
    Restart-Computer
}
else
{
    WriteLine "Lucky Chap! Restart not initiated."
}

Print-ScriptCompleted "Initiation"