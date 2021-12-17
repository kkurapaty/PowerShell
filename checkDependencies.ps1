#=================================================================================================
#
# Verify all project dependencies including 3rdParty/NuGet packages from a specified Path
# Author: Kiran Kurapaty
# Dated: 01 Dec 2021
# Copyright (c) Kiran Kurapaty
#
#=================================================================================================

# Comment below if you are debugging
Param(
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [string] $Path = $null,
        [string] $Exclude = $null,
        [switch] $ShowReport = $true,
        [switch] $ShowGrid = $false
    )

#$ErrorActionPreference = 'Continue';

# Constant Declarations 
[System.Collections.ArrayList] $keywords = @("HintPath");
[System.Collections.ArrayList] $excluded = @("PostBuildEvent", "Import Project");
[System.Collections.ArrayList] $excludedFolders = @("Debug", "Release");

# Customise below as per your requirements
[string] $displayType = "Invalid";
[string] $filter = $null;

# Constraint Check
if ([string]::IsNullOrEmpty($Path)) {
    $Path = (Read-Host "Please provide path of your working directory [ex: C:\Dev\] ").Trim();
}

if ($Exclude -ne $null) {
    $excl = $Exclude -split ","
    foreach($str in $excl) {
        [void]$excluded.Add($str);
    }
}

# Custom Structure
$myFileInfo = @{
    TypeName      = $null
    LineNumber    = $null
    ProjectName   = $null
    LibraryName   = $null
    SuggestedPath = $null
    IsValid       = $null
};

trap {
    Write-Host "[ERROR]: Unhandled error has occured on line $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    Write-Error $_
}

function GetCurrentDirectory() {
    $path = $PSScriptRoot;
    Write-Host "Using PSScriptRoot: $path" -ForegroundColor Gray
    if ([string]::IsNullOrEmpty($path)) {
        $path = $PSCommandPath;
        Write-Host "Using PSCommandPath: $path" -ForegroundColor Gray
    }
    elseif ([string]::IsNullOrEmpty($path)) {
        $path = $MyInvocation.MyCommand.Path;
        Write-Host "Using MyCommandPath: $path" -ForegroundColor Gray
    }
    elseif ([string]::IsNullOrEmpty($path)) {
        $path = $PWD;
        Write-Host "Using PWD: $path" -ForegroundColor Gray
    }
    return $path;
}

function ResolvePath($lhs, $rhs) {
    $relativePath = [System.IO.Path]::Combine($lhs, $rhs);
    $path = [System.IO.Path]::GetFullPath($relativePath);
    return $path;
}

