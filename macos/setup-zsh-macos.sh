#!/bin/bash
#
# Zsh + Powerlevel10k Setup Script for macOS
#
# @author: Ovestokke
# @version: 1.0
#
# This script sets up Zsh with Powerlevel10k theme and modern CLI tools
# Based on: https://www.josean.com/posts/how-to-setup-wezterm-terminal
# Usage: bash Setup-Zsh-macOS.sh
#

set -e  # Exit on error

# Check bash version (require 3.2+ for macOS compatibility)
if [ "${BASH_VERSINFO:-0}" -lt 3 ]; then
    echo "Error: This script requires Bash 3.2 or later. Current version: $BASH_VERSION"
    exit 1
fi

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

print_header "Zsh + Powerlevel10k Setup for macOS"

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

print_header "Prerequisites Check"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_error "Homebrew is not installed"
    print_info "Install it from: https://brew.sh/"
    print_info "Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

print_success "Homebrew is installed"

# Check if zsh is installed and default shell
if ! command -v zsh &> /dev/null; then
    print_error "Zsh is not installed"
    exit 1
fi

print_success "Zsh is installed"

# Check current shell
CURRENT_SHELL=$(echo $SHELL)
if [[ "$CURRENT_SHELL" != *"zsh"* ]]; then
    print_warning "Current shell is not Zsh: $CURRENT_SHELL"
    read -p "Change default shell to Zsh? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        chsh -s $(which zsh)
        print_success "Default shell changed to Zsh (restart terminal to apply)"
    fi
else
    print_success "Zsh is the default shell"
fi

#endregion

#region Install Powerlevel10k

print_header "Powerlevel10k Installation"

if brew list powerlevel10k &> /dev/null; then
    print_warning "Powerlevel10k is already installed"
    read -p "Reinstall/Update? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        brew upgrade powerlevel10k || brew reinstall powerlevel10k
        print_success "Powerlevel10k updated"
    fi
else
    print_info "Installing Powerlevel10k via Homebrew..."
    if brew install powerlevel10k; then
        print_success "Powerlevel10k installed"
    else
        print_error "Failed to install Powerlevel10k"
        exit 1
    fi
fi

# Add to .zshrc
P10K_SOURCE_LINE="source \$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
if grep -q "powerlevel10k.zsh-theme" ~/.zshrc 2>/dev/null; then
    print_warning "Powerlevel10k already sourced in .zshrc"
else
    print_info "Adding Powerlevel10k to .zshrc..."
    echo "" >> ~/.zshrc
    echo "# Powerlevel10k theme" >> ~/.zshrc
    echo "$P10K_SOURCE_LINE" >> ~/.zshrc
    print_success "Powerlevel10k added to .zshrc"
fi

#endregion

#region Configure History

print_header "Zsh History Configuration"

HISTORY_CONFIG="# history setup
HISTFILE=\$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify"

if grep -q "HISTFILE=\$HOME/.zhistory" ~/.zshrc 2>/dev/null; then
    print_warning "History configuration already present in .zshrc"
else
    print_info "Adding history configuration to .zshrc..."
    echo "" >> ~/.zshrc
    echo "$HISTORY_CONFIG" >> ~/.zshrc
    print_success "History configuration added"
fi

# Get arrow key codes
print_info "Configuring arrow key history search..."
print_warning "Press UP arrow key now (or press Enter to use default ^[[A):"
read -t 5 -n 1 UP_KEY || UP_KEY=""
if [ -z "$UP_KEY" ]; then
    UP_CODE="^[[A"
else
    UP_CODE=$(printf '%s' "$UP_KEY" | od -An -tx1 | tr -d ' \n')
fi

print_warning "Press DOWN arrow key now (or press Enter to use default ^[[B):"
read -t 5 -n 1 DOWN_KEY || DOWN_KEY=""
if [ -z "$DOWN_KEY" ]; then
    DOWN_CODE="^[[B"
else
    DOWN_CODE=$(printf '%s' "$DOWN_KEY" | od -An -tx1 | tr -d ' \n')
fi

ARROW_BINDINGS="# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward"

if grep -q "history-search-backward" ~/.zshrc 2>/dev/null; then
    print_warning "Arrow key bindings already present in .zshrc"
else
    echo "" >> ~/.zshrc
    echo "$ARROW_BINDINGS" >> ~/.zshrc
    print_success "Arrow key bindings added"
fi

#endregion

#region Install Zsh Plugins

print_header "Zsh Plugins Installation"

# Install zsh-autosuggestions
if brew list zsh-autosuggestions &> /dev/null; then
    print_warning "zsh-autosuggestions already installed"
else
    print_info "Installing zsh-autosuggestions..."
    if brew install zsh-autosuggestions; then
        print_success "zsh-autosuggestions installed"
    else
        print_error "Failed to install zsh-autosuggestions"
    fi
