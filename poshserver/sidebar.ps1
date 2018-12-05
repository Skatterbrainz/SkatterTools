@"
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" type="text/css" href="$STTheme"/>
<script src="accordion.js"></script>
</head>
<body style="margin: 0;background:#303030;">

<button class="statbutton" onClick="window.top.location.href='./index.htm'" title="Dashboard" target="main">Dashboard</button>

<button class="accordion" title="Assets">Assets</button>
<div class="panel">
	<ul class="ulmenu">
		<li class="limenu"><a href="cmusers.ps1" title="Users" target="main">Users</a></li>
		<li class="limenu"><a href="cmdevices.ps1" title="Devices" target="main">Devices</a></li>
		<li class="limenu"><a href="cmucollections.ps1" title="User Collections" target="main">User Collections</a></li>
		<li class="limenu"><a href="cmdcollections.ps1" title="Device Collections" target="main">Device Collections</a></li>
        <li class="limenu"><a href="formtest.ps1" title="Search" target="main">Search</a></li>
	</ul>
</div>

<button class="accordion" title="Software">Software</button>
<div class="panel">
	<ul class="ulmenu">
		<li class="limenu"><a href="cmapps.htm" target="main" title="Applications">Applications</a></li>
		<li class="limenu"><a href="cmpackages.htm" target="main" title="Packages">Packages</a></li>
		<li class="limenu">Software Updates</li>
		<li class="limenu">Operating Systems</li>
		<li class="limenu">Boot Images</li>
		<li class="limenu">Task Sequences</li>
		<li class="limenu">Scripts</li>
		<li class="limenu"><a href="https://chocolatey.org/packages" target="main">Choco Packages</a></li>
	</ul>
</div>

<button class="accordion" title="Monitoring">Monitoring</button>
<div class="panel">
	<ul class="ulmenu">
		<li class="limenu">Queries</li>
		<li class="limenu">Reporting</li>
		<li class="limenu">System Status</li>
		<li class="limenu">Component Status</li>
		<li class="limenu">SQL Status</li>
	</ul>
</div>

<button class="accordion" title="Administrators">Administration</button>
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

<button class="accordion" title="Active Directory">Active Directory</button>
<div class="panel">
	<ul class="ulmenu">
		<li class="limenu">Forests and Domains</li>
		<li class="limenu">Sites</li>
		<li class="limenu">Site Links</li>
		<li class="limenu">Domain Controllers</li>
		<li class="limenu"><a href="adcomputers.ps1" target="main" title="AD Computers">Computers</a></li>
		<li class="limenu"><a href="adusers.ps1" target="main" title="AD Users">Users</a></li>
		<li class="limenu"><a href="adgroups.ps1" target="main" title="AD Groups">Groups</a></li>
		<li class="limenu">Printers</li>
		<li class="limenu">Shares</li>
		<li class="limenu">OU Browser</li>
		<li class="limenu">Group Policy</li>
        <li class="limenu"><a href="adreps.ps1" target="main">AD Reports</a></li>
	</ul>
</div>

<button class="accordion" title="Support">Support</button>
<div class="panel">
	<ul class="ulmenu">
		<li class="limenu">ConfigMgr Docs</li>
		<li class="limenu"><a href="downloads.ps1" target="main" title="Downloads">Downloads</a></li>
		<li class="limenu"><a href="learning.ps1" target="main" title="Learning">Learning</a></li>
		<li class="limenu">CMWT Help</li>
		<li class="limenu">CMWT Feedback</li>
		<li class="limenu">Donate!</li>
		<li class="limenu"><a href="https://github.com/Skatterbrainz/SkatterTools/blob/master/README.md" target="main" title="Check for Update">Check for Update</a></li>
		<li class="limenu"><a href="about.ps1" target="main" title="About">About</a></li>
	</ul>
</div>

<script>
SetMenu();
</script>

</body>
</html>
"@