
CLS
## MAKE SURE TO ADD BELOW TO YOUR SCRIPT ##
. "$PSScriptRoot\fileIOUtil.ps1" -Force
#END OF USAGE


# Base Directory
$configFileName = "C:\Work\Scripts\scriptSettings.json"

# Load and parse the JSON configuration file
try {
	$global:Config = Get-Content "$configFileName" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
} catch {
	Write-PoshError -Message "The configuration file is missing!" -Stop
}

# Check the configuration
if (!($Config)) {
	Write-PoshError -Message "The configuration file is missing!" -Stop
}

function Get-ScriptInfo
{
    $ScriptInfo = ($Config.ScriptInfo) | Select -Property * # | ConvertTo-Html | Out-String
    if ($ScriptInfo -ne $null) {
        Print-KeyValue "Title" $ScriptInfo.Title
        Print-KeyValue "Author" $ScriptInfo.Author
        Print-KeyValue "Dated" $ScriptInfo.Created
        Print-KeyValue "Link" $ScriptInfo.Link
        Print-KeyValue "License" $ScriptInfo.License
        Print-KeyValue "Copyright" $ScriptInfo.Copyright
    }
    return $ScriptInfo;
}

# Internal Version information (For future use)
$ConfigVersion = ($Config.Params.ConfigVersion)

# Environment (Production, Leaduser, Testing, Development)
$Environment = ($Config.Params.Environment)

$Emailing = ($Config.Emailing)

Clear;

Script::RepeatText -Text "#*" -Count 40 
Get-ScriptInfo | Out-Null;
Script::RepeatText -Text "#*" -Count 40 
Write-Host

<#	Any further Script here #>
Write-Host "Version: $ConfigVersion"
Write-Host "Environment: $Environment"
if ($Emailing.Enabled -eq "true")
{
    Write-Host "Sender: $($Emailing.Settings.Sender)"
    Write-Host "Recipients: $($Emailing.Settings.Recipients)"
    Write-Host "Subject: $($Emailing.Settings.Subject)"
}