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

$blockedGroups = @(
'Access Control Assistance Operators',
'Administrators',
'Allowed RODC Password Replication Group',
'Cert Publishers',
'Certificate Service DCOM Access',
'Cloneable Domain Controllers',
'Cryptographic Operators',
'Denied RODC Password Replication Group',
'DHCP Users',
'Distributed COM Users',
'DnsAdmins',
'DnsUpdateProxy',
'Domain Admins',
'Domain Computers',
'Domain Controllers',
'Domain Guests',
'Domain Users',
'Enterprise Admins',
'Enterprise Key Admins',
'Enterprise Read-only Domain Controllers',
'Group Policy Creator Owners',
'Guests',
'IIS_IUSRS',
'Incoming Forest Trust Builders',
'Key Admins',
'Network Configuration Operators',
'Pre-Windows 2000 Compatible Access',
'Protected Users',
'RAS and IAS Servers',
'RDS Endpoint Servers',
'RDS Management Servers',
'RDS Remote Access Servers',
'Read-only Domain Controllers',
'Remote Management Users',
'Replicator',
'Schema Admins',
'Server Operators',
'Storage Replica Administrators',
'System Managed Accounts Group',
'Terminal Server License Servers',
'Users',
'Windows Authorization Access Group'
)

if ([string]::IsNullOrEmpty($username) -and [string]::IsNullOrEmpty($groupname)) {
    $content = "<table id=table2><tr style=`"height:200px`"><td style=`"text-align:center`">"
    $content += "Missing required parameters: userid -and- groupid</td><tr></table>"
}
else {
    if (![string]::IsNullOrEmpty($username) -and ![string]::IsNullOrEmpty($groupname)) {
        # both input params were provided
        $content = "<table id=table2><tr><td>both</td></tr></table>"
    }
    elseIf (![string]::IsNullOrEmpty($username)) {
        # username provided, prompt for group
        $list = ""
        [array]$groupsAll = Get-ADsGroups | Sort-Object Name | Select -ExpandProperty Name 
        [array]$groupsUsr = Get-ADsUserGroups -UserName $username | Sort-Object Name | Select -ExpandProperty Name 
        [array]$result = $groupsAll | Select-String $($groupsUsr -join "|") -NotMatch
        foreach ($item in $result) {
            if ($item -notin $blockedGroups) {
                $list += "<option value=`"$item`">$item</option>"
            }
        }
        $content = "<h3>$opname`: $username to AD Groups</h3>"
        $content += "<form name=`"form1`" id=`"form1`" method=`"POST`" action=`"admod2.ps1`">"
        $content += "<input type=`"hidden`" name=`"userid`" id=`"userid`" value=`"$username`" />"
        $content += "<input type=`"hidden`" name=`"op`" id=`"op`" value=`"$opname`" />"
        $content += "<table id=table2><tr><td>"
        $content += "<select name=groupid id=groupid size=10 style=`"width:400px;padding:5px;font-size:10pt;`">"
        $content += $list
        $content += "</select><br/>"
        $content += "<input type=button name=cancel id=cancel value=`"Cancel`" class=button1 onClick=`"javascript`:window.history.back(1);`" /> "
        $content += "<input type=submit name=ok id=ok value=`"Add to Selected`" class=button1 />"
        $content += "</td></tr></table></form>"
    }
    else {
        # groupname provided, prompt for user
        $content = "<h3>$opname $username to AD Group</h3>"
        $content += "<table id=table2><tr><td>"
        $content += "... form data ..."
        $content += "</td></tr></table>"
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