$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "exact"
$SortField   = Get-PageParam -TagName 's' -Default ""
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$TabSelected = Get-PageParam -TagName 'tab' -Default 'general'

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
            $user = Get-ADsUsers | Where-Object {$_.UserName -eq $SearchValue}
            $columns = $user.psobject.properties | Select-Object -ExpandProperty Name
            $content = '<table id=table2><tr>'
            foreach ($col in $columns) {
                $fv = $($user."$col")
                $fvx = '<a href="adusers.ps1?f='+$col+'&v='+$fv+'" title="Details">'+$fv+'</a>'
                $content += '<tr>'
                $content += '<td style="width:200px;">'+$col+'</td>'
                $content += '<td>'+$fvx+'</td>'
                $content += '</tr>'
            }
            $content += '</tr></table>'    
        }
        catch {
            $content = "Error: $($Error[0].Exception.Message)"
        }
        break
    }
    'Groups' {
        $content = "<p>Group Memberships</p>"
        break
    }
    'Notes' {
        $notes = Get-NoteAttachments -ObjectType "aduser" -ObjectID $SearchValue
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
        break
    }
}

if ($SkNotesEnable -eq 'true') {
    $tabs = @('General','Groups','Notes')
}
else {
    $tabs = @('General','Groups')
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