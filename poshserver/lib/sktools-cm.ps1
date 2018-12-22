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

$Global:SkToolsLibCM = "1812.22.03"
