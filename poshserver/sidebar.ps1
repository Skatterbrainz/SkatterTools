$content = ""

if ($ADEnabled -ne 'false') {
    $content += @"
<button class="accordion" title="Active Directory">Active Directory</button>
<div class="panel">
	<ul class="ulmenu">
		<li class="limenu"><a href="adusers.ps1" target="main" title="AD Users">Users</a></li>
		<li class="limenu"><a href="adgroups.ps1" target="main" title="AD Groups">Groups</a></li>
		<li class="limenu"><a href="adcomputers.ps1" target="main" title="AD Computers">Computers</a></li>
		<li class="limenu"><a href="adforest.ps1" target="main" title="AD Forest">Forest</a></li>
		<li class="limenu"><a href="adsites.ps1" target="main" title="AD Sites">Sites</a></li>
		<li class="limenu"><a href="adbrowser.ps1" target="main" title="AD OU Explorer">OU Explorer</a></li>
        <li class="limenu"><a href="adreps.ps1" target="main">AD Reports</a></li>
	</ul>
</div>
"@
}

if ($CmEnabled -ne 'false') {
    $content += @"
<button class="accordion" title="Configuration Manager Assets">CM Assets</button>
<div class="panel">
	<ul class="ulmenu">
		<li class="limenu"><a href="cmusers.ps1" title="Users" target="main">Users</a></li>
		<li class="limenu"><a href="cmdevices.ps1" title="Devices" target="main">Devices</a></li>
		<li class="limenu"><a href="cmcollections.ps1?t=1" title="User Collections" target="main">User Collections</a></li>
		<li class="limenu"><a href="cmcollections.ps1?t=2" title="Device Collections" target="main">Device Collections</a></li>
	</ul>
</div>

<button class="accordion" title="Configuration Manager Software">CM Software</button>
<div class="panel">
	<ul class="ulmenu">
		<li class="limenu"><a href="cmapps.ps1" target="main" title="Applications">Applications</a></li>
		<li class="limenu"><a href="cmpackages.ps1" target="main" title="Packages">Packages</a></li>
        <li class="limenu"><a href="cmproducts.ps1" target="main" title="Installed Software">Installed Software</a></li>
        <li class="limenu"><a href="cmfiles.ps1" target="main" title="Software Files">Software Files</a></li>
		<li class="limenu">Software Updates</li>
		<li class="limenu">Operating Systems</li>
		<li class="limenu">Boot Images</li>
		<li class="limenu">Task Sequences</li>
		<li class="limenu">Scripts</li>
	</ul>
</div>

<button class="accordion" title="Configuration Manager Monitoring">CM Monitoring</button>
<div class="panel">
	<ul class="ulmenu">
		<li class="limenu">Queries</li>
		<li class="limenu">Reporting</li>
		<li class="limenu">System Status</li>
		<li class="limenu">Component Status</li>
		<li class="limenu">SQL Status</li>
	</ul>
</div>

<button class="accordion" title="Configuration Manager Site">CM Site</button>
<div class="panel">
	<ul class="ulmenu">
		<li class="limenu">Hierarchy</li>
		<li class="limenu">Discovery Methods</li>
		<li class="limenu">Boundaries</li>
		<li class="limenu">Boundary Groups</li>
		<li class="limenu">Site Systems</li>
		<li class="limenu">Site Components</li>
		<li class="limenu">Client Settings</li>
		<li class="limenu">Maintenance Tasks</li>
		<li class="limenu">Accounts</li>
		<li class="limenu">Roles</li>
	</ul>
</div>
"@
}

@"
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" type="text/css" href="$STTheme"/>
<script src="accordion.js"></script>
</head>
<body style="margin: 0;">

<form action="search.ps1" method="get">
<button type="submit" class="statbutton" formtarget="main" title="Search">Search</button>
</form>

$content

<button class="accordion" title="Support">Support</button>
<div class="panel">
	<ul class="ulmenu">
		<li class="limenu"><a href="https://docs.microsoft.com/en-us/sccm/" target="_new" title="ConfigMgr Docs">ConfigMgr Docs</a></li>
		<li class="limenu"><a href="downloads.ps1" target="main" title="Downloads">Downloads</a></li>
		<li class="limenu"><a href="learning.ps1" target="main" title="Learning">Learning</a></li>
        <li class="limenu"><a href="acknowledgements.ps1" target="main" title="Acknowledgements">Acknowledgements</a></li>
		<li class="limenu"><a href="help.ps1" target="main" title="SkatterTools Help">SkatterTools Help</a></li>
		<li class="limenu"><a href="https://github.com/Skatterbrainz/SkatterTools/blob/master/README.md" target="_new" title="Check for Update">Check for Update</a></li>
		<li class="limenu"><a href="about.ps1" target="main" title="About">About</a></li>
	</ul>
</div>

<script>
SetMenu();
</script>

</body>
</html>
"@