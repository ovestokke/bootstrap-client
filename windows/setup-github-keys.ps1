#
# GitHub SSH & GPG Keys Setup Script
#
# @author: Ovestokke
# @version: 1.0
#
# Run this script to generate and upload SSH and GPG keys to GitHub
# Usage: Run in PowerShell (Admin not required)
#

#region Functions

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Fail {
    param([string]$Message)
    Write-Host "  [FAIL] $Message" -ForegroundColor Red
}

function Write-Skip {
    param([string]$Message)
    Write-Host "  [SKIP] $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "  → $Message" -ForegroundColor Cyan
}

#endregion

# Start logging
$logFile = Join-Path $PSScriptRoot "Setup-GitHubKeys-Log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').log"
Start-Transcript -Path $logFile
Write-Host "Logging to: $logFile" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub SSH & GPG Keys Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

#region Check Prerequisites

# Check if gh CLI is installed
try {
    $ghVersion = gh --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "gh not found"
    }
    Write-Success "GitHub CLI (gh) is installed"
}
catch {
    Write-Fail "GitHub CLI (gh) is not installed"
    Write-Info "Install it with: winget install --id GitHub.cli -e"
    exit 1
}

# Check if git is installed
try {
    $gitVersion = git --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git not found"
    }
    Write-Success "Git is installed"
}
catch {
    Write-Fail "Git is not installed"
    Write-Info "Install it with: winget install --id Git.Git -e"
    exit 1
}

# Check if gpg is installed
try {
    $gpgVersion = gpg --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "gpg not found"
    }
    Write-Success "GPG is installed"
}
catch {
    Write-Fail "GPG is not installed"
    Write-Info "Install it with: winget install --id GnuPG.GnuPG -e"
    exit 1
}

Write-Host ""

#endregion

#region User Information

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "User Information" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get user information (prompt once, use immediately)
$existingName = git config --global user.name 2>$null
$existingEmail = git config --global user.email 2>$null

if ([string]::IsNullOrWhiteSpace($existingName)) {
    $gitName = Read-Host "Enter your full name (for Git)"
}
else {
    Write-Info "Current Git name: $existingName"
    $newName = Read-Host "Press Enter to use this name, or type a new one"
    $gitName = if ([string]::IsNullOrWhiteSpace($newName)) { $existingName } else { $newName }
}

if ([string]::IsNullOrWhiteSpace($existingEmail)) {
    $gitEmail = Read-Host "Enter your email (for Git & GitHub)"
}
else {
    Write-Info "Current Git email: $existingEmail"
    $newEmail = Read-Host "Press Enter to use this email, or type a new one"
    $gitEmail = if ([string]::IsNullOrWhiteSpace($newEmail)) { $existingEmail } else { $newEmail }
}

# Configure git immediately with user-confirmed values
Write-Info "Configuring Git..."
git config --global user.name "$gitName"
git config --global user.email "$gitEmail"
Write-Success "Git configured with name: $gitName and email: $gitEmail"

Write-Host ""

#endregion

#region SSH Key Generation

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SSH Key Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$sshDir = Join-Path $env:USERPROFILE ".ssh"
$sshKeyPath = Join-Path $sshDir "id_ed25519"
$sshPubKeyPath = "$sshKeyPath.pub"

if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}

$skipSsh = $false
if (Test-Path $sshKeyPath) {
    Write-Host "SSH key already exists at $sshKeyPath" -ForegroundColor Yellow
    $response = Read-Host "Do you want to generate a new one? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Info "Using existing SSH key"
        $skipSsh = $true
    }
}

if (-not $skipSsh) {
    Write-Info "Generating new SSH key (ed25519)..."
    
    # Generate SSH key
    ssh-keygen -t ed25519 -C "$gitEmail" -f $sshKeyPath -N '""'
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "SSH key generated at $sshKeyPath"
        
        # Start ssh-agent and add key
        try {
            Start-Service ssh-agent -ErrorAction SilentlyContinue
            Set-Service -Name ssh-agent -StartupType Automatic -ErrorAction SilentlyContinue
            ssh-add $sshKeyPath 2>$null
            Write-Success "SSH key added to ssh-agent"
        }
        catch {
            Write-Skip "Could not add key to ssh-agent (this is optional)"
        }
    }
    else {
        Write-Fail "Failed to generate SSH key"
        exit 1
    }
}

Write-Host ""

#endregion

#region GPG Key Generation

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GPG Key Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if GPG key already exists for this email
$existingGpg = gpg --list-secret-keys --keyid-format=long $gitEmail 2>$null

$skipGpg = $false
$gpgKeyId = $null

if (-not [string]::IsNullOrWhiteSpace($existingGpg)) {
    Write-Host "GPG key already exists for $gitEmail" -ForegroundColor Yellow
    gpg --list-secret-keys --keyid-format=long $gitEmail
    Write-Host ""
    $response = Read-Host "Do you want to generate a new one? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Info "Using existing GPG key"
        $skipGpg = $true
        
        # Extract key ID
        $gpgOutput = gpg --list-secret-keys --keyid-format=long $gitEmail 2>$null | Select-String "sec"
        if ($gpgOutput) {
            $gpgKeyId = ($gpgOutput -split "/")[1] -split " " | Select-Object -First 1
        }
    }
}

