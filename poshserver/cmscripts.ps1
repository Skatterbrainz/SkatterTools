$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "like"
$SortField   = Get-PageParam -TagName 's' -Default "ScriptName"
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Scripts"
$PageCaption = "CM Scripts"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

try {
    $query = 'select distinct 
        ScriptGuid,
        ScriptVersion,
        ScriptName,
        Author,
        CASE 
          when (ApprovalState = 0) then ''Pending''
          when (ApprovalState = 1) then ''Denied''
          when (ApprovalState = 3) then ''Approved''
          else ''Unknown''
          end as Approval,
        LastUpdateTime
        FROM vSMS_Scripts'

    if (![string]::IsNullOrEmpty($SearchValue)) {
        $IsFiltered = $True
        switch ($SearchType) {
            'equals' {
                $query += " where ($SearchField = '$SearchValue')"
                break;
            }
            'like' {
                $query += " where ($SearchField like '%$SearchValue%')"
                break;
            }
            'begins' {
                $query += " where ($SearchField like '$SearchValue%')"
                break;
            }
            'ends' {
                $query += " where ($SearchField like '%$SearchValue')"
                break;
            }
        }
        $PageTitle += ": $SearchValue"
        $PageCaption = $PageTitle
    }
    $query += " order by $SortField $SortOrder"

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
        $colcount = 1
        $content = "<table id=table1>"
        $content += "<tr><th>Name</th><th>Version</th><th>Author</th><th>Approval</th><th>Last Update</th></tr>"
        [void]$rs.MoveFirst()
        while (!$rs.EOF) {
            $scid = $rs.Fields("ScriptGuid").value
            $scv  = $rs.Fields("ScriptVersion").value
            $scn  = $rs.Fields("ScriptName").value
            $sca  = $rs.Fields("Author").value
            $scav = $rs.Fields("Approval").value
            $scut = $rs.Fields("LastUpdateTime").value
            $xlink = "<a href=`"cmscript.ps1?f=ScriptGuid&v=$scid&x=equals&n=$scn`" title=`"Details`">$scn</a>"
            $content += "<tr><td>$xlink</td><td style=`"text-align:center`">$scv</td><td>$sca</td><td style=`"text-align:center`">$scav</td><td>$scut</td></tr>"
            [void]$rs.MoveNext()
            $rowcount++
        }
        $content += "<tr><td colspan=5 class=lastrow>$rowcount items returned"
        if ($IsFiltered -eq $true) {
            $content += " - <a href=`"cmscripts.ps1`" title=`"Show All`">Show All</a>"
        }
        $content += "</td></tr>"
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

$content += Write-DetailInfo -PageRef "cmpackages.ps1" -Mode $Detailed

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