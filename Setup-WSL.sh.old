#!/bin/bash
#
# WSL Ubuntu Setup Script
#
# @author: Ovestokke
# @version: 1.0
#
# Run this script inside WSL Ubuntu after initial WSL installation
# Usage: bash Setup-WSL.sh
#

echo "Starting WSL Ubuntu configuration..."

# Update package lists and install required packages
echo "Updating apt and installing required packages..."
sudo apt-get update
sudo apt-get install -y curl git zsh fontconfig

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Powerlevel10k theme
echo "Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Set Powerlevel10k as the theme in .zshrc
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc

# Install zsh-autosuggestions plugin
echo "Installing zsh-autosuggestions plugin..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install zsh-syntax-highlighting plugin
echo "Installing zsh-syntax-highlighting plugin..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Enable plugins in .zshrc
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc

# Install eza (better ls) via apt (available in Ubuntu 24.04+) or download binary
echo "Installing eza (better ls)..."
if apt-cache show eza &>/dev/null; then
    sudo apt-get install -y eza
else
    sudo apt-get install -y wget gpg
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update
    sudo apt-get install -y eza
fi

# Add eza alias to .zshrc
echo "" >> ~/.zshrc
echo "# ---- Eza (better ls) -----" >> ~/.zshrc
echo 'alias ls="eza --icons=always"' >> ~/.zshrc

# Install zoxide (better cd) via apt (available in Ubuntu 23.10+) or curl installer
echo "Installing zoxide (better cd)..."
if apt-cache show zoxide &>/dev/null; then
    sudo apt-get install -y zoxide
else
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# Add zoxide to .zshrc
echo "" >> ~/.zshrc
echo "# ---- Zoxide (better cd) ----" >> ~/.zshrc
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
echo 'alias cd="z"' >> ~/.zshrc

# Install Meslo Nerd Font (for terminal icons)
echo "Installing Meslo Nerd Font..."
mkdir -p ~/.local/share/fonts
FONT_DIR=~/.local/share/fonts
curl -fLo "$FONT_DIR/MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
curl -fLo "$FONT_DIR/MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
curl -fLo "$FONT_DIR/MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
curl -fLo "$FONT_DIR/MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
fc-cache -f -v

echo ""
echo "WSL Ubuntu configuration completed!"
echo ""
echo "Next steps:"
echo "1. Change your default shell to zsh: chsh -s \$(which zsh)"
echo "2. Restart your WSL session"
echo "3. Run 'p10k configure' to configure the Powerlevel10k theme"
echo "4. Reference guide: https://www.josean.com/posts/how-to-setup-wezterm-terminal"
