CLS
## MAKE SURE TO ADD BELOW TO YOUR SCRIPT ##
. "$PSScriptRoot\fileIOUtil.ps1" -Force
#END OF USAGE

function Print-ScriptTitle() {
    Clear
    Write-Host "" -ForegroundColor Cyan
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#* " -ForegroundColor Cyan
    Write-Host "* " -ForegroundColor Cyan -NoNewLine
    Write-Host " PurgeFilesOlderThan "  -NoNewline
    Write-Host " -PowerShell script by " -ForegroundColor Gray -NoNewline
    Write-Host "KIRAN KURAPATY " -ForegroundColor Green -NoNewline
    Write-Host "     * " -ForegroundColor Cyan
    Write-Host "* " -ForegroundColor Cyan -NoNewLine
    Write-Host "Hello " -ForegroundColor DarkYellow -NoNewline
    Write-Host $env:USERNAME -NoNewline
    Write-Host ", this script will delete without UNDO option. " -ForegroundColor DarkYellow -NoNewline
    Write-Host "   * " -ForegroundColor Cyan
    Write-Host "* " -ForegroundColor Cyan -NoNewLine
    Write-Host "    Make sure you are 100% sure to run this at your own risk.  " -ForegroundColor Yellow -NoNewline
    Write-Host " * " -ForegroundColor Cyan  
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#* " -ForegroundColor Cyan 
    Write-Host ""
    Write-Host ""
}
function Prompt-LocalPath([string] $title)
{
    $path = $null; $repeat = $true;
    do {
        $path = (Prompt-User -Message "Please enter $title Path" -Hint "C:\Temp\Logs\" -IsRequired).ToString().Trim();
        $repeat = (Get-DirectoryExists $path);
        if (!$repeat) {
            WriteLine "$path Invalid path or does not exist." -MessageType 2
        }
    } while (!$repeat);
    return $path;
}

function DeleteFilesOlderThan([parameter(Mandatory)][ValidateScript({Test-Path $_})][string] $Path, [string] $Filter, [parameter(Mandatory)][DateTime] $DateTime, [switch] $OutputDeletedPaths, [switch] $WhatIf)
{
    Get-ChildItem -Path $Path -Recurse -Force -Filter $Filter -File | Where-Object { $_.LastWriteTime -lt $DateTime } | 
	ForEach-Object { if ($OutputDeletedPaths) { WriteLine $_.FullName } Remove-Item -Path $_.FullName -Force -WhatIf:$WhatIf }
}

function ArchiveFilesOlderThan([parameter(Mandatory)][ValidateScript({Test-Path $_})][string] $Path, [string] $Filter, [string] $TargetPath, [parameter(Mandatory)][DateTime] $DateTime, [switch] $OutputArchivedPaths, [switch] $WhatIf)
{
    Get-ChildItem -Path $Path -Filter $Filter -Force -Recurse -File | Where-Object { $_.LastWriteTime -lt $DateTime } | 
    ForEach-Object { 
        $fileDate = $_.LastWriteTime.ToShortDateString();
        $monthFolder = Get-Date $fileDate -Format "yyyy\\MM-MMM";
        $newFolder = Get-Date $fileDate -Format "dd.MMM.yyyy";
        $destPath = "$TargetPath\$monthFolder\$newFolder";
        if (!$WhatIf) { ForceDirectories $destPath }
        # if (!(Test-Path $destPath)) { New-Item -ItemType Directory -Path $destPath -WhatIf:$WhatIf }
        
        if ($OutputArchivedPaths) { WriteLine $_.FullName }    
        Move-Item $_.FullName $destPath -Force -WhatIf:$WhatIf        
    }
}

Clear;

Print-ScriptTitle;

$USER_ACTION = (Prompt-User "What do you want to perform" -Hint "ARCHIVE/DELETE" -IsRequired -IsQuestion).ToString().ToUpper();
$Path = Prompt-LocalPath "Cleanup"
$Filter = (Prompt-User "Please enter filter" -Hint "*.log" -IsRequired).ToString();
$DateTime = (Prompt-User "Please enter date you want to $USER_ACTION files older than" -Hint "30-Oct-2019" -IsRequired).ToString();

$TargetPath = $null;

if ([string]::IsNullOrEmpty($USER_ACTION)) {
    WriteLine "You must mention what you want to do. Please try again later" -MessageType 2;
    Exit;
}
If (! "ARCHIVE DELETE" -contains $USER_ACTION) {
    WriteLine "Unable to read your intent. Please try again later" -MessageType 2;
    Exit;
}
if ([string]::IsNullOrEmpty($Filter))  { $Filter = "*.log"; }

if ($USER_ACTION -like "ARCHIVE")
{
    $TargetPath = Prompt-LocalPath "Archive"
}
$TEST_MODE = (Prompt-User "Do you want to test $USER_ACTION first" -Hint "Y/N" -IsRequired -IsQuestion).ToString().ToUpper();

if ($TEST_MODE -like "Y") {
    If ($USER_ACTION -eq "DELETE") {
        DeleteFilesOlderThan -Path $Path -Filter $Filter -DateTime $DateTime -OutputDeletedPaths -WhatIf
    } elseIf ($USER_ACTION -eq "ARCHIVE") {
        ArchiveFilesOlderThan -Path $Path -Filter $Filter -TargetPath $TargetPath -DateTime $DateTime -OutputArchivedPaths -WhatIf
    }
} elseif ((Prompt-User "Are you ready to see $USER_ACTION in action now" -Hint "Y/N" -IsRequired -IsQuestion).ToString().ToUpper() -like "Y")
{
    If ($USER_ACTION -eq "DELETE") {
        DeleteFilesOlderThan -Path $Path -Filter $Filter -DateTime $DateTime -OutputDeletedPaths
    } elseIf ($USER_ACTION -eq "ARCHIVE") {
        ArchiveFilesOlderThan -Path $Path -Filter $Filter -TargetPath $TargetPath -DateTime $DateTime -OutputArchivedPaths
    }
}


Print-ScriptCompleted "Cleanup";
