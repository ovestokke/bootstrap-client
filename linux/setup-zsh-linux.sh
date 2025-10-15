#!/bin/bash
#
# Zsh + Powerlevel10k Setup Script for Linux/Ubuntu
#
# @author: Ovestokke
# @version: 1.0
#
# This script sets up Zsh with Oh My Zsh, Powerlevel10k theme, and modern CLI tools
# Works on Ubuntu, Debian, and WSL
# Usage: bash Setup-Zsh-Linux.sh
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

print_header "Zsh + Powerlevel10k Setup for Linux"

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

#region Check Prerequisites

print_header "Prerequisites Check"

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    print_warning "Zsh is not installed"
    read -p "Install Zsh? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing Zsh..."
        sudo apt-get update
        sudo apt-get install -y zsh
        print_success "Zsh installed"
    else
        print_error "Zsh is required for this setup"
        exit 1
    fi
else
    print_success "Zsh is installed"
fi

# Check current shell
CURRENT_SHELL=$(echo $SHELL)
if [[ "$CURRENT_SHELL" != *"zsh"* ]]; then
    print_warning "Current shell is not Zsh: $CURRENT_SHELL"
    read -p "Change default shell to Zsh? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        chsh -s $(which zsh)
        print_success "Default shell changed to Zsh (logout and login to apply)"
    fi
else
    print_success "Zsh is the default shell"
fi

# Install required packages
print_info "Installing required packages (curl, git)..."
sudo apt-get update
sudo apt-get install -y curl git fontconfig
print_success "Required packages installed"

#endregion

#region Install Oh My Zsh

print_header "Oh My Zsh Installation"

if [ -d "$HOME/.oh-my-zsh" ]; then
    print_warning "Oh My Zsh is already installed"
    read -p "Reinstall Oh My Zsh? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Removing existing Oh My Zsh..."
        rm -rf "$HOME/.oh-my-zsh"
        print_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    fi
else
    print_info "Installing Oh My Zsh..."
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        print_success "Oh My Zsh installed"
    else
        print_error "Failed to install Oh My Zsh"
        exit 1
    fi
fi

#endregion

#region Install Powerlevel10k

print_header "Powerlevel10k Installation"

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
    print_warning "Powerlevel10k already installed"
    read -p "Update Powerlevel10k? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Updating Powerlevel10k..."
        cd "$P10K_DIR"
        git pull
        cd - > /dev/null
        print_success "Powerlevel10k updated"
    fi
else
    print_info "Installing Powerlevel10k theme..."
    if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"; then
        print_success "Powerlevel10k installed"
    else
        print_error "Failed to install Powerlevel10k"
        exit 1
    fi
fi

# Set Powerlevel10k as the theme in .zshrc
if grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc 2>/dev/null; then
    print_warning "Powerlevel10k theme already configured in .zshrc"
else
    print_info "Configuring Powerlevel10k theme..."
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc
    print_success "Theme configured"
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

# Add arrow key bindings
ARROW_BINDINGS="# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward"

if grep -q "history-search-backward" ~/.zshrc 2>/dev/null; then
    print_warning "Arrow key bindings already present in .zshrc"
else
    print_info "Adding arrow key bindings to .zshrc..."
    echo "" >> ~/.zshrc
    echo "$ARROW_BINDINGS" >> ~/.zshrc
    print_success "Arrow key bindings added"
fi

#endregion

#region Install Zsh Plugins

print_header "Zsh Plugins Installation"

# Install zsh-autosuggestions plugin
AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ -d "$AUTOSUGGESTIONS_DIR" ]; then
    print_warning "zsh-autosuggestions already installed"
else
    print_info "Installing zsh-autosuggestions plugin..."
    if git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"; then
        print_success "zsh-autosuggestions installed"
    else
        print_error "Failed to install zsh-autosuggestions"
        exit 1
    fi
fi

# Install zsh-syntax-highlighting plugin
SYNTAX_HIGHLIGHTING_DIR="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ -d "$SYNTAX_HIGHLIGHTING_DIR" ]; then
    print_warning "zsh-syntax-highlighting already installed"
