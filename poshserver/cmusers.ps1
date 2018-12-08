$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'user_name0'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default $DefaultGroupsTab
$Detailed    = Get-PageParam -TagName 'zz' -Default ""

$PageTitle   = "CM Users"
$PageCaption = "CM Users"

$TabSelected = $SearchValue
if ($SearchValue -eq 'all') {
    $SearchValue = ""
}

$query = 'select 
ResourceID, 
User_Name0 as UserName, 
AADUserID, 
Windows_NT_Domain0 as Domain, 
User_Principal_Name0 as UPN,
Department, 
Title  
from v_R_User'

if (![string]::IsNullOrEmpty($SearchValue)) {
    switch ($SearchType) {
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
        default {
        $query += " where ($SearchField = '$SearchValue')"
        }
    }
    $IsFiltered = $True
    $PageTitle += " ($SearchValue)"
    $PageCaption = $PageTitle
}
$query += " order by $SortField $SortOrder"

try {
    $connection = New-Object -ComObject "ADODB.Connection"
    $connString = "Data Source=$CmDBHost;Initial Catalog=CM_$CmSiteCode;Integrated Security=SSPI;Provider=SQLOLEDB"
    $connection.Open($connString);
    $IsOpen = $True
    $rs = New-Object -ComObject "ADODB.RecordSet"
    $rs.Open($query, $connection)
    $xxx += "<br/>recordset defined"
    $content = '<table id=table1><tr>'
    if ($rs.BOF -and $rs.EOF) {
        $content += "<tr><td style=`"height:150px;text-align:center`">"
        $content += "No matching results found</td></tr>"
    }
    else {
        $colcount = $rs.Fields.Count
        $xxx += "$colcount columns returned"
        $rs.MoveFirst()
        for ($i = 0; $i -lt $colcount; $i++) {
            if ($rs.Fields($i).Name -ne 'ResourceID') {
                $content += '<th>'+$rs.Fields($i).Name+'</th>'
            }
        }
        $content += '</tr>'
        $rowcount = 0
        while (!$rs.EOF) {
            $content += '<tr>'
            $rid = $rs.Fields('ResourceID').value
            for ($i = 0; $i -lt $colcount; $i++) {
                $fn = $rs.Fields($i).Name
                $fv = $rs.Fields($i).Value
                switch ($fn) {
                    'UserName' {
                        $fvx = "<a href=`"cmuser.ps1?f=ResourceID&v=$rid&n=$fv`" title=`"Details`">$fv</a>"
                        $content += "<td>$fvx</td>"
                        break;
                    }
                    'Department' {
                        if (![string]::IsNullOrEmpty($fv)) {
                            $fvx = "<a href=`"cmusers.ps1?f=Department&v=$fv&x=equals`" title=`"Filter`">$fv</a>"
                        }
                        else {
                            $fvx = ""
                        }
                        $content += "<td>$fvx</td>"
                        break;
                    }
                    'Title' {
                        if (![string]::IsNullOrEmpty($fv)) {
                            $fvx = "<a href=`"cmusers.ps1?f=Title&v=$fv&x=equals`" title=`"Filter`">$fv</a>"
                        }
                        else {
                            $fvx = ""
                        }
                        $content += "<td>$fvx</td>"
                        break;
                    }
                    'ResourceID' {
                        break;
                    }
                    default {
                        $content += "<td>$fv</td>"
                        break;
                    }
                }
            }
            $content += '</tr>'
            $rs.MoveNext()
            $rowcount++
        } # while
    }
    $content += '<tr>'
    $content += '<td colspan='+$($colcount-1)+'>'+$rowcount+' rows returned'
    if ($IsFiltered -eq $true) {
        $content += " - <a href=`"cmusers.ps1`" title=`"Show All`">Show All</a>"
    }
    $content += '</td></tr>'
    $content += '</table>'
}
catch {
    $content = "Error: $($Error[0].Exception.Message)"
}
finally {
    if ($isopen -eq $true) {
        $connection.Close()
    }
}

$tabset = New-MenuTabSet -BaseLink 'cmusers.ps1?x=begins&f=User_Name0&v=' -DefaultID $TabSelected
$content += Write-DetailInfo -PageRef "cmcollections.ps1" -Mode $Detailed

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

$tabset
$content

$(if ($DebugMode -eq 1) {"<p>$query</p>"})

</body>
</html>
"@