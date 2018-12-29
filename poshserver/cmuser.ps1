$Script:SearchField = Get-PageParam -TagName 'f' -Default "UserName"
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default 'equals'
$Script:SortField   = Get-PageParam -TagName 's' -Default ""
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:CustomName  = Get-PageParam -TagName 'n' -Default ""
$Script:PageTitle   = "CM User: $CustomName"
$Script:PageCaption = "CM User: $CustomName"

$content = ""
$tabset  = ""

switch ($Script:TabSelected) {
    'General' {
        $xxx = "queryfile: cmuser.sql"
        $content = Get-SkQueryTable2 -QueryFile "cmuser.sql" -PageLink "cmuser.ps1" -Columns ('UserName','FullName','UserDomain','ResourceID','Department','Title','Email','UPN','UserDN','SID','Mgr')
        break;
    }
    'Computers' {
        $xxx = "queryfile: cmuserdevices.sql"
        $content = Get-SkQueryTable3 -QueryFile "cmuserdevices.sql" -PageLink "cmuser.ps1" -Columns ('ComputerName','ProfilePath','TimeStamp','ResourceID','ADSite') -NoUnFilter
        break;
    }
} # switch

if ($SkNotesEnable -eq 'true') {
    $tabs = @('General','Computers','Notes')
}
else {
    $tabs = @('General','Computers')
}

$tabset = New-MenuTabSet2 -MenuTabs $tabs -BaseLink "cmuser.ps1"
$content += Write-DetailInfo -PageRef "cmuser.ps1" -Mode $Detailed

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