$Script:PageTitle   = "CM SQL Server: Database Recovery Models"
$Script:PageCaption = "CM SQL Server: Database Recovery Models"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

try {
    $content += (Get-DbaDbRecoveryModel -SqlInstance $CmDbHost -ErrorAction Continue | 
        ConvertTo-Html -Fragment) -replace '<table>', '<table id=table1>'

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