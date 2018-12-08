$Comment    = $PostPost.comment
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
$xxx = "objecttype: $ObjectType<br/>objectname: $ObjectName<br/>keyname: $keyname"
$TargetLink = "$ObjectType.ps1`?f=$keyname&v=$ObjectName&tab=notes"
$xxx += "<br/>target: $TargetLink"
$xxx += "<br/>comment: $Comment"

if ([string]::IsNullOrEmpty($Comment)) {
    $content = "<table id=table2><tr><td style=height:100px>No text was entered for note attachment</td></tr></table>"
}
else {
    New-NoteAttachment -Comment -ObjectType -ObjectID
    $content = "<table id=table2><tr><td style=height:100px>
        <h2>Adding Note...</h2>
        <br/>
        <p style=`"text-alignment:center`">
        <img src=`"graphics/301.gif`" alt=`"`" border=0 /></p>
        </td></tr></table>"
}
$content = "<table id=table2><tr><td>$xxx</td></tr></table>"

@"
<html>
<head>
<!--<meta http-equiv=`"refresh`" content=`"2;url=$TargetLink`" />-->
<link rel=`"stylesheet`" type=`"text/css`" href=`"$STTheme`"/>
</head>

<body>

<h1>$PageCaption</h1>

$content

</body>
</html>
"@