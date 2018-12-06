$STPageTitle   = "About SkatterTools"
$STPageCaption = "About SkatterTools"

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$STPageCaption</h1>

<table id=table2>
	<tr><td style='width:200px'>Version</td><td>$STVersion</td></tr>
    <tr><td>ConfigMgr DB Host</td><td>$CmDBHost</td></tr>
    <tr><td>ConfigMgr Site</td><td>$CmSiteCode</td></tr>
	<tr><td>Current User</td><td>$PoshUserName</td></tr>
    <tr><td>Install Path</td><td>$SkWebPath
    <tr><td>SMS Provider</td><td>$CmSMSProvider
    <tr><td>SkDBHost</td><td>$SkDBHost
    <tr><td>SkDBName</td><td>$SkDBDatabase
    <tr><td>Web Theme</td><td>$STTheme
    <tr><td>Notes Enabled</td><td>$SkNotesEnable
    <tr><td>Notes Path</td><td>$SkNotesPath
</table>
</body>
</html>
"@