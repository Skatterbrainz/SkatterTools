Get-SkParams | Out-Null

$PageTitle   = "AD Groups"
if (![string]::IsNullOrEmpty($Script:SearchValue)) {
    $PageTitle += ": $($Script:SearchValue)"
}
$content  = ""
$menulist = ""
$tabset   = ""
$pagelink = Split-Path -Leaf $MyInvocation.MyCommand.Definition

$tabset = New-MenuTabSet -BaseLink 'adgroups.ps1?x=begins&f=name&v=' -DefaultID $TabSelected
$content = Get-ADObjectTableMultiple -ObjectType 'group' -Columns ('Name','Description') -SortColumn "Name" -NoSortHeadings

Show-SkPage