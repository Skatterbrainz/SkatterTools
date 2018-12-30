$Script:PageTitle   = "CM SQL Server Report"
$Script:PageCaption = "CM SQL Server Report"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

try {
    $content = "<h3>Database State</h3>"
    $content += (Get-DbaDbState -SqlInstance $CmDbHost -Database "CM_$CmSiteCode" | ConvertTo-Html -Fragment) -replace '<table>','<table id=table1>'

    $content += "<h3>Maximum Memory Allocation</h3>"
    $content += (Get-DbaMaxMemory -SqlInstance $CmDbHost -ErrorAction Continue | ConvertTo-Html -Fragment) -replace '<table>', '<table id=table1>'

    $content += "<h3>Memory Usage</h3>"
    $content += (Get-DbaMemoryUsage -ComputerName $CmDbHost -ErrorAction Continue | ConvertTo-Html -Fragment) -replace '<table>', '<table id=table1>'

    $content += "<h3>Startup Parameters</h3>"
    $content += (Get-DbaStartupParameter -SqlInstance $CmDbHost | ConvertTo-Html -Fragment) -replace '<table>', '<table id=table1>'

    $content += "<h3>Disk Allocation</h3>"
    $content += (Test-DbaDiskAllocation -ComputerName $CmDbHost -ErrorAction Continue | ConvertTo-Html -Fragment) -replace '<table>','<table id=table1>'

    $content += "<h3>Latency</h3>"
    $content += (Get-DbaIoLatency -SqlInstance $CmDbHost -ErrorAction Continue | ConvertTo-Html -Fragment) -replace '<table>', '<table id=table1>'

}
catch {
    $content = "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
}


@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

$tabset
$content

</body>
</html>
"@