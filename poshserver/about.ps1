$PageTitle = "About $Global:AppName"

$tabset = ""
$content = "<table style='width:100%;border:none;'>
    <tr>
        <td style='width:50%;vertical-align:top'>
            <table id=table2>
	            <tr><td style='width:200px'>Version</td><td>$SkToolsVersion</td></tr>
                <tr><td>CM Tools Enabled</td><td>$CMEnabled</td></tr>
                <tr><td>AD Tools Enabled</td><td>$ADenabled</td></tr>
                <tr><td>ConfigMgr DB Host</td><td>$CmDBHost</td></tr>
                <tr><td>ConfigMgr Site</td><td>$CmSiteCode</td></tr>
	            <tr><td>Current User</td><td>$PoshUserName</td></tr>
                <tr><td>Install Path</td><td>$HomeDirectory</td></tr>
                <tr><td>SMS Provider</td><td>$CmSMSProvider</td></tr>
            </table>
        </td>
        <td style='vertical-align:top;'>
            <table id=table2>
                <tr><td>CM Collection Manage</td><td>$CmCollectionManage</td></tr>
                <tr><td>AD Group Manage</td><td>$ADGroupManage</td></tr>
                <tr><td>CustomConfig</td><td>$CustomConfig</td></tr>
                <tr><td>Web Theme</td><td>$STTheme</td></tr>
                <tr><td>Notes Enabled</td><td>$SkNotesEnable</td></tr>
                <tr><td>Notes Path</td><td>$SkNotesPath</td></tr>
                <tr><td>Last Load</td><td>$LastLoadTime</td></tr>
            </table>
        </td>
    </tr>
</table>"

Show-SkPage
