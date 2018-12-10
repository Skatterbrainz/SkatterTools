$SearchPhrase = $($PoshPost.qtext).Trim()
$SearchScope  = $PoshPost.scope
$c1 = $PoshPost.c01
$c2 = $PoshPost.c02
$c3 = $PoshPost.c03
$c4 = $PoshPost.c04
$c5 = $PoshPost.c05
#$c6 = $PoshPost.c06

$a1 = $PoshPost.a01
$a2 = $PoshPost.a02
$a3 = $PoshPost.a03
#$a4 = $PoshPost.a04

$targets = @($c1,$c2,$c3,$c4,$c5,$a1,$a2,$a3)

switch ($SearchScope) {
    'like'   { $sscope = 'Contains'; break; }
    'begins' { $sscope = 'Begins With'; break; }
    'ends'   { $sscope = 'Ends With'; break; }
    'equals' { $sscope = '='; break; }
}

function Find-ResultCounts {
    [CmdletBinding()]
    param (
        [string] $SearchText,
        [parameter(Mandatory=$False)]
        [ValidateSet('equals','like','begins','ends')]
        [string] $SearchType = 'like',
        [string[]] $SearchTargets
    )
    foreach ($target in $SearchTargets) {
        $results = $null
        switch ($target) {
            'cmdevices' {
                $tname = "ConfigMgr Devices"
                $output = 0
                try {
                    $query = "select count(*) as QTY from dbo.v_R_System"
                    switch ($SearchType) {
                        'equals' { $query += " where (name0 = '$SearchText')"; break; }
                        'begins' { $query += " where (name0 like '$SearchText%')"; break; }
                        'ends'   { $query += " where (name0 like '%$SearchText')"; break; }
                        'like'   { $query += " where (name0 like '%$SearchText%')"; break; }
                    }
                    $connection = New-Object -ComObject "ADODB.Connection"
                    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
                    $connection.Open($connString);
                    $rs = New-Object -ComObject "ADODB.RecordSet"
                    $rs.Open($query, $connection)
                    $output = $rs.Fields("QTY").Value
                }
                catch {
                    $output = 0
                }
                finally {
                    [void]$rs.Close()
                    [void]$connection.Close()
                }
                if ($output -gt 0) {
                    $xlink = "<a href=`"cmdevices.ps1?f=name&v=$SearchText&x=$SearchScope`">$tname</a><br/><span style=`"font-size:8pt`">$query</span>"
                }
                else {
                    $xlink = "$tname<br/><span style=`"font-size:8pt`">$query</span>"
                }
                break;
            }
            'cmusers' {
                $tname = "ConfigMgr Users"
                $output = 0
                try {
                    $query = "select count(*) as QTY from dbo.v_R_User"
                    switch ($SearchType) {
                        'equals' { $query += " where (user_name0 = '$SearchText') or (full_user_name0 = '$SearchText')"; break; }
                        'begins' { $query += " where (user_name0 like '$SearchText%') or (full_user_name0 like '$SearchText%')"; break; }
                        'ends'   { $query += " where (user_name0 like '%$SearchText') or (full_user_name0 like '%$SearchText')"; break; }
                        'like'   { $query += " where (user_name0 like '%$SearchText%') or (full_user_name0 like '%$SearchText%')"; break; }
                    }
                    $connection = New-Object -ComObject "ADODB.Connection"
                    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
                    $connection.Open($connString);
                    $rs = New-Object -ComObject "ADODB.RecordSet"
                    $rs.Open($query, $connection)
                    $output = $rs.Fields("QTY").Value
                }
                catch {
                    $output = 0
                }
                finally {
                    [void]$rs.Close()
                    [void]$connection.Close()
                }
                if ($output -gt 0) {
                    $xlink = "<a href=`"cmusers.ps1?f=user_name0&v=$SearchText&x=$SearchScope`">$tname</a><br/><span style=`"font-size:8pt`">$query</span>"
                }
                else {
                    $xlink = "$tname<br/><span style=`"font-size:8pt`">$query</span>"
                }
                break;
            }
            'cmdevcolls' {
                $tname = "ConfigMgr Device Collections"
                $output = 0
                try {
                    $query = "select count(*) as QTY from dbo.v_Collection"
                    switch ($SearchType) {
                        'equals' { $query += " where ((collectiontype=2) and (name = '$SearchText'))"; break; }
                        'begins' { $query += " where ((collectiontype=2) and (name like '$SearchText%'))"; break; }
                        'ends'   { $query += " where ((collectiontype=2) and (name like '%$SearchText'))"; break; }
                        'like'   { $query += " where ((collectiontype=2) and (name like '%$SearchText%'))"; break; }
                    }
                    $connection = New-Object -ComObject "ADODB.Connection"
                    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
                    $connection.Open($connString);
                    $rs = New-Object -ComObject "ADODB.RecordSet"
                    $rs.Open($query, $connection)
                    $output = $rs.Fields("QTY").Value
                }
                catch {
                    $output = 0
                }
                finally {
                    [void]$rs.Close()
                    [void]$connection.Close()
                }
                if ($output -gt 0) {
                    $xlink = "<a href=`"cmcollections.ps1?f=CollectionName&v=$SearchText&x=$SearchScope&t=2`">$tname</a><br/><span style=`"font-size:8pt`">$query</span>"
                }
                else {
                    $xlink = "$tname<br/><span style=`"font-size:8pt`">$query</span>"
                }
                break;
            }
            'cmusercolls' {
                $tname = "ConfigMgr User Collections"
                $output = 0
                try {
                    $query = "select count(*) as QTY from dbo.v_Collection"
                    switch ($SearchType) {
                        'equals' { $query += " where ((collectiontype=1) and (name = '$SearchText'))"; break; }
                        'begins' { $query += " where ((collectiontype=1) and (name like '$SearchText%'))"; break; }
                        'ends'   { $query += " where ((collectiontype=1) and (name like '%$SearchText'))"; break; }
                        'like'   { $query += " where ((collectiontype=1) and (name like '%$SearchText%'))"; break; }
                    }
                    $connection = New-Object -ComObject "ADODB.Connection"
                    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
                    $connection.Open($connString);
                    $rs = New-Object -ComObject "ADODB.RecordSet"
                    $rs.Open($query, $connection)
                    $output = $rs.Fields("QTY").Value
                }
                catch {
                    $output = 0
                }
                finally {
                    [void]$rs.Close()
                    [void]$connection.Close()
                }
                if ($output -gt 0) {
                    $xlink = "<a href=`"cmcollections.ps1?f=CollectionName&v=$SearchText&x=$SearchScope&t=1`">$tname</a><br/><span style=`"font-size:8pt`">$query</span>"
                }
                else {
                    $xlink = "$tname<br/><span style=`"font-size:8pt`">$query</span>"
                }
                break;
            }
            'cmproducts' {
                $tname = "ConfigMgr Software Products"
                $xlink = $tname
                break;
            }
            'cmfiles' {
                $tname = "ConfigMgr Software Files"
                $xlink = $tname
                break;
            }
            'adusers' {
                $tname = "AD Users"
                switch ($SearchType) {
                    'equals'   { $results = Get-ADsUsers | Where {$_.UserName -eq $SearchText}; break; }
                    'like'     { $results = Get-ADsUsers | Where {$_.UserName -like "*$SearchText*"}; break; }
                    'begins'   { $results = Get-ADsUsers | Where {$_.UserName -like "$SearchText*"}; break; }
                    'ends'     { $results = Get-ADsUsers | Where {$_.UserName -like "*$SearchText"}; break; }
                    default { $results = $null }
                }
                $xlink  = "<a href=`"adusers.ps1?f=name&v=$SearchText&x=$SearchType`">$tname</a>"
                if ($null -ne $results) {
                    if ($results.GetType() -eq 'array') {
                        $output = $results.Count
                    }
                    elseif ($results.GetType().Name -eq 'PSCustomObject') {
                        $output = 1
                    }
                }
                break;
            }
            'adgroups' {
                $tname = "AD Groups"
                switch ($SearchType) {
                    'equals'   { $results = Get-ADsGroups | Where {$_.Name -eq $SearchText}; break; }
                    'like'     { $results = Get-ADsGroups | Where {$_.Name -like '*'+$SearchText+'*'}; break; }
                    'begins'   { $results = Get-ADsGroups | Where {$_.Name -like $SearchText+'*'}; break; }
                    'ends'     { $results = Get-ADsGroups | Where {$_.Name -like '*'+$SearchText}; break; }
                    default { $results = $null }
                }
                $xlink  = "<a href=`"adgroups.ps1?f=name&v=$SearchText&x=$SearchType`">$tname</a>"
                if ($null -ne $results) {
                    if ($results.GetType() -eq 'array') {
                        $output = $results.Count
                    }
                    elseif ($results.GetType().Name -eq 'PSCustomObject') {
                        $output = 1
                    }
                }
                break;
            }
            'adcomputers' {
                $tname = "AD Computers"
                switch ($SearchType) {
                    'equals'   { $results = Get-ADsComputers | Where {$_.Name -eq $SearchText}; break; }
                    'like'     { $results = Get-ADsComputers | Where {$_.Name -like '*'+$SearchText+'*'}; break; }
                    'begins'   { $results = Get-ADsComputers | Where {$_.Name -like $SearchText+'*'}; break; }
                    'ends'     { $results = Get-ADsComputers | Where {$_.Name -like '*'+$SearchText}; break; }
                    default { $results = $null }
                }
                $xlink  = "<a href=`"adcomputers.ps1?f=name&v=$SearchText&x=$SearchType`">$tname</a>"
                if ($null -ne $results) {
                    if ($results.GetType() -eq 'array') {
                        $output = $results.Count
                    }
                    elseif ($results.GetType().Name -eq 'PSCustomObject') {
                        $output = 1
                    }
                }
                break;
            }
            default {
                $tname = ""
                break;
            }
        } # switch
        if ($tname -ne "") {
            $props = [ordered]@{
                SearchTarget = $xlink
                Hits = $output
            }
            New-Object PSObject -Property $props
        }
    } # foreach
}

$matches = Find-ResultCounts -SearchText $SearchPhrase -SearchType $SearchScope -SearchTargets $targets -Verbose

$content = "<table id=table1>"
$content += "<tr><th>Search Target</th><th>Results</th></tr>"
foreach ($match in $matches) {
    $content += "<tr><td>$($match.SearchTarget)</td><td>$($match.Hits)</td></tr>"
}
$content += "</table>"

#$content =+ "<input action=`"action`" type=`"button`" name=`"back`" id=`"back`" onClick=`"window.history.go(-1); return false;`" class=`"button1`" value=`"Go Back`" />"

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>Search Results: $sscope '$SearchPhrase'</h1>

$content

</body>
</html>
"@