#!/bin/bash
#
# WezTerm Setup Script for macOS
#
# @author: Ovestokke
# @version: 1.0
#
# This script installs and configures WezTerm with Meslo Nerd Font on macOS
# Usage: bash Setup-WezTerm.sh
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

print_header "WezTerm Setup Script for macOS"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_warning "This script is designed for macOS"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
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

#region Install WezTerm

print_header "WezTerm Installation"

if command -v wezterm &> /dev/null; then
    WEZTERM_VERSION=$(wezterm --version | head -n1)
    print_warning "WezTerm is already installed: $WEZTERM_VERSION"
    read -p "Reinstall/Update WezTerm? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Updating WezTerm via Homebrew..."
        if brew upgrade --cask wezterm 2>/dev/null || brew install --cask wezterm; then
            print_success "WezTerm updated successfully"
        else
            print_error "Failed to update WezTerm"
            exit 1
        fi
    else
        print_info "Keeping existing WezTerm installation"
    fi
else
    print_info "Installing WezTerm via Homebrew..."
    if brew install --cask wezterm; then
        print_success "WezTerm installed successfully"
    else
        print_error "Failed to install WezTerm"
        exit 1
    fi
fi

#endregion

#region Install Meslo Nerd Font

print_header "Meslo Nerd Font Installation"

# Check if font is already installed
FONT_INSTALLED=false
if fc-list | grep -i "meslo.*nerd" &> /dev/null; then
    FONT_INSTALLED=true
fi

if [ "$FONT_INSTALLED" = true ]; then
    print_warning "Meslo Nerd Font is already installed"
    read -p "Reinstall font? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Keeping existing font installation"
        SKIP_FONT=true
    else
        SKIP_FONT=false
    fi
else
    SKIP_FONT=false
fi

if [ "$SKIP_FONT" = false ]; then
    print_info "Installing Meslo Nerd Font via Homebrew..."
    
    # Tap homebrew-cask-fonts if not already tapped
    if ! brew tap | grep -q "homebrew/cask-fonts"; then
        print_info "Tapping homebrew/cask-fonts..."
        brew tap homebrew/cask-fonts
    fi
    
    if brew install --cask font-meslo-lg-nerd-font; then
        print_success "Meslo Nerd Font installed successfully"
    else
        print_warning "Failed to install via Homebrew, trying manual installation..."
        
        # Fallback: Manual installation
        FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip"
        FONT_ZIP="/tmp/Meslo.zip"
        FONT_DIR="$HOME/Library/Fonts"
        
        print_info "Downloading Meslo Nerd Font..."
        if curl -fL "$FONT_URL" -o "$FONT_ZIP"; then
            print_success "Download completed"
            
            print_info "Extracting fonts..."
            TEMP_EXTRACT="/tmp/MesloFonts"
            mkdir -p "$TEMP_EXTRACT"
            unzip -q "$FONT_ZIP" -d "$TEMP_EXTRACT"
            
            print_info "Installing fonts to $FONT_DIR..."
            mkdir -p "$FONT_DIR"
            INSTALLED=0
            for font in "$TEMP_EXTRACT"/*.ttf "$TEMP_EXTRACT"/*.otf; do
                if [ -f "$font" ]; then
                    cp "$font" "$FONT_DIR/"
                    INSTALLED=$((INSTALLED + 1))
                fi
            done
            
            print_success "Installed $INSTALLED font files"
            
            # Cleanup
            rm -rf "$FONT_ZIP" "$TEMP_EXTRACT"
            print_success "Cleanup completed"
        else
            print_error "Failed to download font"
            print_info "Manual installation: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip"
        fi
    fi
fi

#endregion

#region Configure WezTerm

print_header "WezTerm Configuration"

WEZTERM_CONFIG="$HOME/.wezterm.lua"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_WEZTERM_CONFIG="$(dirname "$SCRIPT_DIR")/.wezterm.lua"

if [ -f "$REPO_WEZTERM_CONFIG" ]; then
    if [ -f "$WEZTERM_CONFIG" ]; then
        print_warning "WezTerm config already exists at: $WEZTERM_CONFIG"
        read -p "Overwrite with repository config? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$REPO_WEZTERM_CONFIG" "$WEZTERM_CONFIG"
            print_success "WezTerm config updated"
        else
            print_info "Keeping existing config"
        fi
    else
        cp "$REPO_WEZTERM_CONFIG" "$WEZTERM_CONFIG"
        print_success "WezTerm config installed to: $WEZTERM_CONFIG"
    fi
else
    print_warning "No .wezterm.lua found in repository at: $REPO_WEZTERM_CONFIG"
    print_info "You'll need to create a config file at: $WEZTERM_CONFIG"
    print_info "Reference: https://wezfurlong.org/wezterm/config/files.html"
fi

#endregion

#region Summary

print_header "Setup Complete!"

echo ""
print_success "WezTerm setup completed successfully!"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Launch WezTerm from Applications or run: ${YELLOW}open -a WezTerm${NC}"
echo "  2. The Meslo Nerd Font should be automatically detected"
echo "  3. Configure your .wezterm.lua file if needed"
echo "  4. Use ${YELLOW}CMD + \\${NC} for horizontal split, ${YELLOW}CMD + -${NC} for vertical split"
echo "  5. Use ${YELLOW}CMD + h/j/k/l${NC} for vim-like pane navigation"
echo ""
echo -e "${CYAN}Configuration file:${NC} $WEZTERM_CONFIG"
echo -e "${CYAN}Reference guide:${NC} https://www.josean.com/posts/how-to-setup-wezterm-terminal"
echo ""

# Offer to launch WezTerm
read -p "Launch WezTerm now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Launching WezTerm..."
    open -a WezTerm
fi

#endregion
