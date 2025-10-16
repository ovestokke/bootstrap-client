#
# PowerShell Profile Configuration
#
# @author: Ovestokke
# @version: 1.0
#
# This profile is loaded when PowerShell starts
# Location (PowerShell 7+): ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# Location (Windows PowerShell): ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
#

#region Oh My Posh

oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/catppuccin_mocha.omp.json | Invoke-Expression

# More themes available at: https://ohmyposh.dev/docs/themes

#endregion

#region Import Modules

Import-Module Terminal-Icons -ErrorAction SilentlyContinue
Import-Module z -ErrorAction SilentlyContinue
Import-Module PSReadLine -ErrorAction SilentlyContinue
Import-Module PSFzf -ErrorAction SilentlyContinue

#endregion

#region PSReadLine Configuration

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -Colors @{
    Command   = 'Cyan'
    Parameter = 'Gray'
    String    = 'Green'
    Operator  = 'Magenta'
}

#endregion

#region PSFzf Configuration

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f'
Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'

#endregion

#region Aliases

Set-Alias -Name g -Value git

if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name vim -Value nvim
}

Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name c -Value Clear-Host

#endregion

#region Custom Functions

function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function touch ($file) {
    if (Test-Path $file) {
        (Get-Item $file).LastWriteTime = Get-Date
    }
    else {
        "" | Out-File $file -Encoding ASCII
    }
}

function mkcd ($dir) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Set-Location $dir
}

function open ($path = ".") {
    Invoke-Item $path
}

function gs { git status }
function ga { git add -A }
function gc ($message) { git commit -m $message }
function gp { git push }
function gpl { git pull }

function glog {
    git log --oneline --graph --decorate --all
}

function dc { docker-compose @args }

function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

function tree ($path = ".", $depth = 2) {
    if (Get-Command tree.com -ErrorAction SilentlyContinue) {
        tree.com /F /A $path
    }
    else {
        Get-ChildItem $path -Recurse -Depth $depth |
            ForEach-Object {
                $indent = "  " * ($_.FullName.Split([IO.Path]::DirectorySeparatorChar).Count - $path.Split([IO.Path]::DirectorySeparatorChar).Count)
                Write-Host "$indent$($_.Name)" -ForegroundColor $(if ($_.PSIsContainer) { "Cyan" } else { "White" })
            }
    }
}

function Reload-Profile {
    & $PROFILE
    Write-Host "Profile reloaded!" -ForegroundColor Green
}

function Edit-Profile {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        code $PROFILE
    }
    elseif (Get-Command notepad++ -ErrorAction SilentlyContinue) {
        notepad++ $PROFILE
    }
    else {
        notepad $PROFILE
    }
}

#endregion
