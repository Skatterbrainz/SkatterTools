$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default "all"
$SearchType  = Get-PageParam -TagName 'x' -Default "like"
$SortField   = Get-PageParam -TagName 's' -Default "name"
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Software"
$PageCaption = "CM Software"
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
        PackageType as [Type],
        Case 
	        When PackageType = 0   Then ''Software Distribution Package'' 
	        When PackageType = 3   Then ''Driver Package'' 
	        When PackageType = 4   Then ''Task Sequence Package''
	        When PackageType = 5   Then ''Software Update Package''
	        When PackageType = 6   Then ''Device Settings Package''
	        When PackageType = 7   Then ''Virtual Package''
	        When PackageType = 8   Then ''Application''
	        When PackageType = 257 Then ''OS Image Package''
	        When PackageType = 258 Then ''Boot Image Package''
	        When PackageType = 259 Then ''OS Upgrade Package''
	        WHEN PackageType = 260 Then ''VHD Package''
	        End as PkgType,
        Description, 
        SourceVersion as Version 
        from dbo.v_Package'
    if (![string]::IsNullOrEmpty($SearchValue)) {
        $IsFiltered = $True
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
        if ($SearchField -eq 'PackageType') {
            $cap = Get-CmPackageTypeName -PkgType $SearchValue
            $PageTitle += ": $cap"
            $PageCaption = $PageTitle
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
                    'Type' {
                        $content += "<td style=`"text-align:center`">$fv</td>"
                        $ptype = $fv
                        break;
                    }
                    'PkgType' {
                        $fvx = "<a href=`"cmpackages.ps1?f=packagetype&v=$ptype&x=equals`" title=`"Filter on $fv`">$fv</a>"
                        $content += "<td>$fvx</td>"
                        break;
                    }
                    'Version' {
                        $content += "<td style=`"text-align:center`">$fv</td>"
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
        $content += "<tr><td colspan=`"$($colcount)`" class=lastrow>$rowcount items returned"
        if ($IsFiltered -eq $true) {
            $content += " - <a href=`"cmpackages.ps1`" title=`"Show All`">Show All</a>"
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

$tabset = New-MenuTabSet -BaseLink 'cmpackages.ps1?x=begins&f=name&v=' -DefaultID $TabSelected
$content += Write-DetailInfo -PageRef "cmpackages.ps1" -Mode $Detailed

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