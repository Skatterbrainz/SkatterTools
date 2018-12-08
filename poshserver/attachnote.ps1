$ObjectType = $PoshPost.otype
$ObjectName = $PoshPost.oid

switch($ObjectType) {
    'aduser' {
        $keyname = 'username'
        break
    }
    'adgroup' {
        $keyname = 'name'
        break
    }
    'adcomputer' {
        $keyname = 'name'
        break
    }
}
$ReturnLink = "$ObjectType.ps1?f=$keyname&v=$ObjectName&tab=notes"

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>
<body onLoad='document.form1.note.focus();'>

<h1>Attach a Note</h1>

<form name=`"form1`" id=`"form1`" method=`"post`" action=`"attachnote2.ps1`">
<input type=`"hidden`" name=`"otype`" id=`"otype`" value=`"$ObjectType`" />
<input type=`"hidden`" name=`"keyname`" id=`"keyname`" value=`"$keyname`" />
<input type=`"hidden`" name=`"oid`" id=`"oid`" value=`"$ObjectName`" />
<table id=table2>
    <tr>
        <td>
            Type: $ObjectType | Name: $ObjectName | Link: $ReturnLink
        </td>
    </tr>
    <tr>
        <td>
            <textarea name=`"comment`" id=`"comment`" rows=`"6`" cols=`"100`"></textarea>
        </td>
    </tr>
    <tr>
        <td>
            <input type=`"button`" name=`"cancel`" id=`"cancel`" class=`"button1`" value=`"Cancel`" title=`"Cancel`" onClick=`"document.location.href=`'$ReturnLink`'`" />
            <input type=`"submit`" name=`"search`" id=`"save`" class=`"button1`" value=`"Save`" title=`"Save`" />
        </td>
    </tr>
</table>
</form>

</body>
</html>
"@