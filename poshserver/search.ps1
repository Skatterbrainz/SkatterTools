$SearchScoping = $PoshQuery.g
$chk1 = ""
$chk2 = ""
if ($SearchScoping -eq 'cm') {
    $chk1 = "checked"
}
if ($SearchScoping -eq 'ad') {
    $chk2 = "checked"
}
@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body onLoad='document.form1.qtext.focus();'>

<h1>Search the #$@&*^% out It</h1>

<form name='form1' id='form1' method='post' action='searchresults.ps1'>
<table id=table2>
    <tr>
        <td style='width:200px'>
            Search Phrase ($SearchScoping)
        </td>
        <td>
            <input type='text' name='qtext' id='qtext' size='20' style='padding:5px;width:400px;' title='Enter a Search Phrase' />
            <select name='scope' id='scope' size='1' style='padding:5px;width:200px'>
                <option value=''></option>
                <option value='equals'>Equals</option>
                <option value='like' selected>Contains</option>
                <option value='begins'>Starts With</option>
                <option value='ends'>Ends With</option>
            </select>
        </td>
    </tr>
    <tr>
        <td>
            Search Targets
        </td>
        <td>
            <table id=table3>
                <tr>
                    <td style='vertical-align: top; width:250px'>
                        <input type='checkbox' name='c01' id='c01' value='cmdevices' $chk1 /> ConfigMgr Devices<br/>
                        <input type='checkbox' name='c02' id='c02' value='cmusers' $chk1 /> ConfigMgr Users<br/>
                        <input type='checkbox' name='c03' id='c03' value='cmcolls' $chk1 /> ConfigMgr Collections<br/>
                        <input type='checkbox' name='c04' id='c04' value='cmproducts' $chk1 /> ConfigMgr Software Products<br/>
                        <input type='checkbox' name='c05' id='c05' value='adusers' $chk2 /> Active Directory Users<br/>
                        <input type='checkbox' name='c06' id='c06' value='adgroups' $chk2 /> Active Directory Groups<br/>
                        <input type='checkbox' name='c07' id='c07' value='adcomputers' $chk2 /> Active Directory Computers<br/>
                    </td>
                    <td style='vertical-align:top;'>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td colspan='2'>
            <input type='button' name='cancel' id='cancel' class='button1' value='Cancel' title='Cancel' />
            <input type='submit' name='search' id='search' class='button1' value='Search' title='Search' />
        </td>
    </tr>
</table>
</form>

</body>
</html>
"@