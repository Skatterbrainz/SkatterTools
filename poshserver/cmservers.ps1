$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default "like"
$Script:SortField   = Get-PageParam -TagName 's' -Default "Name"
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:CustomName  = Get-PageParam -TagName 'n' -Default ""
$Script:RoleCode    = Get-PageParam -TagName 'rc' -Default ""
$Script:IsFiltered  = $False
$Script:PageTitle   = "CM Site Systems"
$Script:PageCaption = "CM Site Systems"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

try {
    switch ($Script:RoleCode) {
        'dp' {
            $content = Get-SkQueryTable3 -QueryFile "cmdps.sql" -PageLink "cmservers.ps1" -Columns ('DPID','DPName','Description','SMSSiteCode','IsPXE','DPType','Type')
            $Script:PageCaption += ": Distribution Points"
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

#$tabset = New-MenuTabSet -BaseLink 'cmbgroups.ps1?x=begins&f=bgname&v=' -DefaultID $Script:TabSelected
$content += Write-DetailInfo -PageRef "cmservers.ps1" -Mode $Detailed

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