#!/usr/bin/env bash

# Exit on error. Append "|| true" if you expect an error.
set -e
# Exit on error in any piped commands
set -o pipefail

# Define constants
INSTALL_FOLDER="${HOME}/.macsetup"
MAC_SETUP_PROFILE="${INSTALL_FOLDER}/macsetup_profile"
CONFIG_DIR="${HOME}/.config"

# Utility functions
log_info() {
    printf "\033[0;34m%s\033[0m\n" "$1"
}

log_warning() {
    printf "\033[0;33m%s\033[0m\n" "$1"
}

log_error() {
    printf "\033[0;31m%s\033[0m\n" "$1" >&2
}

# Create necessary directories
mkdir -p "${INSTALL_FOLDER}"
mkdir -p "${CONFIG_DIR}"

# Check for and install Homebrew
if ! command -v brew >/dev/null 2>&1; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo >> "${HOME}/.zprofile"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    brew update
    source $HOME/.zprofile
else
    log_warning "Homebrew is already installed"
fi

# Install Rosetta 2 for M1 compatibility
log_info "Installing Rosetta 2..."
softwareupdate --install-rosetta --agree-to-license

# Basic development tools
log_info "Installing basic development tools..."
brew install \
    curl \
    wget \
    git \
    cmake \
    jq \
    htop \
    ripgrep \
    fzf
cp fzf.zsh $HOME/.fzf.zsh

# Install and configure ZSH
log_info "Setting up ZSH..."
if [[ -f "$HOME/.zshrc" ]]; then
    touch $HOME/.zshrc
else
    log_warning "$HOME/.zshrc already exists"
fi
brew install zsh zsh-completions
cat >> "$HOME/.zshrc" << 'EOF'
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH=$HOME/.local/bin:$PATH
alias tf=terraform
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:$(go env GOPATH)/bin"
# zsh syntax highlighting theme
source /Users/ireydiak/.config/zsh/zsh-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh
# now load zsh-syntax-highlighting plugin
source /Users/ireydiak/.config/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF

source $HOME/.zshrc

# ZSH completion configuration
cat >> "$HOME/.zshrc" << 'EOF'
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
    autoload -Uz compinit
    compinit
fi
EOF

# Install and configure Starship prompt
log_info "Setting up Starship prompt..."
sudo mkdir -p /usr/local/bin
if [[ -f "starship.toml" ]]; then
    cp starship.toml "${CONFIG_DIR}/"
else
    log_warning "starship.toml not found in current directory"
fi
curl -sS https://starship.rs/install.sh | sh
echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"

# Install Oh My Zsh
log_info "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Terminal utilities and aliases
log_info "Setting up terminal utilities..."
brew install --cask iterm2
cat >> "$HOME/.zshrc" << 'EOF'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
EOF

# Development environments
log_info "Installing development environments..."
brew install --cask jetbrains-toolbox
brew install neovim
cp -r nvim $HOME/.config

# Programming languages and tools
# Node.js
log_info "Setting up Node.js environment..."
brew install nvm
mkdir -p "${HOME}/.nvm"
cat >> "$HOME/.zshrc" << 'EOF'
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
EOF
source "$HOME/.zshrc"
nvm install node
brew install yarn
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Python
log_info "Setting up Python environment..."
brew install python pyenv
echo 'eval "$(pyenv init -)"' >> "$HOME/.zshrc"
pip3 install --user pipenv
pip3 install --upgrade setuptools pip

# Go
log_info "Setting up Go environment..."
brew install go

# PHP
log_info "Setting up PHP environment..."
/bin/bash -c "$(curl -fsSL https://php.new/install/mac)"

# Fonts
log_info "Installing fonts..."
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono

# Browsers
log_info "Installing browsers..."
brew install --cask \
    arc \
    google-chrome \
    firefox

# Applications
log_info "Installing applications..."
brew install --cask \
    spotify \
    slack \
    rapidapi \
    docker \
    dbeaver-community

# Docker utilities
log_info "Setting up Docker utilities..."
brew install \
    bash-completion \
    docker-completion \
    docker-compose-completion \
    docker-machine-completion

# Database tools
log_info "Setting up database tools..."
brew install libpq
brew link --force libpq

# AWS CLI
log_info "Installing AWS CLI..."
brew install awscli

# Terraform
log_info "Installing Terraform..."
brew install terraform
terraform -v

# Window management
log_info "Setting up window management..."
if [[ ! -d "./yabai" ]]; then
    git clone https://github.com/koekeishiya/yabai
    cd yabai
    make install > /dev/null
    cd ..
fi
if [[ -f "yabairc" ]]; then
    cp yabairc "${HOME}/.yabairc"
else
    log_warning "yabairc not found in current directory"
fi

# Final profile setup
log_info "Finalizing profile setup..."
echo "source $HOME/zshrc # alias and things added by mac_setup script" >> "${HOME}/.zsh_profile"
source "${HOME}/.zshrc"

log_info "Setup complete! Please restart your terminal for all changes to take effect."
