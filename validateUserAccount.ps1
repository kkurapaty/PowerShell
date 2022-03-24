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
    return ($lowPart + $highPart);
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

function Convert-ADSearchResult {
    [cmdletbinding()] Param(
    [Parameter(Position = 0,Mandatory,ValueFromPipeline)]
    [ValidateNotNullorEmpty()] [System.DirectoryServices.SearchResult]$SearchResult
    )
    Begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
    }
    Process {
        Write-Verbose "Processing result for $($searchResult.Path)"
        #create an ordered hashtable with property names alphabetized
        $props = $SearchResult.Properties.PropertyNames | Sort-Object
        $objHash = [ordered]@{}
        foreach ($p in $props) {
         $value =  $searchresult.Properties.item($p)
         if ($value.count -eq 1) {
            $value = $value[0]
         }
         $objHash.add($p,$value)
        }
        New-Object PSObject -property $objHash
    }
    End {
        Write-Verbose "Ending $($MyInvocation.MyCommand)"
    }
}
function SearchUserAccount([string] $userName) {
    WriteLine "Please wait, Searching for $userName account..."
    try {
          $adSearcher = New-Object System.DirectoryServices.DirectorySearcher;
          if ($adSearcher -eq $null)
          {
            #Write-Error $Error[0]
            WriteLine "Could not instantiate ADSI Searcher." -MessageType 2
            #Exit(1)
          }
          else
          {
            # $adSearcher.FindAll()    
            if ([string]::IsNullOrWhiteSpace($userName)) { 
                $adSearcher.filter = "(objectclass=user)"
            } else {
                $adSearcher.filter = "(&(objectclass=user)(samaccountname=$userName))"
            }
            #$adSearcher.filter = "(&(objectclass=user)(department=finance))"
            
            # Ref: https://www.rlmueller.net/UserAttributes.htm
            $props = "distinguishedname","name", "displayName", "samaccountname","title","department","directreports", 
                     "whencreated","whenchanged","givenname","sn","userprincipalname","adspath", "l", "c", "physicalDeliveryOfficeName",
                     "telephoneNumber", "mobile", "manager", "accountExpires", "employeeID", "userAccountControl",
                     "lastLogon", "lastLogonTimestamp",  "userWorkstations", "minPwdAge",
                     "meetingID", "meetingDescription", "meetingURL"
            foreach ($item in $props) {
                $adSearcher.PropertiesToLoad.Add($item) | out-null
            }

             $adSearcher.FindAll() | Convert-ADSearchResult |
                      Select @{Name = "Name";Expression = {$_.Name}}, `
                             @{Name = "Display Name"; Expression = {$_.displayName}}, `
                             @{Name = "Emp Id";Expression = {$_.EmployeeID}},`
                             @{Name = "GivenName";Expression = {$_.GivenName}},`
                             @{Name = "Surname";Expression = {$_.SN}},`
                             @{Name = "samAccountName";Expression = {$_.samAccountName}},`
                             @{Name = "Disabled";Expression = {$_.userAccountControl}},`
                             @{Name = "Title";Expression = {$_.Title}},`
                             @{Name = "Department";Expression = {$_.Department}},`
                             @{Name = "Direct Reports";Expression = {$_.DirectReports}},`
                             @{Name = "UserPrincipal";Expression = {$_.UserPrincipalName}},`
                             @{Name = "Manager"; Expression = {$_.manager}}, `
                             @{Name = "City";Expression = {$_.l}},`
                             @{Name = "Country";Expression = {$_.c}},`
                             @{Name = "Office"; Expression = {$_.physicalDeliveryOfficeName}}, `
                             @{Name = "Phone"; Expression = {$_.telephoneNumber}}, `
                             @{Name = "Mobile"; Expression = {$_.mobile}}, `
                             @{Name = "Workstation"; Expression = {$_.userWorkstations}}, `
                             @{Name = "Account Expires";Expression = {[datetime]::fromfiletime($_.AccountExpires) }},` 
                             @{Name = "Created";Expression = {$_.whencreated}},`
                             @{Name = "Modified";Expression = {$_.whenchanged}},` 
                             @{Name = "Last Logon";Expression = {[datetime]::fromfiletime($_.lastLogonTimestamp) }},`                             
                             @{Name = "Last Logoff";Expression = {[datetime]::fromfiletime($_.lastLogoff) }},`
                             #@{Name = "AdsPath";Expression = {$_.AdsPath}},`
                             #@{Name = "DN";Expression = {$_.DistinguishedName}},`                                                          
                             @{Name = "PwdAge"; Expression = {(new-timespan -seconds ($_.ConvertLargeIntegerToInt64($_.minPwdAge) /10000000)).ToString() }} | Out-GridView
             
            
            #$adSearcher.FindAll() | Convert-ADSearchResult | Select Name,GivenName,Title,SamAccountName,SN,UserPrincipalName,Department,City,Country,WhenCreated,WhenChanged | Out-GridView
            
            #WriteLine "Users by Department" -MessageType 1
            #$adSearcher.FindAll() | Convert-ADSearchResult | Group Department -NoElement | Sort Count -Descending
            #$adSearcher.FindAll() | Convert-ADSearchResult | Select Name,Department,Title
            
          }
        }
        catch [Exception] {
            WriteLine "Could not fetch $userName account." -MessageType 2
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
while ((Prompt-User -Message "Would you like to search for an account ?" -Hint "Y/N" -IsRequired).ToString().ToUpper() -like "Y") 
{ 
    $userName = (Prompt-User -Message "User Name" -Hint "username" -IsOptional)    
    SearchUserAccount $userName
}

Write-Host ""
if ((Prompt-User -Message "Do you wish to validate service accounts ?" -Hint "Y/N" -IsRequired).ToString() -like "Y")
{
    Write-Host "Validating Predefined User/Service Accounts, Please Wait..." -ForegroundColor Cyan
    foreach($account in $serviceAccounts.Keys) #  | Sort-Object -Property Key
    {
        # Write-Host "Checking $account ..." # =>  $($serviceAccounts[$account])"
        ValidateUserAccount $account $($serviceAccounts[$account])
    }
}

Write-Host ""

Print-ScriptCompleted "Validatation";
