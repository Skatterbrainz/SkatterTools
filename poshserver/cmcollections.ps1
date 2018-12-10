$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'CollectionName'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = ""
$CollectionType = Get-PageParam -TagName 't' -Default '2'
$IsFiltered  = $False

if ($CollectionType -eq '2') {
    $Ctype = "Device"
}
else {
    $Ctype = "User"
}
$PageTitle   = "CM $CType Collections"
$PageCaption = "CM $CType Collections"
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

$query = 'SELECT DISTINCT 
    dbo.v_Collection.Name as CollectionName, 
    dbo.v_FullCollectionMembership.CollectionID, 
    dbo.v_Collection.Comment, 
    dbo.v_Collection.MemberCount as Members, 
    dbo.v_Collection.CollectionType as [Type], 
    dbo.v_Collections.CollectionVariablesCount as Variables, 
    dbo.v_Collections.LimitToCollectionID as LimitedTo
FROM 
    dbo.v_FullCollectionMembership INNER JOIN
    dbo.v_Collection ON 
    dbo.v_FullCollectionMembership.CollectionID = dbo.v_Collection.CollectionID 
    INNER JOIN dbo.v_Collections ON 
    dbo.v_Collection.Name = dbo.v_Collections.CollectionName'

if (![string]::IsNullOrEmpty($SearchValue)) {
    if ($SearchType -eq 'like') {
        $query += " WHERE (dbo.v_Collection.CollectionType=$CollectionType) and ($SearchField like '$SearchValue%')"
    }
    else {
        $query += " WHERE (dbo.v_Collection.CollectionType=$CollectionType) and ($SearchField = '$SearchValue')"
    }
    $IsFiltered = $True
}
else {
    $query += " WHERE (dbo.v_Collection.CollectionType=$CollectionType)"
}
$query += " ORDER BY $SortField $SortOrder"
$xxx = "query: $query"

try {
    $connection = New-Object -ComObject "ADODB.Connection"
    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
    $connection.Open($connString);
    $IsOpen = $True
    $xxx += "<br/>connection opened"
    $rs = New-Object -ComObject "ADODB.RecordSet"
    $rs.Open($query, $connection)
    $xxx += "<br/>recordset defined"
    $colcount = $rs.Fields.Count
    $rowcount = 0
    $xxx += "<br/>$colcount columns returned"
    if ($rs.BOF -and $rs.EOF) {
        $content = "<table id=table2><tr><td>No matching records found</td></tr>"
    }
    else {
        $rs.MoveFirst()
        $content = '<table id=table1><tr>'
        for ($i = 0; $i -lt $colcount; $i++) {
            $fn = $rs.Fields($i).Name
            $content += "<th>$fn</th>"
        }
        $content += '</tr>'
        while (!$rs.EOF) {
            $content += "<tr>"
            for ($i = 0; $i -lt $colcount; $i++) {
                $fn = $rs.Fields($i).Name
                $fv = $rs.Fields($i).Value
                switch ($fn) {
                    'CollectionName' {
                        $cn = $fv
                        $fvx = $fv
                        break;
                    }
                    'CollectionID' {
                        $fvx = "<a href=`"cmcollection.ps1?f=collectionid&v=$fv&t=$CollectionType&n=$cn`" title=`"Details`">$fv</a>"
                        break;
                    }
                    'LimitedTo' {
                        $fvx = "<a href=`"cmcollection.ps1?f=collectionid&v=$fv&t=$CollectionType`" title=`"Details`">$fv</a>"
                        break;
                    }
                    default {
                        $fvx = $fv
                        break;
                    }
                } # switch
                $content += "<td>$fvx</td>"
            }
            $content += "</tr>"
            $rs.MoveNext();
            $rowcount++
        } # while
    }
    $content += "<tr><td colspan=`"$($colcount)`">$rowcount rows returned"
    if ($IsFiltered -eq $true) {
        $content += " - <a href=`"cmcollections.ps1?t=$CollectionType`" title=`"Show All`">Show All</a>"
    }
    $content += "</td></tr>"
    $content += "</table>"
}
catch {
    $xxx += $Error[0].InnerException
}
finally {
    if ($IsOpen) {
        [void]$connection.Close()
    }
}

$tabset = New-MenuTabSet -BaseLink "cmcollections.ps1?t=$CollectionType&x=like&f=collectionname&v=" -DefaultID $TabSelected
$content += Write-DetailInfo -PageRef "cmcollections.ps1" -Mode $Detailed

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