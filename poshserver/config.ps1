# Copyright (C) 2014 Yusuf Ozturk
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

# SkatterTools Site Configuration

$SkWebPath     = "e:\web"
$STTheme       = "stdark.css"
$CmDBHost      = "cm02.contoso.local"
$CmSMSProvider = "cm02.contoso.local"
$CmSiteCode    = "P02"
$SkNotesEnable = "false"
$SkNotesDBHost = ""
$SkDBDatabase  = ""
$SkNotesPath   = "notes\notes.xml"
$DefaultGroupsTab    = "all"
$DefaultUsersTab     = "all"
$DefaultComputersTab = "all"

# PoSH Server Configuration

# Default Document
$DefaultDocument = "index.htm"

# Log Schedule
# Options: Hourly, Daily
$LogSchedule = "Daily"

# Basic Authentication
# Options: On, Off
$BasicAuthentication = "Off"

# Windows Authentication
# Options: On, Off
$WindowsAuthentication = "On"

# DirectoryBrowsing
# Options: On, Off
$DirectoryBrowsing = "Off"

# IP Restriction
# Options: On, Off
$IPRestriction = "Off"
$IPWhiteList = "::1 127.0.0.1"

# Content Filtering
# Options: On, Off
$ContentFiltering = "Off"
$ContentFilterBlackList = "audio/mpeg video/mpeg"

# PHP Cgi Path
$PHPCgiPath = ($env:PATH).Split(";") | Select-String "PHP"
$PHPCgiPath = [string]$PHPCgiPath + "\php-cgi.exe"

$STVersion  = "1812.08.01"

# --------------------------------------------------

function Get-CmAdoConnection {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True, HelpMessage="ConfigMgr SQL Server hostname")]
        [ValidateNotNullOrEmpty()]
        [string] $SQLServerName,
        [parameter(Mandatory=$True, HelpMessage="SQL Server database name")]
        [ValidateNotNullOrEmpty()]
        [string] $DatabaseName,
        [parameter(Mandatory=$False, HelpMessage="SQL connection timeout value")]
        [int] $ConnectionTimeout = 30,
        [parameter(Mandatory=$False, HelpMessage="SQL query timeout value")]
        [int]$QueryTimeout = 120
    )
    $conn = New-Object System.Data.SqlClient.SQLConnection
    $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $SQLServerName,$DatabaseName,$ConnectionTimeout
    $conn.ConnectionString = $ConnectionString
    try {
        $conn.Open()
        Write-Output $conn
    }
    catch {
        Write-Error $Error[0].Exception.Message
        break
    }
}

function Get-CmSqlQueryData {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$False, ValueFromPipeline=$True, HelpMessage="SQL Query Statement")]
            [ValidateNotNullOrEmpty()]
            [string] $Query,
        [parameter(Mandatory=$False, HelpMessage="SQL Server ADO Connection Object")]
            $AdoConnection
    )
    $cmd = New-Object System.Data.SqlClient.SqlCommand($Query,$AdoConnection)
    $cmd.CommandTimeout = $QueryTimeout
    $ds = New-Object System.Data.DataSet
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    [void]$da.Fill($ds)
    $rows = $($ds.Tables).Rows.Count
    Write-Output $($ds.Tables).Rows
}

