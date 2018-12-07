$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'Name'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""

$PageTitle   = "CM Collections"
$PageCaption = "CM Collections"
$content     = ""
$tabset      = ""

$query = 'SELECT DISTINCT 
    dbo.v_FullCollectionMembership.CollectionID, 
    dbo.v_Collection.Name, 
    dbo.v_Collection.Comment, 
    dbo.v_Collection.MemberCount, 
    dbo.v_Collection.CollectionType, 
    dbo.v_Collections.CollectionVariablesCount, 
    dbo.v_Collections.LimitToCollectionID
FROM 
    dbo.v_FullCollectionMembership INNER JOIN
    dbo.v_Collection ON 
    dbo.v_FullCollectionMembership.CollectionID = dbo.v_Collection.CollectionID 
    INNER JOIN dbo.v_Collections ON 
    dbo.v_Collection.Name = dbo.v_Collections.CollectionName'

if (![string]::IsNullOrEmpty($SearchField)) {
    $query += " (WHERE $SearchField = '$SearchValue')"
}

$query += "ORDER BY $SortField $SortOrder"

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