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
$content = "<table id=table1>"
$content += "<tr><th>Name</th><th>Path</th></tr>"
foreach ($ou in $oulist) {
    $ouname = $ou.Name
    $fpath  = $ou.FullPath
    $cdist  = $ou.ChildPath.Length
    $xlink  = "<a href=`"adbrowser.ps1?f=FullPath&v=$fpath`" title=`"Explore`">$ouname</a>"
    $content += "<tr><td>$xlink</td><td>$fpath ($cdist)</td></tr>"
    $rowcount++
}
$content += "<tr><td colspan=2 class=lastrow>$rowcount found</td></tr>"
$content += "</table>"

$content += Write-DetailInfo -PageRef "adbrowser.ps1" -Mode $Detailed

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