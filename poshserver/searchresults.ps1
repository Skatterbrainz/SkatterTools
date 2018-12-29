$SearchPhrase = $($PoshPost.qtext).Trim()
$SearchType   = $PoshPost.scope
$PageTitle    = "Search Results"
$PageCaption  = "Search Results"

if (!(Get-Module dbatools)) { Import-Module dbatools }

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
$targets = $targets | Where-Object{if($_) {$_}}

$content = "<h1>$PageCaption</h1>"

if ($SearchPhrase -eq "") {
    $content += "<table id=table2><tr style=`"height:100px`"><td style=`"text-align:center`">"
    $content += "No search phrase was entered</td></tr></table>"
}
else {
    $content += "<table id=table1><tr>"

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
                $xlink  = "adusers.ps1?f=username&v=$SearchPhrase&x=$SearchType";
                break;
            }
            'adgroups' { 
                $tscope = "Groups"; 
                $xlink  = "adgroups.ps1?f=name&v=$SearchPhrase&x=$SearchType";
                break;
            }
            'adcomputers' { 
                $tscope = "Computers"; 
                $xlink  = "adcomputers.ps1?f=name&v=$SearchPhrase&x=$SearchType";
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
                $rs = @(Invoke-DbaQuery -SqlInstance $CmDBHost -Database "CM_$CmSiteCode" -Query $query)
                $qty = $rs[0].Qty
                $err = ""
            }
            catch {
                $content += "<tr><td>error: $($Error[0].Exception.Message)</td></tr>"
            }
            finally {}
        }
        else {
            switch ($tgroup) {
                'adusers' {
                    try {
                        switch ($SearchType) {
                            'like' { 
                                $users = Get-ADsUsers | ?{$_.UserName -like "*$SearchPhrase*"}
                                $query = "get-adusers where {username like '*$SearchPhrase*'}"
                                break;
                            }
                            'begins' {
                                $users = Get-ADsUsers | ?{$_.UserName -like "$SearchPhrase*"}
                                $query = "get-adusers where {username like '$SearchPhrase*'}"
                                break;
                            }
                            'ends' {
                                $users = Get-ADsUsers | ?{$_.UserName -like "*$SearchPhrase"}
                                $query = "get-adusers where {username like '*$SearchPhrase'}"
                                break;
                            }
                            default {
                                $users = Get-ADsUsers | ?{$_.UserName -eq "$SearchPhrase"}
                                $query = "get-adusers where {username = '$SearchPhrase'}"
                                break;
                            }
                        }
                        if ($qty.count -gt 1) {
                            $qty = $groups.count
                        }
                        elseif ($qty.Name -ne "") {
                            $qty = 1
                        }
                    }
                    catch {
                        $qty = 0
                    }
                    break;
                }
                'adgroups' {
                    try {
                        switch ($SearchType) {
                            'like' { 
                                $groups = Get-ADsGroups | ?{$_.Name -like "*$SearchPhrase*"}
                                $query = "get-adgroups where {name like '*$SearchPhrase*'}"
                                break;
                            }
                            'begins' {
                                $groups = Get-ADsGroups | ?{$_.Name -like "$SearchPhrase*"}
                                $query = "get-adgroups where {name like '$SearchPhrase*'}"
                                break;
                            }
                            'ends' {
                                $groups = Get-ADsGroups | ?{$_.Name -like "*$SearchPhrase"}
                                $query = "get-adgroups where {name like '*$SearchPhrase'}"
                                break;
                            }
                            default {
                                $groups = Get-ADsGroups | ?{$_.UserName -eq "$SearchPhrase"}
                                $query = "get-adgroups where {name = '$SearchPhrase'}"
                                break;
                            }
                        }
                        if ($qty.count -gt 1) {
                            $qty = $groups.count
                        }
                        elseif ($qty.Name -ne "") {
                            $qty = 1
                        }
                    }
                    catch {
                        $qty = 0
                    }
                    break;
                }
                'adcomputers' {
                    try {
                        switch ($SearchType) {
                            'like' { 
                                $comps = Get-ADsComputers | ?{$_.Name -like "*$SearchPhrase*"}
                                $query = "get-adcomputers where {name like '*$SearchPhrase*'}"
                                break;
                            }
                            'begins' {
                                $comps = Get-ADsComputers | ?{$_.Name -like "$SearchPhrase*"}
                                $query = "get-adcomputers where {name like '$SearchPhrase*'}"
                                break;
                            }
                            'ends' {
                                $comps = Get-ADsComputers | ?{$_.Name -like "*$SearchPhrase"}
                                $query = "get-adcomputers where {name like '*$SearchPhrase'}"
                                break;
                            }
                            default {
                                $comps = Get-ADsComputers | ?{$_.UserName -eq "$SearchPhrase"}
                                $query = "get-adcomputers where {name = '$SearchPhrase'}"
                                break;
                            }
                        }
                        $qty = $comps.count
                    }
                    catch {
                        $qty = 0
                    }
                    break;
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
}
$content += "<form name=`"form1`" id=`"form1`" method=`"post`" action=`"search.ps1`">"
$content += "<input type=`"submit`" name=`"search`" id=`"search`" class=`"button1`" value=`"New Search`" />"
$content += "</form>"

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