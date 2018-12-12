$SearchPhrase = $($PoshPost.qtext).Trim()
$SearchType   = $PoshPost.scope
$PageTitle    = "Search Results"
$PageCaption  = "Search Results"

$c1 = $PoshPost.c1
$c2 = $PoshPost.c2
$c3 = $PoshPost.c3
$c4 = $PoshPost.c4
$c5 = $PoshPost.c5
$c6 = $PoshPost.c6
$c7 = $PoshPost.c7
$c8 = $PoshPost.c8

$a1 = $PoshPost.a1
$a2 = $PoshPost.a2
$a3 = $PoshPost.a3

$targets = ($a1, $a2, $a3, $c1, $c2, $c3, $c4, $c5, $c6, $c7, $c8)
$rowcount = 0
$targets = $targets | ?{if($_) {$_}}

$content = "<h1>$PageCaption</h1><table id=table1><tr>"
$content += "<th>Category</th><th>Scope</th><th>Query</th><th>Hits</th></tr>"

foreach ($target in $targets) {
    $tset = $null
    $q2 = ""
    $v2 = ""
    $qty = 0
    $tset = $target.Split(':')
    if ($tset.Count -gt 1) {
        $tgroup = $tset[0]
        $tablen = $tset[1]
        $key    = $tset[2]
        if ($tgroup.Substring(0,2) -eq 'cm') {
            $tcat = "ConfigMgr"
        }
        else {
            $tcat = "Active Directory"
        }
        switch ($SearchType) {
            'like'   { $clause = "like '%$SearchPhrase%'"; break; }
            'begins' { $clause = "like '$SearchPhrase%'"; break; }
            'ends'   { $clause = "like '%$SearchPhrase'"; break; }
            default  { $clause = "= '$SearchPhrase'"; break; }
        }
        $query = "select count(*) as QTY from $tablen where ($key $clause)"
        if ($tset.Count -gt 3) {
            $q2 = $tset[3]
            $v2 = $tset[4]
            $query += " and ($q2 = $v2)"
        }
    }
    else {
        $tgroup = $tset
        $tablen = ""
        $key    = ""
        $query  = ""
        if ($tgroup.Substring(0,2) -eq 'cm') {
            $tcat = "ConfigMgr"
        }
        else {
            $tcat = "Active Directory"
        }
    }
    switch ($tgroup) {
        'cmdevices' { 
            $tscope = "Devices"; 
            $xlink  = "cmdevices.ps1?f=name&v=$SearchPhrase&x=$SearchType"
            break; 
        }
        'cmusers' { 
            $tscope = "Users"; 
            $xlink  = "cmusers.ps1?f=username&v=$SearchPhrase&x=$SearchType"
            break; 
        }
        'cmdevcolls' { 
            $tscope = "Device Collections"; 
            $xlink  = "cmcollections.ps1?f=collectionname&v=$SearchPhrase&x=$SearchType&t=2"
            break; 
        }
        'cmusercolls' { 
            $tscope = "User Collections"; 
            $xlink  = "cmcollections.ps1?f=collectionname&v=$SearchPhrase&x=$SearchType&t=1"
            break; 
        }
        'cmproducts' { 
            $tscope = "Software Products"; 
            $xlink  = "cmproducts.ps1"
            break;
        }
        'cmpackages' {
            $tscope = "Packages";
            $xlink = "cmpackages.ps1"
            break;
        }
        'cmfiles' { 
            $tscope = "Software Files"; 
            $xlink  = "cmfiles.ps1?f=filename&v=$SearchPhrase&x=$SearchType"
            break; 
        }
        'cmts' { 
            $tscope = "Task Sequences"; 
            $xlink  = "cmts.ps1";
            break;
        }
        'adusers' { 
            $tscope = "Users"; 
            $xlink  = "adusers.ps1";
            break;
        }
        'adgroups' { 
            $tscope = "Groups"; 
            $xlink  = "adgroups.ps1";
            break;
        }
        'adcomputers' { 
            $tscope = "Computers"; 
            $xlink  = "adcomputers.ps1";
            break;
        }
        'adsites' { 
            $tscope = "Sites"; 
            $xlink  = "adsites.ps1"
            break;
        }
    }

    if ($query -ne "") {
        try {
            $connection = New-Object -ComObject "ADODB.Connection"
            $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
            $connection.Open($connString);
            $IsOpen = $True
            $rs = New-Object -ComObject "ADODB.RecordSet"
            $rs.Open($query, $connection)
            if ($rs.BOF -and $rs.EOF) {
                $qty = 0
            }
            else {
                $qty = $rs.Fields("QTY").Value
            }
            $err = ""
        }
        catch {
            $content += "<tr><td>error: $($Error[0].Exception.Message)</td></tr>"
        }
        finally {
            [void]$rs.Close()
            if ($IsOpen -eq $True) {
                [void]$connection.Close()
            }
        }
    }
    $xscope = $tscope
    if ($qty -gt 0) {
        $xscope = "<a href=`"$xlink`" title=`"Detailed Results`">$tscope</a>"
        $cell1 = "style=`"background-color:#196F3D;`""
        $cell2 = "style=`"background-color:#196F3D;text-align:right;`""
    }
    else {
        $cell1 = ""
        $cell2 = "style=`"text-align:right;`""
    }
    $content += "<tr><td $cell1>$tcat</td><td $cell1>$xscope</td><td>$query</td><td $cell2>$qty</td></tr>"
}
$content += "</table>"

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>
<body>

$content

</body>
</html>
"@