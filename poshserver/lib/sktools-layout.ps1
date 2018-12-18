$Global:SkToolsLibLayout = "1812.15.01"

function New-MenuTabSet {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $BaseLink,
        [parameter(Mandatory=$False)]
        [string] $DefaultID = ""
    )
    $output = "<table id=table3><tr>"
    if ($DefaultID -eq 'all') {
        $output += "<td class=`"dyn2`" title='All'>All</td>"
    }
    else {
        $xlink = $BaseLink + 'all'
        $output += "<td class=`"dyn1`" onMouseOver=`"this.className='dyn2'`" onMouseOut=`"this.className='dyn1'`" title=`"Show All`" onClick=`"document.location.href='$xlink'`">All</td>"
    }
    for ($i=65; $i -lt $(65+26); $i++) {
        $c = [char]$i
        $xlink = $BaseLink + $c
        if ($DefaultID -eq $c) {
            $output += "<td class=`"dyn2`">$c</td>"
        }
        else {
            $output += "<td class=`"dyn1`" onMouseOver=`"this.className='dyn2'`" onMouseOut=`"this.className='dyn1'`" title=`"Filter on $c`" onClick=`"document.location.href='$xlink'`">$c</td>"
        }
    }
    for ($i=0; $i -lt 10; $i++) {
        $xlink = $BaseLink + $i
        if ($DefaultID -eq $c) {
            $output += "<td class=`"dyn2`">$i</td>"
        }
        else {
            $output += "<td class=`"dyn1`" onMouseOver=`"this.className='dyn2'`" onMouseOut=`"this.className='dyn1'`" title=`"Filter on $i`" onClick=`"document.location.href='$xlink'`">$i</td>"
        }
    }
    $output += "</tr></table>"
    return $output
}

function New-MenuTabSet2 {
    param (
        [parameter(Mandatory=$True)]
        [string[]] $MenuTabs,
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $BaseLink
    )
    $output = "<table id=tablex><tr>"
    foreach ($tab in $tabs) {
        $xlink = "$baselink`?f=$SearchField&v=$SearchValue&x=$SearchType&s=$SortField&so=$SortOrder&n=$CustomName&tab=$tab"
        if ($tab -eq $TabSelected) {
            $output += "<td class=`"btab`">$tab</td>"
        }
        else {
            $output += "<td class=`"btab`" onClick=`"document.location.href='$xlink'`" title=`"$tab`">$tab</td>"
        }
    }
    $output += "</tr></table>"
    return $output
}

function New-ColumnSortRow {
    param (
        [parameter(Mandatory=$True)]
        [string[]] $ColumnNames,
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $BaseLink,
        [parameter(Mandatory=$False)]
        [ValidateSet('Asc','Desc')]
        [string] $SortDirection = 'Asc'
    )
    $output = ""
    foreach ($col in $ColumnNames) {
        if ($col -eq $SortField) {
            if ($SortDirection -eq 'Asc') {
                $xlink = "<a href=`"$BaseLink&s=$col&so=desc`">$col</a>"
                $ilink = "<img src='graphics/sortasc.png' border=0 alt='' />"
            }
            else {
                $xlink = "<a href=`"$BaseLink&s=$col&so=asc`">$col</a>"
                $ilink = "<img src='graphics/sortdesc.png' border=0 alt='' />"
            }
        }
        else {
            $xlink = "<a href=`"$BaseLink&s=$col&so=asc`">$col</a>"
            $ilink = ""
        }
        $output += '<th>'+$xlink+' '+$ilink+'</th>'
    }
    return $output
}