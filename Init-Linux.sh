#!/bin/bash
#
# Bootstrap Client Initialization Script for Linux/Ubuntu
#
# @author: Ovestokke
# @version: 1.0
#
# This script automates the initial setup:
# 1. Installs Git via apt
# 2. Clones the bootstrap-client repository
# 3. Launches the setup scripts
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YOUR-USERNAME/bootstrap-client/master/Init-Linux.sh | bash
#   OR save this file and run: bash Init-Linux.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_info() { echo -e "${CYAN}→${NC} $1"; }
print_header() { echo -e "\n${CYAN}========================================${NC}\n${CYAN}$1${NC}\n${CYAN}========================================${NC}"; }

print_header "Bootstrap Client Initialization for Linux"

# Detect environment
if grep -qi microsoft /proc/version 2>/dev/null; then
    ENV_TYPE="WSL"
    print_info "Detected environment: WSL"
elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    ENV_TYPE="$ID"
    print_info "Detected environment: $NAME"
else
    ENV_TYPE="Unknown"
    print_warning "Could not detect environment"
fi

echo ""

#region Install Git

print_header "Git Installation"

if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    print_success "Git is already installed: $GIT_VERSION"
else
    print_warning "Git is not installed"
    print_info "Installing Git via apt..."
    echo ""
    
    sudo apt-get update
    
    if sudo apt-get install -y git; then
        GIT_VERSION=$(git --version)
        print_success "Git installed: $GIT_VERSION"
    else
        print_error "Git installation failed"
        exit 1
    fi
fi

echo ""

#endregion

#region Install curl

print_header "curl Installation"

if command -v curl &> /dev/null; then
    CURL_VERSION=$(curl --version | head -n 1)
    print_success "curl is already installed: $CURL_VERSION"
else
    print_warning "curl is not installed"
    print_info "Installing curl via apt..."
    echo ""
    
    sudo apt-get update
    
    if sudo apt-get install -y curl; then
        CURL_VERSION=$(curl --version | head -n 1)
        print_success "curl installed: $CURL_VERSION"
    else
        print_error "curl installation failed"
        exit 1
    fi
fi

echo ""

#endregion

#region Clone Repository

print_header "Repository Setup"

# Ask for clone location
DEFAULT_LOCATION="$HOME/bootstrap-client"
echo ""
print_info "Where should the repository be cloned?"
read -p "Location (default: $DEFAULT_LOCATION): " CLONE_LOCATION

if [[ -z "$CLONE_LOCATION" ]]; then
    CLONE_LOCATION="$DEFAULT_LOCATION"
fi

print_info "Clone location: $CLONE_LOCATION"
echo ""

# Check if directory already exists
if [[ -d "$CLONE_LOCATION" ]]; then
    print_warning "Directory already exists: $CLONE_LOCATION"
    
    # Check if it's a git repository
    if [[ -d "$CLONE_LOCATION/.git" ]]; then
        print_success "Directory is a git repository"
        
        read -p "Update repository? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Updating repository..."
            cd "$CLONE_LOCATION"
            git pull
            print_success "Repository updated"
        fi
    else
        print_error "Directory exists but is not a git repository"
        print_warning "Please remove the directory or choose a different location"
        exit 1
    fi
else
    echo ""
    print_info "Repository URL options:"
    echo "  [1] HTTPS (default): https://github.com/ovestokke/bootstrap-client.git"
    echo "  [2] SSH: git@github.com:ovestokke/bootstrap-client.git"
    echo "  [3] Custom URL (your fork or private repo)"
    echo ""
    
    read -p "Choose clone method (1, 2, or 3, default: 1): " URL_CHOICE
    
    # Default to HTTPS if empty
    if [[ -z "$URL_CHOICE" ]]; then
        URL_CHOICE=1
    fi
    
    case $URL_CHOICE in
        1)
            REPO_URL="https://github.com/ovestokke/bootstrap-client.git"
            ;;
        2)
            REPO_URL="git@github.com:ovestokke/bootstrap-client.git"
            ;;
        3)
            read -p "Enter repository URL: " REPO_URL
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
    
    echo ""
    print_info "Cloning repository from: $REPO_URL"
    print_info "To: $CLONE_LOCATION"
    echo ""
    
    if git clone "$REPO_URL" "$CLONE_LOCATION"; then
        print_success "Repository cloned successfully"
    else
        print_error "Git clone failed"
        exit 1
    fi
fi

echo ""

#endregion

#region Launch Setup Scripts

print_header "Launch Setup Scripts"

cd "$CLONE_LOCATION/linux"

echo ""
print_info "Available setup scripts:"
echo "  1. Setup-Zsh-Linux.sh    - Configure Zsh with Powerlevel10k and tools"
echo "  2. Setup-GitHubKeys.sh   - Generate and upload SSH/GPG keys to GitHub"
echo "  3. Setup-WSL.sh          - Legacy WSL configuration (use option 1 instead)"
echo "  4. Run recommended scripts (1 & 2)"
echo ""

read -p "What would you like to do? (1-4 or skip): " SCRIPT_CHOICE

case $SCRIPT_CHOICE in
    1)
        print_info "Launching Setup-Zsh-Linux.sh..."
        echo ""
        bash Setup-Zsh-Linux.sh
        ;;
    2)
        print_info "Launching Setup-GitHubKeys.sh..."
        echo ""
        bash Setup-GitHubKeys.sh
        ;;
    3)
        print_info "Launching Setup-WSL.sh (legacy)..."
        echo ""
        bash Setup-WSL.sh
        ;;
    4)
        print_info "Running recommended setup scripts..."
        echo ""
        
        print_header "Step 1: Zsh Setup"
        bash Setup-Zsh-Linux.sh
        
        print_header "Step 2: GitHub Keys Setup"
        bash Setup-GitHubKeys.sh
        
        print_header "All setup scripts completed!"
        ;;
    *)
        print_warning "Skipping script execution"
        echo ""
        print_info "To run setup scripts manually:"
        echo "  cd $CLONE_LOCATION/linux"
        echo "  bash Setup-Zsh-Linux.sh"
        echo "  bash Setup-GitHubKeys.sh"
        ;;
esac

echo ""
print_header "Initialization Complete!"
print_success "Bootstrap client is ready to use"
echo ""

#endregion
