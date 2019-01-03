$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default ""
$SortField   = Get-PageParam -TagName 's' -Default ""
$SortOrder   = Get-PageParam -TagName 'so' -Default ""
$TabSelected = Get-PageParam -TagName 'tab' -Default ""
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Applications"
$PageCaption = "CM Applications"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

try {
    $query = "SELECT DISTINCT 
	    dbo.v_GS_ADD_REMOVE_PROGRAMS.DisplayName0, 
	    dbo.v_GS_ADD_REMOVE_PROGRAMS.Publisher0, 
	    dbo.v_GS_ADD_REMOVE_PROGRAMS.Version0,
	    COUNT(*) AS Installs 
    FROM 
	    dbo.v_R_System INNER JOIN 
	    dbo.v_GS_ADD_REMOVE_PROGRAMS ON 
	    dbo.v_R_System.ResourceID = dbo.v_GS_ADD_REMOVE_PROGRAMS.ResourceID 
    GROUP BY 
	    DisplayName0,
	    Publisher0,
	    Version0"
    $result = @(Invoke-DbaQuery -SqlInstance $CmDbHost -Database "CM_$CmSiteCode" -Query $query -ErrorAction SilentlyContinue)
    if ($result.Count -gt 0) {
        $content = "<table id=table1>"
        foreach ($rs in $result) {
            $pn = $rs.ProductName
            $pv = $rs.Version
            $vn = $rs.Publisher
            $qx = $rs.Installs
            $content += "<tr><td>$pn</td><td>$pv</td><td>$vn</td><td>$qx</td></tr>"
        }
        $content += "</table>"
    }
}
catch {
    $content = "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
}

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