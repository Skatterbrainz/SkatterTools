$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'exact'
$SortField   = Get-PageParam -TagName 's' -Default 'Name'
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""

$PageTitle   = "CM Device: $CustomName"
$PageCaption = "CM Device: $CustomName"

if ([string]::IsNullOrEmpty($TabSelected)) {
    $TabSelected = "General"
}

$content = ""
$tabset  = ""

$tabs = @('General','Storage','Collections','Software','Tools','Notes')
$tabset = "<table id=tablex><tr>"
foreach ($tab in $tabs) {
    $xlink = "cmdevice.ps1?f=$SearchField&v=$SearchValue&x=$SearchType&s=$SortField&so=$SortOrder&n=$CustomName&tab=$tab"
    if ($tab -eq $TabSelected) {
        $tabset += "<td class=`"btab`">$tab</td>"
    }
    else {
        $tabset += "<td class=`"btab`" onClick=`"document.location.href='$xlink'`" title=`"$tab`">$tab</td>"
    }
}
$tabset += "</tr></table>"

switch ($TabSelected) {
    'General' {

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
WHERE ($SearchField = '$SearchValue') 
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
    
            $content = '<table id=table2><tr>'

            for ($i = 0; $i -lt $colcount; $i++) {
                $fn = $rs.Fields($i).Name
                $fv = $rs.Fields($i).Value
                if (![string]::IsNullOrEmpty($fv)) {
                    $fvx = '<a href="cmdevices.ps1?f='+$fn+'&v='+$fv+'" title="Filter">'+$fv+'</a>'
                }
                else {
                    $fvx = ""
                }
                $content += '<tr><td style="width:200px;background-color:#435168">'+$fn+'</td>'
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
        break;
    }
    'Collections' {
        $query = @"
SELECT DISTINCT 
    dbo.v_FullCollectionMembership.CollectionID, 
    dbo.v_Collection.Name, 
    dbo.v_Collection.MemberCount 
FROM 
    dbo.v_FullCollectionMembership INNER JOIN 
    dbo.v_Collection ON 
    dbo.v_FullCollectionMembership.CollectionID = dbo.v_Collection.CollectionID 
    INNER JOIN dbo.v_Collections ON 
    dbo.v_Collection.Name = dbo.v_Collections.CollectionName 
WHERE 
    (dbo.v_Collection.CollectionID IN 
      (SELECT DISTINCT CollectionID 
       FROM dbo.v_FullCollectionMembership AS T2 
       WHERE (ResourceID = $SearchValue)
      )
    ) 
ORDER BY dbo.v_Collection.Name
"@
        $xxx = "query defined"
        try {
#            $content = $query
            $connection = New-Object -ComObject "ADODB.Connection"
            $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
            $connection.Open($connString);
            $xxx = "connection opened"
            $IsOpen = $True
            $rs = New-Object -ComObject "ADODB.RecordSet"
            $rs.Open($query, $connection, 0, 1)
            $xxx = "recordset created"
            $rowcount = 0

            if ($rs.BOF -and $rs.BOF) {
                $xxx = "recordset is empty"
            }
            else {
                $content = "<table id=table1>"
                $content += "<tr>"
                for ($i=0; $i -lt $colcount; $i++) {
                    $fn = $rs.Fields($i).Name
                    $content += "<th>$fn</th>"
                    $xxx = $fn
                }
                $content += "</tr>"
                $xxx = "column headings defined"
                $colcount = $rs.Fields.Count
                $rs.MoveFirst()
                $xxx = "recordset opened ($colcount columns)"
            
                while (!$rs.EOF) {
                    $content += '<tr>'
    #                $cid = $rs.Fields('CollectionID').value
                    for ($i = 0; $i -lt $colcount; $i++) {
                        $fn = $rs.Fields($i).Name
                        $fv = $rs.Fields($i).Value
                        $xxx = $fn
                        if ([string]::IsNullOrEmpty($fv)) { $fv = "" }
                        $content += "<td>$fv</td>"
                    } # for
                    $content += '</tr>'
                    $rs.MoveNext()
                    $rowcount++
                }
            }
            $rs.Close()
            $content += "</table>"
        }
        catch {
            $content = "<table id=table2>"
            $content += "<tr><td>Error: $($Error[0].Exception.Message)</td></tr>"
            $content += "<tr><td>Query: $query</td></tr>"
            $content += "<tr><td>Last Step: $xxx</td></tr>"
            $content += "</table>"
        }
        finally {
            if ($IsOpen) {
                $connection.Close()
            }
        }
        break;
    }
    'Notes' {
        break;
    }
}
$content += Write-DetailInfo -PageRef "cmdevice.ps1" -Mode $Detailed

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

$tabset
$content

$(if ($DebugMode -eq 1) {"<p>$query</p>"})

</body>
</html>
"@