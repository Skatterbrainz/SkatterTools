$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "like"
$SortField   = Get-PageParam -TagName 's' -Default "name"
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Boundary Group: $CustomName"
$PageCaption = "CM Boundary Group: $CustomName"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

switch ($TabSelected) {
    'General' {
        $xxx += ";queryfile: cmboundarygroup.sql"
        $content = Get-SkQueryTable2 -QueryFile "cmboundarygroup.sql" -PageLink "cmbgroup.ps1" -Columns ('BGName','DefaultSiteCode','GroupID','GroupGUID','Description','Flags','CreatedBy','CreatedOn','ModifiedBy','ModifiedOn','MemberCount','SiteSystemCount','Shared')
        break;
    }
    'Boundaries' {
        $xxx += ";queryfile: cmboundaries.sql"
        $content = Get-SkQueryTable3 -QueryFile "cmboundaries.sql" -PageLink "cmbgroup.ps1" -Columns ('DisplayName','BoundaryID','BValue','BoundaryType','BoundaryFlags','CreatedBy','CreatedOn','ModifiedBy','ModifiedOn','GroupID','BGName') -NoUnFilter
        break;
    }
}

if ($SkNotesEnable -eq 'true') {
    $tabs = @('General','Boundaries','Systems','Notes')
}
else {
    $tabs = @('General','Boundaries','Systems')
}
$tabset = New-MenuTabSet2 -MenuTabs $tabs -BaseLink "cmbgroup.ps1"
$content += Write-DetailInfo -PageRef "cmbgroup.ps1" -Mode $Detailed

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