$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default 'equals'
$Script:SortField   = Get-PageParam -TagName 's' -Default "CollectionName"
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:CustomName  = Get-PageParam -TagName 'n' -Default ""
$CollectionType = Get-PageParam -TagName 't' -Default '2'
$Script:IsFiltered  = $False

if ($CollectionType -eq '2') {
    $Ctype = "Device"
    $ResType = 5
}
else {
    $Ctype = "User"
    $ResType = 4
}
$Script:PageTitle   = "CM Collection: $CustomName"
$Script:PageCaption = "CM Collection: $CustomName"
$content     = ""
$tabset      = ""
if ($SkNotesEnabled -eq "true") {
    $tabs = @('General','Members','QueryRules','Variables','Tools','Notes')
}
else {
    $tabs = @('General','Members','QueryRules','Variables','Tools')
}

switch ($Script:TabSelected) {
    'General' {
        $content = Get-SkQueryTable2 -QueryFile "cmcollection.sql" -PageLink "cmcollection.ps1" -Columns ('CollectionName','CollectionID','Comment','Members','Type','Variables','LimitedTo')
        break;
    }
    'Members' {
        $content = Get-SkQueryTable -QueryFile "cmcollectionmembers.sql" -PageLink "cmcollection.ps1" -Columns ('Name','ResourceID','ResourceType','Domain','SiteCode','RuleType') -Sorting "Name"
        break;
    }
    'DirectRules' {
        if ($SearchValue -notlike 'SMS*') {
            $content = Get-SkQueryTable -QueryFile "cmcollectionmembers.sql" -PageLink "cmcollection.ps1" -Columns ('Name','ResourceID','ResourceType','Domain','SiteCode','RuleType')
        }
        else {
            $content = "<table id=table2><tr><td style=`"height:200px;text-align:center`">Direct Membership Rules do not apply</td></tr></table>"
        }
        break;
    }
    'QueryRules' {
        $content = "<table id=table1>"
        $content += "<tr><td style=`"height:150px;text-align:center`">Still in Development. Check back soon.</td></tr>"
        $content += "</table>"
        break;
    }
    'Variables' {
        $content = "<table id=table1>"
        $content += "<tr><td style=`"height:150px;text-align:center`">Still in Development. Check back soon.</td></tr>"
        $content += "</table>"
        break;
    }
    'Tools' {
        $content = "<table id=table1>"
        $content += "<tr><td style=`"height:150px;text-align:center`">Still in Development. Check back soon.</td></tr>"
        $content += "</table>"
        break;
    }
    'Notes' {
        $content = "<table id=table1>"
        $content += "<tr><td style=`"height:150px;text-align:center`">Still in Development. Check back soon.</td></tr>"
        $content += "</table>"
        break;
    }
} # switch

$tabset = New-MenuTabSet2 -MenuTabs $tabs -BaseLink "cmcollection.ps1"

$content += Write-DetailInfo -PageRef "cmcollection.ps1" -Mode $Detailed

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