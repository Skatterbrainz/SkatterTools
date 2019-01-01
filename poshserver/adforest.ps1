$SearchField = Get-PageParam -TagName 'f' -Default ""
$SearchValue = Get-PageParam -TagName 'v' -Default ""
$SearchType  = Get-PageParam -TagName 'x' -Default ""
$SortField   = Get-PageParam -TagName 's' -Default ""
$SortOrder   = Get-PageParam -TagName 'so' -Default ""
$TabSelected = Get-PageParam -TagName 'tab' -Default ""
$Detailed    = Get-PageParam -TagName 'zz' -Default ""
$CustomName  = Get-PageParam -TagName 'n' -Default ""

$PageTitle   = "AD Forest"
$PageCaption = "AD Forest"
$content     = ""
$tabset      = ""

$schemaVersion = $(
    #https://blogs.msmvps.com/richardsiddaway/2016/12/14/active-directory-schema-versions/
    $sch = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema()
    $de = $sch.GetDirectoryEntry()
    switch ($de.ObjectVersion) {
        13 {"{0,25} " -f "Schema Version $($de.ObjectVersion) = Windows 2000"; break}
        30 {"{0,25} " -f "Schema Version $($de.ObjectVersion) = Windows 2003"; break}
        31 {"{0,25} " -f "Schema Version $($de.ObjectVersion) = Windows 2003 R2"; break}
        44 {"{0,25} " -f "Schema Version $($de.ObjectVersion) = Windows 2008"; break}
        47 {"{0,25} " -f "Schema Version $($de.ObjectVersion) = Windows 2008 R2"; break}
        56 {"{0,25} " -f "Schema Version $($de.ObjectVersion) = Windows 2012"; break}
        69 {"{0,25} " -f "Schema Version $($de.ObjectVersion) = Windows 2012 R2"; break}
        87 {"{0,25} " -f "Schema Version $($de.ObjectVersion) = Windows 2016"; break}
        default {"{0,25} {1,2} " -f "Unknown Schema Version", $($de.ObjectVersion); break}
    }
)

$forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()

switch ($forest.ForestModeLevel) {
    0 { $flvl = 'Windows Server 2000'; break; }
    1 { $flvl = 'Windows Server 2003 Interim'; break; }
    2 { $flvl = 'Windows Server 2003'; break; }
    3 { $flvl = 'Windows Server 2008'; break; }
    4 { $flvl = 'Windows Server 2008 R2'; break; }
    5 { $flvl = 'Windows Server 2012'; break; }
    6 { $flvl = 'Windows Server 2012 R2'; break; }
    7 { $flvl = 'Windows Server 2016'; break; }
    default { $flvl = 'Windows Server 2000'; break; }
}

$rootDom = $forest.RootDomain
#$rootDom.DomainControllers
switch ($rootDom.DomainModeLevel) {
    0 { $dlvl = 'Windows Server 2000 mixed'; break; }
    1 { $dlvl = 'Windows Server 2003 Interim'; break; }
    2 { $dlvl = 'Windows Server 2003'; break; }
    3 { $dlvl = 'Windows Server 2008'; break; }
    4 { $dlvl = 'Windows Server 2008 R2'; break; }
    5 { $dlvl = 'Windows Server 2012'; break; }
    6 { $dlvl = 'Windows Server 2012 R2'; break; }
    7 { $dlvl = 'Windows Server 2016'; break; }
    default { $dlvl = 'Windows Server 2000'; break; }
}

$im = $rootDom.InfrastructureRoleOwner
$pdc = $rootDom.PdcRoleOwner
$rid = $rootDom.RidRoleOwner

$pdcName = $pdc.Name
$pdcIP   = $pdc.IPAddress
$pdcOS   = $pdc.OSVersion
$pdcSite = $pdc.SiteName
$pdcGC   = $pdc.IsGlobalCatalog()
$pdcx    = $pdc.GetAllReplicationNeighbors()

$imName  = $im.Name
$imIP    = $im.IPAddress
$imOS    = $im.OSVersion
$imSite  = $im.SiteName
$imGC    = $im.IsGlobalCatalog()
$imx     = $im.GetAllReplicationNeighbors()

$ridName = $rid.Name
$ridIP   = $rid.IPAddress
$ridOS   = $rid.OSVersion
$ridSite = $rid.SiteName
$ridGC   = $rid.IsGlobalCatalog()
$ridx    = $rid.GetAllReplicationNeighbors()

$smdc = $forest.SchemaRoleOwner
$smnm = $forest.NamingRoleOwner

$smdcx = "<a href=`"adcomputer.ps1?f=Name&v=$($($smdc -split '\.')[0])`">$smdc</a>"
$smnmx = "<a href=`"adcomputer.ps1?f=Name&v=$($($smnm -split '\.')[0])`">$smnm</a>"
$ridnx = "<a href=`"adcomputer.ps1?f=Name&v=$($($ridName -split '\.')[0])`">$ridName</a>"
$pdcnx = "<a href=`"adcomputer.ps1?f=Name&v=$($($pdcName -split '\.')[0])`">$pdcName</a>"
$imnx  = "<a href=`"adcomputer.ps1?f=Name&v=$($($imName -split '\.')[0])`">$imName</a>"

$content = "<table id=table2>"
$content += "<tr><td>Active Directory Forest</td><td>$($forest.Name)</td></tr>"
$content += "<tr><td>Forest Schema</td><td>$schemaVersion</td></tr>"
$content += "<tr><td>Forest Mode Level</td><td>$flvl</td></tr>"
$content += "<tr><td>Root Domain Level</td><td>$dlvl</td></tr>"
$content += "<tr><td>FSMO - PDC emulator</td><td>$pdcnx ($pdcIP - $pdcOS)</td></tr>"
$content += "<tr><td>FSMO - Infrastructure master</td><td>$imnx ($imIP - $imOS)</td></tr>"
$content += "<tr><td>FSMO - RID master</td><td>$ridnx ($ridIP - $ridOS)</td></tr>"
$content += "<tr><td>FSMO - Schema master</td><td>$smdcx</td></tr>"
$content += "<tr><td>FSMO - Naming master</td><td>$smnmx</td></tr>"
$content += "<tr><td>Global Catalogs</td><td><ul>$($forest.GlobalCatalogs | %{"<li>$_</li>"})</ul></td></tr>"
$content += "<tr><td>Partitions</td><td><ul>$($forest.ApplicationPartitions | %{"<li>$_</li>"})</ul></td></tr>"
$content += "</table>"

@"
<html>
<head>
<link rel="stylesheet" type="text/css" href="$STTheme"/>
</head>

<body>

<h1>$PageCaption</h1>

$content

</body>
</html>
"@