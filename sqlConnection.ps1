function Test-SqlConnection 
{
    param(
        [Parameter(Mandatory)] [string] $ServerName,
        [Parameter(Mandatory)] [string] $DatabaseName,
        [switch] $AuthenticationRequired
    )

    $ErrorActionPreference = 'Stop'
    
    if ($AuthenticationRequired)
    {
        $Credential = (Get-Credential)
        $userName = $Credential.UserName
        $password = $Credential.GetNetworkCredential().Password
        $connectionString =	'Provider=SQLOLEDB;Server={0};Database={1};UID={2};Pwd={3};Connection Timeout=500;' -f $ServerName, $DatabaseName, $userName, $password
    }
    else
    {
        $connectionString = 'Data Source={0};database={1};User ID=CAM;Password=CAM' -f $ServerName, $DatabaseName
    }

    try 
    {
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
        $sqlConnection.Open()
        
        Send-Email -Subject "Connection Successful" -Body "Tested: Sql Connection: {0}" -f $connectionString
        ## This will run if the Open() method does not throw an exception
        $true
    } 
    catch 
    { 
        Send-Email -Subject "Connection failed" -Body "Tested: Sql Connection: {0}" -f $connectionString
        $false 
    } 
    finally 
    {
        ## Close the connection when we're done
        $sqlConnection.Close()
    }
}

function Send-Email
{
    Param(  [ValidateNotNullOrEmpty()] [string] $Subject, [ValidateNotNullOrEmpty()] [string] $Body )
    $footer = "<br><br><hr><small>This is autogenerated email by {0} at {1} </small>" -f $env:USERNAME, $(Get-Date)
    $messageParams = @{
         SmtpServer = "smtp.gmail.com"
         From = "No Reply <{0}@gmail.com>" -f $env:USERNAME
         To = @("Kiran Kurapaty <kkurapaty@gmail.com>")
         Body = "{0}{1}" -f $Body, $footer
         Subject = $Subject
    }
    try
    {
        Send-MailMessage @messageParams -BodyAsHtml -DeliveryNotificationOption OnFailure,OnSuccess -ErrorAction SilentlyContinue
        Write-Host "Sent: $Subject" 
    }
    catch
    {
        Write-Host "Unable to send email: $Subject" 
    }
}


# .\sqlConnection.ps1
Test-SqlConnection -ServerName 'SQLSERVER\UAT' -DatabaseName 'Database1' 
