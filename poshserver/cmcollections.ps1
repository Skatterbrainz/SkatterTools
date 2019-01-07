Get-SkParams | Out-Null
$Script:CollectionType = Get-PageParam -TagName 't' -Default '2'
if ($CollectionType -eq '2') {
    $Ctype = "Device"
    $qfname = "cmdevicecollections.sql"
}
else {
    $Ctype = "User"
    $qfname = "cmusercollections.sql"
}

$PageTitle   = "CM $CType Collections"
if (![string]::IsNullOrEmpty($Script:SearchValue)) {
    $PageTitle += ": $($Script:SearchValue)"
}
$content  = ""
$menulist = ""
$tabset   = ""
$pagelink = Split-Path -Leaf $MyInvocation.MyCommand.Definition

$content = Get-SkQueryTableMultiple -QueryFile $qfname -PageLink "cmcollections.ps1" -NoCaption
$tabset  = New-MenuTabSet -BaseLink "cmcollections.ps1?t=$CollectionType&f=collectionname&x=begins&v=" -DefaultID $TabSelected
$content += Write-DetailInfo -PageRef "cmcollections.ps1" -Mode $Detailed

Show-SkPage