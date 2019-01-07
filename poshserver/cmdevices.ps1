Get-SkParams | Out-Null

$PageTitle   = "CM Devices"
if (![string]::IsNullOrEmpty($Script:SearchValue)) {
    $PageTitle += ": $($Script:SearchValue)"
}
$content  = ""
$menulist = ""
$tabset   = ""
$pagelink = Split-Path -Leaf $MyInvocation.MyCommand.Definition

$tabset = New-MenuTabSet -BaseLink "cmdevices.ps1`?x=begins&f=name&v=" -DefaultID $Script:TabSelected

$qfile = "cmdevices.sql"
$content = Get-SkQueryTableMultiple -QueryFile $qfile -PageLink $pagelink -Columns ('Name','ResourceID','Manufacturer','Model','OSName','OSBuild','ADSiteName') -Sorting "Name"

Show-SkPage