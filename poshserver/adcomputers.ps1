$SearchField = $PoshQuery.f
$SearchValue = $PoshQuery.v
$SortField   = Get-SortField -Default "Name"
$DebugMode   = $PoshQuery.z

$PageTitle   = "AD Computers"
$PageCaption = "AD Computers"
$IsFiltered  = $False

try {
    $computers = Get-ADsComputers | Sort-Object $SortField
    if (![string]::IsNullOrEmpty($SearchValue)) {
        $computers = $computers | Where-Object {$_."$SearchField" -eq $SearchValue}
        $IsFiltered = $True
    }
    $columns = @('Name','OS','OSVer','Created','LastLogon')
    $content = '<table id=table1><tr>'
    foreach ($col in $columns) {
        $content += '<th>'+$col+'</th>'
    }
    $content += '</tr>'
    $rowcount = 0
    foreach ($comp in $computers) {
        $content += '<tr>'
        foreach ($col in $columns) {
            $fv = $($comp."$col")
            switch ($col) {
                'Name' {
                    $fvx = '<a href="adcomputer.ps1?f=Name&v='+$fv+'" title="Details">'+$fv+'</a>'
                    break;
                }
                'OS' {
                    $fvx = '<a href="adcomputers.ps1?f=OS&v='+$fv+'" title="Filter">'+$fv+'</a>'
                    break;
                }
                'OSVer' {
                    $fvx = "$fv - $(Get-OSBuildName -BuildData $fv)"
                    break;
                }
                'LastLogon' {
                    $fvx = "$fv `($($(New-TimeSpan -Start $fv -End (Get-Date)).Days)` days)"
                    break;
                }
                default {
                    $fvx = $fv
                }
            }
            $content += '<td>'+$fvx+'</td>'
        }
        $content += '</tr>'
        $rowcount++
    } # foreach
    $content += '<tr>'
    $content += '<th colspan='+$($columns.Count)+'>'+$rowcount+' computers found'
    if ($IsFiltered -eq $True) {
        $content += ' - <a href="adcomputers.ps1" title="Show All">Show All</a>'
    }
    $content += '</th></tr></table>'    
}
catch {
    $content = "Error: $($Error[0].Exception.Message)"
}

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
