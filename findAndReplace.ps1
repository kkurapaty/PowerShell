
<#
    You can run simple command to see find text in a file
    Command: Dir Path -Include *.xml, *.config -Recurse | Select-String find1, find2, find3

    Example: Dir C:\Config -I *.xml, *.config -R | Select-String SSL.SVRCONN
#>


$Path = "C:\\Config\"; # "D:\Deploy\Code\UAT02\Enterprise\";
$find = 'ebplqm1';
$replace = 'DEV01';
$filter = '*.xml';


$files = Get-ChildItem -Path $Path -Filter $filter -Recurse -File;

function FindString([String] $find)
{
    try 
    {
        Write-Host "Please wait, Finding text $find ..."
        foreach($file in $files)
        {    
            $matches = Select-String -Path $($file.FullName) -Pattern $find -AllMatches;

            foreach($match in $matches)
            {
                Write-Host $match
            }
        }
        Write-Host "Find Completed."
    }
    catch 
    {
        Write-Error $_.Exception.Message;
    }
}

function ReplaceString([String] $find, [String] $replace)
{
    try
    {
        Write-Host "Please wait, Replacing $find with $replace ..."
        foreach($file in $files)
        {
            $filePath = $($file.FullName);    
            $tempFilePath = "$env:TEMP\$($filePath | Split-Path -Leaf)"
        
            $matches = Select-String -Path $filePath -Pattern $find -AllMatches;
            if ($matches -ne $null)
            {
                (Get-Content -Path $filePath) -replace $find, $replace | Add-Content -Path $tempFilePath -Encoding UTF8;
            
                Write-Host "Updating File $filePath"
                Remove-Item -Path $filePath
                Move-Item -Path $tempFilePath -Destination $filePath
            }
        }
        Write-Host "Replace Completed."
    }
    catch 
    {
        Write-Error $_.Exception.Message;
    }
}

Cls

FindString $find

# ReplaceString $find $replace