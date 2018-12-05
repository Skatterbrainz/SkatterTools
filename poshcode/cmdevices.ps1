$SearchField = $PoshQuery.f
$SearchValue = $PoshQuery.v
$SortField   = Get-SortField -Default "Name"
$DebugMode   = $PoshQuery.z

$PageTitle   = "CM Devices"
$PageCaption = "CM Devices"

$content = ""

$query = @"
select distinct 
    ResourceID, Name, UserName, OperatingSystem,
    OsBuild,SystemType,ClientVersion FROM (
SELECT 
	dbo.vWorkstationStatus.ResourceID, 
    dbo.vWorkstationStatus.Name, 
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
	dbo.vWorkstationStatus.ClientVersion 
FROM 
	dbo.vWorkstationStatus LEFT OUTER JOIN
	dbo.v_GS_OPERATING_SYSTEM ON 
    dbo.vWorkstationStatus.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID 
) AS T1 
"@

if (![string]::IsNullOrEmpty($SearchField)) {
    $query += " where ($SearchField = '$SearchValue')"
    $PageCaption += " ($SearchValue)"
    $IsFiltered = $True
}
$query += ' order by '+$SortField

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
        if ($rs.Fields($i).Name -ne 'ResourceID') {
            $content += '<th>'+$rs.Fields($i).Name+'</th>'
        }
    }
    $content += '</tr>'

    while (!$rs.EOF) {
        $content += '<tr>'
        $rid = $rs.Fields('ResourceID').value
        for ($i = 0; $i -lt $colcount; $i++) {
            $fn = $rs.Fields($i).Name
            $fv = $rs.Fields($i).Value
            switch ($fn) {
                'Name' {
                    $fvx = '<a href="cmdevice.ps1?f=ResourceID&v='+$rid+'&n='+$fv+'" title="Details">'+$fv+'</a>'
                    $content += '<td>'+$fvx+'</td>'
                    break;
                }
                'OsBuild' {
                    $content += '<td>'+$fv+'</td>'
                    break;
                }
                'ResourceID' {
                    break;
                }
                default {
                    if (![string]::IsNullOrEmpty($fv)) {
                        $fvx = '<a href="cmdevices.ps1?f='+$fn+'&v='+$fv+'" title="Filter">'+$fv+'</a>'
                    }
                    else {
                        $fvx = ""
                    }
                    $content += '<td>'+$fvx+'</td>'
                    break;
                }
            }
        }
        $content += '</tr>'
        $rs.MoveNext()
    }
    $content += '<tr>'
    $content += '<td colspan='+$($colcount-1)+'>'+$rowcount+' rows returned'
    if ($IsFiltered -eq $true) {
        $content += ' - <a href="cmdevices.ps1" title="Show All">Show All</a>'
    }
    $content += '</td></tr>'
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
