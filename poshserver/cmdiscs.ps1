$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default "like"
$Script:SortField   = Get-PageParam -TagName 's' -Default "itemtype"
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:CustomName  = Get-PageParam -TagName 'n' -Default ""
$Script:IsFiltered  = $False
$Script:PageTitle   = "CM Discovery Methods"
$Script:PageCaption = "CM Discovery Methods"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

$content = Get-SkQueryTable3 -QueryFile "cmdiscoveries.sql" -PageLink "cmdiscs.ps1" -Columns ('ItemType','SiteNumber','SourceTable')

#$tabset = New-MenuTabSet -BaseLink 'cmdiscs.ps1?x=begins&f=name&v=' -DefaultID $TabSelected
$content += Write-DetailInfo -PageRef "cmdiscs.ps1" -Mode $Detailed

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