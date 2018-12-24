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
        <li class="limenu"><a href="addomain.ps1" target="main" title="AD Domain">Domain</a></li>
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
		<li class="limenu"><a href="cmpackages.ps1" target="main" title="Software Deployments">Software - All</a></li>
		<li class="limenu"><a href="cmpackages.ps1?f=packagetype&v=8&x=equals" target="main" title="Software Applications">Applications</a></li>
		<li class="limenu"><a href="cmpackages.ps1?f=packagetype&v=0&x=equals" target="main" title="Software Packages">Packages</a></li>
		<li class="limenu"><a href="cmpackages.ps1?f=packagetype&v=257&x=equals" target="main" title="Operating System Images">OS Images</a></li>
		<li class="limenu"><a href="cmpackages.ps1?f=packagetype&v=259&x=equals" target="main" title="Operating System Upgrade Packages">OS Upgrades</a></li>
		<li class="limenu"><a href="cmpackages.ps1?f=packagetype&v=258&x=equals" target="main" title="Boot Images">Boot Images</a></li>
		<li class="limenu"><a href="cmpackages.ps1?f=packagetype&v=5&x=equals" target="main" title="Software Updates">Software Updates</a></li>
		<li class="limenu"><a href="cmpackages.ps1?f=packagetype&v=4&x=equals" target="main" title="Task Sequences">Task Sequences</a></li>
        <li class="limenu"><a href="cmproducts.ps1" target="main" title="Software Products Inventory">Software Inventory</a></li>
        <li class="limenu"><a href="cmfiles.ps1" target="main" title="Software Files">Software Files</a></li>
		<li class="limenu"><a href="cmscripts.ps1" target="main" title="Scripts">Scripts</a></li>
	</ul>
</div>

<button class="accordion" title="Configuration Manager Monitoring">CM Monitoring</button>
<div class="panel">
	<ul class="ulmenu">
		<li class="limenu"><a href="cmqueries.ps1" target="main" title="Queries">Queries</a></li>
		<li class="limenu">Reporting</li>
		<li class="limenu"><a href="cmsitestatus.ps1" target="main" title="Site Status">Site Status</a></li>
		<li class="limenu"><a href="cmcompstat.ps1" target="main" title="Component Status">Site Components</a></li>
		<li class="limenu">SQL Status</li>
	</ul>
</div>

<button class="accordion" title="Configuration Manager Site">CM Site</button>
<div class="panel">
	<ul class="ulmenu">
		<li class="limenu">Hierarchy</li>
		<li class="limenu"><a href="cmdiscs.ps1" target="main" title="Discovery Methods">Discovery Methods</a></li>
        <li class="limenu"><a href="cmforestdisc.ps1" target="main" title="AD Forest Discovery and Publishing">AD Forest</a></li>
		<li class="limenu"><a href="cmbgroups.ps1" target="main" title="Boundary Groups">Boundary Groups</a></li>
		<li class="limenu">Site Systems</li>
		<li class="limenu">Site Components</li>
        <li class="limenu"><a href="cmsumtasks.ps1" target="main" title="Summary Tasks">Summary Tasks</a></li>
        <li class="limenu"><a href="cmcerts.ps1" target="main" title="Certificates">Certificates</a></li>
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