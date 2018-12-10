﻿$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'UserName'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default $DefaultUsersTab
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "AD Users"
$PageCaption = "AD Users"
$content     = ""
$tabset      = ""

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
    if ($SortOrder -eq 'Asc') {
        $users = Get-ADsUsers | Sort-Object $SortField
    }
    else {
        $users = Get-ADsUsers | Sort-Object $SortField -Descending
    }
    if (![string]::IsNullOrEmpty($SearchValue)) {
        switch ($SearchType) {
            'like' {
                $users = $users | Where-Object {$_."$SearchField" -like "*$SearchValue*"}
                break;
            }
            'begins' {
                $users = $users | Where-Object {$_."$SearchField" -like "$SearchValue*"}
                break;
            }
            'ends' {
                $users = $users | Where-Object {$_."$SearchField" -like "*$SearchValue"}
                break;
            }
            default {
                $users = $users | Where-Object {$_."$SearchField" -eq $SearchValue}
            }
        }
        $IsFiltered = $True
    }
    $usercount = 0
    $columns = @('UserName','DisplayName','Title','Department','Email')
    $content = '<table id=table1><tr>'
    $content += New-ColumnSortRow -ColumnNames $columns -BaseLink "adusers.ps1?f=$SearchField&v=$SearchValue&x=$SearchType" -SortDirection $SortOrder
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
        $usercount++
    }
    $content += '<tr>'
    $content += '<td colspan='+$($columns.Count)+' class=lastrow>'+$(Write-RowCount -ItemName 'user' -RowCount $usercount)
    if ($IsFiltered -eq $True) {
        $content += ' - <a href="adusers.ps1" title="Show All">Show All</a>'
    }
    $content += '</th></tr></table>'    
}
catch {
    $content = "Error: $($Error[0].Exception.Message)"
}

$tabset = New-MenuTabSet -BaseLink 'adusers.ps1?x=begins&f=username&v=' -DefaultID $TabSelected

$content += Write-DetailInfo -PageRef "adusers.ps1" -Mode $Detailed

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