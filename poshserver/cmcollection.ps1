﻿$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'equals'
$SortField   = Get-PageParam -TagName 's' -Default ""
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$CollectionType = Get-PageParam -TagName 't' -Default '2'

if ($CollectionType -eq '2') {
    $Ctype = "Device"
}
else {
    $Ctype = "User"
}
$PageTitle   = "CM $CType Collection: $CustomName"
$PageCaption = "CM $CType Collection: $CustomName"
$content     = ""
$tabset      = ""
if ($SkNotesEnabled -eq "true") {
    $tabs = @('General','DirectRules','QueryRules','Variables','Tools','Notes')
}
else {
    $tabs = @('General','DirectRules','QueryRules','Variables','Tools')
}
$xxx = ""

switch ($TabSelected) {
    'General' {
        try {
            $query = ""
            $query = 'SELECT TOP 1  
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
                dbo.v_Collection.Name = dbo.v_Collections.CollectionName
            WHERE (dbo.v_Collection.CollectionID='''+$SearchValue+''')'
            $xxx += "<br/>query: $query"
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
                $content = "<table id=table1>"
                for ($i = 0; $i -lt $colcount; $i++) {
                    $fn = $rs.Fields($i).Name
                    $fv = $rs.Fields($i).Value
                    $content += "<tr><td style=`"width:200px`">$fn</td>"
                    $content += "<td>$fv</td></tr>"
                }
                $content += "</table>"
                [void]$rs.Close()
            }
        }
        catch {
            $xxx += "<br/>Error: $($Error[0].Exception.Message)"
        }
        finally {
            if ($IsOpen) {
                [void]$connection.Close()
            }
        }
        break;
    }
    'DirectRules' {
        try {
            $query = 'SELECT DISTINCT 
                dbo.v_CollectionRuleDirect.CollectionID, 
                dbo.v_CollectionRuleDirect.RuleName, 
                dbo.v_CollectionRuleDirect.ResourceID, 
                dbo.v_CollectionRuleDirect.ResourceType, 
                dbo.v_Collection.Name AS CollectionName
            FROM dbo.v_CollectionRuleDirect INNER JOIN 
                dbo.v_Collection ON 
                dbo.v_CollectionRuleDirect.CollectionID = dbo.v_Collection.CollectionID
            WHERE (dbo.v_CollectionRuleDirect.CollectionID = '''+$SearchValue+''') 
            ORDER BY dbo.v_CollectionRuleDirect.RuleName'
            $xxx += "<br/>query: $query"
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
                $content = "<table id=table2><tr><td style=`"text-align:center`">No Direct Membership Rules found</td></tr>"
            }
            else {
                [void]$rs.MoveFirst()
                $content = "<table id=table1><tr>"
                for ($i = 0; $i -lt $colcount; $i++) {
                    $fn = $rs.Fields($i).Name
                    $content += "<th>$fn</th>"
                }
                $content += "</tr>"
                while (!$rs.EOF) {
                    $content += "<tr>"
                    for ($i = 0; $i -lt $colcount; $i++) {
                        $fn = $rs.Fields($i).Name
                        $fv = $($rs.Fields($i).Value | Out-String).Trim()
                        $content += "<td>$fv</td>"
                    }
                    $content += "</tr>"
                    $rowcount++
                    [void]$rs.MoveNext()
                }
                $content += "<tr><td colspan=`"$($colcount)`">$rowcount rules returned</td></tr>"
                $content += "</table>"
                [void]$rs.Close()
                $xxx += "<br/>recordset closed"
            }
        }
        catch {
            $xxx += "<br/>Error: $($Error[0].Exception.Message)"
        }
        finally {
            if ($IsOpen -eq $true) {
                [void]$connection.Close()
            }
        }
        break;
    }
    'QueryRules' {
        try {
            $query = 'SELECT CollectionID, RuleName, QueryExpression, LimitToCollectionID, QueryID 
            FROM dbo.v_CollectionRuleQuery 
            WHERE (CollectionID = '''+$SearchValue+''') 
            ORDER BY QueryID'

            $xxx += "<br/>query: $query"
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
                $content = "<table id=table2><tr><td style=`"text-align:center`">No Query Membership Rules found</td></tr>"
            }
            else {
                [void]$rs.MoveFirst()
                $content = "<table id=table1><tr>"
                for ($i = 0; $i -lt $colcount; $i++) {
                    $fn = $rs.Fields($i).Name
                    $content += "<th>$fn</th>"
                }
                $content += "</tr>"
                while (!$rs.EOF) {
                    $content += "<tr>"
                    for ($i = 0; $i -lt $colcount; $i++) {
                        $fn = $rs.Fields($i).Name
                        $fv = $($rs.Fields($i).Value | Out-String).Trim()
                        switch ($fn) {
                            'QueryExpression' {
                                $fvx = $fv.Replace(',',', ')
                                break;
                            }
                            'LimitToCollectionID' {
                                $fvx = "<a href=`"cmcollection.ps1?f=collectionid&v=$fv`" title=`"Details`">$fv</a>"
                                break;
                            }
                            default {
                                $fvx = $fv
                                break;
                            }
                        }
                        $content += "<td>$fvx</td>"
                    }
                    $content += "</tr>"
                    $rowcount++
                    [void]$rs.MoveNext()
                }
                $content += "<tr><td colspan=`"$($colcount)`">$rowcount rules returned</td></tr>"
                $content += "</table>"
                [void]$rs.Close()
                $xxx += "<br/>recordset closed"
            }
        }
        catch {
            $xxx += "<br/>Error: $($Error[0].Exception.Message)"
        }
        finally {
            if ($IsOpen -eq $true) {
                [void]$connection.Close()
            }
        }
        break;
    }
    'Variables' {
        $content = "<table id=table1>"
        $content += "<tr><td style=`"height:150px;text-align:center`">Still in Development. Check back soon.</td></tr>"
        $content += "</table>"
        break;
    }
    'Tools' {
        $content = "<table id=table1>"
        $content += "<tr><td style=`"height:150px;text-align:center`">Still in Development. Check back soon.</td></tr>"
        $content += "</table>"
        break;
    }
    'Notes' {
        $content = "<table id=table1>"
        $content += "<tr><td style=`"height:150px;text-align:center`">Still in Development. Check back soon.</td></tr>"
        $content += "</table>"
        break;
    }
} # switch

$tabset = New-MenuTabSet2 -MenuTabs $tabs -BaseLink "cmcollection.ps1"

$content += Write-DetailInfo -PageRef "cmcollection.ps1" -Mode $Detailed

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