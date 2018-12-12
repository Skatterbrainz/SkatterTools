$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "equals"
$SortField   = Get-PageParam -TagName 's' -Default "name"
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Software: $CustomName"
$PageCaption = "CM Software: $CustomName"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

switch ($TabSelected) {
    'General' {
        try {
            $query = 'select 
                PackageID,
                Name, 
                Version, 
                Manufacturer,
                PackageType as [Type],
                Case 
	                When PackageType = 0   Then ''Software Distribution Package'' 
	                When PackageType = 3   Then ''Driver Package'' 
	                When PackageType = 4   Then ''Task Sequence Package''
	                When PackageType = 5   Then ''Software Update Package''
	                When PackageType = 6   Then ''Device Settings Package''
	                When PackageType = 7   Then ''Virtual Package''
	                When PackageType = 8   Then ''Application''
	                When PackageType = 257 Then ''OS Image Package''
	                When PackageType = 258 Then ''Boot Image Package''
	                When PackageType = 259 Then ''OS Upgrade Package''
	                WHEN PackageType = 260 Then ''VHD Package''
	                End as PkgType,
                Description, 
                PkgSourcePath, 
                SourceVersion, 
                SourceDate, 
                SourceSite, 
                LastRefreshTime 
                from dbo.v_Package 
                where (PackageID = '''+$SearchValue+''')'
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
                $content = "<table id=table2>"
                for ($i = 0; $i -lt $colcount; $i++) {
                    $fn = $rs.Fields($i).Name
                    $fv = $rs.Fields($i).Value
                    $content += "<tr><td style=`"width:200px`">$fn</td>"
                    $content += "<td>$fv</td></tr>"
                }
                $content += "</table>"
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
    'Programs' {
        try {
            $query = 'select 
	            ProgramName,
	            Comment, 
	            Description, 
	            CommandLine,
	            Duration,
	            DiskSpaceRequired, 
	            ProgramFlags 
            from [dbo].[v_Program]
            WHERE (PackageID = '''+$SearchValue+''') 
            order by ProgramName'
            $connection = New-Object -ComObject "ADODB.Connection"
            $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
            $connection.Open($connString);
            $IsOpen = $true
            $rs = New-Object -ComObject "ADODB.RecordSet"
            $rowcount = 0
            $rs.Open($query, $connection)
            if ($rs.BOF -and $rs.EOF) {
                $content = "<table id=table2><tr><td>No Programs found for this Package</td></tr></table>"
            }
            else {
                $colcount = $rs.Fields.Count
                $content = "<table id=table1>"
                for ($i = 0; $i -lt $colcount; $i++) {
                    $fn = $rs.Fields($i).Name
                    $fv = $rs.Fields($i).Value
                    $content += "<tr><td style=`"width:200px`">$fn</td>"
                    $content += "<td>$fv</td></tr>"
                }
                $content += "</table>"
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
    'Advertisements' {
        $content = "<table id=table2><tr><td style=`"height:200px;text-align:center`">"
        $content += "Coming soon</td></tr></table>"
        break;
    }
}

if ($SkNotesEnable -eq 'true') {
    $tabs = @('General','Programs','Advertisements','Notes')
}
else {
    $tabs = @('General','Programs','Advertisements')
}
$tabset = New-MenuTabSet2 -MenuTabs $tabs -BaseLink "cmpackage.ps1"

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