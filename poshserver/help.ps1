Get-SkParams | Out-Null

$PageTitle   = "Help"
$content  = ""
$menulist = ""
$tabset   = ""
$pagelink = Split-Path -Leaf $MyInvocation.MyCommand.Definition

$content += "<table id=table2><tr><td style=`"height:150px;text-align:center`">"
$content += "Be patient. I'm still working on it. :)</td></tr></table>"


$content = @"
<table id=table2>
    <tr>
        <td>
            <h2>You Sure do Need Help!</h2>

            <p>If you clicked on a link to this page, you're in trouble.  But don't worry, this page
            should keep you sufficiently confused and annoyed.</p>
            
            <p>So, what the ____ exactly is this $Global:AppName crap anyway?</p>

            <p>It began with a stupid idea and turned into a dumb project.  Okay, that's not entirely true.
            But... It actually began from the pieces left from a dozen past web app projects involving ASP, 
            PHP, Active Directory, SQL Server, Configuration Manager and so on.  
            The issue has always been "but i don't want to stand up another server to manage
            another web app".  So I found PoSH Server, a micro-web server that runs PowerShell for the 
            content engine.</p>

            <p>That's right! Everything in this site is built from the following:
            <ul>
                <li>PowerShell</li>
                <li>HTML, CSS and some crappy graphics</li>
                <li>Coffee.  Lots and lots of coffee</li>
                <li>More PowerShell.  You can never have enough PowerShell</li>
            </ul>
            That's it.</p>

            <p>Version: $Global:SkToolsVersion</p>
        </td>
    </tr>
    <tr>
        <td>
            <h2>Setup and Configuration</h2>

            <p>Note that this is only going to describe how this works as of now.  This may change in a future
            release, so keep that in mind.</p>

            <p>Once you've downloaded this garbage and extracted it into a folder somewhere, you should 
            find a file in that folder named "config.txt".  Open that in your favorite text editor. 
            Modify the settings to suit your needs.  After saving the changes, restart the PoSH Server instance.</p>

            <h2>Options and Variables</h2>

            <ul>
                <li>AppName = The name of this app, which is currently $Global:AppName</li>
                <li>STTheme = CSS stylesheet theme to apply. (stdark.css or stlight.css)</li>
                <li>CMEnabled = Enable Configuration Manager features (true or false)</li>
                <li>ADenabled = Enable Active Directory features (true or false)</li>
                <li>ADGroupManage = Enable features to modify AD group memberships</li>
                <li>CMCollectionManage = Enable features to modify Collection memberships</li>
                <li>CmDBHost = Configuration Manager SQL Server hostname</li>
                <li>CmSMSProvider = Configuration Manager SMS Provider hostname</li>
                <li>CmSiteCode = Configuration Manager site code</li>
                <li>DefaultGroupsTab = Default menubar index tab for Groups</li>
                <li>DefaultUsersTab = Default menubar index tab for Users</li>
                <li>DefaultComputersTab = Default menubar index tab for Computers/Devices</li>
            </ul>

            <p>NOTE: Always keep a copy of your config.txt file somewhere, in case you download a new
            update and it whacks your existing copy.  <a href="https://www.merriam-webster.com/dictionary/whack">Whacks</a> 
            is a real word. I looked it up. Don't confuse "wax" with "whacks".  You can "wax on" and "wax off", but if you 
            get caught doing a "whacks off" you might end up in jail.</p>

            <p>If you modify config.txt, you will need to stop and start the PoSH Server process again.</p>

            <p>Stay tuned.  More to come!</p>

        </td>
    </tr>
</table>
"@

Show-SkPage