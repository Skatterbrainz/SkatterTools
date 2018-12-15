$SearchField = Get-PageParam -TagName 'f' -Default "ScriptGuid"
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "equals"
$SortField   = Get-PageParam -TagName 's' -Default ""
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Script: $CustomName"
$PageCaption = "CM Script: $CustomName"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

try {
    $query = 'select TOP 1 
    ScriptName,
    ScriptVersion,
    ScriptGuid,
    Author,
    ScriptType,
    Feature,
    ApprovalState,
    CASE 
        when (ApprovalState = 0) then ''Pending''
        when (ApprovalState = 1) then ''Denied''
        when (ApprovalState = 3) then ''Approved''
        else ''Unknown''
        end as Approval,
    Approver,
    ''(It looks like Chinese writing, so I cant display it yet)'' as Script,
    ScriptHashAlgorithm,
    ScriptHash,
    LastUpdateTime,
    Comment,
    --ParamsDefinition,
    ParameterlistXML,
    ParameterGroupHash 
    FROM vSMS_Scripts 
    WHERE (ScriptGuid = '''+$SearchValue+''')'

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
        $content = "<table id=table2>"
        [void]$rs.MoveFirst()
        for ($i = 0; $i -lt $rs.Fields.Count; $i++) {
            $fn = $rs.Fields($i).Name
            $fv = $rs.Fields($i).Value
            switch ($fn) {
                'Approver' {
                    ($fv -split '\\') | ForEach-Object {$unn = $_}
                    $fvx = "<a href=`"aduser.ps1?f=username&v=$unn&x=equals`" title=`"User Account`">$fv</a>"
                    break;
                }
                'Author' {
                    ($fv -split '\\') | ForEach-Object {$aun = $_}
                    $fvx = "<a href=`"cmscripts.ps1?f=author&v=$aun&x=contains`" title=`"Other scripts by $aun`">$fv</a>"
                    break;
                }
                default {
                    $fvx = $fv
                    break;
                }
            }
            $content += "<tr><td style=`"width:200px`">$fn</td><td>$fvx</td></tr>"
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