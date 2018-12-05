$PageTitle   = "About SkatterTools"
$PageCaption = "About SkatterTools"

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

<table id=table1>
	<tr>
		<td>Version</td>
		<td>$STVersion</td>
	</tr>
    <tr>
        <td>ConfigMgr DB Host</td>
        <td>$CmDBHost</td>
    </tr>
    <tr>
        <td>ConfigMgr Site</td>
        <td>$CmSiteCode</td>
    </tr>
	<tr>
		<td>Current User</td>
		<td>$PoshUserName</td>
	</tr>
</table>
</body>
</html>
"@
