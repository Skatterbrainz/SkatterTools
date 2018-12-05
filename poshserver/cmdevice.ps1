$SearchField = $PoshQuery.f
$SearchValue = $PoshQuery.v
$ItemName    = $PoshQuery.n
$SortField   = Get-SortField -Default "Name"
$DebugMode   = $PoshQuery.z

$PageTitle   = "CM Device: $ItemName"
$PageCaption = "CM Device: $ItemName"

$content = ""

$query = @"
SELECT TOP 1 
	dbo.vWorkstationStatus.Name, 
    dbo.vWorkstationStatus.ResourceID,
	dbo.vWorkstationStatus.UserName, 
	dbo.v_GS_OPERATING_SYSTEM.Caption0 AS OperatingSystem, 
	CASE
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 10586) THEN '1511'
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 14393) THEN '1607'
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 15063) THEN '1703'
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 16299) THEN '1709'
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 17134) THEN '1803'
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 7601) THEN 'SP1'
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 9600) THEN 'RTM'
		ELSE dbo.v_GS_OPERATING_SYSTEM.BuildNumber0
		END AS OsBuild, 
	dbo.vWorkstationStatus.SystemType, 
	dbo.vWorkstationStatus.ClientVersion, 
	dbo.vWorkstationStatus.UserDomain, 
	CASE
		WHEN (dbo.vWorkstationStatus.IsVirtualMachine = 1) THEN 'Y'
		ELSE 'N' END AS IsVM, 
	dbo.vWorkstationStatus.LastHealthEvaluationResult AS LastHealthEval, 
	dbo.vWorkstationStatus.LastHardwareScan AS LastHwScan, 
	dbo.vWorkstationStatus.LastDDR
FROM 
	dbo.vWorkstationStatus LEFT OUTER JOIN
	dbo.v_GS_OPERATING_SYSTEM ON dbo.vWorkstationStatus.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID
WHERE ($SearchField = '$SearchValue')"
"@

try {
    $connection = New-Object -ComObject "ADODB.Connection"
    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
    $connection.Open($connString);
    $IsOpen = $True
    $rs = New-Object -ComObject "ADODB.RecordSet"
    $rs.Open($query, $connection)
    $rowcount = 0
    $rowcount += $rs.RecordCount
    $colcount = $rs.Fields.Count
    $rs.MoveFirst()
    
    $content = '<table id=table1><tr>'

    for ($i = 0; $i -lt $colcount; $i++) {
        $fn = $rs.Fields($i).Name
        $fv = $rs.Fields($i).Value
        if (![string]::IsNullOrEmpty($fv)) {
            $fvx = '<a href="cmdevices.ps1?f='+$fn+'&v='+$fv+'" title="Filter">'+$fv+'</a>'
        }
        else {
            $fvx = ""
        }
        $content += '<tr><td style="width:200px">'+$fn+'</td>'
        $content += '<td>'+$fvx+'</td></tr>'        
    }
    $content += '</table>'
}
catch {
    $content += "Error: $($Error[0].Exception.Message)"
    $content += "<br/>SearchField: $SearchField"
    $content += "<br/>SearchValue: $SearchValue"
    $content += "<br/>Query: $query"
}
finally {
    if ($isopen -eq $true) {
        $connection.Close()
    }
}

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

$content

$(if ($DebugMode -eq 1) {"<p>$query</p>"})

</body>
</html>
"@
