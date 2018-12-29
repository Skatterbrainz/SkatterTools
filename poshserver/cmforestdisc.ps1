$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "like"
$SortField   = Get-PageParam -TagName 's' -Default "name"
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM AD Forest Discovery"
$PageCaption = "CM AD Forest Discovery"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

$content = Get-SkQueryTable3 -QueryFile "cmforests.sql" -PageLink "cmforests.ps1" -Columns ('ForestID','SMSSiteCode','SMSSiteName','LastDiscoveryTime','LastDiscoveryStatus','LastPublishingTime','PublishingStatus','DiscoveryEnabled','PublishingEnabled')

#$tabset = New-MenuTabSet -BaseLink 'cmforestdisc.ps1' -DefaultID $TabSelected
$content += Write-DetailInfo -PageRef "cmforestdisc.ps1" -Mode $Detailed

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