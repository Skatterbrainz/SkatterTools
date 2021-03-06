$PageTitle   = "AD Reports"
$PageCaption = "AD Reports"

$users = Get-ADsUsers
$comps = Get-ADsComputers -SearchType All
$noexp = Get-ADsUserPwdNoExpire
$exps  = Get-ADsUserPwdExpirations | ? {$_.Expires -lt 14} | ? {$_.UserName -ne 'krbtgt'}

$uDates = $users | Select -ExpandProperty LastLogon
$mDates = $comps | Select -ExpandProperty LastLogon

$dayslist = @(30, 60, 90, 180, 365)

$content = "<table style=`"width:100%;border:none`"><tr>"
$content += "<td style=`"width:50%; vertical-align:top`">"

    $content += "<h2>User Accounts</h2>"

    $content += "<table id=table1>"
    $content += "<tr><th>Users</th><th>Days since last login</th></tr>"
    foreach ($dx in $dayslist) {
        $content += "<tr>"
        $num = ($uDates | %{(New-TimeSpan -Start $_ -End $(Get-Date)).Days} | ?{$_ -gt $dx}).Count
        $content += "<td style=`"width:100px;text-align:right`">$num</td>"
        $content += "<td><a href=`"adrep.ps1?a=user&d=$dx`">$dx days</a></td>"
        $content += "</tr>"
    }
    $content += "<tr><td style=`"width:100px;text-align:right`">"
    $content += "<a href=`"aduserpwdexp.ps1?p=0`">$($noexp.Count)</a></td><td>Password never expires</td></tr>"
    $content += "<tr><td style=`"width:100px;text-align:right`">"
    $content += "<a href=`"aduserpwdexp.ps1?p=1`">$($exps.Count)</a></td><td>Password expires within 14 days</td></tr>"
    $content += "</table>"

$content += "</td><td style=`"width:50%;vertical-align:top`">"

    $content += "<h2>Computer Accounts</h2>"

    $content += "<table id=table1>"
    $content += "<tr><th>Computers</th><th>Days since last login</th></tr>"
    foreach ($dx in $dayslist) {
        $content += "<tr>"
        $num = ($mDates | %{(New-TimeSpan -Start $_ -End $(Get-Date)).Days} | ?{$_ -gt $dx}).Count
        $content += "<td style=`"width:100px;text-align:right`">$num</td>"
        $content += "<td><a href=`"adrep.ps1?a=computer&d=$dx`">$dx days</a></td>"
        $content += "</tr>"
    }
    $content += "</table>"

$content += "</td></tr></table>"

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