fi

# Add to .zshrc
AUTOSUGGESTIONS_SOURCE="source \$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
if grep -q "zsh-autosuggestions.zsh" ~/.zshrc 2>/dev/null; then
    print_warning "zsh-autosuggestions already sourced in .zshrc"
else
    print_info "Adding zsh-autosuggestions to .zshrc..."
    echo "" >> ~/.zshrc
    echo "# zsh-autosuggestions" >> ~/.zshrc
    echo "$AUTOSUGGESTIONS_SOURCE" >> ~/.zshrc
    print_success "zsh-autosuggestions added to .zshrc"
fi

# Install zsh-syntax-highlighting
if brew list zsh-syntax-highlighting &> /dev/null; then
    print_warning "zsh-syntax-highlighting already installed"
else
    print_info "Installing zsh-syntax-highlighting..."
    if brew install zsh-syntax-highlighting; then
        print_success "zsh-syntax-highlighting installed"
    else
        print_error "Failed to install zsh-syntax-highlighting"
    fi
fi

# Add to .zshrc
SYNTAX_HIGHLIGHTING_SOURCE="source \$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if grep -q "zsh-syntax-highlighting.zsh" ~/.zshrc 2>/dev/null; then
    print_warning "zsh-syntax-highlighting already sourced in .zshrc"
else
    print_info "Adding zsh-syntax-highlighting to .zshrc..."
    echo "" >> ~/.zshrc
    echo "# zsh-syntax-highlighting" >> ~/.zshrc
    echo "$SYNTAX_HIGHLIGHTING_SOURCE" >> ~/.zshrc
    print_success "zsh-syntax-highlighting added to .zshrc"
fi

#endregion

#region Install Modern CLI Tools

print_header "Modern CLI Tools Installation"

# Install eza (better ls)
if command -v eza &> /dev/null; then
    print_warning "eza is already installed"
else
    print_info "Installing eza (better ls)..."
    if brew install eza; then
        print_success "eza installed"
    else
        print_error "Failed to install eza"
    fi
fi

# Add eza alias
if grep -q 'alias ls="eza --icons=always"' ~/.zshrc 2>/dev/null; then
    print_warning "eza alias already configured"
else
    print_info "Adding eza alias to .zshrc..."
    echo "" >> ~/.zshrc
    echo "# ---- Eza (better ls) -----" >> ~/.zshrc
    echo 'alias ls="eza --icons=always"' >> ~/.zshrc
    print_success "eza alias added"
fi

# Install zoxide (better cd)
if command -v zoxide &> /dev/null; then
    print_warning "zoxide is already installed"
else
    print_info "Installing zoxide (better cd)..."
    if brew install zoxide; then
        print_success "zoxide installed"
    else
        print_error "Failed to install zoxide"
    fi
fi

# Add zoxide to .zshrc
if grep -q 'eval "$(zoxide init zsh)"' ~/.zshrc 2>/dev/null; then
    print_warning "zoxide already configured"
else
    print_info "Adding zoxide to .zshrc..."
    echo "" >> ~/.zshrc
    echo "# ---- Zoxide (better cd) ----" >> ~/.zshrc
    echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
    echo 'alias cd="z"' >> ~/.zshrc
    print_success "zoxide configured"
fi

#endregion

#region Summary

print_header "Setup Complete!"

echo ""
print_success "Zsh with Powerlevel10k configured successfully!"
echo ""
echo -e "${CYAN}Installed:${NC}"
echo "  ✓ Powerlevel10k theme"
echo "  ✓ zsh-autosuggestions"
echo "  ✓ zsh-syntax-highlighting"
echo "  ✓ eza (better ls)"
echo "  ✓ zoxide (better cd)"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Restart your terminal or run: ${YELLOW}source ~/.zshrc${NC}"
echo "  2. Run Powerlevel10k configuration wizard: ${YELLOW}p10k configure${NC}"
echo "  3. For coolnight theme colors, choose ${YELLOW}lean${NC} (8 colors) or ${YELLOW}rainbow${NC} style"
echo ""
echo -e "${CYAN}Tips:${NC}"
echo "  - Use ${YELLOW}ls${NC} (eza) for better file listings with icons"
echo "  - Use ${YELLOW}cd${NC} or ${YELLOW}z${NC} (zoxide) for smart directory jumping"
echo "  - Use ${YELLOW}UP/DOWN${NC} arrows to search command history"
echo "  - Use ${YELLOW}RIGHT${NC} arrow to accept autosuggestions"
echo ""
echo -e "${CYAN}Configuration file:${NC} ~/.zshrc"
echo -e "${CYAN}P10k configuration:${NC} ~/.p10k.zsh"
echo -e "${CYAN}Reference guide:${NC} https://www.josean.com/posts/how-to-setup-wezterm-terminal"
echo ""

#endregion
