$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default ""
$SortField   = Get-PageParam -TagName 's' -Default ""
$SortOrder   = Get-PageParam -TagName 'so' -Default ""
$TabSelected = Get-PageParam -TagName 'tab' -Default ""
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Applications"
$PageCaption = "CM Applications"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

$content = "<table id=table2><tr><td style=`"height:200px;text-align:center`">"
$content += "Coming soon</td></tr></table>"

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