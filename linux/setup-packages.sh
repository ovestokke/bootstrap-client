#!/bin/bash
#
# Linux Packages Installation Script
#
# @author: Ovestokke
# @version: 1.0
#
# This script installs development tools and applications.
# Configuration is managed by chezmoi - this script only installs packages.
#
# Requirements: apt package manager (Debian/Ubuntu-based distributions)
# Supported: Ubuntu, Debian, WSL (Ubuntu/Debian), Linux Mint, Pop!_OS, etc.
#
# Installed packages:
# - Zsh + Oh My Zsh + Powerlevel10k
# - Modern CLI tools (eza, zoxide, fzf, ripgrep, fd, bat)
# - Neovim + LazyVim dependencies (lazygit, build-essential)
# - GitHub CLI (gh)
# - GPG (for git signing)
# - chezmoi (dotfiles manager)
# - Meslo Nerd Font
#
# Usage:
#   bash linux/setup-packages.sh
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
print_header() { 
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
}

print_header "Linux Packages Installation"
echo ""
print_warning "This script installs packages only"
print_info "Configuration is managed by chezmoi"
echo ""

# Check for apt package manager
if ! command -v apt-get &> /dev/null; then
    print_error "This script requires apt package manager (Debian/Ubuntu-based distributions)"
    print_info "Supported: Ubuntu, Debian, WSL with Ubuntu/Debian, Linux Mint, Pop!_OS, etc."
    exit 1
fi

print_success "apt package manager detected"
echo ""

#region System Update

print_header "System Update"
print_info "Updating package lists..."
sudo apt-get update -qq
print_success "Package lists updated"
echo ""

#endregion

#region Essential Tools

print_header "Essential Tools"

ESSENTIAL_TOOLS=("curl" "git" "wget" "unzip" "build-essential")

for tool in "${ESSENTIAL_TOOLS[@]}"; do
    if dpkg -l | grep -q "^ii  $tool "; then
        print_success "$tool is already installed"
    else
        print_info "Installing $tool..."
        sudo apt-get install -y "$tool"
        print_success "$tool installed"
    fi
done

echo ""

#endregion

#region Zsh & Oh My Zsh

print_header "Zsh & Oh My Zsh"

# Install Zsh
if command -v zsh &> /dev/null; then
    print_success "Zsh is already installed"
else
    print_info "Installing Zsh..."
    sudo apt-get install -y zsh
    print_success "Zsh installed"
fi

# Install Oh My Zsh
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_success "Oh My Zsh is already installed"
else
    print_info "Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_success "Oh My Zsh installed"
    else
        print_error "Oh My Zsh installation failed"
    fi
fi

# Install Powerlevel10k
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ -d "$P10K_DIR" ]]; then
    print_success "Powerlevel10k is already installed"
else
    print_info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    print_success "Powerlevel10k installed"
fi

# Install zsh-autosuggestions
AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [[ -d "$AUTOSUGGESTIONS_DIR" ]]; then
    print_success "zsh-autosuggestions is already installed"
else
    print_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
    print_success "zsh-autosuggestions installed"
fi

# Install zsh-syntax-highlighting
SYNTAX_HIGHLIGHTING_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [[ -d "$SYNTAX_HIGHLIGHTING_DIR" ]]; then
    print_success "zsh-syntax-highlighting is already installed"
else
    print_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HIGHLIGHTING_DIR"
    print_success "zsh-syntax-highlighting installed"
fi

echo ""

#endregion

#region Modern CLI Tools

print_header "Modern CLI Tools"

# Install eza (better ls)
if command -v eza &> /dev/null; then
    print_success "eza is already installed"
else
    print_info "Installing eza..."
    if apt-cache show eza &>/dev/null; then
        sudo apt-get install -y eza
        print_success "eza installed via apt"
    else
        sudo apt-get install -y gpg
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt-get update -qq
        sudo apt-get install -y eza
        print_success "eza installed from third-party repository"
    fi
fi

# Install zoxide (better cd)
if command -v zoxide &> /dev/null; then
    print_success "zoxide is already installed"
else
    print_info "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    print_success "zoxide installed"
fi

# Install fzf (fuzzy finder)
if command -v fzf &> /dev/null; then
    print_success "fzf is already installed"
else
    print_info "Installing fzf..."
    sudo apt-get install -y fzf
    print_success "fzf installed"
fi

# Install ripgrep (better grep)
if command -v rg &> /dev/null; then
    print_success "ripgrep is already installed"
else
    print_info "Installing ripgrep..."
    sudo apt-get install -y ripgrep
    print_success "ripgrep installed"
fi

# Install fd (better find)
if command -v fd &> /dev/null || command -v fdfind &> /dev/null; then
    print_success "fd is already installed"
else
    print_info "Installing fd-find..."
    sudo apt-get install -y fd-find
    # Create symlink if fd doesn't exist
    if ! command -v fd &> /dev/null; then
        sudo ln -sf $(which fdfind) /usr/local/bin/fd 2>/dev/null || true
    fi
    print_success "fd-find installed"
fi

# Install bat (better cat)
if command -v bat &> /dev/null || command -v batcat &> /dev/null; then
    print_success "bat is already installed"
else
    print_info "Installing bat..."
    sudo apt-get install -y bat
    # Create symlink if bat doesn't exist
    if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
        sudo ln -sf $(which batcat) /usr/local/bin/bat 2>/dev/null || true
    fi
    print_success "bat installed"
