$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "equals"
$SortField   = Get-PageParam -TagName 's' -Default "Name"
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$NestedLevel = Get-PageParam -TagName 'nl' -Default ""
$IsFiltered  = $False
$PageTitle   = "Files: $SearchValue"
$PageCaption = "Files: $SearchValue"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

$content = "<table id=table1>"
try {
    if ($NestedLevel -gt 0) {
        $uplink = ($SearchValue -split '\\')
        $uplink = "\\$($uplink[2..$($uplink.length -2)] -join '\')"
        $uplink = "<a href=`"showfiles.ps1?f=folderpath&v=$uplink&x=equals`">Go Back</a>"
        $content += "<tr><td>$uplink</td></tr>"
    }
    if (Test-Path $SearchValue) {
        $subs = Get-ChildItem -Path $SearchValue -Directory -ErrorAction SilentlyContinue
        foreach ($sub in $subs) {
            $fpath = $sub.FullName
            $fname = $sub.Name
            $flink = "<a href=`"showfiles.ps1?f=folderpath&v=$fpath&x=equals&nl=1`">$fname</a>"
            $content += "<tr><td>$flink</td></tr>" 
        }
    }
    else {
        $content += "<tr><td>no folders were found in $SearchValue</td></tr>"
    }
    $resolved = $true
}
catch {
    $content += "<tr><td>$($Error[0].Exception.Message)</td></tr>"
    $resolved = $false
}
finally {
    $content += "</table>"
}

if ($resolved -eq $true) {
    $content += "<h3>Files in: $SearchValue</h3>"
    $content += "<table id=table2>"
    try {
        $fount = 0
        $files = Get-ChildItem -Path $SearchValue -File -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $fpath = $file.FullName
            $fname = $file.Name
            $flink = "<a href=`"showfiles.ps1?f=folderpath&v=$fpath&x=equals&nl=1`">$fname</a>"
            $content += "<tr><td>$flink</td></tr>" 
            $fcount++
        }
        if ($fcount -gt 0) {
            $content += "<tr><td class=lastrow>$fcount files were found</td></tr>"
        }
        else {
            $content += "<tr><td>No files were found in this location</td></tr>"
        }
    }
    catch {
        $content += "<tr><td>$($Error[0].Exception.Message)</td></tr>"
    }
    finally {
        $content += "</table>"
    }
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