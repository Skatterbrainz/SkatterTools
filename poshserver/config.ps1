# Copyright (C) 2014 Yusuf Ozturk
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

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

# --------------------------------------------------

# SkatterTools Site Configuration

$Global:SkToolsVersion = "1812.27.03"

$configFile = Join-Path -Path $HomeDirectory -ChildPath "config.txt"
if (!(Test-Path $configFile)) {
    Write-Warning "Config.txt was not found. Shit just got real."
    break
}
$cdata = Get-Content $configFile | Where-Object{$_ -notlike ';*'}
foreach ($line in $cdata) {
    $varset = $line -split '='
    if ($varset.Count -gt 1) {
        Set-Variable -Name $varset[0] -Value $($varset[1]).Trim() -Scope Global | Out-Null
    }
}

foreach ($m in @('sqlserver','dbatools','carbon')) {
    if (Get-Module -Name $m) {
        #Write-Host "importing powershell module: $m" -ForegroundColor Cyan
        Import-Module -Name $m
    }
}

<#
if ($Global:SkToolsLoaded -ne 1) {
    try {
        Get-ChildItem (Join-Path -Path $HomeDirectory -ChildPath "lib") -Filter "*.ps1" -ErrorAction Stop | ForEach-Object { . $_.FullName }
        $Global:SkToolsLoaded = 1
        $Global:LastLoadTime = Get-Date
    }
    catch {
        Write-Error "OMFG - something smells really bad in here?!"
        break
    }
}
#>

