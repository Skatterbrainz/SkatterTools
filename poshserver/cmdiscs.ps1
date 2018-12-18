$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "like"
$SortField   = Get-PageParam -TagName 's' -Default "itemtype"
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Discovery Methods"
$PageCaption = "CM Discovery Methods"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

try {
    $query = 'SELECT distinct
        ItemType,
        Sitenumber,
        SourceTable 
        FROM SC_Properties
        WHERE (ItemType LIKE ''%Discover%'')
        ORDER BY ItemType'
    #$query = Get-SkDbQuery -QueryText $query
    #if (![string]::IsNullOrEmpty($SearchValue)) {$IsFiltered = $True}

    $connection = New-Object -ComObject "ADODB.Connection"
    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
    $connection.Open($connString);
    $IsOpen = $true
    $rs = New-Object -ComObject "ADODB.RecordSet"
    $rowcount = 0
    $rs.Open($query, $connection)
    if ($rs.BOF -and $rs.EOF) {
        $content = "<table id=table2><tr><td>No records found!</td></tr></table>"
    }
    else {
        $colcount = $rs.Fields.Count
        $content = "<table id=table1><tr>"
        for ($i = 0; $i -lt $colcount; $i++) {
            $fn = $rs.Fields($i).Name
            $content += "<th>$fn</th>"
        }
        $content += "</tr>"
        [void]$rs.MoveFirst()
        while (!$rs.EOF) {
            $dnum   = $rs.Fields("SiteNumber").Value
            $dname  = $rs.Fields("ItemType").Value
            $dtab   = $rs.Fields("SourceTable").Value
            $dlink  = "<a href=`"cmdisc.ps1?f=itemtype&v=$dname&x=equals&n=$dname`" title=`"Details`">$dname</a>"

            $content += "<tr>"
            $content += "<td>$dlink</td>"
            $content += "<td>$dnum</td>"
            $content += "<td>$dtab</td>"
            $content += "</tr>"
            [void]$rs.MoveNext()
            $rowcount++
        }
        $content += "<tr><td colspan=`"$($colcount)`" class=lastrow>$rowcount items returned</td></tr>"
        $content += "</table>"
        [void]$rs.Close()
    }
}
catch {
    $content += "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
}
finally {
    if ($IsOpen -eq $true) {
        [void]$connection.Close()
    }
}

#$tabset = New-MenuTabSet -BaseLink 'cmdiscs.ps1?x=begins&f=name&v=' -DefaultID $TabSelected
#$content += Write-DetailInfo -PageRef "cmdiscs.ps1" -Mode $Detailed

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