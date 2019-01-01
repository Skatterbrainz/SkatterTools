$DeviceName = Get-PageParam -Tagname 'c' -Default ""
$ToolName   = Get-PageParam -Tagname 't' -Default ""

$ReturnLink = "<a href=`"adcomputer.ps1?v=$DeviceName&tab=Tools`">Return</a>"

switch ($ToolName) {
    'gpupdate' {
        $output = Invoke-Command -ComputerName $DeviceName -ScriptBlock { "GPUPDATE.exe /FORCE" }
        $result = "Result = $output"
        break;
    }
}

$content = "<table id=table2><tr><td>$result<br/><br/>$ReturnLink</td></tr></table>"

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