
<# 
    Function to remove all empty directories under the given path.
    If -DeletePathIfEmpty is provided the given Path directory will also be deleted if it is empty.
    If -OnlyDeleteDirectoriesCreatedBeforeDate is provided, empty folders will only be deleted if they were created before the given date.
    If -OnlyDeleteDirectoriesNotModifiedAfterDate is provided, empty folders will only be deleted if they have not been written to after the given date.
#>

function Remove-EmptyDirectories([parameter(Mandatory)][ValidateScript({Test-Path $_})][string] $Path, [switch] $DeletePathIfEmpty, [DateTime] $OnlyDeleteDirectoriesCreatedBeforeDate = [DateTime]::MaxValue, [DateTime] $OnlyDeleteDirectoriesNotModifiedAfterDate = [DateTime]::MaxValue, [switch] $OutputDeletedPaths, [switch] $WhatIf)
{
    Get-ChildItem -Path $Path -Recurse -Force -Directory | Where-Object { (Get-ChildItem -Path $_.FullName -Recurse -Force -File) -eq $null } | 
        Where-Object { $_.CreationTime -lt $OnlyDeleteDirectoriesCreatedBeforeDate -and $_.LastWriteTime -lt $OnlyDeleteDirectoriesNotModifiedAfterDate } | 
        ForEach-Object { if ($OutputDeletedPaths) { Write-Output $_.FullName } Remove-Item -Path $_.FullName -Force -WhatIf:$WhatIf }

    # If we should delete the given path when it is empty, and it is a directory, and it is empty, and it meets the date requirements, then delete it.
    if ($DeletePathIfEmpty -and (Test-Path -Path $Path -PathType Container) -and (Get-ChildItem -Path $Path -Force) -eq $null -and
        ((Get-Item $Path).CreationTime -lt $OnlyDeleteDirectoriesCreatedBeforeDate) -and ((Get-Item $Path).LastWriteTime -lt $OnlyDeleteDirectoriesNotModifiedAfterDate))
    { if ($OutputDeletedPaths) { Write-Output $Path } Remove-Item -Path $Path -Force -WhatIf:$WhatIf }
}

# Function to remove all files in the given Path that were created before the given date, as well as any empty directories that may be left behind.
function Remove-FilesCreatedBeforeDate([parameter(Mandatory)][ValidateScript({Test-Path $_})][string] $Path, [parameter(Mandatory)][DateTime] $DateTime, [switch] $DeletePathIfEmpty, [switch] $OutputDeletedPaths, [switch] $WhatIf)
{
    Get-ChildItem -Path $Path -Recurse -Force -File | Where-Object { $_.CreationTime -lt $DateTime } | 
		ForEach-Object { if ($OutputDeletedPaths) { Write-Output $_.FullName } Remove-Item -Path $_.FullName -Force -WhatIf:$WhatIf }
    Remove-EmptyDirectories -Path $Path -DeletePathIfEmpty:$DeletePathIfEmpty -OnlyDeleteDirectoriesCreatedBeforeDate $DateTime -OutputDeletedPaths:$OutputDeletedPaths -WhatIf:$WhatIf
}

# Function to remove all files in the given Path that have not been modified after the given date, as well as any empty directories that may be left behind.
function Remove-FilesNotModifiedAfterDate([parameter(Mandatory)][ValidateScript({Test-Path $_})][string] $Path, [parameter(Mandatory)][DateTime] $DateTime, [switch] $DeletePathIfEmpty, [switch] $OutputDeletedPaths, [switch] $WhatIf)
{
    Get-ChildItem -Path $Path -Recurse -Force -File | Where-Object { $_.LastWriteTime -lt $DateTime } | 
	ForEach-Object { if ($OutputDeletedPaths) { Write-Output $_.FullName } Remove-Item -Path $_.FullName -Force -WhatIf:$WhatIf }
    Remove-EmptyDirectories -Path $Path -DeletePathIfEmpty:$DeletePathIfEmpty -OnlyDeleteDirectoriesNotModifiedAfterDate $DateTime -OutputDeletedPaths:$OutputDeletedPaths -WhatIf:$WhatIf
}

CLS
# Show help if required
Write-Host "****************************************************************** " -ForegroundColor Cyan
Write-Host "*        Delete Files / Folders Older than 'n' Days              * " -ForegroundColor Cyan 
Write-Host "*           PowerShell script by Kiran Kurapaty                  * " -ForegroundColor Cyan
Write-Host "****************************************************************** " -ForegroundColor Cyan
Write-Host " "

# Get required parameters
$FilePath = (Read-Host "Please provide full Path ").ToString().Trim();
$Filter = (Read-Host "File Filter (ex: *.log) ").ToString().ToLower();
$DeleteEmptyFolders = (Read-Host "Do wish to delete empty folders [Y/N] ").ToString().ToUpper();
$DaysToKeep = (Read-Host "Delete files older than xx days ").ToString();


Write-Host " Please verify below details carefully " -ForegroundColor Yellow
Write-Host "............................................................................................."
Write-Host " Delete Files from Path - $FilePath"
Write-Host " Delete older than Days - $DaysToKeep"
Write-Host " Delete Empty Folders   - $DeleteEmptyFolders"
Write-Host "............................................................................................."
Write-Host " You are about DELETE files/folders, which is UNDOABLE." -ForegroundColor Red
Write-Host " Please terminate by pressing [Ctrl + C] if you are not sure or do not want to proceed." -ForegroundColor Yellow
Write-Host ""
$CHOICE = (Read-Host "Are you sure to continue? [Y/N] " ).ToString().ToUpper();
if ($CHOICE -like "N") { exit(1); }

Write-Host "Please wait, whilst $FilePath is being cleaned..."
# Write-Host "[INFO] Delete all files created more than 2 days ago."
# Remove-FilesCreatedBeforeDate -Path "$FilePath" -DateTime ((Get-Date).AddDays(-$DaysToKeep)) -DeletePathIfEmpty

# Write-Host "[INFO] Delete all files that have not been updated in 8 hours."
# Remove-FilesNotModifiedAfterDate -Path "C:\Another\Directory" -DateTime ((Get-Date).AddHours(-8))

# Write-Host "[INFO] Delete a single file if it is more than 30 minutes old.£
# Remove-FilesCreatedBeforeDate -Path "C:\Another\Directory\SomeFile.txt" -DateTime ((Get-Date).AddMinutes(-30))

# Write-Host "[INFO] Delete all empty directories in the Temp folder, as well as the Temp folder itself if it is empty.£
# Remove-EmptyDirectories -Path "C:\SomePath\Temp" -DeletePathIfEmpty

# Write-Host "[INFO] Delete all empty directories created BEFORE Jan 1, 2018 3PM."
# Remove-EmptyDirectories -Path "C:\SomePath\WithEmpty\Directories" -OnlyDeleteDirectoriesCreatedBeforeDate ([DateTime]::Parse("Jan 1, 2018 15:00:00"))

# Write-Host "[INFO] See what files and directories would be deleted if we ran the command."
# Remove-FilesCreatedBeforeDate -Path "C:\SomePath\Temp" -DateTime (Get-Date) -DeletePathIfEmpty -WhatIf

# Write-Host "[INFO] Delete all files and directories in the Temp folder, as well as the Temp folder itself if it is empty, and output all paths that were deleted."
# Remove-FilesCreatedBeforeDate -Path "C:\SomePath\Temp" -DateTime (Get-Date) -DeletePathIfEmpty -OutputDeletedPaths

Write-Host "**** Process Completed Successfully. *****" -ForegroundColor Green