$Global:SkToolsLibDB = "1.0.0"

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