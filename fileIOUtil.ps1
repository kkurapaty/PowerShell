#region Originating script: '.\fileIOUtil.ps1'
##################################################################################
##      Author: KIRAN KURAPATY - kkurapaty@gmail.com                ##
##      Dated: Monday, 29th October 2018                                        ##
##      Copyright (c) Kiran Kurapaty, London 2018  All rights reserved.     ##
##################################################################################
# This script must be loaded only on demand. Make sure test any changes you make #
##################################################################################
<## PLEASE NOTE THIS FILE MUST NOT HAVE ANY DEPENDENCIES ##>


## MAKE SURE TO ADD BELOW TO YOUR SCRIPT ##
# $Global:ScriptsDir = Split-Path "C:\CAM\Support\PowerShell";
# . "$PSScriptRoot\CAMEntCommon.ps1" -Force
#END OF USAGE


### USINGS ###
Add-Type -Assembly System.IO.Compression.FileSystem
# Add-Type -Assembly 

### END OF USINGS ###

#region Global Variables
$dateFormat = $(Get-Date).ToString('yyyyMMddTHHmmsss')
$Global:GlobalVerbose = $false;
$Global:LoggingEnabled = $false;
$Global:UserCredential = $null;
$Global:HasSCPermissions = $false;
$Global:LogFileName =  "{0}\CAM_{1}.log" -f $env:TEMP, $dateFormat;
$Global:ExclusionList = @("Archived", "Backup", "Archive")
$Global:DEBUG_LOG_FILE = "{0}\Transcript_{1}.log" -f $env:TEMP, $dateFormat; 
#endregion Global Variables

