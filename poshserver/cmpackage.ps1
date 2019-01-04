$Script:SearchField = Get-PageParam -TagName 'f' -Default ""
$Script:SearchValue = Get-PageParam -TagName 'v' -Default ""
$Script:SearchType  = Get-PageParam -TagName 'x' -Default "equals"
$Script:SortField   = Get-PageParam -TagName 's' -Default "name"
$Script:SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$Script:TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Script:Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Script:CustomName  = Get-PageParam -TagName 'n' -Default ""
$Script:IsFiltered  = $False
$Script:PageTitle   = "CM Software"
$Script:PageCaption = "CM Software"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

switch ($TabSelected) {
    'General' {
        $content = Get-SkQueryTableSingle -QueryFile "cmpackage.sql" -PageLink "cmpackage.ps1" -Columns ('PackageID','Name','Version','Manufacturer','PackageType','PkgType','Description','PkgSourcePath','SourceVersion','SourceDate','SourceSite','LastRefreshTime')
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