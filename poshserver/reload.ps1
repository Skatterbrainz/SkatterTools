$PageCaption = "Reload SkatterTools"
$content = "<div align=`"center`"><table id=table2 style=`"width:75%`"><tr><td style=`"text-align:center`">Please wait, this is going to be really cool, I promise!...</td></tr>"
$content += "<tr><td style=`"height:250px;text-align:center;background-color:#fff`"><img src=`"graphics/301.gif`" border=0 /></td></tr></table></div>"
$TargetLink = "index.htm"

$Global:SkToolsLoaded = 0
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