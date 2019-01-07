$img = ""
switch ($Global:AppName) {
    'DeathFace' { $img = "<img src=`"graphics/dflogo.png`" style=`"height:80px;vertical-align:middle`" border=`"0`" />"; break; }
    'SkyDouche' { $img = "<img src=`"graphics/sdlogo.png`" style=`"height:80px;vertical-align:middle`" border=`"0`" />"; break; }
}
@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>
<body class="bannerbody">
<span onClick="window.top.location.href='./index.htm'" style=`"vertical-align:absmiddle`">$img $($Global:AppName)</span>
</body>
</html>
"@