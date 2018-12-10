$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'Name'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default $DefaultGroupsTab
$Detailed    = Get-PageParam -TagName 'zz' -Default ""

$PageTitle   = "AD Groups"
$PageCaption = "AD Groups"
$content     = ""
$tabset      = ""

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
$subcap = ""
try {
    if ($SortOrder -eq 'Asc') {
        $groups = Get-ADsGroups | Sort-Object $SortField
    }
    else {
        $groups = Get-ADsGroups | Sort-Object $SortField -Descending
    }
    if (![string]::IsNullOrEmpty($SearchValue)) {
        switch ($SearchType) {
            'like' {
                $groups = $groups | Where-Object {$_."$SearchField" -like "*$SearchValue*"}
                $subcap = "$SearchField contains $SearchValue"
                break;
            }
            'begins' {
                $groups = $groups | Where-Object {$_."$SearchField" -like "$SearchValue*"}
                $subcap = "$SearchField begins with $SearchValue"
                break;
            }
            'ends' {
                $groups = $groups | Where-Object {$_."$SearchField" -like "*$SearchValue"}
                $subcap = "$SearchField ends with $SearchValue"
                break;
            }
            default {
                $groups = $groups | Where-Object {$_."$SearchField" -eq "$SearchValue"}
                $subcap = "$SearchField equals $SearchValue"
                break;
            }
        }

        $IsFiltered = $True
    }
    $columns = @('Name','Description')
    $content = '<table id=table1><tr>'
    $content += New-ColumnSortRow -ColumnNames $columns -BaseLink "adgroups.ps1?f=$SearchField&v=$SearchValue&x=$SearchType" -SortDirection $SortOrder
    $content += '</tr>'
    $rowcount = 0
    foreach ($group in $groups) {
        $content += '<tr>'
        foreach ($col in $columns) {
            $fv = $($group."$col")
            switch ($col) {
                'Name' {
                    $fvx = '<a href="adgroup.ps1?f=Name&v='+$fv+'" title="Details">'+$fv+'</a>'
                    $content += '<td style=`"width:30%`">'+$fvx+'</td>'
                }
                default {
                    $fvx = $fv
                    $content += '<td>'+$fvx+'</td>'
                }
            }
        }
        $content += '</tr>'
        $rowcount++
    }
    $content += '<tr>'
    $content += '<td colspan='+$($columns.Count)+'>'+$rowcount+' groups found'
    if ($IsFiltered -eq $True) {
        $content += ' - <a href="adgroups.ps1" title="Show All">Show All</a>'
    }
    $content += '</td></tr></table>'    
}
catch {
    $content = "Error: $($Error[0].Exception.Message)"
}

$tabset = New-MenuTabSet -BaseLink 'adgroups.ps1?x=begins&f=name&v=' -DefaultID $TabSelected

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>
<h3>$subcap</h3>

$tabset
$content

</body>
</html>
"@