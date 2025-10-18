#!/bin/bash
#
# GitHub SSH & GPG Keys Setup Script
#
# @author: Ovestokke
# @version: 1.0
#
# Run this script to generate and upload SSH and GPG keys to GitHub
# Usage: bash Setup-GitHubKeys.sh
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_info() { echo -e "${CYAN}→${NC} $1"; }
print_header() { echo -e "\n${CYAN}========================================${NC}\n${CYAN}$1${NC}\n${CYAN}========================================${NC}"; }

print_header "GitHub SSH & GPG Keys Setup"

# Check and install required tools
print_info "Checking required tools..."

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_info "Installing Git..."
    sudo apt-get update -qq
    sudo apt-get install -y git
    print_success "Git installed"
else
    print_success "Git is already installed"
fi

# Check if gpg is installed
if ! command -v gpg &> /dev/null; then
    print_info "Installing GPG..."
    sudo apt-get install -y gnupg
    print_success "GPG installed"
else
    print_success "GPG is already installed"
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    print_info "Installing GitHub CLI (gh)..."
    
    # Add GitHub CLI repository
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    
    sudo apt-get update -qq
    sudo apt-get install -y gh
    print_success "GitHub CLI installed"
else
    print_success "GitHub CLI is already installed"
fi

echo ""

# Get user information from git config (should be set by chezmoi dotfiles)
print_header "User Information"

GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
    print_error "Git user.name or user.email not configured"
    echo ""
    print_warning "Your Git configuration should come from chezmoi dotfiles"
    print_info "Please ensure chezmoi is initialized and applied:"
    echo "  1. chezmoi init https://github.com/YOUR_USERNAME/dotfiles.git"
    echo "  2. chezmoi apply"
    echo ""
    print_info "Or manually configure Git:"
    echo "  git config --global user.name \"Your Name\""
    echo "  git config --global user.email \"your.email@example.com\""
    echo ""
    exit 1
fi

print_success "Using Git config from dotfiles:"
print_info "Name: $GIT_NAME"
print_info "Email: $GIT_EMAIL"

# SSH Key Generation
print_header "SSH Key Setup"

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
SSH_PUB_KEY_PATH="$SSH_KEY_PATH.pub"

if [ -f "$SSH_KEY_PATH" ]; then
    print_warning "SSH key already exists at $SSH_KEY_PATH"
    read -p "Do you want to generate a new one? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Using existing SSH key"
        SKIP_SSH=true
    else
        SKIP_SSH=false
    fi
else
    SKIP_SSH=false
fi

if [ "$SKIP_SSH" = false ]; then
    print_info "Generating new SSH key (ed25519)..."
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY_PATH" -N ""
    print_success "SSH key generated at $SSH_KEY_PATH"
    
    # Start ssh-agent and add key
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add "$SSH_KEY_PATH" 2>/dev/null
    print_success "SSH key added to ssh-agent"
fi

# GPG Key Generation
print_header "GPG Key Setup"

# Check if GPG key already exists for this email
EXISTING_GPG=$(gpg --list-secret-keys --keyid-format=long "$GIT_EMAIL" 2>/dev/null | grep "sec" || echo "")

if [ ! -z "$EXISTING_GPG" ]; then
    print_warning "GPG key already exists for $GIT_EMAIL"
    gpg --list-secret-keys --keyid-format=long "$GIT_EMAIL"
    echo
    read -p "Do you want to generate a new one? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Using existing GPG key"
        SKIP_GPG=true
        # Get the key ID
        GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format=long "$GIT_EMAIL" | grep "sec" | awk '{print $2}' | cut -d'/' -f2)
    else
        SKIP_GPG=false
    fi
else
    SKIP_GPG=false
fi

if [ "$SKIP_GPG" = false ]; then
    print_info "Generating new GPG key..."
    
    # Create batch file for unattended GPG key generation
    GPG_BATCH=$(mktemp)
    cat > "$GPG_BATCH" <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $GIT_NAME
Name-Email: $GIT_EMAIL
Expire-Date: 0
EOF
    
    gpg --batch --generate-key "$GPG_BATCH"
    rm "$GPG_BATCH"
    
    print_success "GPG key generated"
    
    # Get the new key ID
    GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format=long "$GIT_EMAIL" | grep "sec" | awk '{print $2}' | cut -d'/' -f2)
    print_success "GPG Key ID: $GPG_KEY_ID"
fi

# Configure Git to use GPG key
print_info "Configuring Git to use GPG key for signing..."
git config --global user.signingkey "$GPG_KEY_ID"
git config --global commit.gpgsign true
git config --global tag.gpgsign true
print_success "Git configured to sign commits and tags with GPG"

# Upload keys to GitHub
print_header "Uploading Keys to GitHub"

# Check if user is authenticated with gh
if ! gh auth status &> /dev/null; then
    print_warning "Not authenticated with GitHub CLI"
    print_info "Authenticating with GitHub..."
    gh auth login
fi

# Upload SSH key
if [ "$SKIP_SSH" = false ] || [ ! -z "$(cat $SSH_PUB_KEY_PATH)" ]; then
    print_info "Uploading SSH key to GitHub..."
    
    HOSTNAME=$(hostname)
    KEY_TITLE="$HOSTNAME-$(date +%Y%m%d)"
    
    if gh ssh-key add "$SSH_PUB_KEY_PATH" --title "$KEY_TITLE" 2>/dev/null; then
        print_success "SSH key uploaded to GitHub with title: $KEY_TITLE"
    else
        print_warning "Failed to upload SSH key automatically"
        print_info "Your public SSH key:"
        echo ""
        cat "$SSH_PUB_KEY_PATH"
        echo ""
        print_info "Add it manually at: https://github.com/settings/ssh/new"
    fi
fi

# Upload GPG key
print_info "Uploading GPG key to GitHub..."

GPG_PUB_KEY=$(gpg --armor --export "$GPG_KEY_ID")

if echo "$GPG_PUB_KEY" | gh gpg-key add 2>/dev/null; then
    print_success "GPG key uploaded to GitHub"
else
    print_warning "Failed to upload GPG key automatically"
    print_info "Your public GPG key:"
    echo ""
    echo "$GPG_PUB_KEY"
    echo ""
    print_info "Add it manually at: https://github.com/settings/gpg/new"
fi

# Test SSH connection
print_header "Testing SSH Connection"
print_info "Testing SSH connection to GitHub..."

if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    print_success "SSH connection to GitHub successful!"
else
    print_warning "SSH connection test inconclusive (this is normal for first-time setup)"
    print_info "Try running: ssh -T git@github.com"
fi

# Final summary
print_header "Setup Complete!"

echo ""
print_success "GitHub SSH & GPG keys configured successfully!"
echo ""
echo -e "${CYAN}Summary:${NC}"
echo "  - SSH key: $SSH_KEY_PATH"
echo "  - GPG key ID: $GPG_KEY_ID"
echo "  - Git commits will be automatically signed"
echo ""
echo -e "${CYAN}Verify your setup:${NC}"
echo "  - View SSH keys: ${YELLOW}gh ssh-key list${NC}"
echo "  - View GPG keys: ${YELLOW}gh gpg-key list${NC}"
echo "  - Test signing: ${YELLOW}git commit --allow-empty -m 'Test signed commit'${NC}"
echo ""
echo -e "${CYAN}GitHub Settings:${NC}"
echo "  - SSH keys: https://github.com/settings/keys"
echo "  - GPG keys: https://github.com/settings/gpg/new"
echo ""
