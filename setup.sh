INSTALL_FOLDER=$HOME/.macsetup
mkdir -p $INSTALL_FOLDER
MAC_SETUP_PROFILE=$INSTALL_FOLDER/macsetup_profile

if ! hash brew
then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew update
else
    printf "\e[93m%s\e[m\n" "You already have brew installed."
fi

# cURL & wget
brew install curl
brew install wget
{
  # shellcheck disable=SC2016
  echo 'export PATH="/usr/local/opt/curl/bin:$PATH"'
  # shellcheck disable=SC2016
  echo 'export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"'
  # shellcheck disable=SC2016
  echo 'export PATH="/usr/local/opt/sqlite/bin:$PATH"'
}>>$MAC_SETUP_PROFILE

# zsh
brew install zsh zsh-completions                                                                      # Install zsh and zsh completions
sudo chmod -R 755 /usr/local/share/zsh
sudo chown -R root:staff /usr/local/share/zsh
{
  echo "if type brew &>/dev/null; then"
  echo "  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH"
  echo "  autoload -Uz compinit"
  echo "  compinit"
  echo "fi"
} >>$MAC_SETUP_PROFILE
curl -sS https://starship.rs/install.sh | sh
echo 'eval "$(starship init zsh)"' >> $MAC_SETUP_PROFILE

# git & cmake
brew install git
brew install cmake

# Install oh-my-zsh on top of zsh to getting additional functionality
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# terminal
brew install --cask iterm2
{
  echo "alias l='ls -l'"
  echo "alias la='ls -a'"
  echo "alias lla='ls -la'"
} >>$MAC_SETUP_PROFILE
brew install jq
brew install htop
brew install ripgrep

# IDE
brew install --cask jetbrains-toolbox
brew install neovim

## Setup Neovim

# JavaScript, NodeJS
brew install nvm                                                                                     # choose your version of npm
nvm install node                                                                                     # "node" is an alias for the latest version
brew install yarn
curl -fsSL https://get.pnpm.io/install.sh | sh -

# PHP
/bin/bash -c "$(curl -fsSL https://php.new/install/mac)"

# Golang
brew install go

# python
echo "export PATH=\"/usr/local/opt/python/libexec/bin:\$PATH\"" >> $MAC_SETUP_PROFILE
brew install python
pip install --user pipenv
pip install --upgrade setuptools
pip install --upgrade pip
brew install pyenv
# shellcheck disable=SC2016
echo 'eval "$(pyenv init -)"' >> $MAC_SETUP_PROFILE

# fonts
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono

# misc
brew install --cask spotify
brew install --cask slack
brew install --cask google-chrome
git clone https://github.com/koekeishiya/yabai && cd ./yabai && make install >> /dev/null && cd ..
brew install alt-tab
brew install --cask rapidapi

# Docker
brew install --cask docker
brew install bash-completion
brew install docker-completion
brew install docker-compose-completion
brew install docker-machine-completion
softwareupdate --install-rosetta

# Databases
brew install --cask dbeaver-community
brew install libpq                  # postgre command line
brew link --force libpq
# shellcheck disable=SC2016
echo 'export PATH="/usr/local/opt/libpq/bin:$PATH"' >> $MAC_SETUP_PROFILE

# AWS command line
brew install awscli

# terraform
brew install terraform
terraform -v

# reload profile
{
  echo "source $MAC_SETUP_PROFILE # alias and things added by mac_setup script"
}>>"$HOME/.zsh_profile"
# shellcheck disable=SC1090
source "$HOME/.zsh_profile"
