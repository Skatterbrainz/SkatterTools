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

$Global:SkToolsLibDB = "1812.18.03"
