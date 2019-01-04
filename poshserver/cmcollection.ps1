$Script:SearchField = Get-PageParam -TagName 'f' -Default "CollectionName"
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default 'equals'
$Script:SortField   = Get-PageParam -TagName 's' -Default "CollectionName"
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:CustomName  = Get-PageParam -TagName 'n' -Default ""
$ScriptCollectionType = Get-PageParam -TagName 't' -Default ""
$Script:IsFiltered  = $False

if ([string]::IsNullOrEmpty($Script:CustomName)) {
    $collName = Get-SkCmCollectionName -CollectionID $Script:SearchValue
}
else {
    $collName = $Script:CustomName
}

if ($CollectionType -eq '2') {
    $Ctype = "Device"
    $ResType = 5
    $CollType = 2
}
else {
    $Ctype = "User"
    $ResType = 4
    $CollType = 1
}
$Script:PageTitle   = "CM Collection: $collName"
$Script:PageCaption = "CM Collection: $collName"
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
        $xxx = "Collection Type: $CollType"
        $params = @{
            QueryFile = "cmcollection.sql"
            PageLink  = "cmcollection.ps1"
            Columns   = ('CollectionName','CollectionID','Comment','Members','Type','Variables','LimitedTo')
        }
        $content = Get-SkQueryTableSingle @params
        #$content = Get-SkQueryTableSingle -QueryFile "cmcollection.sql" -PageLink "cmcollection.ps1" -Columns ('CollectionName','CollectionID','Comment','Members','Type','Variables','LimitedTo')
        break;
    }
    'Members' {
        $xxx = "Collection Type: $CollType"
        if ($CollType -eq 2) {
            $qfile = "cmdevicecollectionmembers.sql"
        }
        else {
            $qfile = "cmusercollectionmembers.sql"
        }
        $content = Get-SkQueryTableMultiple -QueryFile $qfile -PageLink "cmcollection.ps1" -NoUnFilter -NoCaption
        break;
    }
    'QueryRules' {
        $xxx = "Collection Type: $CollType"
        $content = Get-SkQueryTableMultiple -QueryFile "cmcollectionqueryrules.sql" -PageLink "cmcollection.ps1" -Columns ('RuleName','QueryID','QueryExpression','LimitToCollectionID') -NoUnFilter -NoCaption -Sorting "RuleName"
        break;
    }
    'Variables' {
        $content = Get-SkQueryTableMultiple -QueryFile "cmcollectionvariables.sql" -PageLink "cmcollection.ps1" -Columns ('Name','Value','IsMasked')
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