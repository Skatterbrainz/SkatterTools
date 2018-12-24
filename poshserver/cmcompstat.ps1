$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'exact'
$SortField   = Get-PageParam -TagName 's' -Default 'ComponentName'
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'

$PageTitle   = "CM Site Components"
$PageCaption = "CM Site Components"
$tabset = ""

try {
    $q2 = 'SELECT DISTINCT 
[ComponentName],
case 
    when (Status = 0) then ''#1ED66B''
    when (Status = 1) then ''#CBD61E''
    when (Status = 2) then ''#D61E37''
    end as Status,
case
  when (state = 0) then ''Stopped''
  when (state = 1) then ''Started''
  when (state = 2) then ''Paused''
  when (state = 3) then ''Installing''
  when (state = 4) then ''Re-installing''
  when (state = 5) then ''De-installing''
  end as [State],
[LastContacted],
MAX([Infos]) as Info,
MAX([Warnings]) as Warning,
MAX([Errors]) as [Error] 
FROM vSMS_ComponentSummarizer 
group by ComponentName, LastContacted, Status, State'

    $query = "select ComponentName, Status, State, LastContacted, Info, Warning, Error from ($q2) as t1"
    $query = Get-SkDbQuery -QueryText $query
    #order by $SortField $SortOrder"

    $connection = New-Object -ComObject "ADODB.Connection"
    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
    $connection.Open($connString);
    $xxx = "connection opened"
    $IsOpen = $True
    $rs = New-Object -ComObject "ADODB.RecordSet"
    $rs.Open($query, $connection)
    if ($rs.BOF -and $rs.EOF) {
        $content = "<table id=table2><tr><td style=`"height:150px;text-align:center`">No matching record found</td></tr></table>"
    }
    else {
        $colcount = $rs.Fields.Count
        $fields = @()
        for ($i = 0; $i -lt $colcount; $i++) {
            $fn = $rs.Fields($i).Name
            $fields += $fn
        }
        $content = "<table id=table2><tr>"
        $content += New-ColumnSortRow -ColumnNames $fields -BaseLink "cmcompstat.ps1?f=$SearchField&v=$SearchValue&x=$SearchType" -SortDirection $SortOrder
        $content += "</tr>"
        $rs.MoveFirst()
        while(!$rs.EOF) {
            $content += "<tr>"
            for ($i = 0; $i -lt $colcount; $i++) {
                $fn = $rs.Fields($i).Name
                $fv = $rs.Fields($i).Value
                switch($fn) {
                    'Status' {
                        $fvx = "<table style=`"width:100%;border:0;`"><tr><td style=`"background:$fv`"> </td></tr></table> "
                        $content += "<td style=`"text-align:center`">$fvx</td>"
                        break;
                    }
                    'State' {
                        $content += "<td style=`"text-align:center`">$fv</td>"
                        break;
                    }
                    default {
                        $fvx = $fv
                        $content += "<td>$fv</td>"
                        break;
                    }
                } # switch
            }
            $content += "</tr>"
            [void]$rs.MoveNext();
            $rowcount++
        }
        $content += "</table>"
    }
}
catch {
    $content = "<table id=table2><tr><td style=`"height:200px;text-align:center`">"
    $content += "Error $($Error[0].Exception.Message)<br/>query: $query</td></tr></table>"
}
finally {
    if ($IsOpen -eq $True) {
        [void]$connection.Close()
    }
}

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