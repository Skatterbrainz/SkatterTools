$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default ""
$SortField   = Get-PageParam -TagName 's' -Default ""
$SortOrder   = Get-PageParam -TagName 'so' -Default ""
$TabSelected = Get-PageParam -TagName 'tab' -Default ""
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Extension1  = Get-PageParam -TagName 'x1' -Default ""
$CustomFlag  = Get-PageParam -TagName 'p' -Default ""
$IsFiltered  = $False
$content = ""
$tabset  = ""

switch ($CustomFlag) {
    "0" {
        $PageTitle   = "AD Reports: Non-Expiring Password"
        $PageCaption = "AD Reports: Non-Expiring Password"
        try {
            $users = Get-ADsUserPwdNoExpire
            $content = "<table id=table1>"
            $content += "<tr><th>UserName</th><th>Name</th><th>LDAP Path</th></tr>"
            $rowcount = 0
            foreach ($user in $users) {
                $name  = $user.Name
                $dn    = $user.DistinguishedName
                $udata = [adsi]"LDAP://$dn"
                $usam  = [string] $udata.sAMaccountName
                $ulink = "<a href=`"aduser.ps1?f=username&v=$usam&x=equals`" title=`"Details`">$usam</a>"
                $content += "<tr><td>$ulink</td><td>$name</td><td>$dn</td></tr>"
                $rowcount++
            }
            $content += "<tr><td class=lastrow colspan=3>$rowcount accounts</td></tr>"
            $content += "</table>"
        }
        catch {
            $content += "<table id=table2><tr><td style=`"height:150px;text-align:center`">"
            $content += "$($Error[0].Exception.Message)</td></tr></table>"
        }
        break;
    }
    "1" {
        $PageTitle   = "AD Reports: Password Expires Soon"
        $PageCaption = "AD Reports: Password Expires Soon"
        try {
            $users = Get-ADsUserPwdExpirations | ? {$_.Expires -lt 14} | ? {$_.UserName -ne 'krbtgt'}
            $content = "<table id=table1>"
            $content += "<tr><th>UserName</th><th>Pwd Set</th><th>Days Left</th></tr>"
            $rowcount = 0
            foreach ($user in $users) {
                $name  = $user.UserName
                $pwdset = $user.LastPwdSet
                $pwdexp = $user.Expires
                $ulink = "<a href=`"aduser.ps1?f=username&v=$name&x=equals`" title=`"Details`">$usam</a>"
                $content += "<tr><td>$ulink</td><td>$pwdset</td><td>$pwdexp</td></tr>"
                $rowcount++
            }
            if ($rowcount -eq 0) {
                $content += "<tr><td colspan=3>No user accounts were found that are expiring within 14 days</td></tr>"
            }
            $content += "<tr><td class=lastrow colspan=3>$rowcount accounts</td></tr>"
            $content += "</table>"
        }
        catch {
            $content += "<table id=table2><tr><td style=`"height:150px;text-align:center`">"
            $content += "$($Error[0].Exception.Message)</td></tr></table>"
        }
        break;
    }
}



@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

$content

</body>
</html>
"@