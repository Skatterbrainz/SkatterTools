$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'productname'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'All'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""

$PageTitle   = "CM Installed Software"
$PageCaption = "CM Installed Software"

if ($SearchValue -eq 'all') {
    $SearchValue = ""
}
else {
    if ($SearchField -eq 'ProductName0') {
        $TabSelected = $SearchValue.Substring(0,1)
    }
}

$query = 'select distinct 
productname0 as ProductName,
productcode0 as ProductCode,
productversion0 as Version, 
publisher0 as Publisher, 
count(*) as Installs  
from v_GS_INSTALLED_SOFTWARE_CATEGORIZED'

<#
# for individual product page

$query = 'select distinct 
productname0 as ProductName,
productcode0 as ProductCode,
productversion0 as Version, 
publisher0 as Publisher, 
installsource0 as Source, 
uninstallstring0 as Uninstall, 
installdate0 as InstallDate,
normalizedname as NormalName, 
normalizedversion as NormalVersion, 
normalizedpublisher as NormalPublisher, 
FamilyName, 
CategoryName 
from v_GS_INSTALLED_SOFTWARE_CATEGORIZED'
#>

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
$query += " group by productname0, productcode0, productversion0, publisher0"
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
            $pn = $rs.Fields('ProductName').Value
            $pc = $rs.Fields('ProductCode').Value
            $pv = $rs.Fields('Version').Value 
            $vn = $rs.Fields('Publisher').Value
            $qx = $rs.Fields('Installs').Value
            $pn2 = Get-CheapEncode $pn
            #$pv2 = Get-CheapEncode $pv
            #$pn2 = $pn
            $pv2 = $pv
            $xx = '<a href="cminstalls.ps1?pn='+$pn2+'&pv='+$pv2+'" title="Show Installations">'+$qx+'</a>'
            $px = '<a href="cmproduct.ps1?pn='+$pn2+'&pv='+$pv2+'" title="Details for $pn">'+$pn+'</a>'
            $vx = '<a href="cmproducts.ps1?f=publisher0&v='+$vn+'&x=equals" title="Find Others by '+$vn+'">'+$vn+'</a>'
            $content += "<tr>"
            $content += "<td>$px</td><td>$pc</td><td>$pv</td><td>$vx</td><td style=`"text-align:right;`">$xx</td></tr>"
            [void]$rs.MoveNext()
            $rowcount++
        }
        $content += '<tr><td colspan='+$($colcount)+' class=lastrow>'+$rowcount+' products returned'
        if ($IsFiltered -eq $true) {
            $content += " - <a href=`"cmproducts.ps1`" title=`"Show All`">Show All</a>"
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

$tabset = New-MenuTabSet -BaseLink 'cmproducts.ps1?x=begins&f=productname0&v=' -DefaultID $TabSelected
$content += Write-DetailInfo -PageRef "cmproducts.ps1" -Mode $Detailed

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