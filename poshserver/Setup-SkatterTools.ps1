<#
.NOTES
2018.27.02 - DS
#>
[CmdletBinding()]
param ()

function New-DesktopShortcut {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True)]
        [string] $Name,
        [parameter(Mandatory=$True)]
        [string] $Target,
        [parameter(Mandatory=$False)]
        [string] $Arguments = "",
        [parameter(Mandatory=$False)]
        [ValidateSet('file','web')]
        [string] $ShortcutType = 'file',
        [switch] $AllUsers
    )
    if ($ShortcutType -eq 'file' -and (!(Test-Path $Target))) {
        Write-Warning "Target not found: $Target"
        break
    }
    try {
        if ($AllUsers) {
            $ShortcutFile = "$env:ALLUSERSPROFILES\Desktop\$Name.lnk"
        }
        else {
            $ShortcutFile = "$env:USERPROFILE\Desktop\$Name.lnk"
        }
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
        $Shortcut.TargetPath = $Target
        if ($ShortcutType -eq 'file' -and $Arguments -ne "") {
            $Shortcut.Arguments = $Arguments
            $Shortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,167"
        }
        else {
            $Shortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,174"
        }
        $Shortcut.Save()
    }
    catch {
        Write-Error $Error[0].Exception.Message
    }
}

function Get-Shortcut {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $Path
    )
    if (!(Test-Path $Path)) {
        Write-Error "$Path was not found!"
        break
    }
    $ScPath = Get-Item $Path
    try {
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($Path)
        if ($ScPath.Extension -eq '.url') {
            $props = [ordered]@{
                Name   = $Shortcut.FullName
                Target = $Shortcut.TargetPath
                Icon   = $Shortcut.IconLocation
            }
        }
        else {
            $props = [ordered]@{
                Name      = $Shortcut.FullName
                Target    = $Shortcut.TargetPath
                Arguments = $Shortcut.Arguments
                Icon      = $Shortcut.IconLocation
            }
        }
        New-Object PSObject -Property $props
    }
    catch {}
}

try {
    Write-Host "unblocking scripts in skattertools folder..." -ForegroundColor Cyan
    Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1" -Recurse | Unblock-File -Confirm:$False
    $configFile  = (Join-Path $PSScriptRoot -ChildPath "config.txt")
    $sktoolsfile = (Join-Path $PSScriptRoot -ChildPath "Start-SkatterTools.ps1")
    Write-Host "opening config.txt for user customization..." -ForegroundColor Cyan
    Start-Process "notepad.exe" -ArgumentList $configFile -Wait
    foreach ($m in @('sqlserver','dbatools','carbon')) {
        if (!(Get-Module -Name $m -ListAvailable)) {
            Write-Host "installing powershell module: $m" -ForegroundColor Cyan
            Install-Module -Name $m -AllowClobber
        }
    }
    Write-Host "creating desktop shortcuts..." -ForegroundColor Cyan
    New-DesktopShortcut -Name "Start SkatterTools Web Service" -Target "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -Arguments $sktoolsfile
    New-DesktopShortcut -Name "SkatterTools" -Target "http://localhost:8080/" -ShortcutType web
    Write-Host "skattertools setup complete!" -ForegroundColor Cyan
}
catch {
    Write-Warning "Welcome to pukeville! Something just puked and died"
    Write-Error $Error[0].Exception.Message
}