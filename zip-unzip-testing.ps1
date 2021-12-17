Clear
Write-Host "[$(Get-Date)] *******************************************************" -ForegroundColor Green
Write-Host "[$(Get-Date)] THIS IS A TEST SCRIPT TO CHECK ZIP AND UNZIP METHODS  *" -ForegroundColor Green
Write-Host "[$(Get-Date)] *******************************************************" -ForegroundColor Green


$global:WorkingDir = "C:\CAM\Subversion\infrastructure\Deployment\TeamCity"
Import-Module "$global:WorkingDir\common.ps1" -Force
Import-Module "$global:WorkingDir\CAM_Hosts.ps1" -Force
$Global:LoggingEnabled = $true

$sourceFolder = "C:\CAM\Subversion\branches\ReleaseCandidate\Shared\Components\node_modules"
$zipFileName = "C:\Temp\Enterprise\node_modules.zip"
$outFilePath = "C:\Temp\Enterprise\Shared\Components\"

if (Test-Path $sourceFolder)
{
    $UserOK = Read-Host -Prompt "[$(Get-Date)] Are you sure want to ZIP node_modules? [Y/N] "
    if ($UserOK -like "Y")
    {
        Write-Host "[$(Get-Date)] Zipping $sourceFolder to $zipFileName"
        Archive-Zip -Target $zipFileName -Source $sourceFolder -Force
       # ZipFiles $zipFileName $sourceFolder
        Write-Host "[$(Get-Date)] Zipped."
    }
}
Write-Host "[$(Get-Date)] Checking target for existing files..."
$count = Get-FileCount $outFilePath\node_modules
if ($count -lt 104267)
{
    if (Test-Path $zipFileName -PathType Leaf)
    {
        $UserOK = Read-Host -Prompt "[$(Get-Date)] Are you sure want to UNZIP node_modules ? [Y/N] "
        if ($UserOK -like "Y")
        {            
            ForceDirectories $outFilePath
            CleanFolders -Path $outFilePath\node_modules 
            Write-Host "[$(Get-Date)] Extracting $zipFileName to $outFilePath"            
            Expand-ZipFile -FilePath $zipFileName -OutputPath $outFilePath -Force                                  
            $count = Get-FileCount -Directory $outFilePath\node_modules
            Write-Host "[$(Get-Date)] Extracted $count items from node_modules.zip."
        }
    }
}
else {
    Write-Host "[$(Get-Date)] $outFilePath has $count items."
}

Write-Host "[$(Get-Date)] Completed." -ForegroundColor Green