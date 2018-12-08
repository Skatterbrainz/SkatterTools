$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'Name'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""

$PageTitle   = "AD Computer ($SearchValue)"
$PageCaption = "AD Computer ($SearchValue)"
$IsFiltered  = $False
$content = ""
$tabset  = ""

if ($SkNotesEnable -eq 'true') {
    $tabs = @('General','Storage','Collections','Software','Tools','Notes')
}
else {
    $tabs = @('General','Storage','Collections','Software','Tools')
}    
$tabset = New-MenuTabSet2 -MenuTabs $tabs -BaseLink "adcomputer.ps1"

switch ($TabSelected) {
    'General' {
        $cdata = Get-ADsComputer -Name $SearchValue
        $content = "<table id=table2>"
        $content += "<tr><td style=`"width:200px`">Name</td><td>$($cdata.Name)</td></tr>"
        $content += "<tr><td style=`"width:200px`">Full Name</td><td>$($cdata.FullName)</td></tr>"
        $content += "<tr><td style=`"width:200px`">LDAP Path</td><td>$($cdata.DN)</td></tr>"
        $content += "<tr><td style=`"width:200px`">OS</td><td>$($cdata.OS)</td></tr>"
        if ($cdata.SPN.Count -gt 0) {
            $spnlist = $cdata.SPN -join "</br>"
            $content += "<tr><td style=`"width:200px`">SPNs</td>"
            $content += "<td>$spnlist</td></tr>"
        }
        $content += "</table>"
        break;
    }
    'Storage' {
        try {
            $disks = Get-WmiObject -Class "Win32_LogicalDisk" -ComputerName $SearchValue -ErrorAction Stop
            $content = "<table id=table1>"
            $content += "<tr><th>Drive</th><th>Name</th><th>Type</th><th>Size</th><th>Free Space</th><th>`% Full</th></tr>"
            foreach ($disk in $disks) {
                switch($disk.DriveType) {
                    2 { $dtype = 'Removable'; break }
                    3 { $dtype = 'Fixed'; break }
                    4 { $dtype = 'Network'; break }
                    5 { $dtype = 'CD-ROM'; break }
                }
                $diskFree = [math]::Round(($disk.FreeSpace / 1GB), 2)
                $diskSize = [math]::Round(($disk.Size / 1GB), 2)
                if ($diskFree -gt 0) {
                    $used  = $diskSize - $diskFree
                    $pct   = ([math]::Round($used / $diskSize, 2) * 100)
                }
                else {
                    $pct = 100
                }
                $content += "<tr>"
                $content += "<td>$($disk.DeviceID)</td>"
                $content += "<td>$($disk.VolumeName)</td>"
                $content += "<td>$dtype</td>"
                $content += "<td style=`"text-align:right`">$diskSize GB</td>"
                $content += "<td style=`"text-align:right`">$diskFree GB</td>"
                $content += "<td style=`"text-align:right`">$pct</td>"
                $content += "</tr>"
            }
            $content += "</table>"
        }
        catch {
            $content = "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
        }
        break;
    }
} # switch

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