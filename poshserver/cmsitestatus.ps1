$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$Script:SortField   = Get-PageParam -TagName 's' -Default 'sitesystem'
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default 'All'
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:IsFiltered  = $False
$Script:PageTitle   = "CM Site Status"
$Script:PageCaption = "CM Site Status"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

$content = Get-SkQueryTableMultiple -QueryFile "cmsitestatus.sql" -PageLink "cmsitestatus.ps1" -Columns ('SiteStatus','Role','SiteCode','SiteSystem','TimeReported')
$content += Write-DetailInfo -PageRef "cmsitestatus.ps1" -Mode $Detailed

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

$content

</body>
</html>
"@