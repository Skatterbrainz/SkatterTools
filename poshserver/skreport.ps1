$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default "equals"
$Script:SortField   = Get-PageParam -TagName 's' -Default ""
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default ""
$Script:CustomName  = Get-PageParam -TagName 'n' -Default ""
$Caption = $Script:CustomName -replace '.sql',''

$Script:PageTitle   = "Custom Report: $Caption"
$Script:PageCaption = "Custom Report: $Caption"
$Script:SortField   = ""
$content     = ""
$tabset      = ""
$query = ""

try {
    $rpath  = $(Join-Path -Path $PSScriptRoot -ChildPath "reports")
    $rfile  = $(Join-Path -Path $rpath -ChildPath $Script:CustomName)
    if (Test-Path $rfile) {
        $content = Get-SkQueryTable3 -QueryFile $rfile -PageLink "skreport.ps1" -NoUnFilter -NoCaption
    }
    else {
        throw "$rfile not found"
    }
}
catch {
    $content = "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
}

$content += Write-DetailInfo -PageRef "skreport.ps1" -Mode $Script:Detailed

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