$SearchField = $PoshQuery.f
$SearchValue = $PoshQuery.v
$SearchType  = $PoshQuery.x
$SortField   = Get-SortField -Default "sAMAccountName"
$DebugMode   = $PoshQuery.z
$TabSelected = $PoshQuery.tab

$PageTitle   = "AD Users"
$PageCaption = "AD Users"
$content = ""
$tabset  = ""

if ([string]::IsNullOrEmpty($TabSelected)) {
    $TabSelected = "all"
}
if ($SearchValue -eq 'all') {
    $SearchValue = ""
}
else {
    if ($SearchField -eq 'UserName') {
        $TabSelected = $SearchValue
        $PageTitle += " ($SearchValue)"
        $PageCaption = $PageTitle
    }
}

try {
    $users = Get-ADsUsers | Sort-Object Name
    if (![string]::IsNullOrEmpty($SearchValue)) {
        if ($SearchType -eq 'like') {
            $users = $users | Where-Object {$_."$SearchField" -like "$SearchValue*"}
        }
        else {
            $users = $users | Where-Object {$_."$SearchField" -eq $SearchValue}
        }
        $IsFiltered = $True
    }
    $usercount = $users.Count
    $columns = @('UserName','DisplayName','Title','Department','Email')
    $content = '<table id=table1><tr>'
    foreach ($col in $columns) {
        $content += '<th>'+$col+'</th>'
    }
    $content += '</tr>'
    foreach ($user in $users) {
        $content += '<tr>'
        foreach ($col in $columns) {
            $fv = $($user."$col")
            switch ($col) {
                'UserName' {
                    $fvx = '<a href="aduser.ps1?f=UserName&v='+$fv+'" title="Details">'+$fv+'</a>'
                }
                default {
                    $fvx = $fv
                }
            }
            $content += '<td>'+$fvx+'</td>'
        }
        $content += '</tr>'
    }
    $content += '<tr>'
    $content += '<th colspan='+$($columns.Count)+'>'+$usercount+' users found'
    if ($IsFiltered -eq $True) {
        $content += ' - <a href="adusers.ps1" title="Show All">Show All</a>'
    }
    $content += '</th></tr></table>'    
}
catch {
    $content = "Error: $($Error[0].Exception.Message)"
}

$tabset = New-MenuTabSet -BaseLink 'adusers.ps1?x=like&f=username&v=' -DefaultID $TabSelected

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