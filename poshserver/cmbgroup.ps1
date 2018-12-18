$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "like"
$SortField   = Get-PageParam -TagName 's' -Default "name"
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Boundary Group: $CustomName"
$PageCaption = "CM Boundary Group: $CustomName"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

switch ($TabSelected) {
    'General' {
        try {
            $query = "SELECT 
                [Name],
                DefaultSiteCode,
                GroupID,
                GroupGUID,
                [Description],
                Flags,
                CreatedBy,
                CreatedOn,
                ModifiedBy,
                ModifiedOn,
                MemberCount,
                SiteSystemCount,
                Shared 
                FROM vSMS_BoundaryGroup"
            $query = Get-SkDbQuery -QueryText $query
            if (![string]::IsNullOrEmpty($SearchValue)) {$IsFiltered = $True}

            $connection = New-Object -ComObject "ADODB.Connection"
            $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
            $connection.Open($connString);
            $IsOpen = $true
            $rs = New-Object -ComObject "ADODB.RecordSet"
            $rowcount = 0
            $rs.Open($query, $connection)
            if ($rs.BOF -and $rs.EOF) {
                $content = "<table id=table2><tr><td>No records found!</td></tr></table>"
            }
            else {
                $colcount = $rs.Fields.Count
                $content = "<table id=table2><tr>"
                for ($i = 0; $i -lt $colcount; $i++) {
                    $fn = $rs.Fields($i).Name
                    $fv = $rs.Fields($i).Value
                    $content += "<tr><td style=`"width:200px`">$fn</td><td>$fv</td></tr>"
                }
                $content += "</table>"
                [void]$rs.Close()
            }
        }
        catch {
            $content += "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
        }
        finally {
            if ($IsOpen -eq $true) {
                [void]$connection.Close()
            }
        }
        break;
    }
    'Boundaries' {
        try {
            $query = 'SELECT 
                dbo.vSMS_Boundary.DisplayName, 
                dbo.vSMS_Boundary.BoundaryID, 
                dbo.vSMS_Boundary.Value, 
                case 
                    when BoundaryType = 0 Then ''IP Subnet''
                    when BoundaryType = 1 Then ''Active Directory Site''
                    when BoundaryType = 2 Then ''IPv6 Prefix''
                    when BoundaryType = 3 Then ''IP Address Range''
                    else ''UnKnown'' end as BoundaryType,
                case
                    when BoundaryFlags = 0 then ''Fast''
                    when BoundaryFlags = 1 then ''Slow''
                    end as BoundaryFlags, 
                dbo.vSMS_Boundary.CreatedBy, 
                dbo.vSMS_Boundary.CreatedOn, 
                dbo.vSMS_Boundary.ModifiedBy, 
                dbo.vSMS_Boundary.ModifiedOn, 
                dbo.vSMS_BoundaryGroupMembers.GroupID
                FROM dbo.vSMS_Boundary INNER JOIN
                dbo.vSMS_BoundaryGroupMembers ON 
                dbo.vSMS_Boundary.BoundaryID = dbo.vSMS_BoundaryGroupMembers.BoundaryID
                where (GroupID = '+$SearchValue+')'
            $connection = New-Object -ComObject "ADODB.Connection"
            $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
            $connection.Open($connString);
            $IsOpen = $true
            $rs = New-Object -ComObject "ADODB.RecordSet"
            $rowcount = 0
            $rs.Open($query, $connection)
            if ($rs.BOF -and $rs.EOF) {
                $content = "<table id=table2><tr><td>No records found!</td></tr></table>"
            }
            else {
                $colcount = $rs.Fields.Count
                $content = "<table id=table1><tr>"
                for ($i = 0; $i -lt $colcount; $i++) {
                    $fn = $rs.Fields($i).Name
                    $content += "<th>$fn</th>"
                }
                $content += "</tr>"
                [void]$rs.MoveFirst()
                while (!$rs.EOF) {
                    $content += "<tr>"
                    for ($i = 0; $i -lt $colcount; $i++) {
                        $fn = $rs.Fields($i).Name
                        $fv = $rs.Fields($i).Value
                        $content += "<td>$fv</td>"
                    }
                    $content += "</tr>"
                    [void]$rs.MoveNext()
                    $rowcount++
                }
                $content += "<tr><td colspan=`"$($colcount)`" class=lastrow>$rowcount items returned</td></tr>"
                $content += "</table>"
                [void]$rs.Close()
            }
        }
        catch {
            $content += "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
        }
        finally {
            if ($IsOpen -eq $true) {
                [void]$connection.Close()
            }
        }
        break;
    }
}

if ($SkNotesEnable -eq 'true') {
    $tabs = @('General','Boundaries','Systems','Notes')
}
else {
    $tabs = @('General','Boundaries','Systems')
}
$tabset = New-MenuTabSet2 -MenuTabs $tabs -BaseLink "cmbgroup.ps1"
#$content += Write-DetailInfo -PageRef "___.ps1" -Mode $Detailed

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

$tabset
$content

</body>
</html>
"@