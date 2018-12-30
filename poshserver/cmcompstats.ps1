$Script:SearchField = Get-PageParam -TagName 'f' -Default "Component"
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default 'equals'
$Script:SortField   = Get-PageParam -TagName 's' -Default 'Component'
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default ''
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:IsFiltered  = $False
$Script:PageTitle   = "CM Component Status: $Script:SearchValue"
$Script:PageCaption = "CM Component Status: $Script:SearchValue"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

$content = Get-SkQueryTable3 -QueryFile "cmcompstat.sql" -PageLink "cmcompstats.ps1" -Columns ('RecordID','MachineName','ModuleName','Win32Error','Time','SiteCode','TopLevelSiteCode','ProcessID','ThreadID','Severity','MessageID','MessageType','ReportFunction','SuccessfulTransaction','Transaction','PerClient') -NoUnFilter

$content += Write-DetailInfo -PageRef "cmcompstats.ps1" -Mode $Detailed

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

$content

</body>
</html>
"@