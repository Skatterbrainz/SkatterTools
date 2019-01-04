$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "equals"
$SortField   = Get-PageParam -TagName 's' -Default ""
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$TabSelected = Get-PageParam -TagName 'tab' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""

$PageTitle   = "PageTitle"
$PageCaption = "PageTitle"
$SortField   = ""
$content     = ""
$tabset      = ""

# insert code here to build HTML $content string

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