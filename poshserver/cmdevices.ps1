$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$Script:SortField   = Get-PageParam -TagName 's' -Default 'Name'
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default $DefaultComputersTab
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:PageFile    = "cmdevices.ps1"

$Script:PageTitle   = "CM Devices"
$Script:PageCaption = "CM Devices"
$Script:IsFiltered  = $False

$content = ""

if ($Script:SearchField -eq 'name') {
    $Script:TabSelected = $SearchValue
}

if ($Script:SearchValue -eq 'all') {
    $Script:SearchValue = ""
    $Caption = "All"
}
else {
    $Caption = $Script:SearchValue
}

$content = Get-SkQueryTable3 -QueryFile "cmdevices.sql" -PageLink "cmdevices.ps1" -Columns ('ResourceID','Name','Manufacturer','Model','OSName','OSBuild','ADSiteName') -ColumnSorting

$tabset = New-MenuTabSet -BaseLink "cmdevices.ps1`?x=begins&f=name&v=" -DefaultID $Script:TabSelected

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