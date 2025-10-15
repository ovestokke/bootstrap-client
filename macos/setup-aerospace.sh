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
echo "  1. ${YELLOW}Disable 'Displays have separate Spaces'${NC} (recommended)"
echo "     → System Settings → Desktop & Dock → Displays have separate Spaces"
echo "     → Or run: ${CYAN}defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer${NC}"
echo "     → ${YELLOW}Logout required${NC} for this setting to take effect"
echo ""
echo "  2. ${YELLOW}Grant Accessibility Permissions${NC} (required)"
echo "     → System Settings → Privacy & Security → Accessibility"
echo "     → Add and enable AeroSpace"
echo ""
echo "  3. ${YELLOW}Arrange monitors properly${NC}"
echo "     → System Settings → Displays → Arrange…"
echo "     → Ensure every monitor has free space in bottom corners"
echo ""
echo "  4. ${YELLOW}Improve Mission Control${NC} (optional)"
echo "     → System Settings → Desktop & Dock → Group windows by application"
echo "     → Or run: ${CYAN}defaults write com.apple.dock expose-group-apps -bool true && killall Dock${NC}"
echo ""

read -p "Disable 'Displays have separate Spaces' now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Disabling 'Displays have separate Spaces'..."
    defaults write com.apple.spaces spans-displays -bool true
    killall SystemUIServer 2>/dev/null || true
    print_success "Setting updated. ${YELLOW}Logout required${NC} for changes to take effect"
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
echo -e "${CYAN}Default Keybindings:${NC}"
echo "  ${YELLOW}Alt + H/J/K/L${NC}         → Focus window (vim-style)"
echo "  ${YELLOW}Alt + Shift + H/J/K/L${NC} → Move window"
echo "  ${YELLOW}Alt + 1-9${NC}             → Switch workspace"
echo "  ${YELLOW}Alt + Shift + 1-9${NC}     → Move window to workspace"
echo "  ${YELLOW}Alt + /${NC}               → Toggle layout (tiles/accordion)"
echo "  ${YELLOW}Alt + Shift + ;${NC}       → Enter service mode"
echo ""
echo -e "${CYAN}Service Mode (Alt + Shift + ;):${NC}"
echo "  ${YELLOW}Esc${NC}       → Reload config & exit mode"
echo "  ${YELLOW}R${NC}         → Reset layout & exit mode"
echo "  ${YELLOW}F${NC}         → Toggle floating & exit mode"
echo "  ${YELLOW}Backspace${NC} → Close all windows but current & exit mode"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Launch AeroSpace: ${YELLOW}open -a AeroSpace${NC}"
echo "  2. Grant Accessibility permissions when prompted"
echo "  3. Customize config if needed: ${YELLOW}$AEROSPACE_CONFIG${NC}"
echo "  4. Check keybindings: ${YELLOW}aerospace list-keys${NC}"
echo "  5. View running apps: ${YELLOW}aerospace list-apps${NC}"
echo ""
echo -e "${CYAN}Configuration file:${NC} $AEROSPACE_CONFIG"
echo -e "${CYAN}Documentation:${NC} https://nikitabobko.github.io/AeroSpace/guide"
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
