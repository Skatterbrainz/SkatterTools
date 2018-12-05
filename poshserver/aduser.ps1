$SearchField = $PoshQuery.f
$SearchValue = $PoshQuery.v
$SortField   = ""
$DebugMode   = $PoshQuery.z

$PageTitle   = "AD User"
$PageCaption = "AD User"
$SortField   = ""
$content     = ""
try {
    $user = Get-ADsUsers | Where-Object {$_.UserName -eq $SearchValue}
    $columns = $user.psobject.properties | Select-Object -ExpandProperty Name
    $content = '<table id=table2><tr>'
    foreach ($col in $columns) {
        $fv = $($user."$col")
        $fvx = '<a href="adusers.ps1?f='+$col+'&v='+$fv+'" title="Details">'+$fv+'</a>'
        $content += '<tr>'
        $content += '<td style="width:200px;">'+$col+'</td>'
        $content += '<td>'+$fvx+'</td>'
        $content += '</tr>'
    }
    $content += '</tr></table>'    
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
