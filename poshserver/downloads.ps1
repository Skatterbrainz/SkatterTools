$PageTitle   = "Tools and Downloads"
$content  = ""
$menulist = ""
$tabset   = ""
$pagelink = Split-Path -Leaf $MyInvocation.MyCommand.Definition

$content = @"
<table id=table2>
	<tr>
		<td style="width:50%; vertical-align:top">
			<h2>ConfigMgr Resources</h2>

			<ul class="ulmenu">
				<li class="limain"><a href="http://www.scconfigmgr.com/driver-automation-tool/" target="_new">Driver Automation Tool - Maurice Daly</a></li>
                <li class="limain"><a href="http://www.scconfigmgr.com/configmgr-osd-frontend/" target="_new">ConfigMgr OSD FrontEnd - Nickolaj Andersen</a></li>
                <li class="limain"><a href="http://www.scconfigmgr.com/configmgrprerequisitestool/" target="_new">ConfigMgr Pre-requisites Tool - Nickolaj Andersen</a></li>
				<li class="limain"><a href="https://gallery.technet.microsoft.com/ConfigMgr-Client-Health-ccd00bd7" target="_new">Client Health Script - Anders Rodland</a></li>
                <li class="limain"><a href="https://home.configmgrftw.com/uiplusplus/" target="_new">UI++ - Jason Sandys</a></li>
                <li class="limain"><a href="https://home.configmgrftw.com/configmgr-client-startup-script/" target="_new">Client Startup Script - Jason Sandys</a></li>
			</ul>

		</td>
		<td style="vertical-align:top">
			<h2>Software Updates</h2>

			<ul class="ulmenu">
				<li class="limain"><a href="https://damgoodadmin.com/2018/10/17/latest-software-maintenance-script-making-wsus-suck-slightly-less/" target="_new">Dam Good Admin: WSUS Configuration Script</a></li>
				<li class="limain"><a href="http://www.scconfigmgr.com/2016/05/10/create-software-update-group-tool-console-extension-for-configmgr/" target="_new">Software Updates ConfigMgr Console Extension - Nickolaj Andersen</a></li>
			</ul>
		</td>
	</tr>
	<tr>
		<td style="width:50%; vertical-align:top">
			<h2>Windows Deployment</h2>

			<ul class="ulmenu">
				<li class="limain"><a href="https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install" target="_new">Windows ADK</a></li>
				<li class="limain"><a href="https://docs.microsoft.com/en-us/sccm/mdt/" target="_new">Microsoft Deployment Toolkit (MDT)</a></li>
				<li class="limain"><a href="https://www.osdeploy.com/" target="_new">OSBuilder - David Segura</a></li>
                <li class="limain"><a href="https://home.configmgrftw.com/task-sequence-one-liners/" target="_new">Task Sequence One-Liners - Jason Sandys</a></li>
                <li class="limain"><a href="https://home.configmgrftw.com/scripts-ftw/" target="_new">Scripts FTW! - Jason Sandys</a></li>
			</ul>
        </td>
        <td style="vertical-align:top">
			<h2>SQL Server</h2>

			<ul class="ulmenu">
				<li class="limain"><a href="https://ola.hallengren.com/" target="_blank">Ola Hallengren: DB Tools</a></li>
				<li class="limain"><a href="https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017" target="_new">SQL Server Management Studio</a></li>
			</ul>

        </td>
    </tr>
    <tr>
        <td style="vertical-align:top">
			<h2>Group Policy</h2>

            <ul class="ulmenu">
                <li class="limain"><a href="https://www.microsoft.com/en-us/download/details.aspx?id=57576" target="_new">ADMX for Windows 10 1809</a></li>
                <li class="limain"><a href="https://www.microsoft.com/en-us/download/details.aspx?id=56880" target="_new">ADMX for Windows 10 1803</a></li>
                <li class="limain"><a href="https://www.microsoft.com/en-us/download/details.aspx?id=56121" target="_new">ADMX for Windows 10 1709</a></li>
                <li class="limain"><a href="https://www.microsoft.com/en-us/download/details.aspx?id=25250" target="_new">Group Policy Reference for Windows and Windows Server</a></li>
                <li class="limain"><a href="https://www.microsoft.com/en-us/download/details.aspx?id=49030" target="_new">ADMX for Office 365 ProPlus, Office 2016, 2019</a></li>
                <li class="limain"><a href="https://support.microsoft.com/en-in/kb/3087759" target="_new">How to: Create and Manage a Group Policy Central Store</a></li>
            </ul>

        </td>
        <td style="vertical-align:top">
			<h2>Other</h2>

			<ul class="ulmenu">
				<li class="limain"><a href="https://code.visualstudio.com/" target="_new" title="Visual Studio Code">Visual Studio Code</a></li>
				<li class="limain"><a href="https://chocolatey.org" target="main" title="Chocolatey">Chocolatey</a></li>
			</ul>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            Want more links added?  Tweet them to me! <a href="https://twitter.com/skatterbrainzz" target="_new">@skatterbrainzz</a>
        </td>
    </tr>
</table>
"@

Show-SkPage