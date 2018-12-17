$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default ""
$SortField   = Get-PageParam -TagName 's' -Default ""
$SortOrder   = Get-PageParam -TagName 'so' -Default ""
$TabSelected = Get-PageParam -TagName 'tab' -Default ""
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "AD Domain Options"
$PageCaption = "AD Domain Options"
$content     = ""
$tabset      = ""
$xxx         = ""

$domainname = $env:USERDOMAIN
[adsi]$domain = "WinNT://$domainname"

$pwa1 = $($domain.MinPasswordAge) / 86400
$pwa2 = $($domain.MaxPasswordAge) / 86400
$pwln = $domain.MinPasswordLength
$mbpa = $domain.MaxBadPasswordsAllowed
$phln = $domain.PasswordHistoryLength
$alin = $domain.AutoUnlockInterval

$content = "<table id=table2>"
$content += "<tr><th>Option / Setting</th><th style=`"width:100px`">Value</th></tr>"
$content += "<tr><td>Minimum Password Age</td><td style=`"text-align:right`">$pwa1 days</td></tr>"
$content += "<tr><td>Maximum Password Age</td><td style=`"text-align:right`">$pwa2 days</td></tr>"
$content += "<tr><td>Minimum Password Length</td><td style=`"text-align:right`">$pwln</td></tr>"
$content += "<tr><td>Max Bad Passwords Allowed</td><td style=`"text-align:right`">$mbpa</td></tr>"
$content += "<tr><td>Password History Length</td><td style=`"text-align:right`">$phln</td></tr>"
$content += "<tr><td>Account Lockout Interval</td><td style=`"text-align:right`">$alin</td></tr>"
$content += "</table>"

# get summary of object types
#$domain.Children | Group-Object {$_.schemaclassname} | Select-Object Count,Name
#$domain.Children | Where-Object {$_.schemaclassname -eq 'computer'}

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

$tabset
$content

</body>
</html>
"@