function ParseLine($file, [string]$xmlTag) 
{
    Write-Host ("[DEBUG]: {0}" -f $file.Path) -ForegroundColor DarkGray
    $result = New-Object PSObject -Property $myFileInfo;
    if ($file -ne $null) 
    {
        $result.ProjectName = $file.Path;
        $result.LineNumber = $file.LineNumber;

        #Write-Host ("[DEBUG]: {0}" -f $file.Line) -ForegroundColor DarkGray;

        if ($file.Line -match $xmlTag) {
            $result.TypeName = "Ref";
            $result.LibraryName = ($file.Line -replace "<$xmlTag>", "" -replace "</$xmlTag>", "").Trim();
        }
        elseif ($file.Line -match "Content Include") {
            $result.TypeName = "Content";
            $result.LibraryName = ($file.Line -replace "<Content Include=", "" -replace "\/\>", "" -replace '\"', "" ).Trim();
        }
        elseif ($file.Line -match "None Include") {
            $result.TypeName = "Package";
            $result.LibraryName = ($file.Line -replace "<None Include=", "" -replace "\/\>", "" -replace '\"', "" ).Trim();            
        }

        # remove any special unwanted characters from the path
        if  ($result.LibraryName) {
            $result.LibraryName = ($result.LibraryName -replace "`"", "" -replace "`<", "" -replace "`>", "" -replace ).Trim();
        }
        $result.SuggestedPath = $result.LibraryName;        
        $projPath = Split-Path -Path $result.ProjectName;
        if ($result.LibraryName[0] -ne '`\' -or $result.LibraryName[0] -ne '.') { $projPath += "`\"; }
        $result.LibraryName = ResolvePath $projPath $result.LibraryName;
        $result.IsValid = (Test-Path $result.LibraryName);
    }
    return $result;
}

function Validate-DependencyPath($matchItem)
{
    $fileInfo = ParseLine $matchItem "HintPath";

    if (!$fileInfo.IsValid)
    {
        $projectPath = Split-Path -Path $fileInfo.ProjectName;
        $libPath = "..`\" + $fileInfo.SuggestedPath;
        $absPath = "";
        $found = $false;
        # Search for exact file path match in upper levels
        for($num = 1; $num -le 5; $num++)
        {
            # Write-Host "Validation: Abs[$absPath], Lib[$libPath]"
            $absPath = ResolvePath $projectPath $libPath;
            if (Test-Path $absPath)
            {
                $fileInfo.SuggestedPath = $absPath;
                $found=$true;
                break;
            } else {
                $libPath = "..`\" + $libPath;
            }
        }
        if (!$found) 
        {
            # Search for matching file from project path
            $libPath = Split-Path $fileInfo.LibraryName -leaf
            $absPath = "`\..";

            for($num=1; $num -le 5; $num++)
            {
                $files = Get-ChildItem ("{0}{1}" -f $projectPath, $absPath) -Filter $libPath -Recurse -Depth 4 -File;
                if ($files -ne $null)
                {
                    $fileInfo.SuggestedPath = ($files | Select-Object FullName | Out-String).Trim();
                    $found = $true;
                    break;
                }
                $absPath += "`\.."
            }
        }

        if (!$found) { $fileInfo.SuggestedPath = "File not found!"; }
    }
    return $fileInfo;
}

function Display-Summary([System.Collections.ArrayList] $items, [int] $projCounter, [int] $counter)
{
    [int] $validCount = $items.Count;
    if ($displayType -match "Invalid") {
        $items = $items | ? { $_.IsValid -ne $true }
    }
    elseif ($displayType -match "Valid") {
        $items = $items | ? { $_.IsValid -eq $true }
    }
    if ($filter -ne $null) {
        $items = $items | ? { $_.ProjectName -match $filter -or $_.LibraryName -match $filter };
    }

    $items | Select -Property IsValid, ProjectName, LibraryName, SuggestedPath, LineNumber | Sort-Object ProjectName | Format-List -GroupBy ProjectName
    if ($ShowGrid) {
        $items | Out-GridView; # Select -Property IsValid, ProjectName, LibraryName, SuggestedPath, LineNumber | Sort-Object ProjectName |
    }
    
    [int]$invalidCount = ($items | ? { $_.IsValid -ne $true }).Count;
    [int] $missingFilesCount = 0;
    if ($invalidCount -ne $null) { 
        $validCount = $validCount - $invalidCount; 
        $missingFilesCount = ($items | { $_.SuggestedPath -match "File Not Found!" }).Count;
    } else { 
        $invalidCount = 0; 
    }

    Write-Host ""
    Write-Host "**********************************************"
    Write-Host " Valid References    : " -NoNewline
    Write-Host $validCount -ForegroundColor Green
    Write-Host " Invalid References  : " -NoNewline
    Write-Host $invalidCount -ForegroundColor Red
    Write-Host " Missing References  : " -NoNewline
    Write-Host $missingFilesCount -ForegroundColor Red
    
    Write-Host " Verified Projects   : " -NoNewline
    Write-Host ("{0} / {1}" -f $projCounter, $counter) -ForegroundColor Cyan
    Write-Host "**********************************************"
    Write-Host ""

    Show-Report $items $validCount $invalidCount $missingFilesCount $projCounter $counter;
}

function Show-Report($items, [int]$validCount, [int] $invalidCount, [int] $missingFilesCount, [int] $projCounter, [int] $counter )
{
    if (-not $ShowReport) { return; }

    $head = @"
    <Title>Project Dependency Report</Title>
    <style>
        body { background-color: #FFFFFF; font-family:Segoe UI; font-size:12pt; }
        td,th { border:0.5px solid black; border-collapse: collapse; }
        th { color:white; background-color: black; }
        table, tr, td, th {padding:2px; margin:0px }
        tr:nth-child(odd) { background-color: lightgray; }
        table { width:95%;margin-left:5px; margin-bottom:20px; }
    </style>
    <br>
    <h1?Dependencies in $Path</h1>
"@
    $paramHash = @{
        Head = $head
        Title= "Project Dependency Report"
        Path = "C:\temp\depends.htm"
        Group= "ProjectName"
        As = "List"
        PreContent = "<div><b>Summary</b>
                        <ul>
                            <li><b>$($invalidCount)</b> out of $($validCount) References are <i>invalid</i>.</li>
                            <li><b>$($missingFilesCount)</b> missing files / references.</li>
                            <li><b>$($projCounter)</b> out of $($counter) projects has dependencies.</li>
                        </u>
                        </div"
        PostContent = "<h6>Generated on $(Get-Date) from <i>PowerShell</i> script by <b>Kiran Kurapaty</b></h6>"
        Properties = "LibraryName", "SuggestedPath", "IsValid", "LineNumber"
    }

    if ($ShowReport) {
        $items | Output-HtmlReport @paramHash
        Invoke-Item C:\temp\depends.htm
    }
}

function Check-Dependencies([string] $Path)
{
    Write-Host ("Search Path: {0}" -f $Path) -ForegroundColor Cyan
    Write-Host "Please wait, checking project dependencies & missing references ..." -ForegroundColor Yellow;

    $items = New-Object System.Collections.ArrayList;
    [int] $counter=0;
    [int] $projCounter = 0;
    $projects = Get-ChildItem $Path -Filter "*.csproj" -Recurse -Force;
    foreach($item in $projects)
    {
        $counter++;
        $nextProject = $true;
        $matchItems = Select-String -Path $($item.FullName) -Pattern $keywords -AllMatches |
                      Select-String -Pattern $excluded -NotMatch | Select Path, LineNumber, Line;

        # Show Progress
        Write-Progress -Activity "Please wait, validating..." -Status ("Project: {0}" -f $item.FullName) -PercentComplete ($counter / $projects.Count * 100)

        if ($matchItems) 
        {
            # Write-Host ("[DEBUG]: Processing {0} ..." -f $($item.FullName)) -ForegroundColor Gray;
            foreach($matchItem in $matchItems)
            {
                if ($matchItem.Line -ne $null)
                {
                    $obj = Validate-DependencyPath $matchItem;
                    #Write-Host ("[{0}] {1} (ln:{2}) {3} => {4}" -f $items.Add($obj), $obj.ProjectName, $obj.LineNumber, $obj.LibraryName, $obj.SuggestedPath);
                    [void] $items.Add($obj);
                    if ($nextProject) {
                        $projCounter++;
                        $nextProject=$false;
                    }
                }
            }
        }
    }
    Display-Summary $items $projCounter $counter;   
}

function Output-HtmlReport {
    #Reference: https://petri.com/create-a-grouped-html-report-with-powershell
    Param (
        [Parameter(Position=0,Mandatory,HelpMessage = "Enter the name of the report to create")]
        [ValidateNotNullorEmpty()]
        [string]$Path, 
        [string]$Group, 
        [ValidateNotNullorEmpty()]
        [string[]]$Properties="*", 
        [string]$CssUri, 
        [ValidateSet("Table","List")]
        [ValidateNotNullorEmpty()]
        [string]$As = "Table", 
        [string]$Title, 
        [string]$Head, 
        [string[]]$PreContent,
        [string[]]$PostContent,
        [Parameter(Position=1,Mandatory,ValueFromPipeline,
        HelpMessage="Enter objects to format")]
        [ValidateNotNullorEmpty()]
        [object[]]$InputObject
        )
        Begin {
            Write-Verbose "Starting $($myinvocation.mycommand)"
            #copy most of the bound parameters since they will
            #be passed to Convertto-HTML
            Write-verbose "PSBoundParameters"
            write-Verbose ($PSBoundParameters | out-string)
                
            #initialize an array to hold all the processed data
            $data=@()
            #iniatilize a variable for the HTML body
            [string[]]$body=@()
            $body+=$PreContent
        } #begin
        Process {
            #add each input object to $data
            foreach ($item in $Inputobject) {
                $data+=$item
            }
        } #process
        End {
            Write-Verbose "Processing $($data.count) objects"
            #sort on grouping property if used
            if ($Group) {
                Write-Verbose "Grouping on $Group"
                 $data | Group-Object -Property $Group |
                 Sort-Object -Property Name |
                 foreach {
                    $body+="<H2>$($_.Name)</H2>"
                    $body+= $_.Group | 
                    Select-Object -property $Properties -ExcludeProperty $Group |
                    ConvertTo-HTML -As $As -Fragment
                 } #foreach
            }
            else {
                Write-Verbose "No grouping"
                $body+= $data | 
                    Select-Object -property $Properties | 
                    ConvertTo-HTML -As $As -Fragment
            }
            #create the HTML
            $htmlParams = $PSBoundParameters
            #remove conflicting or unused parameters
            "InputObject","Path","Group","Properties",
            "PreContent","WhatIf","Confirm" | 
            foreach {
                $htmlparams.Remove($_) | out-null
            }
            #add body
            $htmlParams.Add("Body",$body)
            Write-Verbose "Using these Convertto-HTML parameters"
            Write-Verbose ($htmlParams | out-string)
            #create the HTML
            $html = ConvertTo-HTML @htmlParams
            #create the file
            $html | Out-File -filepath $Path -encoding ASCII
            Write-Verbose "Report created at $path"
            Write-Verbose "Ending $($myinvocation.mycommand)"
        } #end
}

Clear;

Check-Dependencies $Path;