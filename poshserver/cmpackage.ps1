$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "equals"
$SortField   = Get-PageParam -TagName 's' -Default "name"
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Package: $CustomName"
$PageCaption = "CM Package: $CustomName"
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
                PackageType, 
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