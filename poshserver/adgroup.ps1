$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'Name'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'general'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""

$PageTitle   = "AD Group: $SearchValue"
$PageCaption = "AD Group: $SearchValue"
$content     = ""
$tabset      = ""

if ($SkNotesEnable -eq 'true') {
    $tabs = @('General','Members','Notes')
}
else {
    $tabs = @('General','Members')
}

switch ($TabSelected) {
    'General' {
        try {
            $group   = Get-ADsGroups | Where-Object {$_."$SearchField" -eq $SearchValue}
            $content = "<table id=table2>
            <tr><td style=`"width:200px`">Name</td><td>$($group.Name)</td></tr>
            <tr><td style=`"width:200px`">LDAP Path</td><td>$($group.DN)</td></tr>
            <tr><td style=`"width:200px`">OU Path</td><td>$($group.OU)</td></tr>
            <tr><td style=`"width:200px`">Description</td><td>$($group.Description)</td></tr>
            <tr><td style=`"width:200px`">Date Created</td><td>$($group.Created)</td></tr>
            <tr><td style=`"width:200px`">Last Modified</td><td>$($group.Changed)</td></tr>
            </table>"    
        }
        catch {
            $content += $Error[0].Exception.Message
        }
        break;
    }
    'Members' {
        try {
            $rowcount = 0
            $columns = @('UserName','Title','Type','LDAP Path', '...')
            $members = Get-ADsGroupMembers -GroupName $SearchValue | Sort-Object UserName
            $xxx = "members: $($members.count)"
            $content += "<table id=table1>"
            $content += "<tr>"
            #$content += New-ColumnSortRow -ColumnNames $columns -BaseLink "adgroup.ps1?f=name&v=$SearchValue" -SortDirection $SortOrder
            $content += $columns | ForEach-Object { "<th>$_</th>" }
            $content += "</tr>"
            foreach ($member in $members) {
                $uname = $member.UserName
                if ($member.Type -eq 'User') {
                    $xlink = "aduser.ps1?f=UserName&v=$uname&x=equals&tab=general"
                }
                else {
                    $xlink = "adgroup.ps1?f=name&v=$uname&x=equals&tab=general"
                }
                $rmvlink = "<a href=`"admod2.ps1?userid=$uname&groupid=$SearchValue&op=delmember`" title=`"Remove from Group`">Remove</a>"
                $content += "<tr><td><a href=`"$xlink`" title=`"Details`">$uname</a></td>"
                $content += "<td>$($member.Title)</td>"
                $content += "<td>$($member.Type)</td>"
                $content += "<td>$($member.DN)</td>"
                $content += "<td style=`"width:80px;text-align:center;`">$rmvlink</td>"
                $content += "</tr>"
                $rowcount++
            }
            $content += "<tr><td colspan=5 class=lastrow>$(Write-RowCount -ItemName 'member' -RowCount $rowcount)</td></tr>"
            $content += "</table><br/>"
            $content += "<form name=`"form11`" id=`"form11`" method=`"POST`" action=`"admod.ps1`">"
            $content += "<input type=hidden name=`"groupid`" id=`"groupid`" value=`"$SearchValue`" />"
            $content += "<input type=hidden name=`"op`" id=`"op`" value=`"addmember`" />"
            $content += "<input type=submit name=`"ok`" id=`"ok`" value=`"Add Members`" class=`"button1`" title=`"Add Members`"/>"
            $content += "</form>"
        }
        catch {
            $content += $Error[0].Exception.Message
        }
        break;
    }
    'Notes' {
        $content += Show-NoteAttachments -ObjectType "adgroup" -ObjectName $SearchValue -ReturnBaseLink "adgroup.ps1" -ReturnBaseSearchField "name"
        break;
    }
} # switch
$tabset = New-MenuTabSet2 -MenuTabs $tabs -BaseLink "adgroup.ps1"
$content += Write-DetailInfo -PageRef "adgroup.ps1" -Mode $Detailed

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