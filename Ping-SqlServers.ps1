<#
	.SYNOPSIS
		Ping-SqlServers
	.DESCRIPTION
		Ping SQL Servers and get status
	.PARAMETER serverList
		Comma delimited server name list
	
#>

param
(
	[string]$serverList = "$(Read-Host 'Server Instances [e.g. SQLSERVER\DB ]')"
)

begin {
	[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
Write-Host "Begin"
}
process {
    Clear
	try {
		$servers = $serverList.Split(",")
		$pingResults = @()

		Write-Verbose "Pinging servers...please wait"

		foreach ($serverInstance in $servers) {
			$serverInstance = $serverInstance.TrimStart(" ")
			$nm = $serverInstance.Split("\")
			$machine = $nm[0]

			# Ping the machine to see if it's on the network
			$results = Get-WMIObject -query "Select StatusCode from Win32_PingStatus where Address = '$machine'"
			$responds = $false
			foreach ($result in $results) {
				# If the machine responds break out of the result loop and indicate success
				if ($result.statuscode -eq 0) {
					$responds = $true
					break
				}
			}

			if ($responds) {
				# Gather info from the server because it responds
				$server = new-object Microsoft.SqlServer.Management.Smo.Server $serverInstance
				$r = $server.Information | select Urn, Version, Edition
				
				$pingRecord = New-Object -TypeName PSObject -Property @{
					Server = $server
					Urn = $r.Urn
					Version = $r.Version
					Edition = $r.Edition
					Status = "Ping Successful"
				}
				$pingResults += $pingRecord

			} else {
				# Let the user know we couldn't connect to the server
				$pingRecord = New-Object -TypeName PSObject -Property @{
					Server = $machine
					Urn = ""
					Version = ""
					Edition = ""
					Status = "Ping failed"
				}
				$pingResults += $pingRecord
			}
		}
		Write-Output $pingResults
	}
	catch [Exception] {
		Write-Error $Error[0]
		$err = $_.Exception
		while ( $err.InnerException ) {
			$err = $err.InnerException
			Write-Output $err.Message
		}
	}
}