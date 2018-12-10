$SearchPhrase = $($PoshPost.qtext).Trim()
$SearchScope  = $PoshPost.scope
$x1 = $PoshPost.c01
$x2 = $PoshPost.c02
$x3 = $PoshPost.c03
$x4 = $PoshPost.c04
$x5 = $PoshPost.c05
$x6 = $PoshPost.c06
$x7 = $PoshPost.c07

$targets = @($x1,$x2,$x3,$x4,$x5,$x6,$x7)

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
        $output  = 0
        $results = $null
        #Write-Verbose "target: $target"
        switch ($target) {
            'cmdevices' {
                $tname = "ConfigMgr Devices"
                break;
            }
            'cmusers' {
                $tname = "ConfigMgr Users"
                break;
            }
            'cmcolls' {
                $tname = "ConfigMgr Collections"
                break;
            }
            'cmproducts' {
                $tname = "ConfigMgr Software Products"
                break;
            }
            'cmfiles' {
                $tname = "ConfigMgr Software Files"
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