#---------------------------------------------------------------------

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
    try {
        $connection = New-Object -ComObject "ADODB.Connection"
        $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
        $connection.Open($connString);
        Write-Output $connection
    }
    catch {
        Write-Error "get-cmadoconnection-error: $($Error[0].Exception.Message)"
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

function Get-SqlRowCount {
    [CmdletBinding()]
    param (
        $ServerName,
        $Database,
        $Query,
        $ReturnColumn = "QTY"
    )
    $output = 0
    try {
        $connection = New-Object -ComObject "ADODB.Connection"
        $connString = "Data Source=$ServerName;Initial Catalog=$Database;Integrated Security=SSPI;Provider=SQLOLEDB"
        $connection.Open($connString);
        Write-Verbose "connection opened"
        $IsOpen = $True
        $rs = New-Object -ComObject "ADODB.RecordSet"
        $rs.Open($query, $connection)
        Write-Verbose "recordset opened"
        if (!$rs.BOF -and !$rs.EOF) {
            Write-Verbose "more than 0 rows returned"
            $output = $rs.Fields($ReturnColumn).Value
        }
        else {
            Write-Verbose "no rows returned"
        }
        [void]$rs.Close()
        Write-Verbose "recordset closed"
    }
    catch {
        Write-Host $connstring
        Write-Host "xxx = $xxx"
        $output = -1
    }
    finally {
        if ($IsOpen -eq $True) {
            Write-Verbose "connection closed"
            [void]$connection.Close()
        }
        Write-Output $output
    }
}

function Get-SkDbQuery {
    param (
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $QueryText,
            [switch] $Extend
    )
    $output = $QueryText
    if (![string]::IsNullOrEmpty($SearchValue)) {
        if ($Extend) {
            $opword = 'and'
        }
        else {
            $opword = 'where'
        }
        switch ($SearchType) {
            'like' {
                $output += " $opword ($SearchField like '%$SearchValue%')"
                break;
            }
            'begins' {
                $output += " $opword ($SearchField like '$SearchValue%')"
                break;
            }
            'ends' {
                $output += " $opword ($SearchField like '%$SearchValue')"
                break;
            }
            default {
                $output += " $opword ($SearchField = '$SearchValue')"
                break;
            }
        }
    }
    if (![string]::IsNullOrEmpty($SortField)) {
        $output += " order by $SortField $SortOrder"
    }
    Write-Output $output
}

function Get-SkQueryTable {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $QueryFile,
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $PageLink,
        [parameter(Mandatory=$False)]
        [string[]] $Columns = "",
        [parameter(Mandatory=$False)]
        [string] $Sorting = ""
    )
    $output = ""
    try {
        $qpath  = $(Join-Path -Path $PSScriptRoot -ChildPath "queries")
        $qfile  = $(Join-Path -Path $qpath -ChildPath "$QueryFile")
        $result = @(Invoke-Sqlcmd -ServerInstance $CmDbHost -Database "CM_$CmSiteCode" -InputFile $qfile)
        if (![string]::IsNullOrEmpty($Script:SearchField)) {
            switch ($Script:SearchType) {
                'like' {
                    $result = $result | Where-Object {$_."$Script:SearchField" -like "*$Script:SearchValue*"}
                    break;
                }
                'begins' {
                    $result = $result | Where-Object {$_."$Script:SearchField" -like "$Script:SearchValue*"}
                    break;
                }
                'ends' {
                    $result = $result | Where-Object {$_."$Script:SearchField" -like "*$Script:SearchValue"}
                    break;
                }
                default {
                    $result = $result | Where-Object {$_."$Script:SearchField" -eq $Script:SearchValue}
                }
            }
            $Script:PageCaption += " ($Caption)"
            $Script:IsFiltered = $True
        }
        if ($Sorting -ne "") {
            $result = $result | Sort-Object $Sorting
        }
        elseif ($Script:SortField -ne "") {
            if ($Script:SortOrder -ne "asc") {
                $result = $result | Sort-Object $Script:SortField -Descending
            }
            else {
                $result = $result | Sort-Object $Script:SortField 
            }
        }
        if ($Columns -ne "") {
            $result = $result | Select $Columns
        }
        $colcount = $Columns.Count
        $output = "<table id=table1><tr>"
        $columns | %{ $output += "<th>$_</th>" }
        $output += "</tr>"
        $rowcount = 0
        foreach ($rs in $result) {
            $output += "<tr>"
            for ($i = 0; $i -lt $rs.psobject.Properties.Name.Count; $i++) {
                $fn = $rs.psobject.Properties.Name[$i]
                $fv = $rs.psobject.Properties.Value[$i]
                $align = ""
                switch ($fn) {
                    'Name' {
                        $itemname = $fv
                        $fvx = "<a href=`"cmdevice.ps1?f=$fn&v=$fv&x=equals&n=$fv`" title=`"Details for $fv`">$fv</a>"
                        break;
                    }
                    'OSName' {
                        $fvx = "<a href=`"cmdevices.ps1?f=$fn&v=$fv&x=equals&n=$fv`" title=`"Filter on $fv`">$fv</a>"
                        break;
                    }
                    'ADSiteName' {
                        $fvx = "<a href=`"cmdevices.ps1?f=$fn&v=$fv&x=equals&n=$fv`" title=`"Filter on $fv`">$fv</a>"
                        break;
                    }
                    'CollectionName' {
                        $fvx = $fv
                        $collname = $fv
                        break;
                    }
                    'CollectionID' {
                        $fvx = "<a href=`"cmcollection.ps1?f=$fn&v=$fv&t=$CollectionType&n=$collname`" title=`"Details`">$fv</a>"
                        break;
                    }
                    'LimitedTo' {
                        $fvx = "<a href=`"cmcollection.ps1?f=$fn&v=$fv&t=$CollectionType`" title=`"Details`">$fv</a>"
                        $align = 'center'
                        break;
                    }
                    'Members' {
                        $fvx = $fv
                        $align = 'center'
                        break;
                    }
                    'Variables' {
                        $fvx = $fv
                        $align = 'center'
                        break;
                    }
                    'Type' {
                        $fvx = $fv
                        $align = 'center'
                        break;
                    }
                    'UserName' {
                        $fvx = $fv
                        break;
                    }
                    'Manufacturer' {
                        $fvx = "<a href=`"cmdevices.ps1?f=$fn&v=$fv&x=equals&n=$fv`" title=`"Filter on $fv`">$fv</a>"
                        break;
                    }
                    'Model' {
                        $fvx = "<a href=`"cmdevices.ps1?f=$fn&v=$fv&x=equals&n=$fv`" title=`"Filter on $fv`">$fv</a>"
                        break;
                    }
                    default {
                        $fvx = $fv
                        break;
                    }
                } # switch
                if ($align -ne "") {
                    $output += "<td style=`"text-align`: $align`">$fvx</td>"
                }
                else {
                    $output += "<td>$fvx</td>"
                }
            } # for
            $output += "</tr>"
            $rowcount++
        } # foreach
        $output += "<tr><td colspan=$colcount class=lastrow>$rowcount items"
        if ($Script:IsFiltered -eq $True) {
            $output += " - <a href=`"$PageLink`" title=`"Show All`">Show All</a>"
        }
        $output += "</td></tr></table>"
    }
    catch {
        $output = "<table id=table2><tr><td>No matching items found"
        $output += "<br/>queryfile: $qfile"
        $output += "<br/>SearchField: $Script:SearchField"
        $output += "<br/>SearchValue: $Script:SearchValue"
        $output += "<br/>SearchType: $Script:SearchType"
        $output += "<br/>SortField: $Script:SortField"
        $output += "</td></tr></table>"
    }
    finally {
        Write-Output $output
    }
}

