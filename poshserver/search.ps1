$PageTitle = "Search"
$PageCaption = "Search"

$SearchScoping = $PoshQuery.g
$chk1 = "false"
$chk2 = "false"
if ($SearchScoping -eq 'cm') {
    $chk1 = "checked"
}
if ($SearchScoping -eq 'ad') {
    $chk2 = "checked"
}

$content = ""

if ($CMEnabled -ne 'false') {
    $chklist  = ('cmdevices:v_r_system:name0','cmusers:v_r_user:user_name0','cmdevcolls:v_collection:name:collectiontype:2','cmusercolls:v_collection:name:collectiontype:1','cmproducts:v_gs_installed_software_categorized:productname0','cmfiles:v_gs_softwarefile:filename','cmts:v_TaskSequencePackage:name')
    $chknames = ('Devices','Users','Device Collections','User Collections','Software Products','Software Files','Task Sequences')
    for ($i = 0; $i -lt $chklist.Count; $i++) {
        $content += "<input type=`"checkbox`" name=`"c$($i+1)`" id=`"c$($i+1)`" value=`"$($chklist[$i])`" class=`"checkbox`" />&nbsp;ConfigMgr $($chknames[$i])<br/>"
    }
}

if ($ADEnabled -ne 'false') {
    $chklist  = ('adusers','adgroups','adcomputers')
    $chknames = ('Users','Groups','Computers')
    for ($i = 0; $i -lt $chklist.Count; $i++) {
        $content += "<input type=`"checkbox`" name=`"a$($i+1)`" id=`"a$($i+1)`" value=`"$($chklist[$i])`" class=`"checkbox`" />&nbsp;Active Directory $($chknames[$i])<br/>"
    }
}

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
<style>
.checkbox {
    height: 18px;
    width: 18px;
}
</style>
</head>

<body onLoad='document.form1.qtext.focus();'>

<h1>$PageCaption</h1>

<form name='form1' id='form1' method='post' action='searchresults.ps1'>
<table id=table2>
    <tr>
        <td style='width:200px'>
            Search Phrase ($SearchScoping)
        </td>
        <td>
            <input type='text' name='qtext' id='qtext' size='20' style='padding:5px;width:400px;font-family:verdana;' title='Enter a Search Phrase' />
            <select name='scope' id='scope' size='1' style='padding:5px;width:200px;font-family:verdana;'>
                <option value=''></option>
                <option value='equals'>Equals</option>
                <option value='like' selected>Contains</option>
                <option value='begins'>Begins With</option>
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
                        $content
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