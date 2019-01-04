$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default "like"
$Script:SortField   = Get-PageParam -TagName 's' -Default "Name"
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:CustomName  = Get-PageParam -TagName 'n' -Default ""
$Script:IsFiltered  = $False
$Script:PageTitle   = "CM Boundary Groups"
$Script:PageCaption = "CM Boundary Groups"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

$content = Get-SkQueryTableMultiple -QueryFile "cmboundarygroups.sql" -PageLink "cmbgroups.ps1" -Columns ('BGName','GroupID','Description','Flags','DefaultSiteCode','CreatedOn','Boundaries','SiteSystems')

#$tabset = New-MenuTabSet -BaseLink 'cmbgroups.ps1?x=begins&f=bgname&v=' -DefaultID $Script:TabSelected
$content += Write-DetailInfo -PageRef "cmgroups.ps1" -Mode $Detailed

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