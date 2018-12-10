$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'Name'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""

$PageTitle   = "AD Sites"
$PageCaption = "AD Sites"
$content     = ""
$tabset      = ""

try {
    $Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
    $sitelist = $Forest.Sites | ForEach-Object {
        $sitename = [string]$_.name
        $subnets  = [string[]]$_.subnets
        $locname  = [string]$_.Location
        $adjsites = [string[]]$_.AdjacentSites
        $props = [ordered]@{
            SiteName = $sitename
            Location = $locname
            Subnets  = $($subnets | %{$_})
            AdjacentSites = $adjsites
        }
        New-Object PSObject -Property $props
    }
    $content = "<table id=table1>"
    $content += "<tr><th>Name</th><th>Location</th><th>Subnets</th><th>Adjacent Sites</td></tr>"
    $rowcount = 0
    $sitelist | ForEach-Object {
        $content += "<tr>"
        $content += "<td>$($_.SiteName)</td><td>$($_.Location)</td>"
        $content += "<td>$($_.Subnets -join ',')</td>"
        $content += "<td>$($_.AdjacentSites -join ',')</td>"
        $content += "</tr>"
        $rowcount++
    }
    $content += "<tr><td class=lastrow colspan=4>$(Write-RowCount 'site' $rowcount)</td></tr>"
    $content += "</table>"
}
catch {
    $content += "<table id=table2><tr><td>$($Error[0].Exception.Message)</td></tr></table>"
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