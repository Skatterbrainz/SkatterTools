$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "equals"
$SortField   = Get-PageParam -TagName 's' -Default ""
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$CustomName  = Get-PageParam -TagName 'n' -Default ""

$PageTitle   = "AD User"
$PageCaption = "AD User"
$SortField   = ""
$content     = ""
$tabset      = ""

$PageTitle += " ($SearchValue)"
$PageCaption = $PageTitle

switch ($TabSelected) {
    'General' {
        try {
            $user = Get-ADsUsers | Where-Object {$_.UserName -eq "$SearchValue"}
            $columns = $user.psobject.properties | Select-Object -ExpandProperty Name
            $content = "<table id=table2>"
            foreach ($col in $columns) {
                $fvx = Get-AdValueLink -PropertyName $col -Value $($user."$col" | Out-String)
                $content += "<tr><td class=`"t2td1`">$col</td><td class=`"t2td2`">$fvx</td></tr>"
            }
            $content += "</table>"
        }
        catch {
            $content = "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
        }
        break;
    }
    'Groups' {
        $content = "<table id=table1>"
        $content += "<tr><th>Name</th><th>LDAP Path</th><th></th></tr>"
        try {
            $groups = Get-ADsUserGroups -UserName "$SearchValue"
            $rowcount = 0
            $groups | ForEach-Object {
                $rmvlink = "<a href=`"admod2.ps1?userid=$SearchValue&groupid=$($_.Name)&op=delmember`" title=`"Remove from Group`">Remove</a>"
                $content += "<tr>"
                $xlink = "<a href=`"adgroup.ps1?f=name&v=$($_.Name)&x=equals`" title=`"Details`">$($_.Name)</a>"
                $content += "<td style=`"width:250px`">$xlink</td>"
                $content += "<td>$($_.DN)</td>"
                $content += "<td style=`"width:80px;text-align:center;`">$rmvlink</td>"
                $content += "</tr>"
                $rowcount++
            }
            $content += "<tr><td colspan=`"3`" class=`"lastrow`">$rowcount groups found</td></tr>"
            $content += "</table><br/>"
            $content += "<form name=`"form11`" id=`"form11`" method=`"POST`" action=`"admod.ps1`">"
            $content += "<input type=`"hidden`" name=`"userid`" id=`"userid`" value=`"$SearchValue`" />"
            $content += "<input type=`"hidden`" name=`"op`" id=`"op`" value=`"addmember`" />"
            $content += "<input type=`"submit`" name=`"ok`" id=`"ok`" value=`"Add to Group`" class=`"button1`" title=`"Add to Group`"/>"
            $content += "</form>"
        }
        catch {}
        finally {}
        break;
    }
    'Devices' {
        try {
            $query = "SELECT DISTINCT
                v_R_System.Name0 AS ADComputerName, 
                v_GS_USER_PROFILE.LocalPath0 AS LocalPath, 
                v_R_System.AD_Site_Name0 AS ADSite, 
                v_GS_COMPUTER_SYSTEM.Model0 AS Model, 
                v_GS_OPERATING_SYSTEM.Caption0 AS OperatingSystem, 
                v_GS_OPERATING_SYSTEM.BuildNumber0 AS OSBuild, 
                v_GS_USER_PROFILE.TimeStamp
                FROM v_GS_USER_PROFILE INNER JOIN
                v_R_System ON dbo.v_GS_USER_PROFILE.ResourceID = v_R_System.ResourceID INNER JOIN
                v_GS_COMPUTER_SYSTEM ON 
                v_GS_USER_PROFILE.ResourceID = v_GS_COMPUTER_SYSTEM.ResourceID INNER JOIN
                v_GS_OPERATING_SYSTEM ON 
                v_GS_USER_PROFILE.ResourceID = v_GS_OPERATING_SYSTEM.ResourceID
                WHERE (v_GS_USER_PROFILE.LocalPath0 LIKE '%$SearchValue')
                ORDER BY v_GS_USER_PROFILE.TimeStamp DESC"
            $result = @(Invoke-DbaQuery -SqlInstance $CmDbHost -Database "CM_$CmSiteCode" -Query $query -ErrorAction Stop)
            $content = "<table id=table1><tr>"
            if ($result.Count -gt 0) {
                $columns  = $result[0].Table.Columns.ColumnName
                $colcount = $columns.Count
                $columns | ForEach-Object { $content += "<th>$_</th>" }
                $content += "</tr>"
                foreach ($rs in $result) {
                    $content += "<tr>"
                    foreach ($fn in $columns) {
                        $fv = $rs."$fn"
                        $fvx = Get-SKDbValueLink -ColumnName $col -Value $fv
                        $content += "<td>$fvx</td>"
                    }
                    $content += "</tr>"
                    $rowcount++
                }
            }
            $content += "<tr><td colspan=$colcount class=lastrow>$rowcount rows returned</td></tr>"
            $content += "</table>"
        }
        catch {
            $content = "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
        }
        break;
    }
    'Notes' {
        $notes = Get-NoteAttachments -ObjectType "aduser" -ObjectID "$SearchValue"
        $content = "<table id=table1>"
        $content += "<tr><th style=`"width:200px`">Date</th>"
        $content += "<th style=`"width:200px`">Author</th><th>Comment</th></tr>"
        if ($notes.count -gt 0) {
            foreach ($note in $notes) {
                $content += "<tr><td>$($note.date)</td>"
                $content += "<td>$($note.author)</td>"
                $content += "<td>$($note.comment)</td></tr>"
            }
        }
        else {
            $content += "<tr><td colspan='3'>No Notes were found</td></tr>"
        }
        $retlink   = (("aduser.ps1?f=username&v=$SearchValue&tab=notes").Replace('?','^')).Replace('&','!')
        $content += "</table><br/>"
        $content += "<form name='form1' id='form1' method='post' action='attachnote.ps1'>"
        $content += "<input type='hidden' name='otype' id='otype' value='aduser' />"
        $content += "<input type='hidden' name='oid' id='oid' value='$SearchValue' />"
        $content += "<input type='hidden' name='retlink' id='retlink' value='$retlink' />"
        $content += "<input type='submit' class='button1' name='ok' id='ok' value='Add Note' />"
        $content += "</form>"
        break;
    }
}

if ($SkNotesEnable -eq 'true') {
    $tabs = @('General','Groups','Devices','Notes')
}
else {
    $tabs = @('General','Groups','Devices')
}
$tabset = New-MenuTabSet2 -MenuTabs $tabs -BaseLink "aduser.ps1"

$content += Write-DetailInfo -PageRef "aduser.ps1" -Mode $Detailed

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