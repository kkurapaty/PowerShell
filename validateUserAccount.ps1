CLS
## MAKE SURE TO ADD BELOW TO YOUR SCRIPT ##
. "$PSScriptRoot\fileIOUtil.ps1" -Force
#END OF USAGE


Clear
function Print-Header() 
{
    Write-Host "" -ForegroundColor Green
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*" -ForegroundColor Green
    Write-Host "* #                                                                             # *" -ForegroundColor Green
    Write-Host "* * *" -ForegroundColor Green -NoNewline
    Write-Host "   Validate User Accounts" -ForegroundColor Cyan -NoNewline
    Write-Host " -" -NoNewline
    Write-Host "   Script by" -ForegroundColor Gray -NoNewline
    Write-Host " KIRAN KURAPATY " -ForegroundColor Yellow -NoNewline
    Write-Host "   * * *" -ForegroundColor Green
    Write-Host "* #                                                                             # *" -ForegroundColor Green
    Write-Host "*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*" -ForegroundColor Green
    Write-Host "" -ForegroundColor Green
}

function Convert-ADSLargeInteger {
    # Take a large value integer and return a 32 bit value
    [cmdletbinding()]
    Param([Parameter(Position = 0, Mandatory)] [object]$adsLargeInteger)
 
    $highPart = $adsLargeInteger.GetType().InvokeMember("HighPart",'GetProperty',$null, $adsLargeInteger, $null)
    $lowPart = $adsLargeInteger.GetType().InvokeMember("LowPart",'GetProperty', $null, $adsLargeInteger, $null)
    $bytes = [System.BitConverter]::GetBytes($highPart)
    $tmp = [System.Byte[]]@(0,0,0,0,0,0,0,0)
    [System.Array]::Copy($bytes, 0, $tmp, 4, 4)
    $highPart = [System.BitConverter]::ToInt64($tmp, 0)
    $bytes = [System.BitConverter]::GetBytes($lowPart)
    $lowPart = [System.BitConverter]::ToUInt32($bytes, 0)
    Write-Output ($lowPart + $highPart)
}

function ValidateUserAccount([string]$user, [string]$password) {
    WriteLine "Please wait, Validating $user account..."
    try {
          $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
          $credential = New-Object System.Management.Automation.PSCredential ($user, $securePassword)
          $username = $credential.username
          $password = $credential.GetNetworkCredential().password

          # Get current domain using logged-on user's credentials
          $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
          Write-Host $CurrentDomain
          $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

          if ($domain.name -eq $null)
          {
            #Write-Error $Error[0]
            WriteLine "Authentication failed - please verify username and password." -MessageType 2
            #Exit(1)
          }
          else
          {
            # $domain.ConvertLargeIntegerToInt64($domain.minPwdAge.value)    
        
            $domain | Select @{Name = "Name";Expression = {$_.Name.value}},                     
                             @{Name = "DN";Expression = {$_.DistinguishedName.value}},
                             @{Name = "Created";Expression = {$_.whencreated.value}},
                             @{Name = "Modified";Expression = {$_.whenchanged.value}},
                             @{Name = "PwdAge"; Expression = {(new-timespan -seconds ($_.ConvertLargeIntegerToInt64($_.minPwdAge.value) /10000000)).ToString() }} | Out-Null
                         
            WriteLine "Successfully authenticated $user with $($domain.Name)" -MessageType 3
          }
        }
        catch [Exception] {
            WriteLine "Could not validate $user account." -MessageType 2
            Write-Error $Error[0]
		    $err = $_.Exception
		    while ( $err.InnerException ) {
			    $err = $err.InnerException
			    Write-Host "[ERROR] $err.Message" -ForegroundColor Red
		    }
	    }    
    Write-Host
}

Clear

$serviceAccounts = [ORDERED] @{
    "DOMAIN\svc_win_dev"  = "";    
    "DOMAIN\svc_win_uat"  = "";    
    "DOMAIN\svc_win_sit"  = "";    
    "DOMAIN\svc_win_prd"  = "";
};

Print-Header;
Write-Host ""
while ((Prompt-User -Message "Do you have account to validate ?" -Hint "Y/N" -IsRequired).ToString().ToUpper() -like "Y") 
{ 
    $userName = (Prompt-User -Message "User Name" -Hint "DOMAIN\username" -IsRequired)
    $userPassword = (Prompt-Password -Message "Password" -Hint "your password may visible")
    ValidateUserAccount -user $userName -password $userPassword
}

Write-Host ""
if ((Prompt-User -Message "Do you wish to validate accounts ?" -Hint "Y/N" -IsRequired).ToString() -like "Y")
{
    Write-Host "Validating Predefined User/Service Accounts, Please Wait..." -ForegroundColor Cyan
    foreach($account in $serviceAccounts.Keys) #  | Sort-Object -Property Key
    {
        # Write-Host "Checking $account ..." # =>  $($serviceAccounts[$account])"
        ValidateUserAccount $account $($serviceAccounts[$account])
    }
}

Write-Host ""

Print-ScriptCompleted "Authentication";
