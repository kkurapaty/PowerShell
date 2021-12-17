#=================================================================================================
# Backup SQL Server Database
# Author: Kiran Kurapaty
# Copyright (c) Kiran Kurapaty
#=================================================================================================
Clear
Write-Host "[$(Get-Date)] *********************************************" -ForegroundColor Green
Write-Host "[$(Get-Date)] * THIS IS A TEST SCRIPT TO BACKUP DATABASE  *" -ForegroundColor Green
Write-Host "[$(Get-Date)] *********************************************" -ForegroundColor Green
Write-Host

function BackupDatabase
{
param ( [string] $Env = $(throw "Environment is required."),
        [string] $BackupTitle = $(throw "Backup title is required."), 
        [string] $SqlServerInstance = $(throw "SqlServerInstance parameter is required."), 
        [string] $ErrorFile = $null
    )
    # Databases to backup
    $DatabaseNames = @("Database1", "Database2");
    
    $ErrorActionPreference = "Stop"
    $backupFolder = "DEV"
    $hostName = "localhost"; # Update Backup HostName

    if ($Env -eq "UAT") { $backupFolder = "UAT"; }
    if ($Env -eq "PROD") { $backupFolder = "Release"; }

    foreach($DatabaseName in $DatabaseNames)
    {
        $timeStamp = Get-Date -format "yyyyMMddHHmmss"
        $backupName="{0}_{1}_{2}.bak" -f $DatabaseName, $BackupTitle, $timeStamp

        $location = "\\$hostName\Backups\{0}\{1}" -f $backupFolder, $backupName
    
        Write-Host "[$(Get-Date)] Please verify, Database: $DatabaseName at $SqlServerInstance"
        Write-Host "[$(Get-Date)] Backup file be created as => $location"
        Write-Host 
        $userOk = Read-Host "Are you sure want to perform $DatabaseName DB Backup? [Y/N] "
    
        if ($userOk -like "Y")
        {
            Write-Host "[$(Get-Date)] Please Wait, $DatabaseName DB backup initiated ..."
            # $out = SQLCMD -b -E -S $SqlServerInstance -Q "BACKUP DATABASE [$DatabaseName] TO DISK='$location' WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD, STATS=10"
            Write-Output $out
            $outSplit = $out -split ' '
            
            if ($ErrorFile) { Set-Content $ErrorFile $out }

            if ($outSplit -contains 'Msg' -and $outSplit -contains 'Level' -and $outSplit -contains 'State')
            {
                Write-Host [$(Get-Date)] $outSplit -ForegroundColor Red
                Write-Host $_
                Exit 1
            }
            Write-Host "[$(Get-Date)] $DatabaseName backup Completed." -ForegroundColor Green
        } else {
            Write-Host "[$(Get-Date)] User changed mind, not to backup $DatabaseName DB." -ForegroundColor Yellow
        }
    }
 }

 BackupDatabase -Env "UAT" -BackupTitle "C1234567" -SqlServerInstance "SQLSERVER\UAT" 
                             