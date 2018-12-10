$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default "all"
$SearchType  = Get-PageParam -TagName 'x' -Default "like"
$SortField   = Get-PageParam -TagName 's' -Default "name"
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Packages"
$PageCaption = "CM Packages"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

$TabSelected = $SearchValue
if ($SearchValue -eq 'all') {
    $SearchValue = ""
}

try {
    $query = 'select distinct 
        PackageID,
        Name, 
        PackageType, 
        Description, 
        SourceVersion  
        from dbo.v_Package'
    if (![string]::IsNullOrEmpty($SearchValue)) {
        switch ($SearchType) {
            'equals' {
                $query += " where ($SearchField = '$SearchValue')"
                break;
            }
            'like' {
                $query += " where ($SearchField like '%$SearchValue%')"
                break;
            }
            'begins' {
                $query += " where ($SearchField like '$SearchValue%')"
                break;
            }
            'ends' {
                $query += " where ($SearchField like '%$SearchValue')"
                break;
            }
        }
    }
    $query += " order by $SortField $SortOrder"

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
            if ($fn -ne 'PackageID') {
                $content += "<th>$fn</th>"
            }
        }
        $content += "</tr>"
        [void]$rs.MoveFirst()
        while (!$rs.EOF) {
            $content += "<tr>"
            for ($i = 0; $i -lt $colcount; $i++) {
                $fn = $rs.Fields($i).Name
                $fv = $rs.Fields($i).Value
                switch ($fn) {
                    'PackageID' {
                        $pkid = $fv;
                        break;
                    }
                    'Name' {
                        $fvx = "<a href=`"cmpackage.ps1?f=packageid&v=$pkid&x=equals&n=$fv`" title=`"Details`">$fv</a>"
                        $content += "<td>$fvx</td>"
                        break;
                    }
                    default {
                        $fvx = $fv
                        $content += "<td>$fvx</td>"
                        break;
                    }
                }
            }
            $content += "</tr>"
            [void]$rs.MoveNext()
            $rowcount++
        }
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

$tabset = New-MenuTabSet -BaseLink 'cmpackages.ps1?x=begins&f=name&v=' -DefaultID $TabSelected
$content += Write-DetailInfo -PageRef "cmpackages.ps1" -Mode $Detailed


#$content = "<table id=table2><tr><td style=`"height:200px;text-align:center`">"
#$content += "Coming soon</td></tr></table>"

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