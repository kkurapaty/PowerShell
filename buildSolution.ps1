#=================================================================================================
# Build .Net Solution
# Author: Kiran Kurapaty
# Copyright (c) Kiran Kurapaty
#=================================================================================================

CLS
#region - Script Methods -

function BuildSolution($solutionFileName)
{
    # C:\"Program Files (x86)"\"Microsoft Visual Studio"\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe 
    # "NetSolution.sln" 
    # "/target:Clean;Build"

    #$pfDir = Get-Item 'Env:\ProgramFiles(x86)' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Value
        
    $MS_BUILD = "C:\`"Program Files (x86)`"\`"Microsoft Visual Studio`"\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe";        
    $args = "`"{0}`" `"/target:Clean;Build`"" -f $solutionFileName    
    
    Write-Host "[INFO] Please wait, Building $solutionFileName ..." 
    Invoke-Expression "$MS_BUILD $args"
}
#endregion

#region - Helper Methods -
function Print-ScriptTitle() {
    Write-Host "" -ForegroundColor Cyan
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#* " -ForegroundColor Cyan
    Write-Host "*       " -ForegroundColor Cyan -NoNewLine
    Write-Host " Build .NET Solution "  -NoNewline
    Write-Host " -PowerShell script by " -ForegroundColor Gray -NoNewline
    Write-Host " KIRAN KURAPATY  " -ForegroundColor Green -NoNewline
    Write-Host "  * " -ForegroundColor Cyan
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#* " -ForegroundColor Cyan
    Write-Host ""
    Write-Host ""
    Write-Host ""
}
#endregion

Print-ScriptTitle;
# Get required parameters
$BRANCH=(Read-Host "Which BRANCH? ").ToString().Trim();
$SolutionName = (Read-Host "Which Solution? ").ToString().Trim();
$ENV=(Read-Host "Which ENV? ").ToString().ToUpper().Trim();


Clear;
Print-ScriptTitle;

$DATE_FORMAT=Get-Date -Format "yyyyMMddTHHmmss"

if ([string]::IsNullOrEmpty($BRANCH)) { $BRANCH="master"; }

# Machine Specific Settings
$BRANCH_DIR="C:\Branches\$BRANCH"

# :: Branch Specific Settings
$WORKING_DIR="$BRANCH_DIR\"
try {
    # Make sure we have existing branch
    If (!(Test-Path $WORKING_DIR)) {
	    Write-Host "[WARN] $WORKING_DIR Does not exists. " -ForegroundColor Yellow;
	    Write-Host "[INFO] Please make sure you have project directory exists and try again." -ForegroundColor Yellow;
	    exit(1);
    }

    If (FileExists "$WORKING_DIR\$SolutionName.sln")
    {
        BuildSolution "$WORKING_DIR\$SolutionName.sln"
    }    
}
catch [Exception] 
{    
    Write-Error $Error[0]
	$err = $_.Exception
	while ( $err -ne $null ) 
    {
		$err = $err.InnerException
		Write-Host "[ERROR] $($err.Message)" -ForegroundColor Red
	}
    Write-Error $StackTrace;
}   

# Output Status
Write-Host "[INFO] Build Completed."