function Get-AdsUsers {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$False, HelpMessage="Optional user name")]
        [string] $UserName = ""
    )
    $pageSize = 1000
    if ([string]::IsNullOrEmpty($UserName)) {
        $as = [adsisearcher]"(objectCategory=User)"
    }
    else {
        $as = [adsisearcher]"(&(objectCategory=User)(sAMAccountName=$UserName))"
    }
    $as.PropertiesToLoad.Add('cn') | Out-Null
    $as.PropertiesToLoad.Add('sAMAccountName') | Out-Null
    $as.PropertiesToLoad.Add('lastlogonTimeStamp') | Out-Null
    $as.PropertiesToLoad.Add('whenCreated') | Out-Null
    $as.PropertiesToLoad.Add('department') | Out-Null
    $as.PropertiesToLoad.Add('title') | Out-Null
    $as.PropertiesToLoad.Add('mail') | Out-Null
    $as.PropertiesToLoad.Add('manager') | Out-Null
    $as.PropertiesToLoad.Add('employeeID') | Out-Null
    $as.PropertiesToLoad.Add('displayName') | Out-Null
    $as.PropertiesToLoad.Add('distinguishedName') | Out-Null
    $as.PageSize = 1000
    $results = $as.FindAll()
    foreach ($item in $results) {
        $cn = ($item.properties.item('cn') | Out-String).Trim()
        [datetime]$created = ($item.Properties.item('whenCreated') | Out-String).Trim()
        $llogon = ([datetime]::FromFiletime(($item.properties.item('lastlogonTimeStamp') | Out-String).Trim())) 
        $ouPath = ($item.Properties.item('distinguishedName') | Out-String).Trim() -replace $("CN=$cn,", "")
        $props  = [ordered]@{
            Name        = $cn
            UserName    = ($item.Properties.item('sAMAccountName') | Out-String).Trim()
            DisplayName = ($item.Properties.item('displayName') | Out-String).Trim()
            Title       = ($item.Properties.item('title') | Out-String).Trim()
            Department  = ($item.Properties.item('department') | Out-String).Trim()
            EmployeeID  = ($item.Properties.item('distinguishedName') | Out-String).Trim()
            Email       = ($item.Properties.item('mail') | Out-String).Trim()
            Manager     = ($item.Properties.item('manager') | Out-String).Trim()
            OUPath      = $ouPath
            Created     = $created
            LastLogon   = $llogon
        }
        New-Object psObject -Property $props
    }
}

function Get-ADsComputers {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$False, HelpMessage="Name of computer to query")]
        [string] $ComputerName = "",
        [parameter(Mandatory=$False, HelpMessage="Search type")]
        [ValidateSet('All','Disabled','Workstations','Servers')]
        [string] $SearchType = 'All'
    )
    $pageSize = 200
    if (![string]::IsNullOrEmpty($ComputerName)) {
        $as = [adsisearcher]"(&(objectCategory=Computer)(name=$ComputerName))"
    }
    else {
        switch ($SearchType) {
            'Disabled' {
                $as = [adsisearcher]"(&(objectCategory=computer)(userAccountControl:1.2.840.113556.1.4.803:=2))"
                break
            }
            'Workstations' {
                $as = [adsisearcher]"(&(objectCategory=computer)(!operatingSystem=*server*))"
                break
            }
            'Servers' {
                $as = [adsisearcher]"(&(objectCategory=computer)(operatingSystem=*server*))"
                break
            }
            default {
                $as = [adsisearcher]"(objectCategory=computer)"
                break
            }
        }
    }
    $as.PropertiesToLoad.Add('cn') | Out-Null
    $as.PropertiesToLoad.Add('lastlogonTimeStamp') | Out-Null
    $as.PropertiesToLoad.Add('whenCreated') | Out-Null
    $as.PropertiesToLoad.Add('operatingSystem') | Out-Null
    $as.PropertiesToLoad.Add('operatingSystemVersion') | Out-Null
    $as.PropertiesToLoad.Add('distinguishedName') | Out-Null
    $as.PageSize = $pageSize
    $results = $as.FindAll()
    foreach ($item in $results) {
        $cn = ($item.properties.item('cn') | Out-String).Trim()
        [datetime]$created = ($item.Properties.item('whenCreated') | Out-String).Trim()
        $llogon = ([datetime]::FromFiletime(($item.properties.item('lastlogonTimeStamp') | Out-String).Trim())) 
        $ouPath = ($item.Properties.item('distinguishedName') | Out-String).Trim() -replace $("CN=$cn,", "")
        $props  = [ordered]@{
            Name       = $cn
            OS         = ($item.Properties.item('operatingSystem') | Out-String).Trim()
            OSVer      = ($item.Properties.item('operatingSystemVersion') | Out-String).Trim()
            DN         = ($item.Properties.item('distinguishedName') | Out-String).Trim()
            OU         = $ouPath
            Created    = $created
            LastLogon  = $llogon
        }
        New-Object psObject -Property $props
    }
}

