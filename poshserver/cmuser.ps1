$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default ""
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""

$PageTitle   = "CM User: $CustomName"
$PageCaption = "CM User: $CustomName"

$content = ""
$tabset  = ""

switch ($TabSelected) {
    'General' {
        $query = "SELECT TOP 1  
        dbo.v_R_User.Full_User_Name0 AS FullName, 
        dbo.v_R_User.Unique_User_Name0 AS UserName, 
        dbo.v_R_User.Windows_NT_Domain0 AS UserDomain, 
        dbo.v_R_User.ResourceID, 
        dbo.v_R_User.department, 
        dbo.v_R_User.title, 
        dbo.v_R_User.Mail0 as Email, 
        dbo.v_R_User.User_Principal_Name0 AS UPN, 
        dbo.v_R_User.Distinguished_Name0 AS UserDN, 
        dbo.v_R_User.SID0 AS SID, 
        u2.Unique_User_Name0 AS Mgr 
        FROM 
        dbo.v_R_User LEFT OUTER JOIN 
        dbo.v_R_User AS u2 ON dbo.v_R_User.manager = u2.Distinguished_Name0 
        WHERE (dbo.v_R_User.ResourceID = $SearchValue)"

        try {
            $connection = New-Object -ComObject "ADODB.Connection"
            $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
            $connection.Open($connString);
            $IsOpen = $True
            $rs = New-Object -ComObject "ADODB.RecordSet"
            $rs.Open($query, $connection)
            $rowcount = 0
            $rowcount += $rs.RecordCount
            $colcount = $rs.Fields.Count
            $rs.MoveFirst()
    
            $content = '<table id=table2><tr>'
            for ($i = 0; $i -lt $colcount; $i++) {
                $fn = $rs.Fields($i).Name
                $fv = $rs.Fields($i).Value
                $content += '<tr>'
                $content += '<td style="width:200px;background-color:#435168">'+$fn+'</td>'
                switch ($fn) {
                    'Department' {
                        if (![string]::IsNullOrEmpty($fv)) {
                            $fvx = '<a href="cmusers.ps1?f=Department&v='+$fv+'" title="Filter">'+$fv+'</a>'
                        }
                        else {
                            $fvx = ""
                        }
                        $content += '<td>'+$fvx+'</td>'
                        break;
                    }
                    'Title' {
                        if (![string]::IsNullOrEmpty($fv)) {
                            $fvx = '<a href="cmusers.ps1?f=Title&v='+$fv+'" title="Filter">'+$fv+'</a>'
                        }
                        else {
                            $fvx = ""
                        }
                        $content += '<td>'+$fvx+'</td>'
                        break;
                    }
                    default {
                        $content += '<td>'+$fv+'</td>'
                        break;
                    }
                }
                $content += '</tr>'
            }
            $content += '</table>'
        }
        catch {
            $content += "<br/>Error: $($Error[0].Exception.Message)"
        }
        finally {
            if ($isopen -eq $true) {
                $connection.Close()
            }
        }
        break;
    }
    'Computers' {
        $query = "SELECT DISTINCT 
        dbo.v_R_System.Name0 as ComputerName, 
        dbo.v_GS_USER_PROFILE.LocalPath0 as ProfilePath, 
        dbo.v_GS_USER_PROFILE.TimeStamp,
        dbo.v_GS_USER_PROFILE.ResourceID, 
        dbo.v_R_System.AD_Site_Name0 as ADSite 
        FROM  
        dbo.v_GS_USER_PROFILE INNER JOIN 
        dbo.v_R_User ON dbo.v_GS_USER_PROFILE.SID0 = dbo.v_R_User.SID0 INNER JOIN 
        dbo.v_R_System ON dbo.v_GS_USER_PROFILE.ResourceID = dbo.v_R_System.ResourceID 
        WHERE dbo.v_R_User.ResourceID = $SearchValue 
        ORDER BY ComputerName"

        try {
            $connection = New-Object -ComObject "ADODB.Connection"
            $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
            $connection.Open($connString);
            $IsOpen = $True
            $rs = New-Object -ComObject "ADODB.RecordSet"
            $rs.Open($query, $connection)

            if ($rs.BOF -and $rs.EOF) {
                $content = '<table id=table2>'
                $content += "<tr><td style=`"height:150px;text-align:center`">"
                $content += "No matching records found</td></tr></table>"
            }
            else {
                $rowcount = 0
                $colcount = $rs.Fields.Count
                $rs.MoveFirst()
                $content = "<table id=table1><tr>"
                for ($i = 0; $i -lt $colcount; $i++) {
                    $fn = $rs.Fields($i).Name
                    $content += "<th>$fn</th>"
                }
                $content += "</tr>"
                while (!$rs.EOF) {
                    $content += "<tr>"
                    for ($i = 0; $i -lt $colcount; $i++) {
                        $fn = $rs.Fields($i).Name
                        $fv = $rs.Fields($i).Value
                        switch ($fn) {
                            'ComputerName' {
                                $fvx = "<a href=`"cmdevice.ps1?f=name&v=$fv&n=$fv&x=equals`" title=`"Details`">$fv</a>"
                                break;
                            }
                            default {
                                $fvx = $fv 
                            }
                        }
                        $content += "<td>$fvx</td>"
                    }
                    $content += "</tr>"
                    $rs.MoveNext();
                    $rowcount++
                }
                $content += "<tr><td colspan=`"$($colcount)`">$rowcount devices found</td></tr>"
                $content += "</table>"
            }
        }
        catch {
            $content += "Error: $($Error[0].Exception.Message)"
        }
        finally {
            if ($IsOpen -eq $True) {
                [void]$connection.Close()
            }
        }
        break;
    }
} # switch

if ($SkNotesEnable -eq 'true') {
    $tabs = @('General','Computers','Notes')
}
else {
    $tabs = @('General','Computers')
}
$tabset = New-MenuTabSet2 -MenuTabs $tabs -BaseLink "cmuser.ps1"

$content += Write-DetailInfo -PageRef "cmuser.ps1" -Mode $Detailed

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