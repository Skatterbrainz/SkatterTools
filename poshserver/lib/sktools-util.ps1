$Global:SkToolsLibUtil = "1.0.3"

function Get-OSBuildName {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$BuildData
    )
    switch ($BuildData) {
        '10.0 (17763)' { return '1809'; break; }
        '10.0 (17134)' { return '1803'; break; }
        '10.0 (16299)' { return '1709'; break; }
        '10.0 (15063)' { return '1703'; break; }
        '10.0 (14393)' { return '1607'; break; }
        '10.0 (10586)' { return '1511'; break; }
    }
}

function Get-PageParam {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $TagName,
        [parameter(Mandatory=$False)]
        [string] $Default = ""
    )
    $output = $PoshQuery."$TagName"
    if ([string]::IsNullOrEmpty($output)) {
        $output = $Default
    }
    return $output
}

function Get-FormParam {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ElementID,
        [parameter(Mandatory=$False)]
        [string] $Default = ""
    )
    $output = $PoshPost."$ElementID"
    if ([string]::IsNullOrEmpty($output)) {
        $output = $Default
    }
    return $output
}

function Write-DetailInfo {
    param (
        [parameter(Mandatory=$False)]
        [string] $PageRef = "", 
        [parameter(Mandatory=$False)]
        [string] $Mode = ""
    )
    if ($Mode -eq "1") {
        $output = @"
<h3>Page Details</h3><table id=tabledetail>
    <tr><td style=`"width:200px;`">SearchField</td><td>$SearchField</td></tr>
    <tr><td style=`"width:200px;`">SearchValue</td><td>$SearchValue</td></tr>
    <tr><td style=`"width:200px;`">SearchType</td><td>$SearchType</td></tr>
    <tr><td style=`"width:200px;`">SortField</td><td>$SortField</td></tr>
    <tr><td style=`"width:200px;`">SortOrder</td><td>$SortOrder</td></tr>
    <tr><td style=`"width:200px;`">CustomName</td><td>$CustomName</td></tr>
    <tr><td style=`"width:200px;`">CollectionType</td><td>$CollectionType</td></tr>
    <tr><td style=`"width:200px;`">TabSelected</td><td>$TabSelected</td></tr>
    <tr><td style=`"width:200px;`">Detailed</td><td>$Detailed</td></tr>
    <tr><td style=`"width:200px;`">PageTitle</td><td>$PageTitle</td></tr>
    <tr><td style=`"width:200px;`">PageCaption</td><td>$PageCaption</td></tr>
    <tr><td style=`"width:200px;`">Last Step</td><td>$xxx</td></tr>
    <tr><td colspan=2>
    <a href=`"$PageRef`?f=$SearchField&v=$SearchValue&x=$SearchType&s=$SortField&so=$SearchOrder&t=$CollectionType&n=$CustomName&tab=$TabSelected`">Hide Details</a>
    </td></tr>
</table>
"@
        return $output
    }
    else {
        $output = @"
<table id=table3>
<tr>
<td><a href=`"$PageRef`?f=$SearchField&v=$SearchValue&x=$SearchType&s=$SortField&so=$SearchOrder&n=$CustomName&tab=$TabSelected&zz=1`">Show Details</a></td>
</tr>
</table>
"@
        return $output
    }
}

function Write-RowCount {
    param (
        [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $ItemName = "item",
        [parameter(Mandatory=$True)]
        [int] $RowCount
    )
    $output = "$RowCount $ItemName"
    if ($RowCount -gt 1) {
        $output += "s"
    }
    Write-Output $output
}

function Get-CheapEncode {
    param ($StringVal)
    $output = ""
    for ($i = 0; $i -lt $StringVal.Length; $i++) {
        $c = $([byte][char]$StringVal[$i] | Out-String).Trim()
        if ($c.Length -lt 3) {
            $output += "0$c"
        }
        else {
            $output += $c
        }
    }
    return $output
}

function Get-CheapDecode {
    param ($EncodedVal)
    $output = [string]::new("")
    $ccount = ($EncodedVal.Length - 2)
    for ($i = 0; $i -lt $ccount; $i+=3) {
        $chunk = $EncodedVal.Substring($i,3)
        $ascii = [convert]::ToUInt16($chunk)
        $output += [char]$ascii
    }
    return $output
}

function Write-HtmlButton {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $Label,
        [int] $Id = 1,
        [string] $Link,
        [string] $PropertySet = ""
    )
    $output = "<form name='form$Id' id='form$Id' method='post' action='$Link'>"
    $output += $PropertySet
    $output += "<input type='submit' class='button1' name='skb1' id='skb1' value='$Label' />"
    $output += "</form>"
    return $output
}