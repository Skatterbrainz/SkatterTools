$ProductName = Get-PageParam -TagName 'pn' -Default ""
$ProductVersion = Get-PageParam -TagName 'pv' -Default ""
$SearchType  = "equals"
$SortField   = Get-PageParam -TagName 's' -Default "computername"
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default ""
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False

$ProductName    = Get-CheapDecode $ProductName
#$ProductVersion = Get-CheapDecode $ProductVersion

$PageTitle   = "CM Installed Software: $ProductName ($ProductVersion)"
$PageCaption = $PageTitle
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

# example url = "http://localhost:8080/cminstalls.ps1?pn=Microsoft%20Visual%20C++%202013%20Redistributable%20(x64)%20-%2012.0.40660&pv=12.0.40660.0"

try {
    $query = 'SELECT DISTINCT 
    dbo.v_R_System.Name0 AS ComputerName, 
    dbo.v_R_System.ResourceID, 
    dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.InstalledLocation0 AS InstallPath, 
    dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.InstallSource0 AS [Source], 
    dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.InstallDate0 AS InstallDate
    FROM dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED INNER JOIN
    dbo.v_R_System ON dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ResourceID = dbo.v_R_System.ResourceID 
    where (ProductName0 = '''+ $ProductName +''') and (ProductVersion0 = '''+ $ProductVersion+''') 
    order by '+$SortField+' '+$SortOrder

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
        $content += "No matching results found for: $ProductName ($ProductVersion)</td></tr>"
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
            $fp = $rs.Fields("InstallPath").Value
            $sp = $rs.Fields("Source").Value
            $dt = $rs.Fields("InstallDate").Value
            $cx = "<a href=`"cmdevice.ps1?f=ResourceID&v=$id&n=$cn`" title=`"View Details for $cn`">$cn</a>"
            $content += "<tr><td>$cx</td><td>$id</td><td>$fp</td><td>$sp</td><td>$dt</td></tr>"
            [void]$rs.MoveNext()
            $rowcount++
        }
        $content += '<tr><td colspan='+$($colcount)+' class=lastrow>'+$rowcount+' installations returned'
        if ($IsFiltered -eq $true) {
            $content += " - <a href=`"cminstalls.ps1`" title=`"Show All`">Show All</a>"
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

$tabset
$content

$(if ($DebugMode -eq 1) {"<p>$query</p>"})

</body>
</html>
"@