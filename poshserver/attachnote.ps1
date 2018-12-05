$ObjectType = $PoshPost.otype
$ObjectID   = $PoshPost.oid
$ReturnLink = $PostPost.rlink

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>
<body>

<h1>Attach a Note</h1>

<form name='form1' id='form1 method='post' action='attachnote2.ps1'>
<input type='hidden' name='otype' id='otype' value='$ObjectType' />
<input type='hidden' name='oid' id='oid' value='$ObjectID' />
<input type='hidden' name='rlink' id='rlink' value='$ReturnLink' />
<table id=table2>
    <tr>
        <td>
            <textarea name='note' id='note' rows='6' cols='80'></textarea>
        </td>
    </tr>
    <tr>
        <td>
            <input type='button' name='cancel' id='cancel' class='button1' value='Cancel' title='Cancel' />
            <input type='submit' name='search' id='search' class='button1' value='Search' title='Search' />
        </td>
    </tr>
</table>
</form>

</body>
</html>
"@