$Global:SkToolsLibADS = "1.0.0"

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
