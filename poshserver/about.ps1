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
    <tr><td>Install Path</td><td>$SkWebPath</td></tr>
    <tr><td>SMS Provider</td><td>$CmSMSProvider</td></tr>
    <tr><td>SkDBHost</td><td>$SkNotesDBHost</td></tr>
    <tr><td>SkDBName</td><td>$SkDBDatabase</td></tr>
    <tr><td>Web Theme</td><td>$STTheme</td></tr>
    <tr><td>Notes Enabled</td><td>$SkNotesEnable</td></tr>
    <tr><td>Notes Path</td><td>$SkNotesPath</td></tr>
    <tr><td>Last Load</td><td>$LastLoadTime</td></tr>
</table>
</body>
</html>
"@