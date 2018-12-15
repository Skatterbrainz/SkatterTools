$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'sitesystem'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'All'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Site Status"
$PageCaption = "CM Site Status"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

try {
    $query = 'select distinct 
    case 
      when (Status = 0) then ''#1ED66B''
      when (Status = 1) then ''#CBD61E''
      when (Status = 2) then ''#D61E37''
      end as SiteStatus,
    Role,
    SiteCode,
    case 
      when (AvailabilityState = 0) then ''Online''
      when (AvailabilityState = 1) then ''1''
      when (AvailabilityState = 2) then ''2''
      when (AvailabilityState = 3) then ''Offline''
      when (AvailabilityState = 4) then ''4''
      end as Availability, 
    SiteSystem, 
    TimeReported  
    FROM v_SiteSystemSummarizer'

    $connection = New-Object -ComObject "ADODB.Connection"
    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
    $connection.Open($connString);
    $IsOpen = $True
    $rs = New-Object -ComObject "ADODB.RecordSet"
    $rs.Open($query, $connection)
    $xxx += "<br/>recordset defined"
    $content = "<table id=table1><tr>"
    if ($rs.BOF -and $rs.EOF) {
        $content += "<tr><td style=`"height:150px;text-align:center`">"
        $content += "No matching results found</td></tr>"
    }
    else {
        $colcount = $rs.Fields.Count
        $xxx += "$colcount columns returned"
        [void]$rs.MoveFirst()
        for ($i = 0; $i -lt $colcount; $i++) {
            $fn = $rs.Fields($i).Name
            $content += "<th>$fn</th>"
        }
        $content += '</tr>'
        $rowcount = 0
        while (!$rs.EOF) {
            $content += "<tr>"
            for ($i = 0; $i -lt $colcount; $i++) {
                $fn = $rs.Fields($i).Name
                $fv = $rs.Fields($i).Value
                switch($fn) {
                    'SiteStatus' {
                        $fvx = "<table style=`"width:100%;border:0;`"><tr><td style=`"background:$fv`"> </td></tr></table>"
                        $content += "<td>$fvx</td>"
                        break;
                    }
                    'SiteSystem' {
                        # '["Display=\\CM02.contoso.local\"]MSWNET:["SMS_SITE=P02"]\\CM02.contoso.local\'
                        $fvx = ($fv -split '\\')[2]
                        $content += "<td>$fvx</td>"
                        break;
                    }
                    'Role' {
                        $content += "<td>$fv</td>"
                        break;
                    }
                    default {
                        $content += "<td style=`"text-align:center`">$fv</td>"
                        break;
                    }
                }
            }
            $content += "</tr>"
            [void]$rs.MoveNext()
            $rowcount++
        }
        [void]$rs.Close()
    }
    $content += "</table>"
}
catch {
    $xxx += $Error[0].InnerException
}
finally {
    if ($IsOpen) {
        [void]$connection.Close()
    }
}

$content += Write-DetailInfo -PageRef "cmsitestatus.ps1" -Mode $Detailed

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

$content

</body>
</html>
"@