New-Task |                        
    Add-TaskAction -Hidden -Script {                        
        $ErrorActionPreference = "Stop"                        
        try {                        
            $messageParameters = @{                        
                Subject = "Installed Program report for $env:ComputerName.$env:USERDNSDOMAIN - $((Get-Date).ToShortDateString())"                        
                Body = Get-WmiObject Win32_Product | Select-Object InstallDate, Name, Version, Vendor `
                                        | ? { $_.InstallDate -ge 20211028 } `
                                        | Sort-Object Name | ConvertTo-Html | Out-String                        
                From = "kkurapaty@gmail.com"
                To = "kkurapaty@gmail.com"
                SmtpServer = "smtp.gmail.com"
            }                        
            Send-MailMessage @messageParameters -BodyAsHtml                        
        } catch {                        
            $_ | Out-File $env:TEMP\ProblemsSendingHotfixReport.log.txt -Append -Width 1000                        
        }                        
    } |            
    Add-TaskTrigger -Daily -At "9:00 AM" |                        
    Add-TaskTrigger -OnRegistration |                         
    Register-ScheduledTask "DailyHotfixReport"