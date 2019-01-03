$ProductName = Get-PageParam -TagName 'p' -Default ""
$Publisher   = Get-PageParam -TagName 'm' -Default ""
$Version     = Get-PageParam -TagName 'v' -Default ""
$SortField   = Get-PageParam -TagName 's' -Default "ComputerName"
$PageTitle   = "App Installs: $ProductName"
$PageCaption = "App Installs: $ProductName"
$SortField   = ""
$content     = ""
$tabset      = ""

try {
    if ([string]::IsNullOrEmpty($ProductName)) {
        throw "Product name was not specified"
    }
$query = "SELECT 
	dbo.v_R_System.ResourceID, 
	dbo.v_R_System.Name0 as ComputerName
FROM 
	dbo.v_GS_ADD_REMOVE_PROGRAMS INNER JOIN
    dbo.v_R_System ON dbo.v_GS_ADD_REMOVE_PROGRAMS.ResourceID = dbo.v_R_System.ResourceID
WHERE 
	(dbo.v_GS_ADD_REMOVE_PROGRAMS.DisplayName0 = '$ProductName')"

    if (![string]::IsNullOrEmpty($Publisher)) {
        $query += " AND (dbo.v_GS_ADD_REMOVE_PROGRAMS.Publisher0 = '$Publisher')"
    }
    if (![string]::IsNullOrEmpty($Version)) {
	    $query += " AND (dbo.v_GS_ADD_REMOVE_PROGRAMS.Version0 = '$Version')"
    }

    $query += " ORDER BY Name0"

    $result = @(Invoke-DbaQuery -SqlInstance $CmDbHost -Database "CM_$CmSiteCode" -Query $query -ErrorAction SilentlyContinue)
    $result = $result | Sort-Object $SortField


}
catch {}

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