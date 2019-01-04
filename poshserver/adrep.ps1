$MaxLoginDays = Get-PageParam -TagName "d" -Default ""
$AccountType  = Get-PageParam -TagName "a" -Default ""
$PageTitle    = "AD Reports: Last Login &gt; $MaxLoginDays days"
$PageCaption  = "AD Reports: Last Login &gt; $MaxLoginDays days"

try {
    switch ($AccountType) {
        "user" {
            $users  = @(Get-ADsUsers)
            $uDates = @($users | Select -ExpandProperty LastLogon)

            $content = "<table id=table1>"
            $content += "<tr><th>User Name</th><th>DistinguishedName</th><th>Login</th></tr>"

            $ulist = $users | ?{(New-TimeSpan -Start $_.LastLogon -End (Get-Date)).Days -gt $MaxLoginDays}

            foreach ($usr in $ulist) {
                $ux = Get-AdValueLink -PropertyName "UserName" -Value $($usr.Name)
                $content += "<tr>"
                $content += "<td>$ux</td>"
                $content += "<td>$([string]$usr.DN)</td>"
                $content += "<td>$([string]$usr.LastLogon)</td>"
                $content += "</tr>"
            }
            $content += "<tr><td colspan=3 class=lastrow>$($ulist.Count) users</td></tr>"
            $content += "</table>"
            break;
        }
        "computer" {
            $comps  = @(Get-ADsComputers -SearchType All)
            $mDates = @($comps | Select -ExpandProperty LastLogon)

            $content = "<table id=table1>"
            $content += "<tr><th>Computer Name</th><th>DistinguishedName</th><th>Login</th></tr>"

            $mlist = $comps | ?{(New-TimeSpan -Start $_.LastLogon -End (Get-Date)).Days -gt $MaxLoginDays}

            foreach ($m in $mlist) {
                $cx = Get-AdValueLink -PropertyName "ComputerName" -Value $($m.Name)
                $content += "<tr>"
                $content += "<td>$cx</td>"
                $content += "<td>$([string]$m.DN)</td>"
                $content += "<td>$([string]$m.LastLogon)</td>"
                $content += "</tr>"
            }
            $content += "<tr><td colspan=3 class=lastrow>$($ulist.Count) computers</td></tr>"
            $content += "</table>"
            break;
        }
    } # switch
}
catch {
    $content = "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
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