Get-SkParams | Out-Null
$Script:SearchField = "Name"
$Script:SearchType  = "equals"

$PageTitle   = "CM Device"
if (![string]::IsNullOrEmpty($Script:SearchValue)) {
    $PageTitle += ": $($Script:SearchValue)"
}
$content  = ""
$menulist = ""
$tabset   = ""
$pagelink = Split-Path -Leaf $MyInvocation.MyCommand.Definition

$plist = @('General','Storage','Collections','Disks','Network','Ping','Tools')
$menulist = New-SkMenuList -PropertyList $plist -TargetLink "cmdevice.ps1?v=$Script:SearchValue" -Default $Script:TabSelected
$tabset = $menulist

switch ($TabSelected) {
    'General' {
        $output = $null
        $params = @{
            QueryFile   = "cmdevice.sql"
            PageLink    = "cmdevice.ps1"
            Columns     = ('Name','ResourceID','Manufacturer','Model','SerialNumber','OperatingSystem','OSBuild','ClientVersion','LastHwScan','LastDDR','LastPolicyRequest','ADSiteName')
        }
        #$xxx = $params -join ';'
        $content = Get-SkQueryTableSingle @params
        break;
    }
    'Collections' {
        try {
            $xxx = "query defined"
            $params = @{
                QueryFile = "cmdevicecolls.sql"
                PageLink  = "cmdevice.ps1"
                Columns   = ('CollectionID','CollectionName')
            }
            $content = Get-SkQueryTableMultiple @params -NoUnFilter -NoCaption
            
            if ($CmCollectionManage -eq 'TRUE') {
                $dcolls  = Get-CmDeviceCollectionMemberships -ComputerName $Script:SearchValue -Inverse
                if ($dcolls.count -gt 0) {
                    $content += "<form name='form1' id='form1' method='post' action='cmaddmember.ps1'>"
                    $content += "<input type='hidden' name='resname' id='resname' value='$CustomName' />"
                    $content += "<input type='hidden' name='resid' id='resid' value='$SearchValue' />"
                    $content += "<input type='hidden' name='restype' id='restype' value='5' />"
                    $content += "<table id=table2><tr><td>"
                    $content += "<select name='collid' id='collid' size=1 style='width:500px;padding:5px'>"
                    $content += "<option value=`"`"></option>"
                    foreach ($row in $dcolls) {
                        $cid = $row.CollectionID
                        $cnn = $row.Name
                        $content += "<option value=`"$cnn`">$cnn</option>"
                    }
                    $content += "</select> <input type='submit' name='ok' id='ok' value='Add' class='button1' />"
                    $content += " (direct membership collections only)</td></tr></table></form>"
                }
            }
        }
        catch {
            $content = "<table id=table2><tr><td>Error: $($Error[0].Exception.Message)</td></tr></table>"
        }
        break;
    }
    'Network' {
        $content = Get-SkQueryTableMultiple -QueryFile "cmdevicenetconfigs.sql" -PageLink "cmdevice.ps1"
        break;
    }
    'Disks' {
        $output = $null
        $content = Get-SkQueryTableMultiple -QueryFile "cmdevicedrives.sql" -PageLink "cmdevice.ps1" -Columns ('Drive','DiskType','Description','DiskSize','Used','FreeSpace','PCT')
        break;
    }
    'Software' {
        $SearchField = 'Name0'
        $content = Get-SkQueryTableMultiple -QueryFile "cmdeviceapps.sql" -PageLink "cmdevice.ps1" -Columns ('ProductName','Publisher','Version') -Sorting "ProductName" -NoUnFilter -NoCaption
        break;
    }
    'Notes' {
        break;
    }
}

$content += Write-DetailInfo -PageRef "cmdevice.ps1" -Mode $Detailed

Show-SkPage