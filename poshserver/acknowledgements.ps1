$PageTitle = "Acknowledgements"

$tabset = ""
$links = @(
    'https://docs.microsoft.com/en-us/powershell/module/configurationmanager/?view=sccm-ps',
    'https://www.petri.com/managing-active-directory-groups-adsi-powershell',
    'https://stackoverflow.com',
    'https://www.petri.com/active-directory-powershell-with-adsi',
    'https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/?view=powershell-5.1',
    'https://lazywinadmin.com/2014/04/powershell-get-list-of-my-domain.html',
    'http://tech-comments.blogspot.com/2010/10/powershell-adsisearcher-basics.html',
    'https://serverfault.com/questions/512228/how-to-check-ad-ds-domain-forest-functional-level-from-domain-joined-workstation',
    'https://blogs.msmvps.com/richardsiddaway/category/powershellandactivedirectory',
    'https://www.andersrodland.com/ultimate-sccm-querie-collection-list/',
    'https://github.com/paulwetter/DocumentConfigMgrCB/blob/master/DocumentCMCB.ps1'
)
$content = "<table id=table2>"
foreach ($link in $links) {
    $content += "<tr><td><a href=`"$link`" target=`"_new`">$link</a></td></tr>"
}
$content += "</table>"

Show-SkPage

