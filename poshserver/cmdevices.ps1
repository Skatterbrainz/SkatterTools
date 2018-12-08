$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'Name'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default $DefaultComputersTab
$Detailed    = Get-PageParam -TagName 'zz' -Default ""

$PageTitle   = "CM Devices"
$PageCaption = "CM Devices"
$IsFiltered  = $False
$content = ""

if ($SearchField -eq 'name') {
    $TabSelected = $SearchValue
}

if ($SearchValue -eq 'all') {
    $SearchValue = ""
}

$query = @"
SELECT
	ResourceID,
	[Name],
	Manufacturer,
	Model,
	OperatingSystem,
	OSBuild,
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
"@

if (![string]::IsNullOrEmpty($SearchField)) {
    if ($SearchType -eq 'like') {
        $query += " where ($SearchField like '$SearchValue%')"
    }
    else {
        $query += " where ($SearchField = '$SearchValue')"
    }
    $PageCaption += " ($SearchValue)"
    $IsFiltered = $True
}
$query += " order by $SortField $SortOrder"
$xxx = "query: $query"

try {
    $connection = New-Object -ComObject "ADODB.Connection"
    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
    $connection.Open($connString);
    $xxx += "<br/>connection opened"
    $IsOpen = $True
    $rs = New-Object -ComObject "ADODB.RecordSet"
    $rs.Open($query, $connection);
    $xxx += "<br/>recordset defined"
    $rowcount = 0
    if ($rs.BOF -and $rs.EOF) {
        $content = "<table id=table1><tr><td>No records found</td></tr></table>"
    }
    else {
        $colcount = $rs.Fields.Count
        $rs.MoveFirst()
    
        $content = '<table id=table1><tr>'
        $columns = @()
        for ($i = 0; $i -lt $colcount; $i++) {
            $fn = $rs.Fields($i).Name
            if ($fn -ne 'ResourceID') {
                $columns += $fn
            }
        }

        $content += New-ColumnSortRow -ColumnNames $columns -BaseLink "cmdevices.ps1?f=$SearchField&v=$SearchValue&x=$SearchType" -SortDirection $SortOrder
        $content += "</tr>"
        $xxx += "<br/>column headings defined"
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
            $rowcount++
        } # while
        $content += '<tr>'
        $content += '<td colspan='+$($colcount-1)+'>'+$rowcount+' rows returned'
        if ($IsFiltered -eq $true) {
            $content += ' - <a href="cmdevices.ps1" title="Show All">Show All</a>'
        }
        $content += '</td></tr>'
        $content += '</table>'
    }
    $rs.Close()
    $xxx += "<br/>recordset closed"       
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

$tabset = New-MenuTabSet -BaseLink "cmdevices.ps1?x=like&f=name&v=" -DefaultID $TabSelected

$content += Write-DetailInfo -PageRef "cmdevices.ps1" -Mode $Detailed

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