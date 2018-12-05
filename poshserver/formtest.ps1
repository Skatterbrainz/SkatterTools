@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body onLoad='document.form1.qtext.focus();'>

<h1>Search the #$@&*^% out It</h1>

<form name='form1' id='form1' method='post' action='formtest2.ps1'>
<table id=table2>
    <tr>
        <td style='width:200px'>
            Search Phrase
        </td>
        <td>
            <input type='text' name='qtext' id='qtext' size='20' style='padding:5px;width:400px;' title='Enter a Search Phrase' />
            <input type='checkbox' name='exact' id='exact' value='exact' checked='true' title='Restrict Search to Exact Matches only' /> Exact Match
        </td>
    </tr>
    <tr>
        <td>
            Search Targets
        </td>
        <td>
            <input type='radio' name='x1' id='x1' value='selectall' style='width:18px' /> Search the Whole #$&@ing mess!<br/>
            <input type='radio' name='x1' id='x1' value='selectnone' style='width:18px' /> Be a picky little bastard<br/>
            <br/>
            <table id=table3>
                <tr>
                    <td style='vertical-align: top; width:250px'>
                        <input type='checkbox' name='c01' id='c01' value='cmdevices' /> ConfigMgr Devices<br/>
                        <input type='checkbox' name='c02' id='c02' value='cmusers' /> ConfigMgr Users<br/>
                        <input type='checkbox' name='c03' id='c03' value='cmdevcolls' /> ConfigMgr Device Collections<br/>
                        <input type='checkbox' name='c04' id='c04' value='cmusercolls' /> ConfigMgr User Collections<br/>
                        <input type='checkbox' name='c05' id='c05' value='cmtasksequences' /> ConfigMgr Task Sequences<br/>
                        <input type='checkbox' name='c06' id='c06' value='cmproducts' /> ConfigMgr Software Products<br/>
                        <input type='checkbox' name='c07' id='c07' value='cmfiles' /> ConfigMgr Software Files<br/>
                    </td>
                    <td style='vertical-align:top;'>
                        <input type='checkbox' name='c08' id='c08' value='adusers' /> Active Directory Users<br/>
                        <input type='checkbox' name='c09' id='c09' value='adgroups' /> Active Directory Groups<br/>
                        <input type='checkbox' name='c10' id='c10' value='adcomputers' /> Active Directory Computers<br/>
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