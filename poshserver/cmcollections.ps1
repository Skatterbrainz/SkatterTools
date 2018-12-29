$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$Script:SortField   = Get-PageParam -TagName 's' -Default 'CollectionName'
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:CustomName  = ""
$Script:CollectionType = Get-PageParam -TagName 't' -Default '2'
$Script:IsFiltered  = $False
$Script:PageFile    = "cmdevices.ps1"

if ($CollectionType -eq '2') {
    $Ctype = "Device"
    $qfname = "cmdevicecollections.sql"
}
else {
    $Ctype = "User"
    $qfname = "cmusercollections.sql"
}
$Script:PageTitle   = "CM $CType Collections"
$Script:PageCaption = "CM $CType Collections"
$content     = ""
$tabset      = ""

if ($SearchField -eq 'collectionname') {
    $TabSelected = $SearchValue
}
if ($SearchValue -eq 'all') {
    $SearchValue = ""
}
else {
    if (![string]::IsNullOrEmpty($SearchValue)) {
        $PageTitle += " ($SearchValue)"
        $PageCaption = $PageTitle
    }
}

$content = Get-SkQueryTable -QueryFile $qfname -PageLink "cmcollections.ps1" -Columns ('CollectionID','CollectionName','Comment','Members','Type','Variables','LimitedTo')
$tabset  = New-MenuTabSet -BaseLink "cmcollections.ps1?t=$CollectionType&f=collectionname&x=begins&v=" -DefaultID $TabSelected
#$content += Write-DetailInfo -PageRef "$Script:PageFile" -Mode $Detailed

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