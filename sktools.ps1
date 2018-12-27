# SkatterTools Site Configuration

$Global:SkToolsVersion = "1812.27.01"

$configFile = Join-Path -Path $HomeDirectory -ChildPath "config.txt"
if (!(Test-Path $configFile)) {
    Write-Warning "Config.txt was not found. Shit just got real."
    break
}
$cdata = Get-Content $configFile | Where-Object{$_ -notlike ';*'}
foreach ($line in $cdata) {
    $varset = $line -split '='
    if ($varset.Count -gt 1) {
        Set-Variable -Name $varset[0] -Value $($varset[1]).Trim() -Scope Global | Out-Null
    }
}

if ($Global:SkToolsLoaded -ne 1) {
    try {
        Get-ChildItem (Join-Path -Path $HomeDirectory -ChildPath "lib") -Filter "*.ps1" -ErrorAction Stop | ForEach-Object { . $_.FullName }
        $Global:SkToolsLoaded = 1
        $Global:LastLoadTime = Get-Date
    }
    catch {
        Write-Error "OMFG - something smells really bad in here?!"
        break
    }
}
