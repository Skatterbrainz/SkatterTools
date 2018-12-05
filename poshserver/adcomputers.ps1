$SearchField = $PoshQuery.f
$SearchValue = $PoshQuery.v
$SearchType  = $PoshQuery.x
$SortField   = Get-SortField -Default "Name"
$DebugMode   = $PoshQuery.z
$TabSelected = $PoshQuery.tab

$PageTitle   = "AD Computers"
$PageCaption = "AD Computers"
$IsFiltered  = $False
$content = ""
$tabset  = ""

if ([string]::IsNullOrEmpty($TabSelected)) {
    $TabSelected = "all"
}
if ($SearchValue -eq 'all') {
    $SearchValue = ""
}
else {
    if ($SearchField -eq 'Name') {
        $TabSelected = $SearchValue
        $PageTitle += " ($SearchValue)"
        $PageCaption = $PageTitle
    }
}

try {
    $computers = Get-ADsComputers | Sort-Object $SortField
    if (![string]::IsNullOrEmpty($SearchValue)) {
        if ($SearchType -eq 'like') {
            $computers = $computers | Where-Object {$_."$SearchField" -like "$SearchValue*"}
        }
        else {
            $computers = $computers | Where-Object {$_."$SearchField" -eq $SearchValue}
        }
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

$tabset = New-MenuTabSet -BaseLink 'adcomputers.ps1?x=like&f=name&v=' -DefaultID $TabSelected

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