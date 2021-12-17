#*******************************************************************
# List all instances of an executable with their version
# Author: Kiran Kurapaty
# Dated: 16 Dec 2021
# Copyright (c) 2021 Kiran Kurapaty
#*******************************************************************

function SearchFiles($path, $filter) {
    Write-Host "Please wait, checking ..." -ForegroundColor Yellow;
    if (!(Test-Path $path)) {
        Write-Host "[ERROR]: Invalid path or directory does not exists. $path" -ForegroundColor Red;
        Return;
    }

    $items = Get-ChildItem $path -Filter "*.exe" -Inclue $filter -Recurse -Force;
    [int] $counter= 0;
    foreach ($file in $items) {
        if ($file -eq $null) { Continue; }

        $counter++;
        [string]$fileName = $file.FullName;
        #Show Progress
        Write-Progress -Activity "Please Wait, Checking ..." -Status $fileName -PercentComplete ($counter/$items.Count * 100)

        if (($fileName.ToLower().EndsWith(".exe")) -or ($fileName.ToLower().EndsWith(".dll"))) {
            $fileVersionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($file.FullName);
            $fileVersionInfo
        } else {
            Write-Host "Not a valid executable or library. $fileName";
        }
    }
    Write-Host "";
    Write-Host ("Found ({0}) files" -f $counter) -ForegroundColor Yellow
}

Clear;
$Path = (Read-Host "Please provide path: ").Trim();
$Filter = @("nunit.exe", "nunitconsole.exe");

SearchFiles $Path $Filter