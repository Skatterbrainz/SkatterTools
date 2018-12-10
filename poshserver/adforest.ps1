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

$content = "<table id=table1>"
$content += "<tr><td>Forest Schema</td><td>$schemaVersion</td></tr>"
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