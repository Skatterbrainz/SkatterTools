Get-SkParams | Out-Null

$PageTitle   = "AD Users"
if (![string]::IsNullOrEmpty($Script:SearchValue)) {
    $PageTitle += ": $($Script:SearchValue)"
}
$content  = ""
$menulist = ""
$tabset   = ""
$pagelink = Split-Path -Leaf $MyInvocation.MyCommand.Definition

$tabset = New-MenuTabSet -BaseLink 'adusers.ps1?x=begins&f=username&v=' -DefaultID $TabSelected
$content = Get-ADObjectTableMultiple -ObjectType 'user' -Columns ('UserName','DisplayName','Title','Department','LastLogon') -SortColumn "UserName" -NoSortHeadings

Show-SkPage