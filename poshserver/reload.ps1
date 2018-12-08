$PageCaption = "Reload SkatterTools"
$content = "<table id=table2><tr><td style=`"text-align:center`">Please wait, this is going to be really cool, I promise!...</td></tr>"
$content += "<tr><td style=`"height:150px;text-align:center;background-color:#fff`"><img src=`"graphics/301.gif`" border=0 /></td></tr></table>"
$TargetLink = "index.htm"

. $HomeDirectory\sktools.ps1

@"
<html>
<head>
<meta http-equiv=`"refresh`" content=`"2;url=$TargetLink`" />
<link rel=`"stylesheet`" type=`"text/css`" href=`"$STTheme`"/>
</head>

<body>

<h1>$PageCaption</h1>

$content

</body>
</html>
"@