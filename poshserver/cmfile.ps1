$FileName    = Get-PageParam -TagName 'n' -Default ""
$FileVersion = Get-PageParam -TagName 'v' -Default ""
$FileSize    = Get-PageParam -TagName 's' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'equals'
$SortField   = Get-PageParam -TagName 's' -Default 'ComputerName'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default ""
$Detailed    = Get-PageParam -TagName 'zz' -Default ""

$PageTitle   = "CM Software File: $FileName"
$PageCaption = "CM Software File: $FileName"

try {
    $query = 'SELECT distinct 
    dbo.v_R_System.Name0 as ComputerName, 
    dbo.v_GS_SoftwareFile.ResourceID, 
    dbo.v_GS_SoftwareFile.FilePath, 
    dbo.v_GS_SoftwareFile.CreationDate, 
    dbo.v_GS_SoftwareFile.FileModifiedDate, 
    dbo.v_GS_SoftwareFile.FileCount 
    from dbo.v_GS_SoftwareFile INNER JOIN 
    dbo.v_R_System ON dbo.v_GS_SoftwareFile.ResourceID = dbo.v_R_System.ResourceID 
    where 
      (dbo.v_GS_SoftwareFile.FileName = '''+$FileName+''') AND 
      (dbo.v_GS_SoftwareFile.FileVersion = '''+$FileVersion+''') AND 
      (dbo.v_GS_SoftwareFile.FileSize = '+$FileSize+') 
    order by name0'

    $connection = New-Object -ComObject "ADODB.Connection"
    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
    $connection.Open($connString);
    $IsOpen = $True
    $rs = New-Object -ComObject "ADODB.RecordSet"
    $rs.Open($query, $connection)
    $xxx += "<br/>recordset defined"
    $content = '<table id=table1><tr>'
    if ($rs.BOF -and $rs.EOF) {
        $content += "<tr><td style=`"height:150px;text-align:center`">"
        $content += "No matching results found</td></tr>"
    }
    else {
        $colcount = $rs.Fields.Count
        $xxx += "$colcount columns returned"
        $rs.MoveFirst()
        for ($i = 0; $i -lt $colcount; $i++) {
            $content += '<th>'+$rs.Fields($i).Name+'</th>'
        }
        $content += '</tr>'
        $rowcount = 0
        while (!$rs.EOF) {
            $content += '<tr>'
            $cn = $rs.Fields("ComputerName").Value
            $id = $rs.Fields("ResourceID").Value
            $fp = $rs.Fields("FilePath").Value
            $dc = $rs.Fields("CreationDate").Value
            $fc = $rs.Fields("FileCount").Value
            $dm = $rs.Fields("FileModifiedDate").Value
            $cx = "<a href=`"cmdevice.ps1?f=ResourceID&v=$id&n=$cn`" title=`"View Details for $cn`">$cn</a>"
            $content += "<tr><td>$cx</td><td>$id</td><td>$fp</td><td>$dc</td><td>$dm</td><td>$fc</td></tr>"
            [void]$rs.MoveNext()
            $rowcount++
        }
        $content += '<tr><td colspan='+$($colcount)+' class=lastrow>'+$rowcount+' instances found'
        if ($IsFiltered -eq $true) {
            $content += " - <a href=`"cmfile.ps1`" title=`"Show All`">Show All</a>"
        }
        $content += '</td></tr></table>'
    }
}
catch {
    $content = "Error: $($Error[0].Exception.Message)"
}
finally {
    if ($isopen -eq $true) {
        $connection.Close()
    }
}

$content += Write-DetailInfo -PageRef "cminstalls.ps1" -Mode $Detailed

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