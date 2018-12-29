$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default "like"
$Script:SortField   = Get-PageParam -TagName 's' -Default "QueryName"
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:CustomName  = Get-PageParam -TagName 'n' -Default ""
$Script:IsFiltered  = $False
$Script:PageTitle   = "CM Queries"
$Script:PageCaption = "CM Queries"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

$content = Get-SkQueryTable3 -QueryFile "cmqueries.sql" -PageLink "cmqueries.ps1" -Columns ('QueryName','QueryID','Comments','TargetClassName','LimitToCollectionID')

#$tabset = New-MenuTabSet -BaseLink 'cmqueries.ps1?x=begins&f=name&v=' -DefaultID $TabSelected
$content += Write-DetailInfo -PageRef "cmqueries.ps1" -Mode $Detailed

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