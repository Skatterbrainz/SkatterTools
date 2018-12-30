$Script:SearchField = Get-PageParam -TagName 'f' -Default "ScriptGuid"
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default "equals"
$Script:SortField   = Get-PageParam -TagName 's' -Default ""
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default ''
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:CustomName  = Get-PageParam -TagName 'n' -Default ""
$Script:IsFiltered  = $False
$Script:PageTitle   = "CM Script: $CustomName"
$Script:PageCaption = "CM Script: $CustomName"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

$content = Get-SkQueryTable2 -QueryFile "cmscript.sql" -PageLink "cmscript.ps1" -Columns ('ScriptName','ScriptVersion','ScriptGuid','Author','ScriptType','Feature','ApprovalState','Approval','Approver','Script','ScriptHashAlgorithm','ScriptHash','LastUpdateTime','Comment','ParameterlistXML','ParameterGroupHash')
$content += Write-DetailInfo -PageRef "cmscript.ps1" -Mode $Detailed

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