fi

echo ""

#endregion

#region Neovim & Dependencies

print_header "Neovim & Dependencies"

# Add Neovim PPA for latest version
if ! grep -q "neovim-ppa/unstable" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
    print_info "Adding Neovim PPA..."
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update -qq
fi

# Install Neovim
if command -v nvim &> /dev/null; then
    NVIM_VERSION=$(nvim --version | head -n 1)
    print_success "Neovim is already installed: $NVIM_VERSION"
else
    print_info "Installing Neovim..."
    sudo apt-get install -y neovim
    print_success "Neovim installed"
fi

# Install lazygit
if command -v lazygit &> /dev/null; then
    print_success "lazygit is already installed"
else
    print_info "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    
    # Use /tmp to avoid WSL filesystem issues
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    curl -sLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    print_success "lazygit installed"
fi

# Check Neovim version
if command -v nvim &> /dev/null; then
    NVIM_VER_NUM=$(nvim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    REQUIRED_VER="0.11.2"
    
    if [[ "$(printf '%s\n' "$REQUIRED_VER" "$NVIM_VER_NUM" | sort -V | head -n1)" != "$REQUIRED_VER" ]]; then
        print_warning "Neovim version $NVIM_VER_NUM is below recommended $REQUIRED_VER"
        print_info "Consider upgrading Neovim"
    fi
fi

echo ""

#endregion

#region Git Tools

print_header "Git Tools"

# Install Git (if not already installed)
if command -v git &> /dev/null; then
    print_success "Git is already installed"
else
    print_info "Installing Git..."
    sudo apt-get install -y git
    print_success "Git installed"
fi

# Install GitHub CLI
if command -v gh &> /dev/null; then
    print_success "GitHub CLI is already installed"
else
    print_info "Installing GitHub CLI..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y gh
    print_success "GitHub CLI installed"
fi

# Install GPG
if command -v gpg &> /dev/null; then
    print_success "GPG is already installed"
else
    print_info "Installing GPG..."
    sudo apt-get install -y gnupg
    print_success "GPG installed"
fi

echo ""

#endregion

#region chezmoi

print_header "chezmoi (Dotfiles Manager)"

if command -v chezmoi &> /dev/null; then
    print_success "chezmoi is already installed"
else
    print_info "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    print_success "chezmoi installed"
fi

echo ""

#endregion

#region Meslo Nerd Font

print_header "Meslo Nerd Font"

mkdir -p "$HOME/.local/share/fonts"
FONT_DIR="$HOME/.local/share/fonts"

FONTS=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
)

for font in "${FONTS[@]}"; do
    if [[ -f "$FONT_DIR/$font" ]]; then
        print_success "$font already exists"
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

echo ""

#endregion

#region Summary

print_header "Package Installation Complete!"

echo ""
print_success "Installed packages:"
echo ""
echo "🐚 Shell:"
[[ -d "$HOME/.oh-my-zsh" ]] && echo "  ✓ Oh My Zsh"
[[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]] && echo "  ✓ Powerlevel10k"
[[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]] && echo "  ✓ zsh-autosuggestions"
[[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]] && echo "  ✓ zsh-syntax-highlighting"
echo ""
echo "🛠️  Modern CLI:"
[[ $(command -v eza) ]] && echo "  ✓ eza (better ls)"
[[ $(command -v zoxide) ]] && echo "  ✓ zoxide (better cd)"
[[ $(command -v fzf) ]] && echo "  ✓ fzf (fuzzy finder)"
[[ $(command -v rg) ]] && echo "  ✓ ripgrep (fast grep)"
[[ $(command -v fd || command -v fdfind) ]] && echo "  ✓ fd (fast find)"
[[ $(command -v bat || command -v batcat) ]] && echo "  ✓ bat (better cat)"
echo ""
echo "💻 Development:"
if command -v nvim &> /dev/null; then
    echo "  ✓ Neovim $(nvim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
fi
[[ $(command -v lazygit) ]] && echo "  ✓ lazygit"
[[ $(command -v gh) ]] && echo "  ✓ GitHub CLI"
[[ $(command -v gpg) ]] && echo "  ✓ GPG"
[[ $(command -v chezmoi) ]] && echo "  ✓ chezmoi"
echo ""
echo "🎨 Fonts:"
[[ -f "$HOME/.local/share/fonts/MesloLGS NF Regular.ttf" ]] && echo "  ✓ Meslo Nerd Font"
echo ""

print_warning "IMPORTANT: Configuration is managed by chezmoi"
echo ""
print_info "Next steps:"
echo "  1. Ensure chezmoi is initialized with your dotfiles"
echo -e "     ${YELLOW}chezmoi status${NC}"
echo ""
echo "  2. Apply your dotfiles configuration"
echo -e "     ${YELLOW}chezmoi apply${NC}"
echo ""
echo "  3. Set Zsh as default shell (if not already)"
echo -e "     ${YELLOW}chsh -s \$(which zsh)${NC}"
echo ""
echo "  4. Restart your terminal"
echo ""
echo "  5. Run Powerlevel10k configuration (first time only)"
echo -e "     ${YELLOW}p10k configure${NC}"
echo ""

print_info "Your dotfiles will configure:"
echo "  • Zsh (~/.zshrc, ~/.zprofile)"
echo "  • Neovim (~/.config/nvim/)"
echo "  • Git (~/.gitconfig)"
echo ""

#endregion
