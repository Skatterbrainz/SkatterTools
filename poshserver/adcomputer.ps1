$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default 'like'
$SortField   = Get-PageParam -TagName 's' -Default 'Name'
$SortOrder   = Get-PageParam -TagName 'so' -Default 'Asc'
$TabSelected = Get-PageParam -TagName 'tab' -Default 'General'
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$Extension1  = Get-PageParam -TagName 'x1' -Default ""

$PageTitle   = "AD Computer ($SearchValue)"
$PageCaption = "AD Computer ($SearchValue)"
$IsFiltered  = $False
$content = ""
$tabset  = ""

if ($SkNotesEnable -eq 'true') {
    $tabs = @('General','Storage','Groups','Software','Ping','Tools','Notes')
}
else {
    $tabs = @('General','Storage','Groups','Software','Ping','Tools')
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
    'Software' {
        if ([string]::IsNullOrEmpty($Extension1)) {
            try {
                $apps = Get-WmiObject -Class "Win32_Product" -ComputerName $SearchValue -ErrorAction Stop | Sort-Object Name
                $content = "<table id=table1>"
                $content += "<tr>"
                $content += "<th>Name</th>"
                $content += "<th>Version</th>"
                $content += "<th>Publisher</th>"
                $content += "<th>Product Code</th>"
                $content += "</tr>"
                $rowcount = 0
                foreach ($app in $apps) {
                    $prodname = [string]$app.Name
                    $prodcode = [string]$app.PackageCode
                    if (![string]::IsNullOrEmpty($prodname)) {
                        $xlink = "<a href=`"adcomputer.ps1?=name&v=$SearchValue&x=equals&tab=software&x1=$prodcode`">$prodname</a>"
                        $content += "<tr>"
                        $content += "<td>$xlink</td>"
                        $content += "<td>$($app.Version)</td>"
                        $content += "<td>$($app.Vendor)</td>"
                        $content += "<td>$prodcode</td>"
                        $content += "</tr>"
                        $rowcount++
                    }
                }
                $content += "<tr><td colspan=4 class=lastrow>$rowcount products found</td></tr>"
                $content += "</table>"
            }
            catch {
            }
        }
        else {
            try {
                $app = Get-WmiObject -Class "Win32_Product" -Filter "PackageCode = '$Extension1'" -ComputerName $SearchValue -ErrorAction Stop
                $props = ('Name','Caption','Vendor','Version','Description','HelpLink','HelpTelephone','IdentifyingNumber',
'InstallDate','InstallDate2','InstallLocation','InstallSource','Language','LocalPackage','PackageCache','PackageCode',
'PackageName','ProductID','RegCompany','RegOwner','SKUNumber','Transforms','URLInfoAbout','URLUpdateInfo')
                
                $content = "<h2>$Extension1</h2>"
                $content += "<table id=table2>"
                $content += "<tr><th>Property</th><th>Value</th></tr>"
                foreach ($prop in $props) {
                    $content += "<tr><td>$prop</td><td>$($app.$prop)</td></tr>"
                }
                $content += "</table>"
            }
            catch {
                $content = "<table id=table2><tr><td>$($Error[0].Exception.Message)</td></tr></table>"
            }
            finally {
                $xlink = "<a href=`"adcomputer.ps1?=name&v=$SearchValue&x=equals&tab=software`">Back to Software Products</a>"
                $content += "<table id=table2><tr><td>$xlink</td></tr></table>"
            }
        }
        break;
    }
    'Groups' {
        $content = "<table id=table2><tr><td style=`"height:150px`">Stay tuned for more</td></tr></table>"
        break;
    }
    'Ping' {
        try {
            $tconn = Test-NetConnection -ComputerName $SearchValue -InformationLevel Detailed
            $content = "<table id=table2>"
            $content += "<tr><td>Ping Succeeded</td><td>$($tconn.PingSucceeded)</td></tr>"
            $content += "<tr><td>RemoteAddress</td><td>$($tconn.RemoteAddress)</td></tr>"
            $content += "<tr><td>NameResolutionResults</td><td>$($tconn.NameResolutionResults)</td></tr>"
            $content += "<tr><td>InterfaceAlias</td><td>$($tconn.InterfaceAlias)</td></tr>"
            #$content += "<tr><td>SourceAddress</td><td>$($tconn.SourceAddress)</td></tr>"
            #$content += "<tr><td>NetRoute (NextHop)</td><td>$($tconn.'NetRoute (NextHop)')</td></tr>"
            #$content += "<tr><td>PingReplyDetails (RTT)</td><td>$($tconn.'PingReplyDetails (RTT)')</td></tr>"
            $content += "</table>"
        }
        catch {
            $content = "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
        }
        break;
    }
    'Tools' {
        $content = "<table id=table2><tr><td style=`"height:150px`">Stay tuned for more</td></tr></table>"
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