Clear

Write-Host ""
Write-Host "********************************************************************" -ForegroundColor Green
Write-Host "*** Search and Replace Config Files - Script by KIRAN KURAPATY   ***" -ForegroundColor Green
Write-Host "********************************************************************" -ForegroundColor Green
Write-Host ""

$environment = (Read-Host "[REQUIRED] Which Environment ?").ToString().ToUpper();
$updateFile = (Read-Host "[REQUIRED] Do you want to update existing file [Y/N] ").ToString().ToUpper();
$fileExtension = (Read-Host "[REQUIRED] File extension [ex - xml] ").ToString().ToLower();
$searchPath = (Read-Host "[REQUIRED] Search Full Path [ex - C:\Temp\Config\] ").ToString().Trim();

# Create TEMP Folder
$DATE_FORMAT=Get-Date -Format "yyyyMMdd"
$tempDir = "C:\TEMP\$DATE_FORMAT"
if (!(Test-Path $tempDir)) {
    Write-Host "Creating $tempDir ..."
    New-Item $tempDir -ItemType Directory |Out-Null 
}

# Please make sure to enter correct details as below format
# Old Fomat = New Format
if ($environment.Equals("LOCAL")) {
    $SearchPatterns = @{
       "this" = "that";
       "here" = "there";
       "now" = "later";
       };
} elseif ($environment.Equals("UAT")) {    
    $SearchPatterns = [ordered] @{ 
        "127.0.0.1" = "01.02.03.04";
        "192.168.0.1" = "11.22.33.44";        
        };
} elseif ($environment.Equals("PROD")) {
    $SearchPatterns = @{
        "PRD1" = "PROD01";
        };
 }

  # foreach($pattern in $SearchPatterns.Keys | Sort-Object -Property Key) {
  <# foreach($pattern in $SearchPatterns.Keys) {
        Write-Host "[DEBUG] Searching $pattern => $($SearchPatterns[$pattern])" -ForegroundColor Gray
        }
    exit;
   #>


 $excluded = @("*Archived*", "*Backup*", "*AppConfig*");
 <#
 $files = Get-ChildItem -Path $searchPath -Recurse -include "*.$fileExtension" -Exclude $excluded | %{ 
    $allowed = $true
    foreach ($exclude in $excluded) { 
        if ((Split-Path $_.FullName -Parent) -ilike $exclude) { 
            $allowed = $false
            break
        }
    }
    if ($allowed) { $_ }
} | Select-String -Path $_.FullName -Pattern $searchPatterns.Keys | select -ExcludeProperty FullName
 #>
 $files = Get-ChildItem -Path $searchPath -Recurse -include "*.$fileExtension"
 
 $fileCount = 0;
 $totalFiles = 0;
 foreach ($file in $files) 
 {
     $totalFiles++;
     Write-Host "Processing $file ..." -ForegroundColor Yellow
     # Load Content
     $content = Get-Content $file -Raw

     # Find and Replace
     foreach($pattern in $SearchPatterns.Keys) {
        Write-Host "[DEBUG] Searching $pattern => $($SearchPatterns[$pattern])" -ForegroundColor Gray
        $content = $content -replace "(?i)$pattern", $($SearchPatterns[$pattern])
     }

     # Create New or Update existing
     if ($updateFile -like "Y") {
        Set-Content -Value $content -Path $file -Force
        Write-Host "[INFO] Updated : $file" -ForegroundColor Yellow
        $fileCount++
     } else {
        $tempPath = "$tempDir\$($file | Split-Path -Leaf)"
        Add-Content -Value $content -Path $tempPath -Force
        Write-Host "[INFO] Created : $tempPath" -ForegroundColor Yellow
        $fileCount++
     }
 }
 
Write-Host "$fileCount out of $totalFiles Files Updated Successfully." -ForegroundColor Green