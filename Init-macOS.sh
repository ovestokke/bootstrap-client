#!/bin/bash
#
# Bootstrap Client Initialization Script for macOS
#
# @author: Ovestokke
# @version: 1.0
#
# This script automates the initial setup:
# 1. Installs Git (via Xcode Command Line Tools or Homebrew)
# 2. Installs Homebrew if needed
# 3. Clones the bootstrap-client repository
# 4. Launches the setup scripts
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YOUR-USERNAME/bootstrap-client/master/Init-macOS.sh | bash
#   OR save this file and run: bash Init-macOS.sh
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

print_header "Bootstrap Client Initialization for macOS"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS"
    exit 1
fi

print_success "Running on macOS"
echo ""

#region Install Git

print_header "Git Installation"

if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    print_success "Git is already installed: $GIT_VERSION"
else
    print_warning "Git is not installed"
    print_info "Installing Git via Xcode Command Line Tools..."
    echo ""
    
    # Install Xcode Command Line Tools
    xcode-select --install 2>/dev/null || true
    
    print_warning "Please complete the Xcode Command Line Tools installation in the popup window"
    print_warning "Press ENTER after installation is complete..."
    read
    
    # Verify installation
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version)
        print_success "Git installed: $GIT_VERSION"
    else
        print_error "Git installation failed"
        exit 1
    fi
fi

echo ""

#endregion

#region Install Homebrew

print_header "Homebrew Installation"

if command -v brew &> /dev/null; then
    BREW_VERSION=$(brew --version | head -n 1)
    print_success "Homebrew is already installed: $BREW_VERSION"
else
    print_warning "Homebrew is not installed"
    print_info "Homebrew is recommended for installing tools and applications"
    echo ""
    
    read -p "Install Homebrew? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for this session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        # Verify installation
        if command -v brew &> /dev/null; then
            BREW_VERSION=$(brew --version | head -n 1)
            print_success "Homebrew installed: $BREW_VERSION"
        else
            print_error "Homebrew installation failed"
            exit 1
        fi
    else
        print_warning "Skipping Homebrew installation"
        print_warning "Some features may require manual installation"
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

cd "$CLONE_LOCATION/macos"

echo ""
print_info "Available setup scripts:"
echo "  1. Setup-WezTerm.sh      - Install and configure WezTerm terminal"
echo "  2. Setup-Zsh-macOS.sh    - Configure Zsh with Powerlevel10k and tools"
echo "  3. Setup-GitHubKeys.sh   - Generate and upload SSH/GPG keys to GitHub"
echo "  4. Run all scripts in order"
echo ""

read -p "What would you like to do? (1-4 or skip): " SCRIPT_CHOICE

case $SCRIPT_CHOICE in
    1)
        print_info "Launching Setup-WezTerm.sh..."
        echo ""
        bash Setup-WezTerm.sh
        ;;
    2)
        print_info "Launching Setup-Zsh-macOS.sh..."
        echo ""
        bash Setup-Zsh-macOS.sh
        ;;
    3)
        print_info "Launching Setup-GitHubKeys.sh..."
        echo ""
        bash Setup-GitHubKeys.sh
        ;;
    4)
        print_info "Running all setup scripts..."
        echo ""
        
        print_header "Step 1: WezTerm Setup"
        bash Setup-WezTerm.sh
        
        print_header "Step 2: Zsh Setup"
        bash Setup-Zsh-macOS.sh
        
        print_header "Step 3: GitHub Keys Setup"
        bash Setup-GitHubKeys.sh
        
        print_header "All setup scripts completed!"
        ;;
    *)
        print_warning "Skipping script execution"
        echo ""
        print_info "To run setup scripts manually:"
        echo "  cd $CLONE_LOCATION/macos"
        echo "  bash Setup-WezTerm.sh"
        echo "  bash Setup-Zsh-macOS.sh"
        echo "  bash Setup-GitHubKeys.sh"
        ;;
esac

echo ""
print_header "Initialization Complete!"
print_success "Bootstrap client is ready to use"
echo ""

#endregion
