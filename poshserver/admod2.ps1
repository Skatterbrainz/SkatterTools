[string]$username  = $PoshPost.userid
[string]$groupname = $PoshPost.groupid
[string]$opname    = $PoshPost.op

if ([string]::IsNullOrEmpty($username)) {
    [string]$username = $PoshQuery.userid
}
if ([string]::IsNullOrEmpty($groupname)) {
    [string]$groupname = $PoshQuery.groupid
}
if ([string]::IsNullOrEmpty($opname)) {
    [string]$opname = $PoshQuery.op
}

$PageTitle = "AD Account Operation: $opname"
$PageCaption = $PageTitle

if ([string]::IsNullOrEmpty($username) -or [string]::IsNullOrEmpty($groupname)) {
    $content = "<table id=table2><tr style=`"height:200px`"><td style=`"text-align:center`">"
    $content += "Username or Groupname parameters were not provided</td></tr></table>"
}
else {
    try {
        [adsi]$group = "WinNT://contoso/$groupname,group"
        switch($opname) {
            'addmember' {
                [void]$group.Add("WinNT://contoso/$username,user")
                break;
            }
            'delmember' {
                [void]$group.Remove("WinNT://contoso/$username,user")
                break;
            }
        }
        $result = "success"
    }
    catch {
        $result = "failed: $($Error[0].Exception.Message)"
    }
    finally {
        $content = "<table id=table2>"
        $content += "<tr><td>action: $opname</td></tr>"
        $content += "<tr><td>result: $result</td></tr>"
        $content += "<tr><td><a href=`"aduser.ps1?f=username&v=$username&x=equals&tab=groups`">Return to User Account</a></td></tr>"
        $content += "</table>"
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