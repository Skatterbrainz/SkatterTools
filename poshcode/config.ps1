# Copyright (C) 2014 Yusuf Ozturk
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

# PoSH Server Configuration

# Default Document
$DefaultDocument = "index.ps1"

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

$STVersion  = "1812.04"
$CmDBHost   = "cm02.contoso.local"
$CmSiteCode = "P02"
$STTheme    = "stdark.css" # "stlight.css"

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
    <#
    .DESCRIPTION
        Returns AD LDAP information for User accounts
    .PARAMETER UserName
        Optional: name of user to query. Default is all users
    .EXAMPLE
        $x = .\Get-ADsUsers.ps1
    .EXAMPLE
        $x = .\Get-ADsUsers.ps1 -UserName "jsmith"
    .EXAMPLE
        $staff = .Get-ADsUsers.ps1 | ?{$_.Manager -eq 'CN=John Smith,OU=Users,OU=CORP,DC=contoso,DC=local'}
    .NOTES
        1.0.0 - DS - Initial release
        1.0.1 - DS - Added UserName parameter for focused search
    #>

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

function Get-ADsGroupMembers {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $GroupName = ""
    )
    if ([string]::IsNullOrEmpty($GroupName)) {
        $strFilter = "(objectCategory=group)"
    }
    else {
        $strFilter = "(&(objectCategory=group)(sAMAccountName=$GroupName))"
    }
    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objSearcher.Filter = $strFilter
    $objSearcher.PageSize = 1000
    $objPath = $objSearcher.FindAll()
    foreach ($objItem in $objPath) {
        try {
            $objUser = $objItem.GetDirectoryEntry()
            $group   = [adsi]$($objUser.distinguishedName).ToString()
            $Group.Member | ForEach-Object {
                $Searcher = [adsisearcher]"(distinguishedname=$_)"
                $searcher.FindOne().Properties
            }
        }
        catch {
            Write-Error $_.Exception.Message
        }
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
