$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default "like"
$SortField   = Get-PageParam -TagName 's' -Default "SMSID"
$SortOrder   = Get-PageParam -TagName 'so' -Default "asc"
$TabSelected = Get-PageParam -TagName 'tab' -Default 'all'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""
$IsFiltered  = $False
$PageTitle   = "CM Certificates"
$PageCaption = "CM Certificates"
$content     = ""
$tabset      = ""
$outree      = $null
$query       = $null
$xxx         = ""

try {
    $query = 'SELECT distinct
        [SMSID]
        ,[IssuedTo]
        ,[ServerName]
        ,case 
            when [Type]=2 then ''BootMedia''
            when [Type]=4 then ''DistributionPoint''
            when [Type]=5 then ''ISVProxy''
            end as CertType
        --,[PublicKey]
        ,case 
            when [KeyType]=1 then ''SelfSigned''
            when [KeyType]=2 then ''Issued''
            end as KeyType
        ,[ValidFrom]
        ,[ValidUntil]
        ,case 
            when [IsApproved]=1 then ''Yes''
            else ''No'' end as Approved
        ,case 
            when [IsBlocked]=1 then ''Yes''
            else ''No'' end as Blocked
        FROM vSMS_Certificate'

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
        $content += "<tr><td colspan=`"$($colcount)`" class=lastrow>$rowcount items returned"
        if ($IsFiltered -eq $true) {
            $content += " - <a href=`"cmcerts.ps1`" title=`"Show All`">Show All</a>"
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

#$tabset = New-MenuTabSet -BaseLink 'cmcerts.ps1?x=begins&f=name&v=' -DefaultID $TabSelected
#$content += Write-DetailInfo -PageRef "cmcerts.ps1" -Mode $Detailed

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