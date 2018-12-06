$ObjectType = $PoshPost.otype
$ObjectID   = $PoshPost.oid
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
$ReturnLink = "$ObjectType.ps1?f=$keyname&v=$ObjectID&tab=notes"

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>
<body onLoad='document.form1.note.focus();'>

<h1>Attach a Note</h1>

<form name='form1' id='form1 method='post' action='attachnote2.ps1'>
<input type='hidden' name='otype' id='otype' value='$ObjectType' />
<input type='hidden' name='keyname' id='keyname' value='$keyname' />
<input type='hidden' name='oid' id='oid' value='$ObjectID' />
<table id=table2>
    <tr>
        <td>
            Type: $ObjectType | Name: $ObjectID | Link: $ReturnLink
        </td>
    </tr>
    <tr>
        <td>
            <textarea name='note' id='note' rows='6' cols='100'></textarea>
        </td>
    </tr>
    <tr>
        <td>
            <input type='button' name='cancel' id='cancel' class='button1' value='Cancel' title='Cancel' onClick=`"document.location.href='$ReturnLink'`" />
            <input type='submit' name='search' id='search' class='button1' value='Search' title='Search' />
        </td>
    </tr>
</table>
</form>

</body>
</html>
"@