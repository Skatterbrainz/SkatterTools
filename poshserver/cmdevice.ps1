$SearchField = $PoshQuery.f
$SearchValue = $PoshQuery.v
$ItemName    = $PoshQuery.n
$SortField   = Get-SortField -Default "Name"
$DebugMode   = $PoshQuery.z

$PageTitle   = "CM Device: $ItemName"
$PageCaption = "CM Device: $ItemName"

$content = ""

$query = @"
SELECT
	ResourceID,
	[Name],
	Manufacturer,
	Model,
	SerialNumber,
	OperatingSystem,
	OSBuild,
	ClientVersion,
	LastHwScan,
	LastDDR,
	LastPolicyRequest,
	ADSite 
FROM (
SELECT 
	dbo.v_R_System.ResourceID, 
	dbo.v_R_System.Name0 as [Name], 
	dbo.v_GS_COMPUTER_SYSTEM.Manufacturer0 as Manufacturer, 
	dbo.v_GS_COMPUTER_SYSTEM.Model0 as Model, 
	dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0 as SerialNumber, 
	dbo.vWorkstationStatus.ClientVersion, 
	dbo.vWorkstationStatus.LastHardwareScan as LastHwScan, 
	dbo.vWorkstationStatus.LastPolicyRequest, 
	dbo.vWorkstationStatus.LastDDR,
	dbo.v_R_System.AD_Site_Name0 as ADSite, 
	dbo.v_GS_OPERATING_SYSTEM.Caption0 as OperatingSystem, 
	dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 as OSBuild
FROM 
	dbo.v_R_System INNER JOIN
    dbo.v_GS_COMPUTER_SYSTEM ON 
	dbo.v_R_System.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID INNER JOIN
    dbo.v_GS_SYSTEM_ENCLOSURE ON 
	dbo.v_R_System.ResourceID = dbo.v_GS_SYSTEM_ENCLOSURE.ResourceID INNER JOIN
    dbo.vWorkstationStatus ON 
	dbo.v_R_System.ResourceID = dbo.vWorkstationStatus.ResourceID INNER JOIN
    dbo.v_GS_OPERATING_SYSTEM ON 
	dbo.v_R_System.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID
) AS T1
WHERE $SearchField = '$SearchValue'
"@

try {
    $connection = New-Object -ComObject "ADODB.Connection"
    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
    $connection.Open($connString);
    $IsOpen = $True
    $rs = New-Object -ComObject "ADODB.RecordSet"
    $rs.Open($query, $connection)
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
