try {
    $noexp = Get-ADsUserPwdNoExpire
    $content = "<table id=table1>"
    $content += "<tr><th>Name</th><th>SAM Account</th><th>LDAP Path</th></tr>"
    $rowcount = 0
    foreach ($user in $noexp) {
        $name = $user.Name
        $dn   = $user.DistinguishedName
        $udata = [adsi]"LDAP://$dn"
        $usam  = [string] $udata.sAMaccountName
        $ulink = "<a href=`"aduser.ps1?f=username&v=$usam&x=equals`" title=`"Details`">$usam</a>"
        $content += "<tr><td>$name</td><td>$ulink</td><td>$dn</td></tr>"
        $rowcount++
    }
    $content += "<tr><td class=lastrow colspan=3>$rowcount accounts</td></tr>"
    $content += "</table>"
}
catch {
    $content += "<table id=table2><tr><td style=`"height:150px;text-align:center`">"
    $content += "$($Error[0].Exception.Message)</td></tr></table>"
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