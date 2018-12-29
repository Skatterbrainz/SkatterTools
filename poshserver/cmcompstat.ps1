$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default 'exact'
$Script:SortField   = Get-PageParam -TagName 's' -Default 'ComponentName'
$Script:CustomName  = Get-PageParam -TagName 'n' -Default ""
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$Script:PageTitle   = "CM Site Components"
$Script:PageCaption = "CM Site Components"
$tabset = ""

$content = Get-SkQueryTable3 -QueryFile "cmcomponentstatus.sql" -PageLink "cmcompstat.ps1" -Columns ('ComponentName','Status','State','LastContacted','Info','Warning','Error')

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