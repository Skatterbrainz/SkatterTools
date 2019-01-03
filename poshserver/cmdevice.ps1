$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'exact'
$SortField   = Get-PageParam -TagName 's' -Default 'Name'
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""

$PageTitle   = "CM Device: $CustomName"
$PageCaption = "CM Device: $CustomName"

if ([string]::IsNullOrEmpty($TabSelected)) {
    $TabSelected = "General"
}

$content = ""
$tabset  = ""

if ($SkNotesEnable -eq 'true') {
    $tabs = @('General','Storage','Collections','Software','Tools','Notes')
}
else {
    $tabs = @('General','Storage','Collections','Software','Tools')
}
$tabset = New-MenuTabSet2 -MenuTabs $tabs -BaseLink "cmdevice.ps1"

switch ($TabSelected) {
    'General' {
        try {
            $content = Get-SkQueryTable2 -QueryFile "cmdevice.sql" -PageLink "cmdevice.ps1"
        }
        catch {
            $content += "Error: $($Error[0].Exception.Message)"
            $content += "<br/>SearchField: $SearchField"
            $content += "<br/>SearchValue: $SearchValue"
            $content += "<br/>Query: $query"
        }
        finally {
            if ($isopen -eq $true) {
                $connection.Close()
            }
        }
        break;
    }
    'Collections' {
        $xxx = "query defined"
        try {
            $query = 'SELECT DISTINCT 
            dbo.v_FullCollectionMembership.CollectionID, dbo.v_Collection.Name AS CollectionName 
            FROM dbo.v_FullCollectionMembership INNER JOIN dbo.v_Collection ON 
            dbo.v_FullCollectionMembership.CollectionID = dbo.v_Collection.CollectionID 
            WHERE (dbo.v_FullCollectionMembership.Name = '''+$CustomName+''') 
            ORDER BY CollectionName'
            $xxx = "query: $query"
            $connection = New-Object -ComObject "ADODB.Connection"
            $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
            $connection.Open($connString);
            $xxx += "<br/>connection opened"
            $IsOpen = $True
            $rs = New-Object -ComObject "ADODB.RecordSet"
            $rs.Open($query, $connection, 0, 1)
            $xxx += "<br/>recordset created"
            $rowcount = 0
            if ($rs.BOF -and $rs.BOF) {
                $xxx += "recordset is empty"
                $content = "<table id=table2><tr><td style=`"height:150px;text-align:center`">No matching records found</td></tr></table>"
            }
            else {
                $xxx += "<br/>recordset is not empty"
                $colcount = $rs.Fields.Count
                $xxx += "<br/>$colcount fields found"
                [void]$rs.MoveFirst()
                $content = "<table id=table1><tr>"
                for ($i = 0; $i -lt $colcount; $i++) {
                    $fn = $rs.Fields($i).Name
                    $content += "<th>$fn</th>"
                }
                $memberlist = @()
                $content += "</tr>"
                $xxx += "<br/>column headings defined"
                while (!$rs.EOF) {
                    $cid = $rs.Fields("CollectionID").Value
                    $cnn = $rs.Fields("CollectionName").Value
                    $memberlist += $cid
                    $content += "<tr><td style=`"width:200px`">"
                    $content += "<a href=`"cmcollection.ps1?f=collectionid&v=$fv&t=2&x=equals&n=$cnn`" title=`"Details`">$cid</a></td>"
                    $content += "<td>$cnn</td></tr>"
                    [void]$rs.MoveNext()
                    $rowcount++
                }
                $content += "<tr><td colspan=`"$colcount`">$rowcount memberships found</td></tr>"
                $content += "</table>"
            }
            [void]$rs.Close()
            $xxx += "<br/>recordset closed"
        }
        catch {
            $xxx += "<br/>Error: $($Error[0].Exception.Message)"
        }
        finally {
            if ($IsOpen) {
                $connection.Close()
                $xxx += "<br/>connection is closed"
            }
        }
        $dcolls = Get-CmCollectionsList -MembershipType direct | ?{$_.CollectionID -notlike 'SMS*'}
        $dcolls = $dcolls | ?{$_.CollectionType -eq 2}
        if ($memberlist.count -gt 0) {
            $dcolls = $dcolls | ?{$_.CollectionID -notin $memberlist}
        }
        $content += "<form name='form1' id='form1' method='post' action='addmember.ps1'>"
        $content += "<input type='hidden' name='resname' id='resname' value='$CustomName' />"
        $content += "<input type='hidden' name='resid' id='resid' value='$SearchValue' />"
        $content += "<input type='hidden' name='restype' id='restype' value='5' />"
        $content += "<table id=table2><tr><td>"
        $content += "<select name='collid' id='collid' size=1 style='width:500px;padding:5px'>"
        $content += "<option value=`"`"></option>"
        foreach ($row in $dcolls) {
            $cid = $row.CollectionID
            $cnn = $row.CollectionName
            $content += "<option value=`"$cnn`">$cnn</option>"
        }
        $content += "</select> <input type='submit' name='ok' id='ok' value='Add' class='button1' />"
        $content += " (direct membership collections only)</td></tr></table></form>"

        break;
    }
    'Storage' {
        $content = Get-SkQueryTable3 -QueryFile "cmdevicedrives.sql" -PageLink "cmdevice.ps1" -Columns ('Drive','DiskType','Description','DiskSize','Used','FreeSpace','PCT')
        break;
    }
    'Software' {
        $SearchField = 'Name0'
        $content = Get-SkQueryTable3 -QueryFile "cmdeviceapps.sql" -PageLink "cmdevice.ps1" -Columns ('ProductName','Publisher','Version') -Sorting "ProductName"
        break;
    }
    'Notes' {
        break;
    }
}
$content += Write-DetailInfo -PageRef "cmdevice.ps1" -Mode $Detailed

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