$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$Script:SortField   = Get-PageParam -TagName 's' -Default ""
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:CustomName  = Get-PageParam -TagName 'n' -Default ""

$Script:PageTitle   = "CM Discovery Method: $CustomName"
$Script:PageCaption = "CM Discovery Method: $CustomName"

$tabset  = ""

$content = Get-SkQueryTable3 -QueryFile "cmdiscovery.sql" -PageLink "cmdisc.ps1" -Columns ('ItemType','ID','Sitenumber','Name','Value1','Value2','Value3','SourceTable') -NoUnFilter

$content += Write-DetailInfo -PageRef "cmdisc.ps1" -Mode $Detailed

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