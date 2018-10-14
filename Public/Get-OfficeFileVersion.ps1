<#
.DESCRIPTION
    Query WINWORD.exe on remote computers to confirm Office installed version
.PARAMETER ServerName
    Name of ConfigMgr SQL Server host
.PARAMETER SiteCode
    ConfigMgr Site Code
.PARAMETER InputFile
    File with computer names
.PARAMETER CollectionID
    One or more ConfigMgr Collection ID values
.NOTES
    If InputFile is not empty, ServerName and SiteCode are ignored
    1.0.0 - DS - Initial release
    1.0.1 - JT - Updated to query x64 and x86 remote install paths
.EXAMPLE
    .\Get-OfficeFileVersion.ps1 -InputFile "computers.txt"
#>
[CmdletBinding()]
param (
    [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName = "hcidalas37.hci.pvt",
    [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode = "HHQ",
    [parameter(Mandatory=$False)]
        [string] $InputFile = "",
    [parameter(Mandatory=$False)]
        [string[]] $CollectionID = ("HHQ0015E","HHQ00168","HHQ0014C")
)

function Get-OfficeFileVersion {
    param (
        [string] $ComputerName,
        [string] $CollectionName
    )
    Write-Host $ComputerName -ForegroundColor Cyan
    $wdpaths = "\\$ComputerName\C`$\Program Files\Microsoft Office\root\Office16\WINWORD.EXE","\\$ComputerName\C`$\Program Files (x86)\Microsoft Office\Root\Office16\WINWORD.EXE"
    if ((Test-NetConnection $ComputerName -WarningAction SilentlyContinue).PingSucceeded) {
        Write-Verbose "$ComputerName is ONLINE"
        $online = $True
        foreach ($wdpath in $wdpaths) {
            try {
                if (Test-Path -Path $wdpath -PathType Leaf) {
                    $f = Get-Item -Path $wdpath -ErrorAction SilentlyContinue
                    $wdver = $f.VersionInfo.ProductVersion
                    Write-Verbose "word version = $wdver"
                    break
                }
                else {
                    $wdver = 'NOTFOUND'
                }
            }
            catch {
                $wdver = 'NOTFOUND'
                Write-Verbose "word version = none"
            }
        }
    }
    else {
        $wdver  = $null
        $online = $False
        Write-Verbose "$ComputerName is offline"
    }
    $data = [ordered]@{
        Computer    = $ComputerName
        Collection  = $CollectionName
        IsOnLine    = $online
        IsInstalled = $wdver
        RunDate     = $(Get-Date).ToShortDateString()+' '+$(Get-Date).ToLongTimeString()
    }
    New-Object PSObject -Property $data
}

if (![string]::IsNullOrEmpty($InputFile)) {
    if (!(Test-Path $InputFile)) {
        Write-Warning "$InputFile not found!"
        break
    }
    Write-Host "reading input file: $InputFile"
    $Computers = Get-Content -Path $InputFile
    $ctotal = $Computers.Length 
    $ccount = 0
    foreach ($computer in $Computers) {
        Write-Progress -Activity "$ccount of $ctotal" -Status "Querying: $Computer" -PercentComplete $(($ccount/$ctotal)*100)
        Get-OfficeFileVersion -ComputerName $Computer -CollectionName "Office 365 ProPlus"
        $ccount++
    }
}
else {
    $DatabaseName = "CM_$SiteCode"
    $QueryTimeout = 120
    $ConnectionTimeout = 30
    $conn = New-Object System.Data.SqlClient.SQLConnection
    $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
    $conn.ConnectionString = $ConnectionString
    try {
        $conn.Open()
        Write-Verbose "connection opened successfully"
    }
    catch {
        Write-Error $_.Exception.Message
        break
    }

    $ccount = 1
    $ctotal = $CollectionID.Count

    foreach ($CollID in $CollectionID) {
        $dcount = 1
        $query  = @"
SELECT DISTINCT 
    dbo.v_Collection.CollectionID, 
    dbo.v_Collection.Name as CollectionName, 
    dbo.v_CollectionRuleDirect.RuleName as DeviceName, 
    dbo.v_CollectionRuleDirect.ResourceID
FROM dbo.v_CollectionRuleDirect INNER JOIN
    dbo.v_Collection ON dbo.v_CollectionRuleDirect.CollectionID = dbo.v_Collection.CollectionID
WHERE 
    (dbo.v_CollectionRuleDirect.CollectionID = `'$CollID`')
ORDER BY DeviceName
"@
        $cmd = New-Object System.Data.SqlClient.SqlCommand($query,$conn)
        $cmd.CommandTimeout = $QueryTimeout
        $ds = New-Object System.Data.DataSet
        $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        try {
            [void]$da.Fill($ds)
        }
        catch {
            Write-Error $_.Exception.Message 
            $conn.Close()
            break
        }
        $rowcount = $($ds.Tables).Rows.Count
        Write-Host "$rowcount rows returned" -ForegroundColor Green
        if ($rowcount -gt 0) {
            Write-Verbose "collectionID: $CollID"
            foreach ($row in $($ds.Tables).Rows) {
                $DeviceName = $row.DeviceName
                $CollName   = $row.CollectionName
                Write-Progress -Activity "Collection: $CollID - $ccount of $ctotal" -Status "Querying: $DeviceName" -PercentComplete $(($dcount/$rowcount)*100)
                Get-OfficeFileVersion -ComputerName $DeviceName -CollectionName $CollName
                $dcount++
            } # foreach
        } # if 
        $ccount++
    }
} # foreach

Write-Verbose "closing database connection"
$conn.Close()
