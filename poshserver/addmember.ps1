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

switch ($ResourceType) {
    5 {
        $TargetLink = "cmdevice.ps1?f=resourceid&v=$ResourceID&x=equals&n=$ResourceName&tab=Collections"
        break;
    }
    4 {
        $TargetLink = "cmuser.ps1?f=resourceid&v=$ResourceID&x=equals&n=$ResourceName&tab=Collections"
        break;
    }
}

#$result = Add-CMCollectionMemberDirect -CollectionName $CollectionName -ResourceName $ResourceName
try {
    [string]$SmsResourceID = $(Get-WmiObject -ComputerName $CmSMSProvider -Namespace "Root\Sms\Site_$CmSiteCode" -Query "Select * From SMS_R_System Where Name='$($ResourceName)'").ResourceID
    $SmsNewRule = $([wmiclass]$("\\$($CmSMSProvider)\root\sms\site_$($CmSiteCode):SMS_CollectionRuleDirect")).CreateInstance()
    $SmsCollection = Get-WmiObject -ComputerName $CmSMSProvider -Namespace "Root\Sms\Site_$CmSiteCode" -Query "Select * From SMS_Collection Where Name='$($CollectionName)'"
    [void]$SmsCollection.Get()
    $SmsNewRule.ResourceClassName = "SMS_R_System"
    $SmsNewRule.ResourceID = $SmsResourceID
    $SmsNewRule.RuleName = $ResourceName
    [System.Management.ManagementBaseObject[]]$SmsRules = $SmsCollection.CollectionRules
    $SmsRules += $SmsNewRule
    $SmsCollection.CollectionRules = $SmsRules
    [void]$SmsCollection.Put()
    $result = "Success"
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