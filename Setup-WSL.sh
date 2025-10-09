#!/bin/bash
#
# WSL Ubuntu Setup Script
#
# @author: Ovestokke
# @version: 1.1
#
# Run this script inside WSL Ubuntu after initial WSL installation
# Usage: bash Setup-WSL.sh
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

# Check if running in WSL
if ! grep -qi microsoft /proc/version 2>/dev/null; then
    print_warning "This script is designed for WSL (Windows Subsystem for Linux)"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_header "WSL Ubuntu Configuration"
print_info "Starting setup process..."

# Update package lists and install required packages
print_header "System Update & Package Installation"
print_info "Updating apt and installing required packages..."

if sudo apt-get update && sudo apt-get install -y curl git zsh fontconfig; then
    print_success "Package installation completed"
else
    print_error "Failed to install required packages"
    exit 1
fi

# Install Oh My Zsh
print_header "Oh My Zsh Installation"

if [ -d "$HOME/.oh-my-zsh" ]; then
    print_warning "Oh My Zsh is already installed, skipping..."
else
    print_info "Installing Oh My Zsh..."
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        print_success "Oh My Zsh installed successfully"
    else
        print_error "Failed to install Oh My Zsh"
        exit 1
    fi
fi

# Install Powerlevel10k theme
print_header "Powerlevel10k Theme Installation"

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
    print_warning "Powerlevel10k already installed, skipping..."
else
    print_info "Installing Powerlevel10k theme..."
    if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"; then
        print_success "Powerlevel10k installed successfully"
    else
        print_error "Failed to install Powerlevel10k"
        exit 1
    fi
fi

# Set Powerlevel10k as the theme in .zshrc
if grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc; then
    print_warning "Powerlevel10k theme already configured in .zshrc"
else
    print_info "Configuring Powerlevel10k theme..."
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc
    print_success "Theme configured"
fi

# Install zsh-autosuggestions plugin
print_header "Zsh Plugins Installation"

AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ -d "$AUTOSUGGESTIONS_DIR" ]; then
    print_warning "zsh-autosuggestions already installed, skipping..."
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
    print_warning "zsh-syntax-highlighting already installed, skipping..."
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
if grep -q "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" ~/.zshrc; then
    print_warning "Plugins already configured in .zshrc"
else
    print_info "Enabling plugins in .zshrc..."
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc
    print_success "Plugins enabled"
fi

# Install eza (better ls)
print_header "Modern CLI Tools Installation"

if command -v eza &> /dev/null; then
    print_warning "eza is already installed, skipping..."
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
if grep -q 'alias ls="eza --icons=always"' ~/.zshrc; then
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
    print_warning "zoxide is already installed, skipping..."
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
if grep -q 'eval "$(zoxide init zsh)"' ~/.zshrc; then
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

# Install Meslo Nerd Font
print_header "Nerd Font Installation"

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

# Final summary
print_header "Setup Complete!"

echo ""
print_success "WSL Ubuntu configuration completed successfully!"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Change your default shell to zsh: ${YELLOW}chsh -s \$(which zsh)${NC}"
echo "  2. Restart your WSL session: ${YELLOW}exit${NC} then ${YELLOW}wsl -d Ubuntu${NC}"
echo "  3. Run Powerlevel10k configuration wizard: ${YELLOW}p10k configure${NC}"
echo ""
echo -e "${CYAN}Reference guide:${NC} https://www.josean.com/posts/how-to-setup-wezterm-terminal"
echo ""