function Get-ADsComputer {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $Name 
    )
    $as = [adsisearcher]"(&(objectCategory=computer)(name=$Name))"
    $comp = $as.FindOne()
    $adprops = $comp.Properties
    $columns = $adprops.PropertyNames

    $props = [ordered]@{
        Name     = $($adprops.cn | Out-String).Trim()
        Fullname = $($adprops.dnshostname | Out-String).Trim()
        Created  = [datetime]($adprops.whencreated | Out-String)
        DN       = $($adprops.distinguishedname | Out-String).Trim()
        SPNlist  = $($adprops.serviceprincipalname)
        OS       = $($adprops.operatingsystem | Out-String).Trim()
    }
    New-Object -TypeName PSObject -Property $props
}

function Get-ADsGroups {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$False)]
        [string] $GroupName = ""
    )
    $pageSize = 200
    if ([string]::IsNullOrEmpty($GroupName)) {
        $as = [adsisearcher]"(objectCategory=Group)"
    }
    else {
        $as = [adsisearcher]"(&(objectCategory=Group)(name=$GroupName)"
    }
    $as.PropertiesToLoad.Add('name') | Out-Null
    $as.PropertiesToLoad.Add('description') | Out-Null
    $as.PropertiesToLoad.Add('whenCreated') | Out-Null
    $as.PropertiesToLoad.Add('whenChanged') | Out-Null
    $as.PropertiesToLoad.Add('distinguishedName') | Out-Null
    $as.PageSize = $pageSize
    $results = $as.FindAll()
    foreach ($item in $results) {
        $cn = ($item.properties.item('name') | Out-String).Trim()
        $ouPath = ($item.Properties.item('distinguishedName') | Out-String).Trim() -replace $("CN=$cn,", "")
        [datetime]$created = ($item.Properties.item('whenCreated') | Out-String).Trim()
        [datetime]$changed = ($item.Properties.item('whenChanged') | Out-String).Trim()
        $desc = ($item.Properties.item('description') | Out-String).Trim()
        $props  = [ordered]@{
            Name        = $cn
            DN          = ($item.Properties.item('distinguishedName') | Out-String).Trim()
            OU          = $ouPath
            Description = $desc
            Created     = $created
            Changed     = $changed
        }
        New-Object psObject -Property $props
    }
}

function Get-ADsGroupMembers {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $GroupName
    )
    $group = Get-ADsGroups | Where-Object {$_.name -eq $GroupName}
    if ($group) {
        Write-Verbose "group information found"
        $dn = $group.DN
        $gx = [adsi]"LDAP://$dn"
        $gx.member | Foreach-Object {
            $searcher = [adsisearcher]"(distinguishedname=$_)"
            $user = $searcher.FindOne().Properties
            $uname   = $($user.name | out-string).Trim()
            $created = [datetime]$($user.whencreated | Out-string).Trim() -f 'mm/DD/yyyy hh:mm'
            $udn     = $($user.distinguishedname | Out-string).Trim()
            if (($user.objectclass -join ',').Trim() -like "*group*") {
                $utype = 'Group'
            }
            else {
                $utype = 'User'
            }
            $utitle  = $($user.title | Out-String).Trim()
            $props = [ordered]@{
                UserName = $uname
                Created  = $created
                Type     = $utype
                DN       = $udn
                Title    = $utitle
            }
            New-Object PSObject -Property $props
        }
    }
    else {
        Write-Verbose "group was not found"
    }
}

function Get-OSBuildName {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$BuildData
    )
    switch ($BuildData) {
        '10.0 (17134)' { return '1803'; break; }
        '10.0 (16299)' { return '1709'; break; }
        '10.0 (15063)' { return '1703'; break; }
        '10.0 (14393)' { return '1607'; break; }
        '10.0 (10586)' { return '1511'; break; }
    }
}

