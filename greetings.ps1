$hour = (Get-Date).Hour
[string]$suffix = "";
[string]$dayOrEvening ="great day";
if ($hour -le 12)
{
    $suffix = "Morning";
}
elseif ($hour -gt 12 -and $hour -le 16)
{
    $suffix = "Afternoon";
}

elseif ($hour -gt 16 -and $hour -le 19)
{
    $suffix = "Evening";
    $dayOrEvening = "wonderful evening";
}
else
{
    $suffix = "Night";
    $dayOrEvening = "pleasant night";
}

Write-Host "** " -ForegroundColor Green -NoNewLine
Write-Host " Good $suffix Kiran, Hope you have a $($dayOrEvening.ToLower())! " -ForegroundColor Cyan -NoNewline
Write-Host " **" -ForegroundColor Green