#region HTML / CSS TEMPLATE
$HTML_TEMPLATE = @"
<!DOCTYPE html>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
<meta name='author' content='Kiran Kurapaty'>
<meta name='viewport' content='width=device-width, initial-scale=1'>
<title><!--##EMAIL_HEADER##--></title>
<style type=`"text/css`">
    /* Client-specific Styles and Fixes */
    #outlook a {padding:0;} /* Force Outlook to provide a `"view in browser`" menu link. */
    body {width:100% !important; -webkit-text-size-adjust:100%; -ms-text-size-adjust:100%; margin:0; padding:0; line-height: 100% !important; }

    /*TABLET STYLES*/
    @media only screen and (max-width: 479px) { table[class=Responsive] {width: 100% !important; } }
    /*MOBILE STYLES*/
    @media only screen and (max-width: 479px) { table[class=Responsive] {width: 100% !important;} }

    *{ margin: 4px; padding: 2px; } 
    html, body { width: 99%; height: 100%; font-family: 'Segoe UI', Verdana, Tahoma, Sans-Serif; counter-reset: section;}
    
    h1,h2,h3,h4,h5 {font-family: 'Trebuchet MS', 'Segoe UI', Verdana, Tahoma, Sans-Serif; width:98%; margin-top:10px; padding: 3px;}
    h1,h2 {font-variant: small-caps; text-align: center;}
    h2 { color:blue; text-shadow: 1px 1px 2px white, 0 0 25px blue, 0 0 5px black;}
    h3 { color:#FFF; text-align:center; border: 1px solid #191970; border-radius:4px; background-color: blue; }
    h4 { color:#1E90FF; text-align:left; border-bottom: 1px solid red; }
    h5 { color:#b22222; text-align:left; border-bottom: 1px solid #b22222; }
    table {color:#000000; border:0.5px solid grey; valign:top; align:left; cellpadding:2px; cellspacing: 2px; font-size:0.8em; width:99%; border-collapse: collapse;}
    th, td { text-align:left; padding:5px; } 
    th { background: #444; color: #f5f5f5; }
    td.empty { border: none; height: 2.0em;}
    tfoot { background-color:#eee; text-align:justify; color:#434343; font-style:italic; valign:center; font-size:0.75em; }
    tbody tr:hover { background: DodgerBlue; color:white; }
    .header tr td {	background-color: #eee; color: #000; }
    .collapsible tr td { font-family: 'Consolas', 'Courier New'; padding: 2px; }
    .collapsible th { background: #eee; color: #434343; padding:2px; }
    .collapsible tr:hover { background: Yellow; color:red; }
    .label tr td label { display: block; cursor:pointer; }
	[data-toggle='toggle'] { display: none; }
    .right{ text-align:right; }
	.justify{ text-align:justify; }
    .center { text-align:center; }
    .numeric { text-align: right; }
    .italics { font-style:italic; }
    .bolder { font-style: bold; }
    .success { background-color: #228b22; color:white; }
    .failure { background-color: red; color:white; }
    .warning { background-color: orange; color:white; }
    .info { background-color: yellow; color:black; }
    .ignored { background-color: #ffff00; }
    .pending { background-color: #dd66ff; }
    .normal { }
    .success:hover { background-color: DodgerBlue; color:white; }
    .failure:hover { background-color: DodgerBlue; color:red; }
    .warning:hover { background-color: DodgerBlue; color:orange; }
    .info:hover { background-color: DodgerBlue; color:yellow; }

    .dot, .reddot, .amberdot, .greendot, .normaldot { height: 5px; width: 5px; background-color: #ccc; border-radius: 50%; display: inline-block; }
    .greendot { background-color:green; }
    .amberdot {background-color:#FF8C00; }
    .reddot {background-color:red; }
    .normaldot {background-color:#2f4f4f; }
	p.uppercase { text-transform: uppercase; }
	p.lowercase { text-transform: lowercase; }
	p.capitalize { text-transform: capitalize; }
	.justify { text-align: justify; font-family: 'Segoe UI'; width:98%; }
    .exception { text-align: justify; font-family: Consolas; width: 98%; color:red; word-wrap:break-word; }
    a:link { text-decoration: none; }	
    a:visited { color: tomato; }	
    a:hover { color: hotpink;}
    a:active { color: blue; }
    .footer { position: relative; right: 0; bottom: 0; left: 0; padding-top: 10px; padding-bottom: 10px; background-color: #f0f0f0; text-align: center; font-size: 8pt; text-color: #ccc;
        -webkit-user-select: none; /* Safari 3.1+ */
        -moz-user-select: none; /* Firefox 2+ */
        -ms-user-select: none; /* IE 10+ */
        user-select: none; /* Standard syntax */
    } 
    .tooltip { position: relative; display: inline-block; border-bottom: 0.5px dotted black; } 
    .comment { text-align: justify; color:#434343; font-size:0.8em;} 
    .disclaimer { font-style: italic; color:#778899; text-align:left; border-bottom: 0.5px solid #444444; }
    table#t01 th { background-color: #434343; color:white; padding:5px; text-align: left; }
    table#t01 tr:nth-child(even) { background-color: #eee; }
    table#t01 tr:nth-child(odd) { background-color: black; }	
	.Legend div{ margin-left:15px; max-width:10px; height:10px; border:1px solid #808080; display:inline-block; }
	.ie7 .Legend div{ display:inline; zoom:1; max-width:10px; }
    #quoted { quotes: "«" "»" "‹" "›"; }
    h3::before { counter-increment: section; content: "Section " counter(section) ": "; }
	.boxed { text-align: justify; font-style:italic; font-size:0.8em; font-family:'Segoe UI'; background-color: #f5f5f5; border: 0.5px solid green; padding:5px; width:98%; }	
	.post-header {display:block; text-align:center; }
	.post-info {display: inline-block; margin-right: 8px; color: #969696; font-size: 12px;  line-height: 125%; letter-spacing: 1px; text-transform: uppercase;}

</style>
<script src="/scripts/jquery.min.js"></script>	
<script>
`$(document).ready(function() {
	`$('[data-toggle="toggle"]').change(function(){
		`$(this).parents().next('.hide').toggle();
	});
});
</script>
<script>
	var showButtonText = "[+]";
    var hideButtonText = "[-]";
      
    function toggle(sdid, event) {
		var link;
        if(window.event) {
			link = window.event.srcElement;
        } else {
			link = event.target;
        }

        toToggle=document.getElementById(sdid);
        if (link.innerHTML==showButtonText) {
           link.innerHTML=hideButtonText;
           toToggle.style.display="block";
        } else {
            link.innerHTML=showButtonText;
            toToggle.style.display="none";
        }
    }

    function copyToClipboard(s) {
        if (window.clipboardData) {
            window.clipboardData.setData('Text',s);
        } else {
            try
            {
                netscape.security.PrivilegeManager.enablePrivilege('UniversalXPConnect');
            }
            catch(e)
            {
                alert("The clipboard copy didn't work.\nYour browser doesn't allow Javascript clipboard copy.\nIf you want to change its behaviour: \n1.Open a new browser window\n2.Enter the URL: about:config\n3.Change the signed.applets.codebase_principal_support property to true");
                return;
            }
            var clip = Components.classes['@mozilla.org/widget/clipboard;1'].createInstance(Components.interfaces.nsIClipboard);
            var trans = Components.classes['@mozilla.org/widget/transferable;1'].createInstance(Components.interfaces.nsITransferable);
            trans.addDataFlavor('text/unicode');
            var len = new Object();
            var str = Components.classes["@mozilla.org/supports-string;1"].createInstance(Components.interfaces.nsISupportsString);
            str.data=s;
            trans.setTransferData("text/unicode",str,s.length*2);
            var clipid=Components.interfaces.nsIClipboard;
            clip.setData(trans,null,clipid.kGlobalClipboard);
        }
    } 
</script>
</head>
<body>
    <div class='post-header'>
        <h2> <!--##EMAIL_HEADER##--> </h2>
        <div class='post-info'><!--##SYSTEM_DATE##--></div>
    </div>
    
    <div class='justify'>                
        <!--##EMAIL_BODY##-->
    </div>
    <!--##CURRENT_BUS_DATE##-->
    <!--##SERVICE_STATUS##-->
    <!--##WEBSITE_STATUS##-->
    <!--##ENDOFDAY_STATUS##-->    
    <!--##LOG_FILE_STATUS##-->
    <!--##EVENT_LOG_STATUS##-->
    <!--##MEMORY_USAGE##-->
    <!--##DB_MEMORY_STATS##-->
    <!--##EXCEPTION_DETAILS##-->      
    <!-- Begin of Footer -->
    <br> 
    <table style="border:0">
	<tr>
      <td align='left' valign='center'>
        <div class="Legend">
		    <div style="width:6px; height:6px" class="success">&nbsp;</div> Good
			<div style="width:6px; height:6px" class="warning">&nbsp;</div> Email Support
			<div style="width:6px; height:6px" class="failure">&nbsp;</div> Call-out
		</div>	
      </td>
	  <td class='comment' align='right' valign='center'>
        <!--##FOOTER_SECTION##-->
      </td>	   
	</tr>
	</table>     
    <!-- End of Footer -->
    <br>     
    <!--##DO_NOT_REPLY##-->    
    <div class='footer' align='center'> 
        Copyright &copy; 2020 <strong>Kiran Kurapaty</strong> All rights reserved.         
    </div> 
    <!-- end of Footer -->
</body>
</html>        
"@;
#endregion HTML / CSS TEMPLATE

#region HELPER FUNCTIONS
function Prompt-User([string] $Message, [string] $Hint, [switch] $IsRequired, [switch] $IsOptional, [switch] $IsQuestion, [String] $Default)
{
    if ($IsRequired -eq $true) { 
        Write-Host "[REQUIRED]" -ForegroundColor red -Background Black -NoNewline 
    } 
    elseif ($IsOptional -eq $true) { 
        Write-Host "[OPTIONAL]" -ForegroundColor white -Background darkGreen -NoNewline 
    }
       
    if ($Hint) { 
        Write-Host " $Message" -NoNewline
        Write-Host " [ex: $Hint]" -ForegroundColor Gray -NoNewline 
    } else {
        Write-Host " $Message" -NoNewline
    }
    if ($IsQuestion) {
        Write-Host " ? " -NoNewline
    } else {
        Write-Host " : " -NoNewline
    }
    $local:inputStr = (Read-Host).ToString();

    if ([String]::IsNullOrEmpty($local:inputStr)) { $local:inputStr = $Default; }
    return $local:inputStr;
}

function Get-UserInput([string] $Message, [string] $Hint, [switch] $IsQuestion, [String] $ExpectedInput, $Default)
{
    do {
        $userInput= Prompt-User -Message $Message -Hint $Hint -IsQuestion $IsQuestion -Default $Default -IsRequired;
        if ($ExpectedInput -notmatch $userInput) {
            WriteLine "$userInput is not a valid input. Please try again" 2;
        }
    } while ($ExpectedInput -notmatch $userInput);
    return $userInput;
}

function Prompt-Password([string] $Message, [string] $Hint)
{
    Write-Host "[REQUIRED]" -ForegroundColor red -Background Black -NoNewline 
    if ($Hint) { 
        Write-Host " $Message" -NoNewline
        Write-Host " [ex: $Hint]" -ForegroundColor Gray -NoNewline 
    } else {
        Write-Host " $Message" -NoNewline
    }
    Write-Host " : " -NoNewline
    $securedValue  = Read-Host -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securedValue)
    $value = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    return $value;
}

function Print-Subtitle([string] $Message)
{
    Write-Host $Message -ForegroundColor Cyan
}

function Write-Subtitle([String] $Message)
{
    $dash = Dash-Line $Message;
    Write-Host $Message -ForegroundColor Green
    Write-Host $dash -ForegroundColor Gray
}

function Print-ScriptStarted([String] $ScriptTitle) 
{
    $strLen = $ScriptTitle.Length;
    if ($strLen -lt 56) 
    {
        $half = (56 - $strLen)  / 2;
        $pref = " " * $half;
        $ScriptTitle = "{0}{1}{0}" -f $pref, $ScriptTitle
    }
    
    Write-Host "" -ForegroundColor Green
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*" -ForegroundColor Green
    Write-Host "* #                                                                             # *" -ForegroundColor Green
    Write-Host "* * *" -ForegroundColor Green -NoNewline
    Write-Host "$ScriptTitle" -ForegroundColor Cyan -NoNewline
    Write-Host "-" -NoNewline
    Write-Host "   Script by" -ForegroundColor Gray -NoNewline
    Write-Host " KIRAN KURAPATY " -ForegroundColor Yellow -NoNewline
    Write-Host "   * * *" -ForegroundColor Green
    Write-Host "* #                                                                             # *" -ForegroundColor Green
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*" -ForegroundColor Green
    Write-Host "" -ForegroundColor Green
}

function Print-ScriptCompleted([string] $Message) 
{
    Write-Host ""
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*" -ForegroundColor DarkGreen
    Write-Host "*****  $Message Completed Scuccessfully  *****" -ForegroundColor Green
}

function Get-FirstBusinessDayOfTheMonth
{
    $date = Get-FirstDayOfTheMonth;
    $day = $date.Day;
    while(-not (IsFirstBusinessDay $date))
    {
        $day += 1;
        $date = $date.AddDays($day);
    }
    return $date;
}

function Get-FirstDayOfTheMonth
{
    # specify the date you want to examine
    # default is today
    $date = Get-Date
    $year = $date.Year
    $month = $date.Month
    
    # create a new DateTime object set to the first day of a given month and year
    $startOfMonth = Get-Date -Year $year -Month $month -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0;    

    return $startOfMonth;
}

function Get-LastDayOfTheMonth
{
    $startOfMonth = Get-FirstDayOfTheMonth;
    # add a month and subtract the smallest possible time unit
    $endOfMonth = ($startOfMonth).AddMonths(1).AddTicks(-1);
    return $endOfMonth;
}

function IsFirstBusinessDay([DateTime] $date)
{
    $dayOfMonth = $date.Day;
    $dayOfWeek = $date.DayOfWeek;
    If ((($dayOfMonth -eq 1) -and ($dayOfWeek -ge [DayOfWeek]::Monday) -and ($dayOfWeek -le [DayOfWeek]::Friday)) -or 
       ((($dayOfMonth -eq 2) -or ($dayOfMonth -eq 3)) -and ($dayOfWeek -eq [DayOfWeek]::Monday))) 
    {
        return $true;
    }
    return $false;
}

function Is-ISE
{
    return ($Host.Name -match 'ISE');
}

function Start-Logging
{
    if (Is-ISE) { return; }
    If ([string]::IsNullOrEmpty($Global:DEBUG_LOG_FILE)) 
    { 
        $Global:DEBUG_LOG_FILE = GetTempFileEx -FileName "Transcript" -Extension "log";
    }    
    Start-Transcript -Path $Global:DEBUG_LOG_FILE -Append -Force -ErrorAction SilentlyContinue
}

function Stop-Logging([Switch] $ShowLog=$false)
{
    if (Is-ISE) { return; }
    Stop-Transcript -ErrorAction SilentlyContinue;
    If ($ShowLog)
    {
        If (FileExists $DEBUG_LOG_FILE) { Invoke-Expression $DEBUG_LOG_FILE; }
    }
}

function RepeatText ([String]$Text, [int]$Count=1)
{
    return ($Text) * $Count
}

function Script::Get-TextStats([String[]] $textIn)
{
    $textIn | Measure-Object -Line -Word -Character
}

# Usage: "This is a string" | ForEach-Object {$_ ; Dash-Line $_}
function Dash-Line([String] $textIn)
{
    return "-" * $textIn.Length;
}

function Print-KeyValue([string] $KeyName, [string] $KeyValue)
{
    "{0,-12}" -f $KeyName | Write-Host -ForegroundColor Green -NoNewline
    Write-Host " : " -ForegroundColor DarkGray -NoNewline
    "{0,-12}" -f $KeyValue | Write-Host
}

function WriteLine([string] $Message, [int] $MessageType=0, [int] $Step=0)
{
    Write-Host "[$(Get-Date)] " -NoNewline
    If ($Step -gt 0) {
        "[STEP {0:d2}]" -f $Step | Write-Host -ForegroundColor Cyan -NoNewline 
    } else {
        switch ($MessageType)
        {          
            0 { Write-Host "[INFO   ]" -ForegroundColor Gray -NoNewline }
            1 { Write-Host "[WARNING]" -ForegroundColor Yellow -NoNewline}
            2 { Write-Host "[ERROR  ]" -ForegroundColor Red -NoNewline}
            3 { Write-Host "[SUCCESS]" -ForegroundColor Green -NoNewline}                    
            4 { Write-Host "[VERBOSE]" -ForegroundColor DarkYellow -NoNewline}                        
		    5 { Write-Host "[EMAIL  ]" -ForegroundColor DarkCyan -NoNewline }
            6 { Write-Host "[DEBUG  ]" -ForegroundColor DarkGray -NoNewline } 		
        }
    }	
    Write-Host " : " -ForegroundColor DarkGray -NoNewline  
    switch ($MessageType)
    {          
        0 { Write-Host $Message -ForegroundColor Gray }
        1 { Write-Host $Message -ForegroundColor Yellow }
        2 { Write-Host $Message -ForegroundColor Red }
        3 { Write-Host $Message -ForegroundColor Green }
        4 { Write-Host $Message -ForegroundColor DarkYellow }
        5 { Write-Host $Message -ForegroundColor Cyan }
        6 { Write-Host $Message -ForegroundColor DarkGray }
    }      
}

function Write-Line 
{
    Param ([ValidateNotNullOrEmpty()][string] $Message, [int] $mode = 0) 
    # $time=Get-Date    
    switch ($mode)
    {  
        -1 { Write-Host $Message }
        0 { Write-Host "[INFO   ] : $Message" -ForegroundColor Gray }
        1 { Write-Host "[WARNING] : $Message" -ForegroundColor Yellow }
        2 { Write-Host "[ERROR  ] : $Message" -ForegroundColor Red }
        3 { Write-Host "[SUCCESS] : $Message" -ForegroundColor Green }
		4 { Write-Host "[VERBOSE] : $Message" -ForegroundColor DarkYellow}                
        5 { Write-Host "[EMAIL  ] : $Message" -ForegroundColor Cyan }        
        6 { Write-Host "[DEBUG  ] : $Message" -ForegroundColor DarkGray } 
    }
    if ($Global:LoggingEnabled)
    {
        $logContent = "[{0}] {1}" -f $(Get-Date).ToString(), $Message   
        Add-Content $Global:LogFileName -value $logContent
    }
}

function IIF([bool]$Condition, $TrueVal, $FalseVal)
{
    if ($Condition) { return $TrueVal } else { return $FalseVal }
}

function Get-Plural([ValidateNotNullOrEmpty()][int] $Count, [ValidateNotNullOrEmpty()][String] $Text)
{
    $length = $Text.Length;
    $lastChars = $Text.Substring($length-2, 2);

    if ($lastChars | Select-String -Pattern @("ay", "ey", "iy", "oy", "uy") -SimpleMatch) { $Suffix = "s"; } 
    elseif ($Text.EndsWith("y")) { $Suffix = "ies"; } else { $Suffix = "s"; }
    if ($Count -gt 1) { return $Text + $Suffix } else { return $Text }
}

function Get-AsDuration 
{
    Param(
        [ValidateNotNullOrEmpty()][DateTime] $FromDate, 
        [ValidateNotNullOrEmpty()][DateTime] $ToDate
     )

    if ($FromDate -eq $null) { $FromDate = Get-Date }
    if ($ToDate -eq $null) { $ToDate = Get-Date }
    $duration = "";
    try {
        [TimeSpan] $elapsed = $ToDate - $FromDate;    
    
        if ($elapsed.Days -gt 0) {
            $local:plural = Get-Plural -Count $elapsed.Days -Text "day"
            $duration = "{0} {1}" -f $elapsed.Days, $local:plural;
        }        

        if ($elapsed.Hours -gt 0) {
            $local:plural = Get-Plural -Count $elapsed.Hours -Text "hour"
            $duration += " {0} {1}" -f $elapsed.Hours, $local:plural;
        }
        if ($elapsed.Minutes -gt 0)
        {
            $local:plural = Get-Plural -Count $elapsed.Minutes -Text "min"
            $duration += " {0} {1}" -f $elapsed.Minutes, $local:plural;
        }
        if ($elapsed.Seconds -gt 0)
        {
            $local:plural = Get-Plural -Count $elapsed.Seconds -Text "sec"
            $duration += " {0} {1}" -f $elapsed.Seconds, $local:plural;
        }
        if ($duration.ToString().Length -eq 0)
        {
           $duration += "{0} msec" -f $elapsed.Milliseconds
        }
    }
    catch [Exception]
    {
       WriteLine "Could not parse $FromDate OR $ToDate" -MessageType 2
       Write-Error $Error[0] 
    }
    return $duration.ToString().Trim();    
}

function ToFriendlyName([string] $text)
{
     $text = $text -replace '_', ''; # remove underscrore characters
     [Regex] $regExpr = new-object System.Text.RegularExpressions.Regex ("(?<=[A-Z])(?=[A-Z][a-z]) | (?<=[^A-Z])(?=[A-Z]) | (?<=[A-Za-z])(?=[^A-Za-z])", [System.Text.RegularExpressions.RegexOptions]::IgnorePatternWhitespace);
     $result = $regExpr.Replace($text, " ");
     return $result;
}
#endregion HELPER FUNCTIONS

#region FILE I/O HELPERS
function Get-DirectoryExists([ValidateNotNullOrEmpty()][string] $Path)
{
    if (Test-Path $Path) { return $true } else { return $false }
}

function FileExists([ValidateNotNullOrEmpty()] [string] $FileName)
{
    if (Test-Path $FileName) { return $true } else { return $false }
}

function ForceDirectories([ValidateNotNullOrEmpty()][string]$Directory)
{
    if ($global:GlobalVerbose) { WriteLine "Checking Directory Structure: $Directory ..." 4 }

    if (!(Get-DirectoryExists $Directory)) 
    {
        WriteLine "Creating Directory: $Directory"
        # mkdir $Directory                
        New-Item $Directory -ItemType Directory |Out-Null       
    }       
}

function ExtractFilePath([string] $fileName)
{
    [string] $path = [System.IO.Path]::GetDirectoryName($fileName);
    return $path;
}

function GetTempFileWithExt([string] $Extension)
{
    $tempFile = [System.IO.Path]::GetTempFileName();
    $tempFile = [System.IO.Path]::ChangeExtension($tempFile, $Extension);
    
    return $tempFile;
}

function GetTempFileEx([string] $FileName, [string] $Extension, [switch] $SuffixDate =$true)
{
    $tempFile = GetTempFileWithExt -Extension: $Extension;    
    $tempFileName = ExtractFileName $tempFile;
    $result = "{0}_{1}.{2}" -f $FileName, (Get-Date -F yyyy-MM-dd_HH-mm), $Extension;    
    $result = $tempFile -replace $tempFileName, $result;
    return $result; 
}

function GetDirectoryName([string] $fileName)
{
    [string] $path = Split-Path $fileName;
    return $path;
}

function ExtractFileName([string] $path)
{
    [string] $fileName = Split-Path $path -Leaf;
    return $fileName;
}

# VALIDATES STRING MIGHT BE A PATH #
function ValidatePath($PathName, $TestPath) 
{
  If([string]::IsNullOrWhiteSpace($TestPath)) 
  {
    WriteLine "$PathName is not a valid path"
  }
}

# NORMALIZES RELATIVE OR ABSOLUTE PATH TO ABSOLUTE PATH #
function NormalizePath($PathName, $TestPath) 
{
  ValidatePath "$PathName" "$TestPath"
  $TestPath = [System.IO.Path]::Combine((pwd).Path, $TestPath)
  $NormalizedPath = [System.IO.Path]::GetFullPath($TestPath)
  return $NormalizedPath
}

# VALIDATES STRING MIGHT BE A PATH AND RETURNS ABSOLUTE PATH #
function ResolvePath($PathName, $TestPath) 
{
  ValidatePath "$PathName" "$TestPath"
  $ResolvedPath = NormalizePath $PathName $TestPath
  return $ResolvedPath
}

# VALIDATES STRING RESOLVES TO A PATH AND RETURNS ABSOLUTE PATH #
function RequirePath($PathName, $TestPath, $PathType) 
{
  ValidatePath $PathName $TestPath
  If(!(Test-Path $TestPath -PathType $PathType)) 
  {
    WriteLine "$PathName ($TestPath) does not exist as a $PathType"
  }
  $ResolvedPath = Resolve-Path $TestPath
  return $ResolvedPath
}

function Get-FileCount([ValidateNotNullOrEmpty()][string] $Directory, [switch] $IncludeSubFolders=$true) 
{
    if (Get-DirectoryExists $Directory) { return $(Get-ChildItem -Path $Directory -Recurse:$IncludeSubFolders).Count } else { return 0 }
}

function Copy-Files 
{
    Param(
        [ValidateNotNullOrEmpty()] [String] $SourcePath,
        [ValidateNotNullOrEmpty()] [String] $TargetPath,
        [ValidateNotNullOrEmpty()] [String] $Filter = "*"    
    )
    ForceDirectories $TargetPath
    Copy-Item -Path $SourcePath\* -Filter $Filter -Destination $TargetPath.ToString() -Recurse -Force -ErrorAction Continue
    $count = Get-FileCount($TargetPath)
    WriteLine "$count files copied to $TargetPath"
}

function Copy-AllFiles 
{
    Param(
        [ValidateNotNullOrEmpty()] [String] $Source,
        [ValidateNotNullOrEmpty()] [String] $Destination,
        [ValidateNotNullOrEmpty()] [String] $Filter = "*"    
    )
    ForceDirectories $Destination   
    Get-ChildItem $Source -Filter $Filter -Recurse | % { Copy-Item -Path $_.FullName -Destination $Destination -Force }    
}

function UpdateConfigSettings 
{
    Param(
        [ValidateNotNullOrEmpty()] [string] $FileName,
        [ValidateNotNullOrEmpty()] [string] $KeyName,
        [ValidateNotNullOrEmpty()] [string] $KeyValue
    )

    $xml = [xml](Get-Content $FileName);
    # WriteLine "Locating key: $KeyName in config file" -MessageType 4;
    # Use XPath to find the appropriate node
    if(($addKey = $xml.SelectSingleNode("//appSettings/add[@key = '$KeyName']")))
    {
        WriteLine "Updating '$KeyName' => $KeyValue";
        $addKey.SetAttribute('value', $KeyValue)
    }    
    $xml.Save($FileName);
}

function StartProcessWithOutput 
{
    Param(
            [ValidateNotNullOrEmpty()] [String] $FilePath, [String[]] $Arguments, [Switch] $NoWindow = $false
        )
    # Write-Host "[DEBUG] Starting Process $FilePath with $Arguments"
    
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $FilePath
    $pinfo.Arguments = $Arguments

    $pinfo.CreateNoWindow = $NoWindow
    $pinfo.UseShellExecute = $false 
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
        
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $pinfo
    $process.Start() | Out-Null
    $process.WaitForExit()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    Write-Host ""
    if (!([string]::IsNullOrEmpty($stdout))) { Write-Host $stdout }
    if (!([string]::IsNullOrEmpty($stderr))) { Write-Host "[ERROR] $stderr" -ForegroundColor Red }
    #Write-Host "[EXIT CODE] " + $process.ExitCode
}

function Delay ([int] $Seconds = 10) { process { $_; Start-Sleep -seconds $Seconds} }

function CleanFolders
{
    Param(
        [ValidateNotNullOrEmpty()] [String] $Path,
        [ValidateNotNullOrEmpty()] [string] $Filter,        
        $ExcludePath = $null
    )

    [regex] $excludeMatchRegEx = '(?i)' + (($ExcludePath | foreach { [regex]::escape($_) }) -join "|") + ''
    $SourcePath = $Path.TrimEnd("\")
    Get-ChildItem -Path $SourcePath -Recurse -Filter $Filter -Exclude $ExcludePath | 
         where { $ExcludePath -eq $null -or $_.FullName.Replace($SourcePath, "") -notmatch $excludeMatchRegEx} |
         foreach ($_) { Write-Host "Deleting $_"
         Remove-Item -Path $_ -Exclude $ExcludePath -Recurse -Force 
         }         
}

function CopyFiles
{
    Param(
        [ValidateNotNullOrEmpty()] [String] $SourcePath,
        [ValidateNotNullOrEmpty()] [String] $TargetPath,
        [ValidateNotNullOrEmpty()] [String] $Filter = "*",
        $ExcludePath = $null
    )

    [regex] $excludeMatchRegEx = '(?i)' + (($ExcludePath | foreach { [regex]::escape($_) }) -join "|") + ''
    $SourcePath = $SourcePath.TrimEnd("*")
    $TargetPath = $TargetPath.TrimEnd("*")
    $SourcePath = $SourcePath.TrimEnd("\")
    $TargetPath = $TargetPath.TrimEnd("\")

    Get-ChildItem -Path $SourcePath -Filter $Filter  -Recurse -Exclude $ExcludePath | 
         where { $ExcludePath -eq $null -or $_.FullName.Replace($SourcePath, "") -notmatch $excludeMatchRegEx} |         
            Copy-Item -Destination {
            if ($_.PSIsContainer) {
                Join-Path $TargetPath $_.Parent.FullName.Substring($SourcePath.Length)
            } else {
                Join-Path $TargetPath $_.FullName.Substring($SourcePath.Length)
            }
        } -Force -Exclude $ExcludePath 
}

function Get-DeployCodePath
{
    Param([ValidateNotNullOrEmpty()][string] $HostName,
          [ValidateNotNullOrEmpty()][string] $Env, 
          [ValidateNotNullOrEmpty()][string] $TargetPath          
          )

    WriteLine "Preparing $ENV Deployment Path $TargetPath for $HostName"
    # Prepare Directory Hierarchy structure
    [string] $path = "\\{0}\Deploy\Code\{1}\{2}" -f $Hostname, $Env, $TargetPath
     
    # Create directory structure if not exists
    ForceDirectories($path)

    IF ($global:GlobalVerbose) { WriteLine "Deployment path - $path" 3 }
    return $path.ToString();
}

function Backup-ZipFile ( 
    [ValidateNotNullOrEmpty()][string]$SourcePath=$(throw " SourcePath is required."), 
    [ValidateNotNullOrEmpty()][string]$TargetPath=$(throw " TargetPath is required."),
    [string] $Filter="*",
    [switch] $Zip=$false,
    [switch] $Clean=$false )
{
    # Import-Module Zip    
    try
    {   
        if ([string]::IsNullOrEmpty($Filter))
        {
            $Filter = "*"
        }
        $cleanFiles = $false
        if (Get-FileCount($SourcePath) -gt 0)
        {
            WriteLine "Please Wait, Starting backup ..."
            $SourceDir = $(Get-Item $SourcePath).Name
            if ($Zip)
            {
                $backupFileName = "$($TargetPath)\$($SourceDir)_$(Get-Date -f yyyy-MM-dd-HH_mm_ss).zip"
                $localBackupFile = "$($env:Temp)\$($SourceDir)_$(Get-Date -f yyyy-MM-dd-HH_mm_ss).zip"
                if ($global:GlobalVerbose) 
                { 
                    WriteLine "$SourcePath => $backupFileName" 4
                    WriteLine "Temp Folder: $localBackupFile" 4
                }                
               
                # ZipFiles -Target $backupZipFileName -Source $SourcePath
                New-ZipFile -ZipFilePath $localBackupFile -InputObject $SourcePath -ErrorAction Continue
                Move-Item -Path $localBackupFile -Destination $TargetPath -Force
                $cleanFiles=$true
                WriteLine "Backup Created: $backupFileName" 3               
            }
            else
            {
                WriteLine "Moving files to Backup"
                Move-Item -Path "$SourcePath\$Filter" -Destination $TargetPath -Force
                WriteLine "Moved files to Backup" 3
            }

            if (($Clean) -and ($cleanFiles))
            {
                WriteLine "Cleanup in progress..."
                # Remove-Item "$SourcePath\$Filter" -Recurse -Force -ErrorAction SilentlyContinue 
                CleanFolders -Path:$SourcePath -Filter $Filter -ExcludePath:$global:ExclusionList               
                WriteLine "Cleanup Success" 3
            }
        }
        else
        {
            WriteLine "$SourcePath is empty. Nothing to backup" 
        }
    }
    catch
    {
        $ErrorMessage = $PSItem.Exception.Message
        $FailedItem = $PSItem.Exception.ItemName
            
        WriteLine "Backup failed. $SourcePath => $TargetPath\n$FailedItem.\nThe reason is: $ErrorMessage" 2
        if ($global:GlobalVerbose) { Write-Error -Exception:$PSItem.Exception }        
        return $PSItem
    }   
}

function Wait-Sleep($seconds, $title, $description) 
{
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity $title -Status $description -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity $title -Status $description -SecondsRemaining 0 -Completed
}

function Wait-Until-ProcessExits([System.Diagnostics.Process] $Process, [string] $Title, [string] $Message)
{
    if ($Process -eq $null) { return; }

    for($i = 0; $i -le 100; $i = ($i + 1) % 100)
    {
        Write-Progress -Activity $Title -PercentComplete $i -Status $Message
        Start-Sleep -Milliseconds 100
        if ($Process.HasExited) {
            Write-Progress -Activity $Title -Completed
            break
        }
    }
}

function UpdateConfigFiles 
{
    Param( [ValidateNotNullOrEmpty()][string] $Path,
           [ValidateNotNullOrEmpty()][string] $Env 
        )

    WriteLine "Please wait, Updating Configuration files..."
    $configFilter = @("*.exe.config", "web.config")
    $configItems = Get-ChildItem -Path $Path\* -Include $configFilter -Exclude $global:ExclusionList -Recurse -Force
    $count = $configItems.Count
    $updated = 0
    foreach ($item in $configItems)
    {
        # Write-Host "Processing $item.DirectoryName"
        $filePath = $item.DirectoryName + "\AppConfig"
        $targetFileName = $item.FullName
        $sourceFileName = "$filePath\$Env.config"
        if ((Get-DirectoryExists $filePath))
        {
            WriteLine "Updating AppConfig\$Env.config => $targetFileName ..." 4
            Copy-Item -Path $sourceFileName -Destination $targetFileName -Force
            $updated++
        } else 
        {
            WriteLine "Path not found! $filePath" 1
        }
    }
    WriteLine "$updated out of $count Configuration files Updated."
}
#endregion FILE I/O HELPERS

#region DISK / MEMORY /EVENT-LOG HELPERS
function Get-OptimalSize 
{
    Param(
        [Parameter(Mandatory = $true, Position = 0,valueFromPipeline=$true)]
        [int64] $sizeInBytes
        )
    Switch ($sizeInBytes)
    {
        {$sizeInBytes -ge 1TB} {"{0:n2}" -f ($sizeInBytes/1TB) + " TB";break}
        {$sizeInBytes -ge 1GB} {"{0:n2}" -f ($sizeInBytes/1GB) + " GB";break}
        {$sizeInBytes -ge 1MB} {"{0:n2}" -f ($sizeInBytes/1MB) + " MB";break}
        {$sizeInBytes -ge 1KB} {"{0:n2}" -f ($sizeInBytes/1KB) + " KB";break}
        Default { "{0:n2}" -f $sizeInBytes + " Bytes" }
    } 
    $sizeInBytes = $null
} 

function Get-ComputerLogicalDisk([string] $computer, $credential)
{
    $FreeSpace = @{Name="FreeSpace"; Expression={Get-OptimalSize $_.FreeSpace}};
    $DiskSize = @{Name="DiskSize"; Expression={Get-OptimalSize $_.Size}};
    $DeviceName = @{Name="Drive"; Expression={$_.DeviceId}};
    $DiskFree = @{name="DiskFree"; Expression={[math]::round((($_.FreeSpace * 100)/ $_.Size),2)}}    
    $Status = @{Name="Status"; Expression={(&{If([math]::round((($_.FreeSpace * 100)/ $_.Size),2) -lt 20) {"ALMOST FULL"} else {"OK"}})}}
    if ($credential -ne $null) 
    {
        $disks = gwmi Win32_LogicalDisk -ComputerName $computer -Credential $credential | ? { $_.DriveType -eq 3 }
    } else {
        $disks = gwmi Win32_LogicalDisk -ComputerName $computer | ? { $_.DriveType -eq 3 }
    }
    return $disks | Select $DeviceName, $FreeSpace, $DiskSize, $DiskFree, $Status
}

function Get-ComputerMemory([string] $computer, $credential)
{
    $TotalVirtualMemory = @{Name="TotalVirtualMemory"; expression={[math]::round(($_.TotalVirtualMemorySize / 1047553),3)}}
    $TotalPhysicalMemory = @{Name= "TotalPhysicalMemory"; expression={[math]::round(($_.TotalVisibleMemorySize / 1047553),3)}}
    $SizeStoredInPagingFiles = @{Name="SizeStoredInPagingFiles"; expression={[math]::round(($_.SizeStoredInPagingFiles / 1047553),3)}}
    $FreeRAM = @{Name="FreeRAM"; expression={[math]::round(($_.FreePhysicalMemory / 1047553),3)}}
    $FreeSpaceinPaging = @{Name="FreeSpaceinPaging"; expression={[math]::round(($_.FreeSpaceInPagingFiles / 1047553),3)}}
    $FreeVirtualMemory = @{Name="FreeVirtualMemory"; expression={[math]::round(($_.FreeVirtualMemory / 1047553),3)}}
    $LastReboot = @{Name="LastReboot"; expression={$_.ConvertToDateTime($_.LastBootUpTime)}}
    $Version = @{Name="Version";expression={"{0} {1} {2}" -f $_.Caption, $_.CSDVersion, $_.OSArchitecture}}
    $Status = @{Name="Status";expression={$_.Status}}
    $CommitedBytesInUse = @{name="CommitedBytesInUse"; expression={[math]::round(([math]::round((($_.TotalVirtualMemorySize - $_.FreeVirtualMemory)/ 1047553),3)/([math]::round(($_.TotalVirtualMemorySize / 1047553),3))*100),3)}}        
    if ($credential -ne $null) { 
        $output = Get-WmiObject -Class Win32_OperatingSystem -Credential $credential -Computer $computer
    } else {
        $output = Get-WmiObject -Class Win32_OperatingSystem -Computer $hostName 
    }

    return $output | Select $Version, $TotalVirtualMemory, $TotalPhysicalMemory, $SizeStoredInPagingFiles, $FreeRAM, $FreeSpaceinPaging, $FreeVirtualMemory, $CommitedBytesInUse, $LastReboot, $Status
}

function Get-ComputerEventLogs([String] $computer, [int] $Count, [DateTime] $StartDate, [String] $Filter, $credential)
{
    $machineName = @{Name="ServerName"; Expression={$_.MachineName}}
    if ($credential -ne $null) { 
        $fieldIndex   = @{Name="Index"; Expression={$_.RecordId}};
        $fieldError   = @{Name="Status"; Expression={$_.LevelDisplayName}};
        $fieldSource  = @{Name="Source"; Expression={$_.ProviderName}};
        $fieldCreated = @{Name="CreatedOn"; Expression={$_.TimeCreated}};
        $eventLogs = Get-WinEvent -Credential $credential -ComputerName $computer `
                                  -FilterHashtable @{ Level=2; LogName='Application'; StartTime=$StartDate; EndTime = Get-Date} `
                                  -MaxEvents $Count | ? { $_.Source -match $Filter -or $_.Message -match $Filter }
    } else {
        $fieldIndex   = @{Name="Index"; Expression={$_.Index}};
        $fieldError   = @{Name="Status"; Expression={$_.EntryType}};
        $fieldSource  = @{Name="Source"; Expression={$_.Source}};
        $fieldCreated = @{Name="CreatedOn"; Expression={$_.TimeGenerated}};
        $eventLogs = Get-EventLog -ComputerName $computer `
                                  -LogName Application -EntryType Error `
                                  -Newest $Count -After $StartDate | ? { $_.Source -match $Filter -or $_.Message -match $Filter }
    }
    return $eventLogs | Select $fieldIndex, $fieldError, Message, $fieldSource, $fieldCreated, $machineName;
}
#endregion

#region SEARCH HELPERS
function Find-InTextFile 
{
    <#
    .SYNOPSIS
        Performs a find (or replace) on a string in a text file or files.
    .EXAMPLE
        PS> Find-InTextFile -FilePath 'C:\MyFile.txt' -Find 'water' -Replace 'wine'
    
        Replaces all instances of the string 'water' into the string 'wine' in
        'C:\MyFile.txt'.
    .EXAMPLE
        PS> Find-InTextFile -FilePath 'C:\MyFile.txt' -Find 'water'
    
        Finds all instances of the string 'water' in the file 'C:\MyFile.txt'.
    .PARAMETER FilePath
        The file path of the text file you'd like to perform a find/replace on.
    .PARAMETER Find
        The string you'd like to replace.
    .PARAMETER Replace
        The string you'd like to replace your 'Find' string with.
    .PARAMETER NewFilePath
        If a new file with the replaced the string needs to be created instead of replacing
        the contents of the existing file use this param to create a new file.
    .PARAMETER Force
        If the NewFilePath param is used using this param will overwrite any file that
        exists in NewFilePath.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NewFile')]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ -PathType 'Leaf'})]
        [string[]]$FilePath,
        [Parameter(Mandatory = $true)]
        [string]$Find,
        [Parameter()]
        [string]$Replace,
        [Parameter(ParameterSetName = 'NewFile')]
        [ValidateScript({ Test-Path -Path ($_ | Split-Path -Parent) -PathType 'Container' })]
        [string]$NewFilePath,
        [Parameter(ParameterSetName = 'NewFile')]
        [switch]$Force
    )
    begin {
        $Find = [regex]::Escape($Find)
    }
    process {
        try 
        {
            foreach ($File in $FilePath) 
            {
                if ($Replace) 
                {
                    if ($NewFilePath) 
                    {
                        if ((Test-Path -Path $NewFilePath -PathType 'Leaf') -and $Force.IsPresent) 
                        {
                            Remove-Item -Path $NewFilePath -Force
                            (Get-Content $File) -replace $Find, $Replace | Add-Content -Path $NewFilePath -Force
                             WriteLine "Created/Overrite: $NewFilePath"
                        } elseif ((Test-Path -Path $NewFilePath -PathType 'Leaf') -and !$Force.IsPresent) 
                        {
                            Write-Warning "The file at '$NewFilePath' already exists and the -Force param was not used"
                        } else 
                        {
                            (Get-Content $File) -replace $Find, $Replace | Add-Content -Path $NewFilePath -Force
                            WriteLine "Created: $NewFilePath"
                        }
                    } else 
                    {
                        (Get-Content $File) -replace $Find, $Replace | Add-Content -Path "$File.tmp" -Force
                        Remove-Item -Path $File
                        Move-Item -Path "$File.tmp" -Destination $File
                    }
                } else 
                {
                    Select-String -Path $File -Pattern $Find
                }
            }
        } 
        catch 
        {
            Write-Error $_.Exception.Message
        }
    }
}
#endregion SEARCH HELPERS

#region COMPRESSION ZIP/UNZIP HELPERS
function New-ZipFile 
{
	#.Synopsis
	#  Create a new zip file, optionally appending to an existing zip...
	[CmdletBinding()]
	param(
		# The path of the zip to create
		[Parameter(Position=0, Mandatory=$true)]
		$ZipFilePath,
 
		# Items that we want to add to the ZipFile
		[Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
		[Alias("PSPath","Item")]
		[string[]]$InputObject = $Pwd, 
    
		# Append to an existing zip file, instead of overwriting it
		[Switch]$Append,
 
		# The compression level (defaults to Optimal):
		#   Optimal - The compression operation should be optimally compressed, even if the operation takes a longer time to complete.
		#   Fastest - The compression operation should complete as quickly as possible, even if the resulting file is not optimally compressed.
		#   NoCompression - No compression should be performed on the file.
		[System.IO.Compression.CompressionLevel]$Compression = "Optimal"        
	    )

    begin 
    {		
        # Make sure the folder already exists
		[string]$File = Split-Path $ZipFilePath -Leaf
		[string]$Folder = $(if($Folder = Split-Path $ZipFilePath) { Resolve-Path $Folder } else { $Pwd })
		$ZipFilePath = Join-Path $Folder $File
		# If they don't want to append, make sure the zip file doesn't already exist.
		if(!$Append) 
        {
            if(Test-Path $ZipFilePath) 
            { 
                WriteLine "Deleting existing ZipFile $ZipFilePath" 1
                Remove-Item $ZipFilePath 
            }
		}

		if ($global:GlobalVerbose) { WriteLine "GivenArgs $ZipFilePath, $InputObject, $File, $Folder" }
        $Archive = [System.IO.Compression.ZipFile]::Open( $ZipFilePath, "Update" )
        if ($global:GlobalVerbose) { WriteLine "Opening ZipFile Archive" }
	}
    process 
    {
        WriteLine "Archiving Contents from $InputObject ..."
        foreach($path in $InputObject) 
        {
            foreach($item in Resolve-Path $path) 
            {
				# Push-Location so we can use Resolve-Path -Relative
				Push-Location (Split-Path $item)
				# This will get the file, or all the files in the folder (recursively)
                foreach($file in Get-ChildItem $item -Recurse -File -Force | % FullName) 
                {
					# Calculate the relative file path
					$relative = (Resolve-Path $file -Relative).TrimStart(".\")
					# Add the file to the zip
					$null = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Archive, $file, $relative, $Compression)
				}
				Pop-Location
			}
		}
        WriteLine "Archiving Completed."
	}
    end 
    {
		$Archive.Dispose()
		Get-Item $ZipFilePath | Out-Null       
        if ($global:GlobalVerbose) { WriteLine "Zip-Archive Disposed." }
	}
}
     
function Expand-ZipFile 
{
	#.Synopsis
	#  Expand a zip file, ensuring it's contents go to a single folder ...
	[CmdletBinding()]
	param(
		# The path of the zip file that needs to be extracted
		[Parameter(ValueFromPipelineByPropertyName=$true, Position=0, Mandatory=$true)]
		[Alias("PSPath")]
		$FilePath,
 
		# The path where we want the output folder to end up
		[Parameter(Position=1)]
		$OutputPath = $Pwd,
 
		# Make sure the resulting folder is always named the same as the archive
		[Switch]$Force
	)
	process {
		$ZipFile = Get-Item $FilePath
		$Archive = [System.IO.Compression.ZipFile]::Open( $ZipFile, "Read" )
 
		# Figure out where we'd prefer to end up
		if(Test-Path $OutputPath) 
        {
			# If they pass a path that exists, we want to create a new folder
			$Destination = Join-Path $OutputPath $ZipFile.BaseName
		} else 
        {
			# Otherwise, since they passed a folder, they must want us to use it
			$Destination = $OutputPath
		}
 
		# The root folder of the first entry ...
		$ArchiveRoot = ($Archive.Entries[0].FullName -Split "/|\\")[0]
 
		Write-Verbose "Desired Destination: $Destination"
		Write-Verbose "Archive Root: $ArchiveRoot"
 
		# If any of the files are not in the same root folder ...
		if($Archive.Entries.FullName | Where-Object { @($_ -Split "/|\\")[0] -ne $ArchiveRoot }) 
        {
			# extract it into a new folder:
			New-Item $Destination -Type Directory -Force
			[System.IO.Compression.ZipFileExtensions]::ExtractToDirectory( $Archive, $Destination )
		} else 
        {
			# otherwise, extract it to the OutputPath
			[System.IO.Compression.ZipFileExtensions]::ExtractToDirectory( $Archive, $OutputPath )
 
			# If there was only a single file in the archive, then we'll just output that file...
			if($Archive.Entries.Count -eq 1) {
				# Except, if they asked for an OutputPath with an extension on it, we'll rename the file to that ...
				if([System.IO.Path]::GetExtension($Destination)) {
					Move-Item (Join-Path $OutputPath $Archive.Entries[0].FullName) $Destination
				} else {
					Get-Item (Join-Path $OutputPath $Archive.Entries[0].FullName)
				}
			} elseif($Force) {
				# Otherwise let's make sure that we move it to where we expect it to go, in case the zip's been renamed
				if($ArchiveRoot -ne $ZipFile.BaseName) {
					Move-Item (join-path $OutputPath $ArchiveRoot) $Destination
					Get-Item $Destination
				}
			} else {
				Get-Item (Join-Path $OutputPath $ArchiveRoot)
			}
		}
 
		$Archive.Dispose()
	}
}
#endregion COMPRESSION ZIP/UNZIP HELPERS

#region XML VALIDATION HELPERS
<#
.SYNOPSIS
Test the validity of an XML file
#>

function Test-XMLFile 
{
    [CmdletBinding()] Param ([parameter(mandatory=$true)][ValidateNotNullorEmpty()][string]$xmlFilePath)

    # Check the file exists
    if (!(Test-Path -Path $xmlFilePath)){
        WriteLine "$xmlFilePath is not valid. Please provide a valid path to the .xml fileh" -MessageType 2
        return $false;
    }
    
    # Check for Load or Parse errors when loading the XML file
    $xml = New-Object System.Xml.XmlDocument
    try 
    {
        $xml.Load((Get-ChildItem -Path $xmlFilePath).FullName)
        return $true
    }
    catch [Exception] 
    {
        WriteLine "$xmlFilePath : $($_.ToString())" -MessageType 2
        return $false
    }
}

#endregion XML VALIDATION HELPERS

#region FILE ARCHIVE HELPERS
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
# Examples for different usages
# Delete all files created more than 2 days ago.
# Remove-FilesCreatedBeforeDate -Path "C:\Temp\Logs" -DateTime ((Get-Date).AddDays(-2)) -DeletePathIfEmpty

# Delete all files that have not been updated in 8 hours.
# Remove-FilesNotModifiedAfterDate -Path "C:\Temp\Logs" -DateTime ((Get-Date).AddHours(-8))

# Delete a single file if it is more than 30 minutes old.
# Remove-FilesCreatedBeforeDate -Path "C:\Temp\Logs\SomeFile.txt" -DateTime ((Get-Date).AddMinutes(-30))

# Delete all empty directories in the Temp folder, as well as the Temp folder itself if it is empty.
# Remove-EmptyDirectories -Path "C:\Temp\Logs" -DeletePathIfEmpty

# Delete all empty directories created after Jan 1, 2014 3PM.
# Remove-EmptyDirectories -Path "C:\Temp\Logs\EmptyFolders" -OnlyDeleteDirectoriesCreatedBeforeDate ([DateTime]::Parse("Jan 1, 2014 15:00:00"))

# See what files and directories would be deleted if we ran the command.
# Remove-FilesCreatedBeforeDate -Path "C:\Temp\Logs" -DateTime (Get-Date) -DeletePathIfEmpty -WhatIf

# Delete all files and directories in the Temp folder, as well as the Temp folder itself if it is empty, and output all paths that were deleted.
# Remove-FilesCreatedBeforeDate -Path "C:\Temp\Logs" -DateTime (Get-Date) -DeletePathIfEmpty -OutputDeletedPaths

#endregion FILE ARCHIVE HELPERS

#region ENCRIPTION HELPERS
<# Usage: Encrypt-Script $home\original.ps1 $home\secure.bin #>
function Encrypt-Script([parameter(Mandatory)][ValidateScript({Test-Path $_})][string]$path, [parameter(Mandatory)][string] $destination) 
{
    $script = Get-Content $path | Out-String
    $secure = ConvertTo-SecureString $script -AsPlainText -Force
    $export = $secure | ConvertFrom-SecureString
    $targetDir= GetDirectoryName $destination;
    if (!(Get-DirectoryExists $targetDir)) { ForceDirectories $targetDir }

    Set-Content $destination $export
    WriteLine "Script '$path' has been encrypted as '$destination'"
}
<# Usage: Execute-EncryptedScript $home\secure.bin #>
function Execute-EncryptedScript([parameter(Mandatory)][ValidateScript({Test-Path $_})][string]$path) 
{
    trap { "Decryption failed"; break }
    $raw = Get-Content $path
    $secure = ConvertTo-SecureString $raw
    $helper = New-Object system.Management.Automation.PSCredential("test", $secure)
    $plain = $helper.GetNetworkCredential().Password
    Invoke-Expression $plain
}
#endregion

#region EMAIL HELPERS
function Send-Email([parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $Subject, 
                    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $Body,                    
                    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $To
                    )
{   
    $footer = "<br><hr noshade color=red><small>This is auto-generated email from {1} by {2} at {0}.</small>" -f $(Get-Date), $env:ComputerName, $env:UserName 
    $messageParams = @{
            SmtpServer = "smtp.gmail.co.uk"
            From =  "No Reply <{0}@gmail.com>" -f $env:USERNAME
            To = $To
            Bcc = "Kiran Kurapaty <kkurapaty@gmail.com>"
            Body = "{0} {1}" -f $Body, $footer
            Subject = $Subject
    }
    try
    {
        Send-MailMessage @messageParams -BodyAsHtml -DeliveryNotificationOption OnFailure,OnSuccess -ErrorAction SilentlyContinue
        WriteLine "Email Sent: $Subject" 3 
    }
    catch
    {
        WriteLine "Unable to send email: $Subject, $_" 5
    }
}

function Send-Email-Attachments([parameter(Mandatory)][ValidateNotNullOrEmpty()][String] $Subject, 
                    [parameter(Mandatory)][ValidateNotNullOrEmpty()][String] $Body,                    
                    [parameter(Mandatory)][ValidateNotNullOrEmpty()][String[]] $To,
                    [String] $From = "No Reply",
                    $FilesToAttach = $null
                    )
{
    $dateFormat = $(Get-Date).ToString('yyyyMMddTHHmmsss')   
    WriteLine "Sending Email To $To"
    $footer = "<br><div class='disclaimer'><small>This is auto-generated email from {1} by {2} at {0}.</small></div>" -f $(Get-Date), $env:ComputerName, $env:UserName         
    $emailBody = $body -replace "<!--##DO_NOT_REPLY##-->", $footer
    $messageParams = @{
            SmtpServer = "ldnsmtp.sbl.co.uk"
            From =  "{1} <{0}@gmail.com>" -f $env:USERNAME, $From
            To = $To            
            Bcc = "Kiran Kurapaty <kkurapaty@gmail.com>"
            Body = $emailBody
            Subject = $Subject
            Attachments = $FilesToAttach
        }
    try
    {
        Send-MailMessage @messageParams -BodyAsHtml -DeliveryNotificationOption OnFailure,OnSuccess -ErrorAction SilentlyContinue
        WriteLine "Email Sent: $Subject" 3
    }
    catch
    {
        WriteLine "Unable to send email: $Subject, $_" 5
    }
}
#endregion EMAIL HELPERS

#region SQL HELPERS 

function Get-CurrentBusinessDate([String] $AppType, [String]$CAMEnv)
{
    $sqlInstance = Get-CAMSQLInstanceByEnv -AppType $AppType -CAMEnv $CAMEnv
    $myConnection = (Get-SqlServerConnection -DbHost $sqlInstance -DbName "CAM" -IntegratedSecurity $true);
    if ((Test-SqlConnection -SqlConnection $myConnection) -eq $true) {  
        if ($global:GlobalVerbose) { WriteLine "$sqlInstance Connection Successful." }
        [string]$query = "  
        SELECT [BusinessDate]=CONVERT(NVARCHAR, CurrentBusinessDate, 107), 
		       [Status] = Case When CAST(CurrentBusinessDate AS DATE) > Cast(getdate() as Date) then 
                                   case when (DatePart(DW, CAST(CurrentBusinessDate AS DATE)) =2) then 'Good' else 'Over system date' end
						       When CAST(CurrentBusinessDate AS DATE) < Cast(GetDate() as Date) then 'Not in Sync'
						    Else 'Good' 
					    End 
	     FROM ViewCurrentBusinessDate;" 
        $res = ( Execute-SqlQuery -SqlConnection $myConnection -SqlStatement $query ) 
        $dataTable = New-Object System.Data.DataTable 
        $dataTable = $res.Tables[0] 
        $Result = $dataTable | Select BusinessDate, Status;
        #$dataTable | ForEach-Object { Print-KeyValue -KeyName "Current Business Date" -KeyValue "$($_.BusinessDate) - $($_.Status)" } 
        $myConnection.Close();
    } else { 
        throw "No database connection possible!" 
    }
    return $Result;
}

function Get-GetApplicationStatusOverview([String] $AppType, [String]$CAMEnv)
{
    $sqlInstance = Get-CAMSQLInstanceByEnv -AppType $AppType -CAMEnv $CAMEnv;
    $myConnection = (Get-SqlServerConnection -DbHost $sqlInstance -DbName "CAM" -IntegratedSecurity $true);
    if ((Test-SqlConnection -SqlConnection $myConnection) -eq $true) {  
        if ($global:GlobalVerbose) { WriteLine "$sqlInstance Connection Successful." }
        [string]$query = "
        WITH appStatus AS (
 SELECT [ServiceId] = ast.AuditedProcessId
	  , [ServiceName] = REPLACE(REPLACE(RTRIM(apc.ProcessName), ' ', ''), 'CAM', '')
      , [ProcessName] = RTRIM(apc.ProcessName)
  	 -- , [ProcessName] = RTRIM(Coalesce(apc.FriendlyName, apc.ProcessName))
	  , StopForEOD = Coalesce(apc.StopForEOD, 'N')
	  , [BlockedBy] = Coalesce(ast.BlockedBy, -1)
	  --, [BlockedProcess] = RTRIM(Coalesce(ap.FriendlyName, ap.ProcessName, ''))
      , [BlockedProcess] = RTRIM(ap.ProcessName)
	  , [BlockAcknowledged] = Coalesce(ast.BlockAcknowledged, '')
	  , [LastStartTime] = Coalesce(ast.LastStartTime, GetDate())
	  , [LastEndTime] = Coalesce(ast.LastEndTime, GetDate())
	  , [MaxSecondsBetweenRuns] = Cast(Coalesce(apc.MaxSecondsBetweenRuns, 900) as int)
	  , [AcceptableRuntimeInSeconds] = Cast(Coalesce(apc.AcceptableRuntimeInSeconds, 900) as int)
	  , [ElapsedTimeInSec] = Cast( DateDiff(ss, Coalesce(ast.LastStartTime, GetDate()), Coalesce(ast.LastEndTime, GetDate())) as int)
   FROM ApplicationStatus ast (nolock)
   JOIN AuditedProcessesCodes apc (nolock) ON ast.AuditedProcessId = apc.AuditedProcessId
   LEFT JOIN AuditedProcessesCodes ap(nolock)  ON ap.AuditedProcessId = ast.BlockedBy
  WHERE ast.AuditedProcessId NOT IN (3, 15)
)
SELECT  ServiceName, ProcessName, BlockedProcess, LastStartTime, LastEndTime, ElapsedTimeInSec, 
		[Comment]= 
			Case 
				When (a.StopForEOD = 'Y' and a.BlockedBy = 10 and ISNULL(a.BlockAcknowledged, 'N') = 'N') Then 'Blocking End of Day - NEEDS RESTART'                
                When (a.ElapsedTimeInSec > a.AcceptableRuntimeInSeconds) Then 'Acceptable Runtime Exceeded. Perhaps, not responding.'				
                When (a.ElapsedTimeInSec > a.MaxSecondsBetweenRuns) Then 'Maximum duration between runs exceeded. This seems unusal.'				                
                When (a.LastStartTime IS NOT NULL AND a.LastEndTime IS NULL) Then 'Currently Processing...'
				Else ''
			End,
		[CallOut]= 
			Case 
				When (a.StopForEOD = 'Y' and a.BlockedBy = 10 and ISNULL(a.BlockAcknowledged, 'N') = 'N') Then 'failure'				
				When (a.ElapsedTimeInSec > a.AcceptableRuntimeInSeconds) Then 'warning'
				When (a.ElapsedTimeInSec > a.MaxSecondsBetweenRuns) Then 'info'
                When (a.LastStartTime IS NOT NULL AND a.LastEndTime IS NULL) Then 'info'
				Else ''
			End
        --,[LastRunDuration] = dbo.GetDuration(a.LastStartTime, a.LastEndTime)		 
  FROM appStatus a ORDER BY [ServiceName] ASC";
        $res = Execute-SqlQuery -SqlConnection $myConnection -SqlStatement $query;
        
        If ($res.Tables[0] -ne $null) { $table = $res.Tables[0] }
        Else { $table = New-Object System.Collections.ArrayList; }
        
        $myConnection.Close();
        return $table;
        #$dataTable | ForEach-Object { Write-Host $_ } 
    } else { 
        throw "No database connection possible!" 
    }
    return $null;
}

function Get-CurrencyHolidays([String] $AppType, [String] $CAMEnv, [DateTime] $startDate, [DateTime] $endDate, [String] $CurrencyPrefix ='X')
{
    $sqlInstance = Get-CAMSQLInstanceByEnv -AppType $AppType -CAMEnv $CAMEnv;
    $myConnection = (Get-SqlServerConnection -DbHost $sqlInstance -DbName "CAM" -IntegratedSecurity $true);
    $table = New-Object System.Collections.ArrayList;
    if ((Test-SqlConnection -SqlConnection $myConnection) -eq $true) 
    {  
        $startDateStr = $startDate.ToString("yyyy-MM-dd");
        $endDateStr = $endDate.ToString("yyyy-MM-dd");
        if ($global:GlobalVerbose) { WriteLine "$sqlInstance Connection Successful." }
        [string]$query = "SELECT [Currency], [Holiday] = ch.[Date], [Description], [Day] 
                            FROM ViewCurrencyHoliday ch  (nolock)
                           WHERE [Description] <> 'Weekend'
                             AND [Currency] like '$CurrencyPrefix%'
                             AND ch.[Date] BETWEEN '$startDateStr' AND '$endDateStr'
                           ORDER BY ch.[Date], [Currency];";
        $res = Execute-SqlQuery -SqlConnection $myConnection -SqlStatement $query;
        
        If ($res.Tables[0] -ne $null) { $table = $res.Tables[0] }        
        
        $myConnection.Close();
        return $table | Select * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors;        
    } else { 
        throw "No database connection possible!" 
    }
    return $table;
}

function Get-ApplicationStatus([String] $AppType, [String] $CAMEnv, [int] $processId)
{
    $sqlInstance = Get-CAMSQLInstanceByEnv -AppType $AppType -CAMEnv $CAMEnv;
    $myConnection = (Get-SqlServerConnection -DbHost $sqlInstance -DbName "CAM" -IntegratedSecurity $true);
    if ((Test-SqlConnection -SqlConnection $myConnection) -eq $true) 
    {  
        if ($global:GlobalVerbose) { WriteLine "$sqlInstance Connection Successful." }
        [string]$query = "SELECT [ProcessName] = apc.ProcessName, -- Coalesce(apc.FriendlyName, apc.ProcessName),
		                         s.LastStartTime, s.LastEndTime,
                                 [BlockedBy] = ISNULL((SELECT Stuff((SELECT N', ' + RTRIM(apc.ProcessName) -- RTRIM(Coalesce(apc.FriendlyName, apc.ProcessName)) 
                                                         FROM AuditedProcessesCodes apc  (nolock)
						                                 JOIN ApplicationStatus s (nolock) ON s.AuditedProcessId = apc.AuditedProcessId
					                                    WHERE apc.StopForEOD = 'Y' AND s.BlockedBy = $processId AND ISNULL(s.BlockAcknowledged, 'N') = 'N'
					                                  FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,2,N'')), '-') 
                            FROM ApplicationStatus s 
                            JOIN AuditedProcessesCodes apc ON apc.AuditedProcessId = s.AuditedProcessId
                           WHERE s.AuditedProcessId = $processId";
        $res = Execute-SqlQuery -SqlConnection $myConnection -SqlStatement $query;
        
        If ($res.Tables[0] -ne $null) { $table = $res.Tables[0] }
        Else { $table = New-Object System.Collections.ArrayList; }
        
        $myConnection.Close();
        return $table;        
    } else { 
        throw "No database connection possible!" 
    }
    return $null;
}

function Get-QueryResults([String] $AppType, [String] $CAMEnv, [String] $query)
{
    $sqlInstance = Get-CAMSQLInstanceByEnv -AppType $AppType -CAMEnv $CAMEnv;
    $myConnection = (Get-SqlServerConnection -DbHost $sqlInstance -DbName "CAM" -IntegratedSecurity $true);
    $table = New-Object System.Collections.ArrayList;
    if ((Test-SqlConnection -SqlConnection $myConnection) -eq $true) 
    {  
        if ($global:GlobalVerbose) { WriteLine "$sqlInstance Connection Successful." }        

        $res = Execute-SqlQuery -SqlConnection $myConnection -SqlStatement $query -CommandTimeout 600;
        
        If ($res.Tables[0] -ne $null) { $table = $res.Tables[0] }
                
        $myConnection.Close();
        return $table | Select * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors;         
    } else { 
        throw "No database connection possible!" 
    }
    return $table;
}
#endregion SQL HELPERS


#region - Validate Special Accounts for PROD -

function Has-SCPermissions([String] $HostName)
{
    try
    {
        gsv -ComputerName $HostName -Name CAM* | Out-Null
        return $true;
    }
    catch [Exception]
    {
        # WriteLine $_ 1
        return $false;
    }
}

function Reset-ServiceCredentials([String] $AppType, [String] $CAMEnv, [String] $hostName, [String] $ServiceAction)
{
    $Global:UserCredential = $null;
    $Global:HasSCPermissions = $false;    
    Check-ServiceCredentials -AppType $AppType -CAMEnv $CAMEnv -HostName $hostName -ServiceAction $serviceAction;
}

function Check-ServiceCredentials ([String] $AppType, [String] $CAMEnv, [String] $hostName, [String] $ServiceAction)
{        
    WriteLine "Checking Permissions..." 6
    if (($Global:UserCredential -eq $null) -or (-not $Global:HasSCPermissions))
    {    
        $Global:HasSCPermissions = Has-SCPermissions -HostName $hostName;
        if ($Global:HasSCPermissions) { return; }

        If (-not [string]::IsNullOrEmpty($ServiceAction) -and ($CAMEnv -match "PROD")) 
        {
            Write-Host "* * * * * * * * * * * * * * * * * * * * * * * * * "
            Write-Host "  We nedd Breakglass account to perform this action ..." -ForegroundColor Magenta
            # $bg_userName = "SBINTL\CAME2019_bg"; 
            Write-Host "* * * * * * * * * * * * * * * * * * * * * * * * * "

            $bg_userName = (Prompt-User -Message "BREAKGLASS Account" -IsRequired -Hint "$env:USERDOMAIN\SVC_XXX_PRD").ToString().ToUpper();
            $bg_password = (Prompt-Password -Message "BREAKGLASS Password" -IsRequired).ToString();    
        } else 
        {
            Write-Host "* * * * * * * * * * * * * * * * * * * * * * * * * "
            Write-Host "  Fetching Service Credentials ..." -ForegroundColor Magenta            
            Write-Host "* * * * * * * * * * * * * * * * * * * * * * * * * "

            $svcAccount = GetCAM-SvcUserAccount -AppType $AppType -CAMEnv $CAMEnv
            $bg_userName = $svcAccount.UserName;
            $bg_password = $svcAccount.Password;
        }

        if ([string]::IsNullOrEmpty($bg_password)) {        
            $Global:UserCredential =  Get-Credential -UserName:"$bg_userName" -Message:"Breakglass Account" -
        } else {
            $securePassword = ConvertTo-SecureString $bg_password -AsPlainText -Force    
            $Global:UserCredential = New-Object System.Management.Automation.PSCredential ($bg_userName, $securePassword)
        }
        $bg_userName = $Global:UserCredential.username
        $bg_password = $Global:UserCredential.GetNetworkCredential().password
        try 
        {
            # Get current domain using logged-on user's credentials
            $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
            $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain, $bg_userName, $bg_password)
            if ($domain.Name -eq $null) 
            {
                WriteLine "Authentication failed - please verify Breakglass account/username and password." -MessageType 2
                Exit(1)
            } 
            else 
            {
                $Global:HasSCPermissions = $true;
                WriteLine "Successfully authenticated $bg_userName with $($domain.Name)" -MessageType 3
            }
        }
	    catch [Exception] {
		    Write-Error $Error[0]
		    $err = $_.Exception
		    while ( $err -ne $null) {
			    $err = $err.InnerException
			    WriteLine "$($err.Message)" 2
		    }
            WriteLine $StackTrace 2;
	    }
    }
}
#endregion

#endregion Originating script: fileIOUtil.ps1