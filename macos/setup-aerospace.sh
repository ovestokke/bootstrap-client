#!/bin/bash
#
# AeroSpace Tiling Window Manager Setup Script for macOS
#
# @author: Ovestokke
# @version: 1.0
#
# This script installs and configures AeroSpace tiling window manager
# Usage: bash Setup-AeroSpace.sh
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

print_header "AeroSpace Tiling Window Manager Setup"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS"
    exit 1
fi

#region Check Prerequisites

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_error "Homebrew is not installed"
    print_info "Install it from: https://brew.sh/"
    print_info "Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

print_success "Homebrew is installed"

#endregion

#region Install AeroSpace

print_header "AeroSpace Installation"

if command -v aerospace &> /dev/null; then
    AEROSPACE_VERSION=$(aerospace --version 2>/dev/null || echo "unknown")
    print_warning "AeroSpace is already installed: $AEROSPACE_VERSION"
    read -p "Reinstall/Update AeroSpace? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Updating AeroSpace via Homebrew..."
        if brew upgrade --cask nikitabobko/tap/aerospace 2>/dev/null || brew install --cask nikitabobko/tap/aerospace; then
            print_success "AeroSpace updated successfully"
        else
            print_error "Failed to update AeroSpace"
            exit 1
        fi
    else
        print_info "Keeping existing AeroSpace installation"
    fi
else
    print_info "Installing AeroSpace via Homebrew..."
    if brew install --cask nikitabobko/tap/aerospace; then
        print_success "AeroSpace installed successfully"
    else
        print_error "Failed to install AeroSpace"
        exit 1
    fi
fi

#endregion

#region Configure AeroSpace

print_header "AeroSpace Configuration"

AEROSPACE_CONFIG="$HOME/.aerospace.toml"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_AEROSPACE_CONFIG="$(dirname "$SCRIPT_DIR")/.aerospace.toml"

if [ -f "$REPO_AEROSPACE_CONFIG" ]; then
    if [ -f "$AEROSPACE_CONFIG" ]; then
        print_warning "AeroSpace config already exists at: $AEROSPACE_CONFIG"
        read -p "Overwrite with repository config? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$REPO_AEROSPACE_CONFIG" "$AEROSPACE_CONFIG"
            print_success "AeroSpace config updated"
        else
            print_info "Keeping existing config"
        fi
    else
        cp "$REPO_AEROSPACE_CONFIG" "$AEROSPACE_CONFIG"
        print_success "AeroSpace config installed to: $AEROSPACE_CONFIG"
    fi
else
    if [ ! -f "$AEROSPACE_CONFIG" ]; then
        print_info "Creating default AeroSpace config..."
        print_info "Copying default config from AeroSpace installation..."
        
        if [ -f "/Applications/AeroSpace.app/Contents/Resources/default-config.toml" ]; then
            cp "/Applications/AeroSpace.app/Contents/Resources/default-config.toml" "$AEROSPACE_CONFIG"
            print_success "Default config installed to: $AEROSPACE_CONFIG"
        else
            print_warning "No default config found"
            print_info "AeroSpace will create one on first launch"
        fi
    else
        print_info "Using existing config at: $AEROSPACE_CONFIG"
    fi
fi

#endregion

#region System Settings Recommendations

print_header "System Settings Recommendations"

echo ""
print_info "For optimal AeroSpace experience, consider these settings:"
echo ""
echo -e "  1. \033[1;33mDisable 'Displays have separate Spaces'\033[0m (recommended)"
echo -e "     → System Settings → Desktop & Dock → Displays have separate Spaces"
echo -e "     → Or run: \033[0;36mdefaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer\033[0m"
echo -e "     → \033[1;33mLogout required\033[0m for this setting to take effect"
echo ""
echo -e "  2. \033[1;33mGrant Accessibility Permissions\033[0m (required)"
echo -e "     → System Settings → Privacy & Security → Accessibility"
echo -e "     → Add and enable AeroSpace"
echo ""
echo -e "  3. \033[1;33mArrange monitors properly\033[0m"
echo -e "     → System Settings → Displays → Arrange…"
echo -e "     → Ensure every monitor has free space in bottom corners"
echo ""
echo -e "  4. \033[1;33mImprove Mission Control\033[0m (optional)"
echo -e "     → System Settings → Desktop & Dock → Group windows by application"
echo -e "     → Or run: \033[0;36mdefaults write com.apple.dock expose-group-apps -bool true && killall Dock\033[0m"
echo ""

read -p "Disable 'Displays have separate Spaces' now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Disabling 'Displays have separate Spaces'..."
    defaults write com.apple.spaces spans-displays -bool true
    killall SystemUIServer 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Setting updated. \033[1;33mLogout required\033[0m for changes to take effect"
fi

read -p "Enable 'Group windows by application' in Mission Control? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Enabling 'Group windows by application'..."
    defaults write com.apple.dock expose-group-apps -bool true
    killall Dock
    print_success "Setting updated"
fi

#endregion

#region Summary

print_header "Setup Complete!"

echo ""
print_success "AeroSpace setup completed successfully!"
echo ""
echo -e "Default Keybindings:"
echo -e "  \033[1;33mAlt + H/J/K/L\033[0m         → Focus window (vim-style)"
echo -e "  \033[1;33mAlt + Shift + H/J/K/L\033[0m → Move window"
echo -e "  \033[1;33mAlt + 1-9\033[0m             → Switch workspace"
echo -e "  \033[1;33mAlt + Shift + 1-9\033[0m     → Move window to workspace"
echo -e "  \033[1;33mAlt + /\033[0m               → Toggle layout (tiles/accordion)"
echo -e "  \033[1;33mAlt + Shift + ;\033[0m       → Enter service mode"
echo ""
echo -e "Service Mode (Alt + Shift + ;):"
echo -e "  \033[1;33mEsc\033[0m       → Reload config & exit mode"
echo -e "  \033[1;33mR\033[0m         → Reset layout & exit mode"
echo -e "  \033[1;33mF\033[0m         → Toggle floating & exit mode"
echo -e "  \033[1;33mBackspace\033[0m → Close all windows but current & exit mode"
echo ""
echo -e "Next steps:"
echo -e "  1. Launch AeroSpace: \033[1;33mopen -a AeroSpace\033[0m"
echo -e "  2. Grant Accessibility permissions when prompted"
echo -e "  3. Customize config if needed: \033[1;33m$AEROSPACE_CONFIG\033[0m"
echo -e "  4. Check keybindings: \033[1;33maerospace list-keys\033[0m"
echo -e "  5. View running apps: \033[1;33maerospace list-apps\033[0m"
echo ""
echo -e "Configuration file: $AEROSPACE_CONFIG"
echo -e "Documentation: https://nikitabobko.github.io/AeroSpace/guide"
echo ""

# Offer to launch AeroSpace
read -p "Launch AeroSpace now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Launching AeroSpace..."
    open -a AeroSpace
    
    sleep 2
    print_warning "Please grant Accessibility permissions in System Settings if prompted"
    print_info "System Settings → Privacy & Security → Accessibility → Enable AeroSpace"
fi

#endregion