else
    print_info "Installing zsh-syntax-highlighting plugin..."
    if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HIGHLIGHTING_DIR"; then
        print_success "zsh-syntax-highlighting installed"
    else
        print_error "Failed to install zsh-syntax-highlighting"
        exit 1
    fi
fi

# Enable plugins in .zshrc
if grep -q "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" ~/.zshrc 2>/dev/null; then
    print_warning "Plugins already configured in .zshrc"
else
    print_info "Enabling plugins in .zshrc..."
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc
    print_success "Plugins enabled"
fi

#endregion

#region Install Modern CLI Tools

print_header "Modern CLI Tools Installation"

# Install eza (better ls)
if command -v eza &> /dev/null; then
    print_warning "eza is already installed"
else
    print_info "Installing eza (better ls)..."
    if apt-cache show eza &>/dev/null; then
        sudo apt-get install -y eza
        print_success "eza installed via apt"
    else
        print_info "Installing eza from third-party repository..."
        sudo apt-get install -y wget gpg
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt-get update
        if sudo apt-get install -y eza; then
            print_success "eza installed from third-party repository"
        else
            print_error "Failed to install eza"
        fi
    fi
fi

# Add eza alias to .zshrc
if grep -q 'alias ls="eza --icons=always"' ~/.zshrc 2>/dev/null; then
    print_warning "eza alias already configured"
else
    print_info "Adding eza alias to .zshrc..."
    {
        echo ""
        echo "# ---- Eza (better ls) -----"
        echo 'alias ls="eza --icons=always"'
    } >> ~/.zshrc
    print_success "eza alias added"
fi

# Install zoxide (better cd)
if command -v zoxide &> /dev/null; then
    print_warning "zoxide is already installed"
else
    print_info "Installing zoxide (better cd)..."
    if apt-cache show zoxide &>/dev/null; then
        sudo apt-get install -y zoxide
        print_success "zoxide installed via apt"
    else
        print_info "Installing zoxide via curl installer..."
        if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; then
            print_success "zoxide installed via curl"
        else
            print_error "Failed to install zoxide"
        fi
    fi
fi

# Add zoxide to .zshrc
if grep -q 'eval "$(zoxide init zsh)"' ~/.zshrc 2>/dev/null; then
    print_warning "zoxide already configured"
else
    print_info "Adding zoxide to .zshrc..."
    {
        echo ""
        echo "# ---- Zoxide (better cd) ----"
        echo 'eval "$(zoxide init zsh)"'
        echo 'alias cd="z"'
    } >> ~/.zshrc
    print_success "zoxide configured"
fi

#endregion

#region Install Meslo Nerd Font

print_header "Meslo Nerd Font Installation"

mkdir -p ~/.local/share/fonts
FONT_DIR=~/.local/share/fonts

print_info "Installing Meslo Nerd Font..."

FONTS=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
)

for font in "${FONTS[@]}"; do
    if [ -f "$FONT_DIR/$font" ]; then
        print_warning "$font already exists, skipping..."
    else
        print_info "Downloading $font..."
        FONT_URL="https://github.com/romkatv/powerlevel10k-media/raw/master/${font// /%20}"
        if curl -fLo "$FONT_DIR/$font" "$FONT_URL"; then
            print_success "$font downloaded"
        else
            print_error "Failed to download $font"
        fi
    fi
done

print_info "Updating font cache..."
fc-cache -f -v > /dev/null 2>&1
print_success "Font cache updated"

#endregion

#region Summary

print_header "Setup Complete!"

echo ""
print_success "Zsh with Oh My Zsh and Powerlevel10k configured successfully!"
echo ""
echo -e "${CYAN}Installed:${NC}"
echo "  ✓ Oh My Zsh"
echo "  ✓ Powerlevel10k theme"
echo "  ✓ zsh-autosuggestions"
echo "  ✓ zsh-syntax-highlighting"
echo "  ✓ eza (better ls)"
echo "  ✓ zoxide (better cd)"
echo "  ✓ Meslo Nerd Font"
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
echo -e "${CYAN}Configuration files:${NC}"
echo "  - Zsh config: ~/.zshrc"
echo "  - P10k config: ~/.p10k.zsh"
echo ""
echo -e "${CYAN}Reference guide:${NC} https://www.josean.com/posts/how-to-setup-wezterm-terminal"
echo ""

#endregion
