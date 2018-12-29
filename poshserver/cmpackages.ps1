$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default "all"
$Script:SearchType  = Get-PageParam -TagName 'x' -Default "like"
$Script:SortField   = Get-PageParam -TagName 's' -Default "name"
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$Script:IsFiltered  = $False
$Script:PageTitle   = "CM Software"
$Script:PageCaption = "CM Software"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

$Script:TabSelected = $Script:SearchValue
if ($Script:SearchValue -eq 'all') {
    $Script:SearchValue = ""
}

$xxx = "requesting query result"
$content = Get-SkQueryTable3 -QueryFile "cmpackages.sql" -PageLink "cmpackages.ps1" -Columns ('PackageID','PkgName','PackageType','PkgType','Description','Version')

if ($Script:SearchField -eq 'PkgType') {
    $cap = Get-CmPackageTypeName -PkgType $Script:SearchValue
    $Script:PageTitle += ": $cap"
    $Script:PageCaption = $PageTitle
}

$tabset = New-MenuTabSet -BaseLink 'cmpackages.ps1?x=begins&f=name&v=' -DefaultID $TabSelected
$content += Write-DetailInfo -PageRef "cmpackages.ps1" -Mode $Detailed

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