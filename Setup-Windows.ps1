#
# Windows 10/11 Setup Script
#
# @author: Ovestokke
# @version: 1.1
#

#region Setup

# Set execution policy
Set-ExecutionPolicy Unrestricted -Force

#endregion

#region Drivers

# Drivers for GIGABYTE B850 AORUS ELITE WIFI7 ICE
# Download and install the latest drivers from the official support page:
# https://www.gigabyte.com/Motherboard/B850-AORUS-ELITE-WIFI7-ICE-rev-1x/support

#endregion

#region Remove Bloatware

# List of bloatware to remove
$bloatware = @(
    "Microsoft.549981C3F5F10", # Cortana
    "Microsoft.MicrosoftOfficeHub", # Office Hub
    "Microsoft.WindowsFeedbackHub", # Feedback Hub
    "Microsoft.GetHelp", # Get Help
    "Microsoft.Getstarted", # Get Started
    "Microsoft.People", # People
    "Microsoft.YourPhone", # Your Phone
    "Microsoft.WindowsAlarms", # Alarms & Clock
    "Microsoft.WindowsCamera", # Camera
    "Microsoft.WindowsMaps", # Maps
    "Microsoft.ZuneMusic", # Groove Music
    "Microsoft.ZuneVideo", # Movies & TV
    "Microsoft.MicrosoftSolitaireCollection", # Solitaire Collection
    "Microsoft.MixedReality.Portal", # Mixed Reality Portal
    "Microsoft.SkypeApp" # Skype
)

# Remove bloatware
foreach ($app in $bloatware) {
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers
}

#endregion

#region Privacy

# Disable telemetry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force

# Disable web search in Start Menu
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Force

# Disable Cortana
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -Force

#endregion

#region UI/UX

# Show file extensions
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Force

# Show hidden files
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Force

#endregion

#region Developer

# Enable Developer Mode
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Force

#endregion

#region WSL

# Enable WSL
wsl --install -d Ubuntu

#endregion

#region Install Applications

# List of applications to install using winget
# NOTE: You can find the exact ID of an application by running 'winget search "Application Name"' on your Windows machine.
# Using the exact ID is more reliable.
$appsToInstall = @(
    "Mozilla.Firefox",
    "Flow-Launcher.Flow-Launcher",
    "7zip.7zip",
    "Microsoft.VisualStudioCode",
    "Signal.Signal",
    "Git.Git",
    "GitHub.GitHubDesktop",
    "Microsoft.PowerToys",
    "WizTree.WizTree",
    "Obsidian.Obsidian",
    "1Password.1Password",
    "Google.Chrome",
    "TIDAL.TIDAL",
    "Valve.Steam",
    "EpicGames.EpicGamesLauncher",
    "ElectronicArts.EADesktop",
    "Discord.Discord",
    "Slack.Slack",
    "Microsoft.WindowsTerminal",
    "Google.CloudSDK",
    "Docker.DockerDesktop",
    "Terraform.Terraform",
    "Python.Python.3",
    "JGraph.Draw",
    "Anthropic.Claude" # Official Claude Desktop App. "Claude Code" is part of this app and not a separate installation.
)

# Install applications
foreach ($app in $appsToInstall) {
    winget install --id $app -e --accept-package-agreements --accept-source-agreements
}

#endregion

Write-Host "Windows setup script finished."
