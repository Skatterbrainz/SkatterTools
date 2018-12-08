$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'CollectionName'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$CollectionType = Get-PageParam -TagName 't' -Default '2'

if ($CollectionType -eq '2') {
    $Ctype = "Device"
}
else {
    $Ctype = "User"
}
$PageTitle   = "CM $CType Collection: $CustomName"
$PageCaption = "CM $CType Collection: $CustomName"
$content     = ""
$tabset      = ""

# add code here

$content += "<table id=table2><tr><td style=`"height:150px;text-align:center`">"
$content += "Be patient. I'm still working on it. :)</td></tr></table>"

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