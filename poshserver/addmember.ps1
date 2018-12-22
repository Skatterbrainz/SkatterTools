$ResourceName   = $PoshPost.resname
$ResourceType   = $PoshPost.restype
$ResourceID     = $PoshPost.resid
$CollectionName = $PoshPost.collid
#$CollectionName = $PoshPost.collname

$PageTitle    = "Add Collection Member"
$PageCaption  = $PageTitle
$content = ""
$query   = ""
$tabset  = ""

if ($ResourceID.IndexOf(':') -gt 0) {
    $xx = $ResourceID -split ':'
    $ResourceID = $xx[0]
    $ResourceName = $xx[1]
}

switch ($ResourceType) {
    5 {
        $TargetLink = "cmdevice.ps1?f=resourceid&v=$ResourceID&x=equals&n=$ResourceName&tab=Collections"
        $laststep = "defined targetlink: device"
        break;
    }
    4 {
        $TargetLink = "cmuser.ps1?f=resourceid&v=$ResourceID&x=equals&n=$ResourceName&tab=Collections"
        $laststep = "defined targetlink: user"
        break;
    }
}

#$result = Add-CMCollectionMemberDirect -CollectionName $CollectionName -ResourceName $ResourceName
try {
    switch ($ResourceType) {
        5 {
            if ($ResourceID -eq "") {
                $laststep = "getting resourceid"
                [string]$ResourceID = $(Get-WmiObject -ComputerName $CmSMSProvider -Namespace "Root\Sms\Site_$CmSiteCode" -Query "Select * From SMS_R_System Where Name='$($ResourceName)'").ResourceID
            }
            $laststep = "defining new rule object"
            $SmsNewRule = $([wmiclass]$("\\$($CmSMSProvider)\root\sms\site_$($CmSiteCode):SMS_CollectionRuleDirect")).CreateInstance()
            $laststep = "getting collection object"
            $SmsCollection = Get-WmiObject -ComputerName $CmSMSProvider -Namespace "Root\Sms\Site_$CmSiteCode" -Query "Select * From SMS_Collection Where Name='$($CollectionName)'"
            [void]$SmsCollection.Get()
            $SmsNewRule.ResourceClassName = "SMS_R_System"
            $SmsNewRule.ResourceID = $ResourceID
            $SmsNewRule.RuleName = $ResourceName
            $laststep = "adding rule to collection"
            [System.Management.ManagementBaseObject[]]$SmsRules = $SmsCollection.CollectionRules
            $SmsRules += $SmsNewRule
            $SmsCollection.CollectionRules = $SmsRules
            $laststep = "updating collection"
            [void]$SmsCollection.Put()
            $laststep = "update completed"
            $result = "Success"
            break;
        }
        4 {
            $result = "NotImplemented"
            break;
        }
    } # switch
}
catch {
    $result = "Error: $($Error[0].Exception.Message)"
}

$content = "<table id=table2>"
$content += "<tr><td>Resource Name</td><td>$ResourceName</td></tr>"
$content += "<tr><td>Resource ID</td><td>$ResourceID</td></tr>"
$content += "<tr><td>Resource Type</td><td>$ResourceType</td></tr>"
$content += "<tr><td>Collection Name</td><td>$CollectionName</td></tr>"
$content += "<tr><td>SMS Provider</td><td>$CmSMSProvider</td></tr>"
$content += "<tr><td>SMS Site Code</td><td>$CmSiteCode</td></tr>"
$content += "<tr><td>Request Status</td><td>$result</td></tr>"
$content += "<tr><td>Last step</td><td>$laststep</td></tr>"

$content += "<tr><td>Return Link</td><td><a href=`"$TargetLink`">$TargetLink</a></td></tr>"
$content += "<tr><td colspan=2 style=`"heigh:150px;text-align:center`">"
$content += "<h3>Adding to collection...</h3>"
$content += "<img src=`"graphics\301.gif`" border=0 /></td></tr>"
$content += "</table>"

$content += Write-DetailInfo -PageRef "addmember.ps1" -Mode $Detailed

@"
<html>
<head>
<!--<meta http-equiv=`"refresh`" content=`"4;url=$TargetLink`" />-->
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

$content

</body>
</html>
"@