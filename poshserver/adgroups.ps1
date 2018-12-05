$SearchField = $PoshQuery.f
$SearchValue = $PoshQuery.v
$SortField   = Get-SortField -Default "Name"
$DebugMode   = $PoshQuery.z

$PageTitle   = "AD Groups"
$PageCaption = "AD Groups"
$content = ""

try {
    $groups = Get-ADsGroups | Sort-Object $SortField
    if (![string]::IsNullOrEmpty($SearchValue)) {
        $groups = $groups | Where-Object {$_."$SearchField" -eq $SearchValue}
        $IsFiltered = $True
    }
    $columns = @('Name','Description','Created','Changed')
    $content = '<table id=table1><tr>'
    foreach ($col in $columns) {
        $content += '<th>'+$col+'</th>'
    }
    $content += '</tr>'
    $rowcount = 0
    foreach ($group in $groups) {
        $content += '<tr>'
        foreach ($col in $columns) {
            $fv = $($group."$col")
            switch ($col) {
                'Name' {
                    $fvx = '<a href="adgroup.ps1?f=Name&v='+$fv+'" title="Details">'+$fv+'</a>'
                }
                default {
                    $fvx = $fv
                }
            }
            $content += '<td>'+$fvx+'</td>'
        }
        $content += '</tr>'
        $rowcount++
    }
    $content += '<tr>'
    $content += '<th colspan='+$($columns.Count)+'>'+$rowcount+' groups found'
    if ($IsFiltered -eq $True) {
        $content += ' - <a href="adgroups.ps1" title="Show All">Show All</a>'
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
