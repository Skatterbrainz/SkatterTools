$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "equals"
$SortField   = Get-PageParam -TagName 's' -Default ""
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$TabSelected = Get-PageParam -TagName 'tab' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""

$PageTitle   = "Custom Reports"
$PageCaption = "Custom Reports"
$SortField   = ""
$content     = ""
$tabset      = ""

try {
    $rpath  = $(Join-Path -Path $PSScriptRoot -ChildPath "reports")
    $rfiles = Get-ChildItem -Path $rpath -Filter "*.sql" | Sort-Object Name
    $content = "<table id=table1><tr><th>Report Name</th></tr>"
    $rowcount = $rfiles.Count
    $rfiles | %{$content += "<tr><td><a href=`"skreport.ps1?n=$($_.Name)`" title=`"Run Report`">$($_.Name -replace '.sql','')</a></td></tr>"}
    $content += "<tr><td class=lastrow>$rowcount reports</td></tr>"
    $content += "</table>"
}
catch {}

$content += Write-DetailInfo -PageRef "skreports.ps1" -Mode $Detailed

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