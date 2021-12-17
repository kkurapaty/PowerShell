CLS
# Show help if required
Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#* " -ForegroundColor Magenta
Write-Host "*#      " -ForegroundColor Magenta -NoNewLine
Write-Host " Search Files / Folders Older than 'n' Days  " -ForegroundColor Cyan -NoNewLine
Write-Host "            #* " -ForegroundColor Magenta 
Write-Host "*#         " -ForegroundColor Magenta -NoNewline
Write-Host " PowerShell script by" -ForegroundColor Gray -NoNewline
Write-Host " KIRAN KURAPATY " -ForegroundColor Green -NoNewline
Write-Host "                 #* " -ForegroundColor Magenta
Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#* " -ForegroundColor Magenta
Write-Host " "

# Get required parameters
$FilePath = (Read-Host "Please provide full Path ").ToString().Trim();
$Filter = (Read-Host "File Filter (ex: *.log) ").ToString().ToLower();
$DaysToKeep = (Read-Host "How old file are ? (ex: days)").ToString();

Write-Host ""
# Validate User Input
if ([string]::IsNullOrEmpty($FilePath)) { Write-Host "You need to provide valid file path." -ForegroundColor Red; Exit; }
if ([string]::IsNullOrEmpty($Filter)) { $Filter="*"; }
if ([string]::IsNullOrEmpty($DaysToKeep)) { $DaysToKeep=2; }

# Prepare Possible Output
$DateTime = ((Get-Date).AddDays(-$DaysToKeep));
Write-Host "Please wait, whilst $FilePath is being searched..." -ForegroundColor Yellow
Write-Host ""
Write-Host "`tCreated On `t`t`t Last Modified `t`t`t File Name"
Write-Host "----------------------------------------------------------------------------------------------"

# Search for files based on user provided conditions
Get-ChildItem -Path $FilePath\$Filter -Recurse -Force -File | Where-Object { $_.CreationTime -ge $DateTime -or $_.LastWriteTime -ge $DateTime } | 
		ForEach-Object { Write-Host $_.CreationTime `t $_.LastWriteTime `t $_.FullName } 

Write-Host " "
Write-Host "**** Process Completed Successfully. *****" -ForegroundColor Green