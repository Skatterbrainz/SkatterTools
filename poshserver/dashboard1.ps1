$PageTitle   = "Dashboard"
$PageCaption = "Dashboard"

$adcomps  = Get-ADsComputers
$adusers  = Get-AdsUsers
$adgrps   = Get-ADsGroups

$ados = (Get-ADsComputers | Group-Object -Property OS | Select Name,Count)
$panel3 = ($ados | ConvertTo-Html -Fragment) -replace '<table>','<table id=table2>'

$content = "<table style=`"width:100%;border:0`">"
$content += "<tr><td style=`"width:50%;vertical-align:top`">PANEL1</td>"
$content += "<td style=`"width:50%;vertical-align:top`">PANEL2</td></tr>"
$content += "<tr><td style=`"vertical-align:top`">PANEL3</td>"
$content += "<td style=`"vertical-align:top`">PANEL4</td></tr>"
$content += "</table>"

$panel1 = "<table id=table2>"
$panel1 += "<tr><th>Name</th><th>Count</th></tr>"
$panel1 += "<tr><td>Active Directoy Computers</td><td style=`"width:100px;text-align:right`">$($adcomps.count)</td></tr>"
$panel1 += "<tr><td>Active Directory Users</td><td style=`"width:100px;text-align:right`">$($adusers.count)</td></tr>"
$panel1 += "<tr><td>Active Directory Groups</td><td style=`"width:100px;text-align:right`">$($adgrps.count)</td></tr>"
$panel1 += "</table>"

$content = $content -replace "PANEL1", $panel1
#$content = $content -replace "PANEL2", $panel2
$content = $content -replace "PANEL3", $panel3
#$content = $content -replace "PANEL4", $panel4

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