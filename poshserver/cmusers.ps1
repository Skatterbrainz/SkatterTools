$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$Script:SortField   = Get-PageParam -TagName 's' -Default 'UserName'
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default $DefaultGroupsTab
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""

$Script:PageTitle   = "CM Users"
$Script:PageCaption = "CM Users"

$Script:TabSelected = $Script:SearchValue
if ($Script:SearchValue -eq 'all') {
    $Script:SearchValue = ""
}

$content = Get-SkQueryTable3 -QueryFile "cmusers.sql" -PageLink "cmusers.ps1" -Columns ('ResourceID','UserName','AADUserID','Domain','UPN','Department','Title') -ColumnSorting

$tabset = New-MenuTabSet -BaseLink 'cmusers.ps1?x=begins&f=UserName&v=' -DefaultID $TabSelected
$content += Write-DetailInfo -PageRef "cmusers.ps1" -Mode $Detailed

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

$tabset
$content

$(if ($DebugMode -eq 1) {"<p>$query</p>"})

</body>
</html>
"@