function Get-ADsServicePrincipalNames {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [string] $Name = ""
    )
    $search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
    $search.filter = "(servicePrincipalName=*)"
    $results = $search.Findall()
    foreach($result in $results) {
        $userEntry = $result.GetDirectoryEntry()
        if (($Name -eq "") -or (($Name -ne "") -and ($userEntry.name -like "$Name"))) {
            $data = [ordered]@{
                Name = $userEntry.name
                DistinguishedName = $userEntry.distinguishedName.ToString()
                ObjectCategory = $userEntry.objectCategory
                SPNList = $userEntry.servicePrincipalName
            }
            Write-Output $data
        }
    }
}

# this one needs to get the hell out of here!
function Get-SortField {
    param (
        [parameter(Mandatory=$False)]
        [string] $Default = ""
    )
    if ([string]::IsNullOrEmpty($PoshQuery.s)) {
        return $Default
    }
    else {
        return $PoshQuery.s
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

function New-NoteAttachment {
    param (
        [parameter(Mandatory=$True)] [ValidateNotNullOrEmpty()] 
            [ValidateLength(1,255)]
            [string] $Comment,
        [parameter(Mandatory=$True)] [ValidateNotNullOrEmpty()] [string] $ObjectType,
        [parameter(Mandatory=$True)] [ValidateNotNullOrEmpty()] [string] $ObjectID
    )
    $xmlfile = Join-Path -Path $SkWebPath -ChildPath "notes\notes.xml"
    if (!(Test-Path $xmlfile)) {
        return -1
    }
    else {
        try {
            $doc = [xml](Get-Content -Path $xmlfile)
            $note = $doc.notes.note[0].clone()
            $note.date = "$(Get-Date)"
            $note.author = $PoshUserName
            $note.otype = $ObjectType
            $note.oid = $ObjectID
            $note.comment = $Comment
            $doc.DocumentElement.AppendChild($note)
            $doc.Save($xmlfile)
            return 0
        }
        catch {
            return $Error[0].Exception.Message
        }
    }
}

function Get-NoteAttachments {
    param (
        [parameter(Mandatory=$True)] [ValidateNotNullOrEmpty()] [string] $ObjectType,
        [parameter(Mandatory=$True)] [ValidateNotNullOrEmpty()] [string] $ObjectID
    )
    $xmlfile = Join-Path -Path $SkWebPath -ChildPath "notes\notes.xml"
    if (!(Test-Path $xmlfile)) {
        return -1
    }
    else {
        try {
            $doc = [xml](Get-Content -Path $xmlfile)
            return $doc.notes.note | ?{$_.otype -eq $ObjectType -and $_.oid -eq $ObjectID}
        }
        catch {
            return ""
        }
    }
}

function Show-NoteAttachments {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ObjectType,
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ObjectName,
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ReturnBaseLink,
        [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $ReturnBaseSearchField = ""
    )
    $notes = Get-NoteAttachments -ObjectType $ObjectType -ObjectID $ObjectName
    $output = "<table id=table1>"
    $output += "<tr><th style=`"width:200px`">Date</th>"
    $output += "<th style=`"width:200px`">Author</th><th>Comment</th></tr>"
    if ($notes.count -gt 0) {
        foreach ($note in $notes) {
            $output += "<tr><td>$($note.date)</td>"
            $output += "<td>$($note.author)</td>"
            $output += "<td>$($note.comment)</td></tr>"
        }
    }
    else {
        $output += "<tr><td colspan='3'>No Notes were found</td></tr>"
    }
    $output += "</table><br/>"
    $output += "<form name='form1' id='form1' method='post' action='attachnote.ps1'>"
    $output += "<input type='hidden' name='otype' id='otype' value='$ObjectType' />"
    $output += "<input type='hidden' name='oid' id='oid' value='$ObjectName' />"
    $output += "<input type='submit' class='button1' name='ok' id='ok' value='Add Note' />"
    $output += "</form>"
    return $output
}

$LastLoadTime = Get-Date