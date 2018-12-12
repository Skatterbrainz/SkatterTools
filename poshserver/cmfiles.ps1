$SearchField = Get-PageParam -TagName 'f' -Default "FileName"
$SearchValue = Get-PageParam -TagName 'v' -Default 'A'
$SearchType  = Get-PageParam -TagName 'x' -Default 'begins'
$SortField   = Get-PageParam -TagName 's' -Default 'filename'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'A'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""

$PageTitle   = "CM Software Files"
$PageCaption = "CM Software Files"

if ($SearchValue -eq 'all') {
    $SearchValue = ""
    $TabSelected = 'all'
}
else {
    if ($SearchField -eq 'FileName') {
        $TabSelected = $SearchValue.Substring(0,1)
    }
}

$query = 'select distinct 
FileName, 
FileVersion, 
FileSize, 
count (*) as Copies 
from v_gs_softwarefile'

if (![string]::IsNullOrEmpty($SearchValue)) {
    switch ($SearchType) {
        'like'   { $query += " where ($SearchField like '%SearchValue%')"; break; }
        'begins' { $query += " where ($SearchField like '$SearchValue%')"; break; }
        'ends'   { $query += " where ($SearchField like '%$SearchValue')"; break; }
        default  { $query += " where ($SearchField = '$SearchValue')"; break; }
    }
    $IsFiltered = $True
    $PageTitle += " ($SearchValue)"
    $PageCaption = $PageTitle
}
$query += " group by filename, fileversion, filesize, filedescription"
$query += " order by $SortField"

try {
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
            $fn = $rs.Fields("FileName").Value
            $fv = $rs.Fields("FileVersion").Value
            $fs = $rs.Fields("FileSize").Value
            $qx = $rs.Fields("Copies").Value
            $fnx = "<a href=`"cmfile.ps1?n=$fn&v=$fv&s=$fs`" title=`"Find Computers with this Instance`">$fn</a>"
            $content += "<tr><td>$fnx</td><td>$fv</td><td>$fs</td><td>$qx</td></tr>"
            [void]$rs.MoveNext()
            $rowcount++
        }
        $content += '<tr><td colspan='+$($colcount)+' class=lastrow>'+$rowcount+' files returned'
        if ($IsFiltered -eq $true) {
            $content += " - <a href=`"cmfiles.ps1`" title=`"Show All`">Show All</a>"
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

$tabset = New-MenuTabSet -BaseLink 'cmfiles.ps1?x=begins&f=filename&v=' -DefaultID $TabSelected
$content += Write-DetailInfo -PageRef "cmfiles.ps1" -Mode $Detailed

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