function Get-SkQueryTable2 {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $QueryFile,
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $PageLink,
        [parameter(Mandatory=$False)]
        [string[]] $Columns = ""
    )
    $output = ""
    try {
        $qpath  = $(Join-Path -Path $PSScriptRoot -ChildPath "queries")
        $qfile  = $(Join-Path -Path $qpath -ChildPath "$QueryFile")
        $result = @(Invoke-Sqlcmd -ServerInstance $CmDbHost -Database "CM_$CmSiteCode" -InputFile $qfile)
        if ($Columns -ne "") {
            $result = $result | Select $Columns
        }
        $result = $result | Where-Object {$_."$Script:SearchField" -eq $Script:SearchValue}
        $Script:IsFiltered = $True

        $output   = "<table id=table2>"
        foreach ($rs in $result) {
            for ($i = 0; $i -lt $rs.psobject.Properties.Name.Count; $i++) {
                $fn = $rs.psobject.Properties.Name[$i]
                $fv = $rs.psobject.Properties.Value[$i]
                switch ($fn) {
                    'Name' {
                        $fvx = "<a href=`"cmdevice.ps1?f=$fn&v=$fv&x=equals&n=$fv`" title=`"Details for $fv`">$fv</a>"
                        break;
                    }
                    'OSName' {
                        $fvx = "<a href=`"cmdevices.ps1?f=$fn&v=$fv&x=equals&n=$fv`" title=`"Filter on $fv`">$fv</a>"
                        break;
                    }
                    'ADSiteName' {
                        $fvx = "<a href=`"cmdevices.ps1?f=$fn&v=$fv&x=equals&n=$fv`" title=`"Filter on $fv`">$fv</a>"
                        break;
                    }
                    'CollectionID' {
                        $fvx = "<a href=`"cmcollection.ps1?f=$fn&v=$fv&t=$CollectionType&n=$cn`" title=`"Details`">$fv</a>"
                        break;
                    }
                    'LimitedTo' {
                        $fvx = "<a href=`"cmcollection.ps1?f=$fn&v=$fv&t=$CollectionType`" title=`"Details`">$fv</a>"
                        break;
                    }
                    'Members' {
                        $fvx = $fv
                        break;
                    }
                    'Variables' {
                        $fvx = $fv
                        break;
                    }
                    'Type' {
                        $fvx = $fv
                        break;
                    }
                    'UserName' {
                        $fvx = $fv
                        break;
                    }
                    'Manufacturer' {
                        $fvx = "<a href=`"cmdevices.ps1?f=$fn&v=$fv&x=equals&n=$fv`" title=`"Filter on $fv`">$fv</a>"
                        break;
                    }
                    'Model' {
                        $fvx = "<a href=`"cmdevices.ps1?f=$fn&v=$fv&x=equals&n=$fv`" title=`"Filter on $fv`">$fv</a>"
                        break;
                    }
                    default {
                        $fvx = $fv
                        break;
                    }
                }
                $output += "<tr><td style=`"width:200px`">$fn</td><td>$fvx</td></tr>"
            }
        }
        $output += "</table>"
    }
    catch {
        $output = "<table id=table2><tr><td>No matching items found<br/>queryfile: $qfile</td></tr></table>"
    }
    finally {
        Write-Output $output
    }
}

$Global:SkToolsLibDB = "1812.27.09"
#---------------------------------------------------------------------

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
    [void]$as.PropertiesToLoad.Add('cn')
    [void]$as.PropertiesToLoad.Add('sAMAccountName')
    [void]$as.PropertiesToLoad.Add('lastlogonTimeStamp')
    [void]$as.PropertiesToLoad.Add('whenCreated')
    [void]$as.PropertiesToLoad.Add('department')
    [void]$as.PropertiesToLoad.Add('title')
    [void]$as.PropertiesToLoad.Add('mail')
    [void]$as.PropertiesToLoad.Add('manager')
    [void]$as.PropertiesToLoad.Add('employeeID')
    [void]$as.PropertiesToLoad.Add('displayName')
    [void]$as.PropertiesToLoad.Add('distinguishedName')
    [void]$as.PropertiesToLoad.Add('memberof')
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
            DN          = ($item.Properties.item('distinguishedName') | Out-String).Trim()
            EmployeeID  = ($item.Properties.item('employeeid') | Out-String).Trim()
            Email       = ($item.Properties.item('mail') | Out-String).Trim()
            Manager     = ($item.Properties.item('manager') | Out-String).Trim()
            Groups      = $item.Properties.item('memberof')
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
    [void]$as.PropertiesToLoad.Add('cn')
    [void]$as.PropertiesToLoad.Add('lastlogonTimeStamp')
    [void]$as.PropertiesToLoad.Add('whenCreated')
    [void]$as.PropertiesToLoad.Add('operatingSystem')
    [void]$as.PropertiesToLoad.Add('operatingSystemVersion')
    [void]$as.PropertiesToLoad.Add('distinguishedName')
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
            $uname   = $($user.samaccountname | out-string).Trim()
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

function Get-ADsUserGroups {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName
    )
    try {
        $user = Get-ADsUsers | Where-Object {$_.UserName -eq "$UserName"}
        $groups = $user.Groups
        $groups | ForEach-Object {
            $Searcher = [adsisearcher]"(distinguishedname=$_)"
            $group = $searcher.FindOne().Properties
            $gprops = [ordered]@{
                Name = [string]$group.name
                DN   = [string]$group.distinguishedname
            }
            New-Object PSObject -Property $gprops
        }
    }
    catch {}
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

function Get-ADsUserPwdNoExpire {
    param ()
    # https://richardspowershellblog.wordpress.com/2012/02/08/finding-user-accounts-with-passwords-set-to-never-expire/
    $root = [ADSI]""            
    $search = [adsisearcher]$root            
    $search.Filter = "(&(objectclass=user)(objectcategory=user)(useraccountcontrol:1.2.840.113556.1.4.803:=65536))"            
    $search.SizeLimit = 3000            
    $results = $search.FindAll()            
    foreach ($result in $results){            
        $result.Properties |             
        Select @{N="Name"; E={$_.name}}, @{N="DistinguishedName"; E={$_.distinguishedname}}            
    }
}

function Get-ADsUserDisabled {
    param()
    # https://blogs.msmvps.com/richardsiddaway/2012/02/04/find-user-accounts-that-are-disabled/
    $root = [ADSI]""            
    $search = [adsisearcher]$root            
    $search.Filter = "(&(objectclass=user)(objectcategory=user)(useraccountcontrol:1.2.840.113556.1.4.803:=2))"            
    $search.SizeLimit = 3000            
    $results = $search.FindAll()            
    foreach ($result in $results){            
        $result.Properties |             
        select @{N="Name"; E={$_.name}}, @{N="DistinguishedName"; E={$_.distinguishedname}}            
    }
}

function Get-ADsOUTree {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$False)]
        [string] $Path = ""
    )
    try {
        $info = ([adsisearcher]"objectclass=organizationalunit")
        $info.PropertiesToLoad.AddRange("CanonicalName")
        $output = $info.findall().properties.canonicalname
        if (![string]::IsNullOrEmpty($Path)) {
            $output = $output | ?{$_ -like "$Path*"}
            if ($output.count -gt 1) {
                $output = $output[1..($output.length-1)]
            }
        }
        foreach ($ou in $output) {
            $oulist = $ou -split '/'
            $props = [ordered]@{
                FullPath  = $ou 
                ChildPath = $oulist[1..$($oulist.length -1)]
                Name      = $oulist[$($oulist.length -1)]
            }
            New-Object PSObject -Property $props
        }
        #return $output
    }
    catch {
        throw $Error[0].Exception.Message
    }
}

function Get-AdOuObjects {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ou,
        [parameter(Mandatory=$False)]
        [string] $ObjectType = ""
    )
    $root = [ADSI]"LDAP://$ou"
    $search = [adsisearcher]$root
    if ($ObjectType -ne "") {
        $search.Filter = "(&(objectclass=$ObjectType)(objectcategory=$ObjectType))"
    }
    $search.SizeLimit = 3000
    $results = $search.FindAll()
    foreach ($result in $results) {
        $props = $result.Properties
        foreach ($p in $props) {
            $itemName = ($p.name | Out-String).Trim()
            $objName  = ($p.samaccountname | Out-String).Trim()
            $itemPath = ($p.distinguishedname | Out-String).Trim()
            $itemPth  = $itemPath -replace "CN=$itemName,", ''
            $itemType = (($p.objectcategory -split ',')[0]) -replace 'CN=', ''
            $output = [ordered]@{
                Name = $itemName
                ObjName = $objName
                DN   = $itemPath
                Path = $itemPth
                Type = $itemType
            }
            New-Object PSObject -Property $output
        }
    }
}

$Global:SkToolsLibADS = "1812.27.01"
#---------------------------------------------------------------------

function Get-CmCollectionsList {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$False)]
        [ValidateSet('direct','query','all')]
        [string] $MembershipType = 'all'
    )
    switch ($MembershipType) {
        'all' {
            $query = 'SELECT DISTINCT dbo.v_Collection.CollectionID, dbo.v_Collection.Name, dbo.v_Collection.CollectionType 
            FROM dbo.v_Collection ORDER BY dbo.v_Collection.Name'
            break;
        }
        'query' {
            $query = 'SELECT DISTINCT dbo.v_CollectionRuleQuery.CollectionID, dbo.v_Collection.Name, dbo.v_Collection.CollectionType 
            FROM dbo.v_CollectionRuleQuery INNER JOIN dbo.v_Collection ON 
            dbo.v_CollectionRuleQuery.CollectionID = dbo.v_Collection.CollectionID 
            ORDER BY dbo.v_Collection.Name'
            break;
        }
        'direct' {
            $query = 'SELECT DISTINCT 
            dbo.v_Collection.CollectionID, dbo.v_Collection.Name, dbo.v_Collection.CollectionType 
            FROM dbo.v_Collection WHERE CollectionID NOT IN (
            SELECT DISTINCT CollectionID from dbo.v_CollectionRuleQuery) 
            ORDER BY dbo.v_Collection.Name'
            break;
        }
    }
    Write-Verbose "query: $query"
    try {
        $connection = New-Object -ComObject "ADODB.Connection"
        $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
        $connection.Open($connString);
        $IsOpen = $True
        Write-Verbose "connection is opened"
        $rs = New-Object -ComObject "ADODB.RecordSet"
        $rs.Open($query, $connection)
        Write-Verbose "recordset opened"
        while (!$rs.EOF) {
            Write-Verbose "reading recordset row..."
            $props = [ordered]@{
                CollectionID   = $($rs.Fields("CollectionID").value | Out-String).Trim()
                CollectionName = $($rs.Fields("Name").value | Out-String).Trim()
                CollectionType = $($rs.Fields("CollectionType").value | Out-String).Trim()
            }
            New-Object PSObject -Property $props
            [void]$rs.MoveNext()
        }
        Write-Verbose "closing recordset"
        [void]$rs.Close()
    }
    catch {
        if ($IsOpen -eq $True) { [void]$connection.Close() }
        throw "Error: $($Error[0].Exception.Message)"
    }
    finally {
        Write-Verbose "closing connection"
        if ($IsOpen -eq $True) { [void]$connection.Close() }
    }
}

function Get-CmResourcesList {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True)]
        [ValidateSet('device','user')]
        [string] $ResourceType,
        [parameter(Mandatory=$False)]
        [string] $ExcludeCollectionID = ""
    )
    switch ($ResourceType) {
        'device' {
            $query = "SELECT ResourceID, Name FROM v_ClientMachines WHERE (v_ClientMachines.IsClient = 1)"
            if ($ExcludeCollectionID -ne "") {
                $query += " AND (ResourceID NOT IN (
                    SELECT DISTINCT ResourceID 
                    FROM v_CollectionRuleDirect 
                    WHERE (CollectionID = '$ExcludeCollectionID')))"
            }
            $query += " ORDER BY Name"
            break;
        }
        'user' {
            $query = "SELECT ResourceID, User_Name0 as ResourceName FROM v_R_User"
            if ($ExcludeCollectionID -ne "") {
                $query += " WHERE ResourceID NOT IN (
	                SELECT DISTINCT ResourceID
	                FROM v_CollectionRuleDirect
	                WHERE (CollectionID = '$ExcludeCollectionID'))"
            }
            $query += " ORDER BY ResourceName"
            break;
        }
    } # switch
    try {
        $connection = New-Object -ComObject "ADODB.Connection"
        $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
        $connection.Open($connString);
        $IsOpen = $True
        Write-Verbose "connection is opened"
        $rs = New-Object -ComObject "ADODB.RecordSet"
        $rs.Open($query, $connection)
        Write-Verbose "recordset opened"
        [void]$rs.MoveFirst()
        while (!$rs.EOF) {
            Write-Verbose "reading recordset row..."
            $props = [ordered]@{
                ResourceID   = $($rs.Fields("ResourceID").value | Out-String).Trim()
                ResourceName = $($rs.Fields("Name").value | Out-String).Trim()
            }
            New-Object PSObject -Property $props
            [void]$rs.MoveNext()
        }
        Write-Verbose "closing recordset"
        [void]$rs.Close()
    }
    catch {
        if ($IsOpen -eq $True) { [void]$connection.Close() }
        throw "Error: $($Error[0].Exception.Message)"
    }
    finally {
        Write-Verbose "closing connection"
        if ($IsOpen -eq $True) { [void]$connection.Close() }
    }
}

function Get-CmPackageTypeName {
    param (
        [parameter(Mandatory=$True)]
        [int] $PkgType
    )
    switch ($PkgType) {
          0 { return 'Software Distribution Package'; break; }
          3 { return 'Driver Package'; break; }
          4 { return 'Task Sequence Package'; break; }
          5 { return 'Software Update Package'; break; }
          6 { return 'Device Settings Package'; break; }
          7 { return 'Virtual Package'; break; }
          8 { return 'Application'; break; }
        257 { return 'OS Image Package'; break; }
        258 { return 'Boot Image Package'; break; }
        259 { return 'OS Upgrade Package'; break; }
        260 { return 'VHD Package'; break; }
    }
}

$Global:SkToolsLibCM = "1812.27.01"
#---------------------------------------------------------------------

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
        $xlink = $($BaseLink -split '\?')[0]
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

$Global:SkToolsLibLayout = "1812.27.03"
#---------------------------------------------------------------------

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

$Global:SkToolsLibUtil = "1812.27.01"
