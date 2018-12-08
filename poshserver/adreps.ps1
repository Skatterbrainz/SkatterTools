$PageTitle   = "AD Reports"
$PageCaption = "AD Reports"

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

<table id=table2>
    <tr>
        <td style="width:50%;vertical-align:top">

            <h2>User Reports</h2>

            <ul class="ulmenu">
	            <li class="limain">Last Login &gt;= 30 Days</li>
	            <li class="limain">Last Login &gt;= 90 Days</li>
            </ul>

        </td>
        <td style="width:50%;vertical-align:top">

            <h2>Computer Reports</h2>

            <ul class="ulmenu">
	            <li class="limain">Last Login &gt;= 30 Days</li>
	            <li class="limain">Last Login &gt;= 90 Days</li>
            </ul>

        </td>
    </tr>
</table>

</body>
</html>
"@