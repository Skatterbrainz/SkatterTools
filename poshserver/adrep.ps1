$MaxLoginDays = Get-PageParam -TagName "d" -Default ""
$AccountType  = Get-PageParam -TagName "a" -Default ""
$PageTitle    = "AD Reports: Last Login &gt; $MaxLoginDays days"
$PageCaption  = "AD Reports: Last Login &gt; $MaxLoginDays days"

switch ($AccountType) {
    "user" {
        $users  = @(Get-ADsUsers)
        $comps  = @(Get-ADsComputers -SearchType All)
        $uDates = @($users | Select -ExpandProperty LastLogon)

        $content = "<table id=table1>"
        $content += "<tr><th>User Name</th><th>DistinguishedName</th><th>Login</th></tr>"

        $ulist = $users | ?{(New-TimeSpan -Start $_.LastLogon -End (Get-Date)).Days -gt $MaxLoginDays}

        foreach ($usr in $ulist) {
            $content += "<tr>"
            $content += "<td>$([string]$usr.Name)</td>"
            $content += "<td>$([string]$usr.DN)</td>"
            $content += "<td>$([string]$usr.LastLogon)</td>"
            $content += "</tr>"
        }
        $content += "<tr><td colspan=3 class=lastrow>$($ulist.Count) users</td></tr>"
        $content += "</table>"
        break;
    }
    "computer" {
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