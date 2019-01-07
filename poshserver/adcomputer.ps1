Get-SkParams | Out-Null

$PageTitle   = "AD Computer"
if (![string]::IsNullOrEmpty($Script:SearchValue)) {
    $PageTitle += ": $($Script:SearchValue)"
}
$content  = ""
$menulist = ""
$tabset   = ""
$pagelink = Split-Path -Leaf $MyInvocation.MyCommand.Definition

$plist = @('General','BIOS','Computer','Disks','Environment','Groups','Local Groups','Memory','Network','Operating System','Processor','Software','Startup','Updates','User Profiles','Tools')
$menulist = New-SkMenuList -PropertyList $plist -TargetLink "adcomputer.ps1?v=$Script:SearchValue" -Default $Script:TabSelected
$tabset   = $menulist

switch ($Script:TabSelected) {
    'General' {
        try {
            $cdata = Get-ADsComputers -ComputerName $Script:SearchValue
            #$cdata = Get-ADsComputer -Name $Script:SearchValue
            $content = "<table id=table2>"
            $content += "<tr><td class=t2td1>Name</td><td class=t2td2>$($cdata.Name)</td></tr>"
            $content += "<tr><td class=t2td1>DNS Name</td><td class=t2td2>$($cdata.DnsName)</td></tr>"
            $content += "<tr><td class=t2td1>LDAP Path</td><td class=t2td2>$($cdata.DN)</td></tr>"
            $content += "<tr><td class=t2td1>OS</td><td class=t2td2>$($cdata.OS)</td></tr>"
            $content += "<tr><td class=t2td1>Date Created</td><td class=t2td2>$($cdata.Created)</td></tr>"
            $content += "<tr><td class=t2td1>Last Login</td><td class=t2td2>$($cdata.LastLogon)</td></tr>"
            if ($cdata.SPNlist.Count -gt 0) {
                $spnlist = $cdata.SPNlist -join "</br>"
                $content += "<tr><td class=t2td1>SPNs</td>"
                $content += "<td class=t2td2>$spnlist</td></tr>"
            }
            $content += "</table>"
        }
        catch {
            $content = "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
        }
        break;
    }
    'Computer' {
        try {
            $content = Get-SkWmiPropTable2 -ComputerName $Script:SearchValue -WmiClass "Win32_ComputerSystem"
        }
        catch {
            if ($Error[0].Exception.Message -like "Access is denied*") {
                $content = Get-WmiAccessError
            }
        }
        break;
    }
    'Disks' {
        try {
            $content = Get-SkWmiPropTable1 -ComputerName $Script:SearchValue -WmiClass "Win32_LogicalDisk" -Columns ('DeviceID','DriveType','VolumeName','Size','FreeSpace') -SortField "DeviceID"
        }
        catch {
            if ($Error[0].Exception.Message -like "Access is denied*") {
                $content = Get-WmiAccessError
            }
        }
        break;
    }
    'BIOS' {
        try {
            $content = Get-SkWmiPropTable2 -ComputerName $Script:SearchValue -WmiClass "Win32_BIOS"
        }
        catch {
            if ($Error[0].Exception.Message -like "Access is denied*") {
                $content = Get-WmiAccessError
            }
        }
        break;
    }
    'Network' {
        try {
            $content = Get-SkWmiPropTable1 -ComputerName $Script:SearchValue -WmiClass "Win32_NetworkAdapterConfiguration" -Columns ('IPEnabled','DHCPEnabled','IPAddress','DefaultIPGateway','DNSDomain','ServiceName','Description','Index') -SortField 'Index'
        }
        catch {
            if ($Error[0].Exception.Message -like "Access is denied*") {
                $content = Get-WmiAccessError
            }
        }
        break;
    }
    'Operating System' {
        try {
            $content = Get-SkWmiPropTable2 -ComputerName $Script:SearchValue -WmiClass "Win32_OperatingSystem"
        }
        catch {
            if ($Error[0].Exception.Message -like "Access is denied*") {
                $content = Get-WmiAccessError
            }
        }
        break;
    }
    'Processor' {
        try {
            $content = Get-SkWmiPropTable1 -ComputerName $Script:SearchValue -WmiClass "Win32_Processor" -Columns ('DeviceID','Caption','Manufacturer','MaxClockSpeed') -SortField 'Caption'
        }
        catch {
            if ($Error[0].Exception.Message -like "Access is denied*") {
                $content = Get-WmiAccessError
            }
        }
        break;
    }
    'Software' {
        try {
            $content = Get-SkWmiPropTable1 -ComputerName $Script:SearchValue -WmiClass "Win32_Product" -Columns ('Name','Vendor','Version','PackageCode') -SortField 'Name'
        }
        catch {
            if ($Error[0].Exception.Message -like "Access is denied*") {
                $content = Get-WmiAccessError
            }
        }
        break;
    }
    'Groups' {
        try {
            $groups = Get-ADsUserGroups -UserName "$SearchValue"
            $content = "<table id=table2><tr><td style=`"height:150px`">Stay tuned for more</td></tr></table>"
        }
        catch {}
        break;
    }
    'Local Groups' {
        try {
            $content = (Get-WmiObject -Class "Win32_Group" -ComputerName $SearchValue -Filter "Domain = '$SearchValue'" | Select Name,Description,SID | Sort-Object Name | ConvertTo-Html -Fragment) -replace '<table>','<table id=table1>'
        }
        catch {
            if ($Error[0].Exception.Message -like "Access is denied*") {
                $content = Get-WmiAccessError
            }
        }
        break;
    }
    'Startup' {
        try {
            $content = Get-SkWmiPropTable1 -ComputerName $SearchValue -WmiClass "Win32_StartupCommand" -Columns ('Name','Description','Command','Location') -SortField 'Name'
        }
        catch {
            if ($Error[0].Exception.Message -like "Access is denied*") {
                $content = Get-WmiAccessError
            }
        }
        break;
    }
    'User Profiles' {
        try {
            $content = Get-SkWmiPropTable1 -ComputerName $SearchValue -WmiClass "Win32_UserProfile" -Columns ('LocalPath','LastUseTime','Special','RoamingConfigured') -SortField 'LocalPath'
        }
        catch {
            if ($Error[0].Exception.Message -like "Access is denied*") {
                $content = Get-WmiAccessError
            }
        }
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
        $content = "<table id=table2><tr><td><ul>"
        $content += "<li><a href=`"adtool.ps1?t=gpupdate&c=$SearchValue`">Invoke Group Policy Update (GPUPDATE)</a></li>"
        $content += "</ul></td></tr></table>"
        break;
    }
} # switch


Show-SkPage