if (-not $skipGpg) {
    Write-Info "Generating new GPG key..."
    
    # Create batch file for unattended GPG key generation
    $gpgBatch = Join-Path $env:TEMP "gpg-batch.txt"
    
    try {
        @"
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $gitName
Name-Email: $gitEmail
Expire-Date: 0
"@ | Out-File -FilePath $gpgBatch -Encoding ASCII
        
        gpg --batch --generate-key $gpgBatch
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "GPG key generated"
            
            # Get the new key ID
            $gpgOutput = gpg --list-secret-keys --keyid-format=long $gitEmail 2>$null | Select-String "sec"
            if ($gpgOutput) {
                $gpgKeyId = ($gpgOutput -split "/")[1] -split " " | Select-Object -First 1
            }
            
            Write-Success "GPG Key ID: $gpgKeyId"
        }
        else {
            Write-Fail "Failed to generate GPG key"
            exit 1
        }
    }
    finally {
        # Always cleanup temp file
        Remove-Item $gpgBatch -Force -ErrorAction SilentlyContinue
    }
}

# Configure Git to use GPG key
if (-not [string]::IsNullOrWhiteSpace($gpgKeyId)) {
    Write-Info "Configuring Git to use GPG key for signing..."
    git config --global user.signingkey $gpgKeyId
    git config --global commit.gpgsign true
    git config --global tag.gpgsign true
    
    # Set GPG program path (needed on Windows)
    $gpgPath = (Get-Command gpg -ErrorAction SilentlyContinue).Path
    if ($gpgPath) {
        git config --global gpg.program $gpgPath
    }
    
    Write-Success "Git configured to sign commits and tags with GPG"
}

Write-Host ""

#endregion

#region Upload Keys to GitHub

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Uploading Keys to GitHub" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if user is authenticated with gh
$ghAuth = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not authenticated with GitHub CLI" -ForegroundColor Yellow
    Write-Info "Authenticating with GitHub..."
    gh auth login
}

# Upload SSH key
if ((-not $skipSsh) -or (Test-Path $sshPubKeyPath)) {
    Write-Info "Uploading SSH key to GitHub..."
    
    $hostname = $env:COMPUTERNAME
    $keyTitle = "$hostname-$(Get-Date -Format 'yyyyMMdd')"
    
    $sshKeyContent = Get-Content $sshPubKeyPath -Raw
    
    try {
        gh ssh-key add $sshPubKeyPath --title $keyTitle 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "SSH key uploaded to GitHub with title: $keyTitle"
        }
        else {
            throw "Failed to upload"
        }
    }
    catch {
        Write-Host "Failed to upload SSH key automatically" -ForegroundColor Yellow
        Write-Info "Your public SSH key:"
        Write-Host ""
        Write-Host $sshKeyContent -ForegroundColor Gray
        Write-Host ""
        Write-Info "Add it manually at: https://github.com/settings/ssh/new"
    }
}

# Upload GPG key
Write-Info "Uploading GPG key to GitHub..."

if (-not [string]::IsNullOrWhiteSpace($gpgKeyId)) {
    $gpgPubKey = gpg --armor --export $gpgKeyId
    
    # Save to temp file for gh
    $gpgTempFile = Join-Path $env:TEMP "gpg-pub-key.asc"
    $gpgPubKey | Out-File -FilePath $gpgTempFile -Encoding ASCII
    
    try {
        gh gpg-key add $gpgTempFile 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "GPG key uploaded to GitHub"
        }
        else {
            throw "Failed to upload"
        }
    }
    catch {
        Write-Host "Failed to upload GPG key automatically" -ForegroundColor Yellow
        Write-Info "Your public GPG key:"
        Write-Host ""
        Write-Host $gpgPubKey -ForegroundColor Gray
        Write-Host ""
        Write-Info "Add it manually at: https://github.com/settings/gpg/new"
    }
    finally {
        Remove-Item $gpgTempFile -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""

#endregion

#region Test SSH Connection

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing SSH Connection" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Info "Testing SSH connection to GitHub..."

$sshTest = ssh -T git@github.com 2>&1
if ($sshTest -match "successfully authenticated") {
    Write-Success "SSH connection to GitHub successful!"
}
else {
    Write-Host "SSH connection test inconclusive (this is normal for first-time setup)" -ForegroundColor Yellow
    Write-Info "Try running: ssh -T git@github.com"
}

Write-Host ""

#endregion

#region Summary

Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Success "GitHub SSH & GPG keys configured successfully!"
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  - SSH key: $sshKeyPath"
Write-Host "  - GPG key ID: $gpgKeyId"
Write-Host "  - Git commits will be automatically signed"
Write-Host ""
Write-Host "Verify your setup:" -ForegroundColor Cyan
Write-Host "  - View SSH keys: " -NoNewline; Write-Host "gh ssh-key list" -ForegroundColor Yellow
Write-Host "  - View GPG keys: " -NoNewline; Write-Host "gh gpg-key list" -ForegroundColor Yellow
Write-Host "  - Test signing: " -NoNewline; Write-Host "git commit --allow-empty -m 'Test signed commit'" -ForegroundColor Yellow
Write-Host ""
Write-Host "GitHub Settings:" -ForegroundColor Cyan
Write-Host "  - SSH keys: https://github.com/settings/keys"
Write-Host "  - GPG keys: https://github.com/settings/gpg/new"
Write-Host ""
Write-Host "Log file: $logFile" -ForegroundColor Cyan
Write-Host ""

Stop-Transcript

#endregion
