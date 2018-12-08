$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'Name'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""

$PageTitle   = "Help"
$PageCaption = "Help"
$content     = ""
$tabset      = ""

# add code here

$content += "<table id=table2><tr><td style=`"height:150px;text-align:center`">"
$content += "Be patient. I'm still working on it. :)</td></tr></table>"

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

<table id=table2>
    <tr>
        <td>
            <h2>Welcome!</h2>

            <p>So, what the ____ exactly is this SkatterTools crap anyway?</p>

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

            <p>Last updated: 2018.12.08.01:59</p>
        </td>
    </tr>
    <tr>
        <td>
            <h2>Setup and Configuration</h2>

            <p>Note that this is only going to describe how this works as of now.  This may change in a future
            release, so keep that in mind.</p>

            <p>Once you've downloaded this garbage and extracted it into a folder somewhere, you should 
            find a file in that folder named "config.ps1".  Open that in your favorite PowerShell editor. Scroll down 
            until you see a section (near the top, actually) for SkatterTools.  Modify the variables to suit your
            needs and preferences.</p>

            <h2>Options and Variables</h2>

            <ul>
                <li>`$SkWebPath     = "e:\web"</li>
                <li>`$STTheme       = "stdark.css"</li>
                <li>`$CmDBHost      = "cm01.contoso.local"</li>
                <li>`$CmSMSProvider = "cm01.contoso.local"</li>
                <li>`$CmSiteCode    = "P02"</li>
                <li>`$SkNotesEnable = "false"</li>
                <li>`$SkNotesDBHost = ""</li>
                <li>`$SkDBDatabase  = ""</li>
                <li>`$SkNotesPath   = "notes\notes.xml"</li>
                <li>`$DefaultGroupsTab    = "all"</li>
                <li>`$DefaultUsersTab     = "all"</li>
                <li>`$DefaultComputersTab = "all"</li>
            </ul>

            <p>NOTE: Always keep a copy of your config.ps1 file somewhere, in case you download a new
            update and it whacks your existing copy.  <a href="https://www.merriam-webster.com/dictionary/whack">Whacks</a> 
            is a real word. I looked it up. Don't confuse "wax" with "whacks".  You can "wax on" and "wax off", but if you 
            get caught doing a "whacks off" you might end up in jail.</p>

            <p>Stay tuned.  More to come!</p>

        </td>
    </tr>
</table>

</body>
</html>
"@