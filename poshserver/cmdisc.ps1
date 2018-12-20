$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default ""
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""

$PageTitle   = "CM Discovery Method: $CustomName"
$PageCaption = "CM Discovery Method: $CustomName"

$content = ""
$tabset  = ""

try {
    $query = 'SELECT 
        ItemType,
        ID,
        Sitenumber,
        [Name],
        Value1,
        Value2,
        Value3,
        SourceTable 
        FROM dbo.SC_Properties
        WHERE (ItemType = '''+$SearchValue+''')' 
    $connection = New-Object -ComObject "ADODB.Connection"
    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
    $connection.Open($connString);
    $IsOpen = $True
    $rs = New-Object -ComObject "ADODB.RecordSet"
    $rs.Open($query, $connection)
    $rowcount = 0
    $rowcount += $rs.RecordCount
    $colcount = $rs.Fields.Count
    $rs.MoveFirst()
    
    $content = '<table id=table2><tr>'
    for ($i = 0; $i -lt $colcount; $i++) {
        $fn = $rs.Fields($i).Name
        $fv = $rs.Fields($i).Value
        $content += "<tr><td style=`"width:200px;background-color:#435168`">$fn</td>"
        $content += "<td>$fv</td></tr>"
    }
    $content += "</table>"
}
catch {
    $content = "<table id=table2><tr><td><br/>Error: $($Error[0].Exception.Message)</td></tr></table>"
}
finally {
    if ($isopen -eq $true) {
        $connection.Close()
    }
}

#$content += Write-DetailInfo -PageRef "cmdisc.ps1" -Mode $Detailed

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