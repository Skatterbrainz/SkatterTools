$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'equals'
$SortField   = Get-PageParam -TagName 's' -Default 'FullPath'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default ""
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "AD OU Explorer"
$PageCaption = "AD OU Explorer"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

if (![string]::IsNullOrEmpty($SearchValue)) {
    $oulist = Get-ADsOUTree | Where {$_.FullPath -like "$SearchValue*"}
    $IsFiltered = $True
}
else {
    $oulist = Get-ADsOUTree | Where {$_.ChildPath.Length -eq 1}
}
$rowcount = 0
if ($SearchValue -ne "") {
    $content = "<h3>$($SearchValue.ToUpper())</h3>"
}
else {
    $content = "<h3>$($env:USERDNSDOMAIN)</h3>"
}
$content += "<table style=`"width:100%; border=0`"><tr>"
$content += "<td style=`"width:250px;vertical-align:top`">"
$content += "<table id=table1>"
$content += "<tr><th>Name</th></tr>"
foreach ($ou in $oulist) {
    $ouname = $ou.Name
    $fpath  = $ou.FullPath
    $cdist  = $ou.ChildPath.Length
    if ($SearchValue -ne "" -and $cdist -eq 1) {
        $xlink = "<a href=`"adbrowser.ps1`">&lt; back...</a>"
    }
    elseif ($fpath -eq $SearchValue) {
        $spath = ($fpath -replace "$ouname", "").TrimEnd('/')
        $xlink = "<a href=`"adbrowser.ps1?f=FullPath&v=$spath`">&lt; back...</a>"
    }
    else {
        $xlink = "<a href=`"adbrowser.ps1?f=FullPath&v=$fpath`" title=`"Explore`">$ouname</a>"
    }
    #$content += "<tr><td>$xlink</td><td>$fpath ($cdist)</td></tr>"
    $content += "<tr><td>$xlink</td></tr>"
    $rowcount++
}
$content += "<tr><td class=lastrow>$rowcount found</td></tr>"
$content += "</table>"
$content += "</td><td style=`"vertical-align:top`">"
try {
    # convert "contoso.local/CORP" to "ou=CORP,dc=contoso,dc=local"
    $pathset = ($SearchValue -split '/')
    # convert "contoso.local" to "dc=contoso,dc=local"
    $domset  = ($pathset[0].Split('.') | %{"dc=$_"}) -join ','
    # convert ("CORP","Workstations") to "ou=workstations,ou=corp"
    $tailset = $pathset[1..($pathset.Length -1)]
    [array]::Reverse($tailset)
    $tailset = ($tailset | %{"ou=$_"}) -join ','
    $oupath  = "$tailset,$domset"
    $items = Get-AdOuObjects -ou $oupath
    $content += "<table id=table1>"
    $content += "<tr><th>Name</th><th>Class</th></tr>"
    $xlist = @('Organizational-Unit','Service-Connection-Point')
    foreach ($item in $items) {
        if ($item.path -eq $oupath -and ($item.name -ne $ouname -and $item.type -notin $xlist)) {
            $itemName = $item.name
            $objName  = ($item.ObjName).TrimEnd('$')
            $itemTypeName = $item.type
            switch ($itemTypeName) {
                'person' {
                    $tlink = "<a href=`"aduser.ps1?f=username&v=$objName&x=equals&n=$itemName`">$itemName</a>"
                    break;
                }
                'computer' {
                    $tlink = "<a href=`"adcomputer.ps1?f=name&v=$objName&x=equals&n=$itemName`">$itemName</a>"
                    break;
                }
                'group' {
                    $tlink = "<a href=`"adgroup.ps1?f=name&v=$objName&x=equals&n=$itemName`">$itemName</a>"
                    break;
                }
                default {
                    $tlink = $itemName
                    break;
                }
            }
            $content += "<tr><td>$tlink</td><td>$itemTypeName</td></tr>"
        }
    }
    $content += "</table>"
}
catch {}
finally {
    $content += "</td></tr></table>"
    #$content += Write-DetailInfo -PageRef "adbrowser.ps1" -Mode $Detailed
}

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