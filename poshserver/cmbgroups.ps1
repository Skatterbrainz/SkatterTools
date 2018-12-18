$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "like"
$SortField   = Get-PageParam -TagName 's' -Default "Name"
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Boundary Groups"
$PageCaption = "CM Boundary Groups"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

try {
    $query = 'SELECT distinct
        Name,
        GroupID,
        Description,
        Flags,
        DefaultSiteCode,
        CreatedOn,
        MemberCount as Boundaries,
        SiteSystemCount as SiteSystems
        FROM vSMS_BoundaryGroup'
    $query = Get-SkDbQuery -QueryText $query
    if (![string]::IsNullOrEmpty($SearchValue)) {$IsFiltered = $True}

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
            $bgname  = $rs.Fields("Name").Value
            $bgid    = $rs.Fields("GroupID").Value
            $desc    = $rs.Fields("Description").Value
            $bgflags = $rs.Fields("Flags").Value
            $bgsite  = $rs.Fields("DefaultSiteCode").Value
            $bgcron  = $rs.Fields("CreatedOn").Value
            $bgmbrs  = $rs.Fields("Boundaries").Value
            $bgsys   = $rs.Fields("SiteSystems").Value
            $bglink = "<a href=`"cmbgroup.ps1?f=groupid&v=$bgid&x=equals&n=$bgname`" title=`"Details`">$bgname</a>"

            $content += "<tr>"
            $content += "<td>$bglink</td>"
            $content += "<td style=`"text-align:center`">$bgid</td>"
            $content += "<td style=`"text-align:center`">$desc</td>"
            $content += "<td style=`"text-align:center`">$bgflags</td>"
            $content += "<td style=`"text-align:center`">$bgsite</td>"
            $content += "<td style=`"text-align:center`">$bgcron</td>"
            $content += "<td style=`"text-align:center`">$bgmbrs</td>"
            $content += "<td style=`"text-align:center`">$bgsys</td>"
            $content += "</tr>"
            [void]$rs.MoveNext()
            $rowcount++
        }
        $content += "<tr><td colspan=`"$($colcount)`" class=lastrow>$rowcount items returned"
        if ($IsFiltered -eq $true) {
            $content += " - <a href=`"___.ps1`" title=`"Show All`">Show All</a>"
        }
        $content += "</td></tr>"
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

#$tabset = New-MenuTabSet -BaseLink 'cmpackages.ps1?x=begins&f=name&v=' -DefaultID $TabSelected
#$content += Write-DetailInfo -PageRef "___.ps1" -Mode $Detailed

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