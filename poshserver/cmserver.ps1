$Script:RoleCode    = Get-PageParam -TagName 'rc' -Default ""
$Script:SearchField = Get-PageParam -TagName 'f' -Default "ServerName"
$Script:SearchValue = Get-PageParam -TagName 'n' -Default ""
$Script:IsFiltered  = $False
$Script:PageTitle   = "CM Site System"
$Script:PageCaption = "CM Site System"
$content     = ""
$tabset      = ""
$xxx         = ""

try {
    switch ($Script:RoleCode) {
        'dp' {
            $Script:PageCaption += ": $CustomName"
            $content = Get-SkQueryTableSingle -QueryFile "cmdp.sql" -PageLink "cmserver.ps1"
            break;
        }
        default {
            $content = "<table id=table2><tr><td>Not implemented</td></tr></table>"
            break;
        }
    }
}
catch {
    $content = "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
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