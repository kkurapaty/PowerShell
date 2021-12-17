CLS
## MAKE SURE TO ADD BELOW TO YOUR SCRIPT ##
. "$PSScriptRoot\fileIOUtil.ps1" -Force
#END OF USAGE
Clear;
function Print-ScriptTitle() {
    Clear
    Write-Host "" -ForegroundColor Cyan
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#* " -ForegroundColor Cyan
    Write-Host "* " -ForegroundColor Cyan -NoNewLine
    Write-Host " ValidateConfigFiles "  -NoNewline
    Write-Host "-PowerShell script by " -ForegroundColor Gray -NoNewline
    Write-Host "KIRAN KURAPATY " -ForegroundColor Green -NoNewline
    Write-Host "      * " -ForegroundColor Cyan
    Write-Host "* " -ForegroundColor Cyan -NoNewLine
    Write-Host "Hello " -ForegroundColor DarkYellow -NoNewline
    Write-Host $env:USERNAME -NoNewline
    Write-Host ", this script is to validate XML files ONLY.   " -ForegroundColor DarkYellow -NoNewline
    Write-Host "   * " -ForegroundColor Cyan
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#* " -ForegroundColor Cyan 
    Write-Host ""
    Write-Host ""
}

Print-ScriptTitle;
$Path = (Prompt-User -Message "Please enter valid Xml Files Path" -Hint "C:\Temp" -IsRequired).ToString();

#Validate File Path
If (([string]::IsNullOrEmpty($Path)) -or (!(Get-DirectoryExists $Path)))
{
    WriteLine "$Path does not exist. Please try again later." -MessageType 2;
    exit;
} 
Get-ChildItem $Path -Filter *.xml |
foreach {
    WriteLine "Please wait, Validating $_ ..."
    If (Test-XMLFile $_.FullName) {
        WriteLine "$_ is Valid." -MessageType 3
    } else {
        WriteLine "$_ is NOT valid." -MessageType 2
    }
}

Print-ScriptCompleted "Validation";