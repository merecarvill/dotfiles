#!/bin/bash

# define helper fns

link () {
  if ! [ -f "$PWD/$1" ]; then
    echo "Error: failed to link $1 (cannot find file)"
    return
  fi

  if [ -L "$HOME/.$1" ]; then
    echo "Already done: link $1"
    return
  fi

  rm -f "$HOME/.$1"

  if ln -s "$PWD/$1" "$HOME/.$1"; then
    echo "Linked: $1"
  fi
}

# install fonts

git clone https://github.com/powerline/fonts.git --depth=1
cd fonts || exit
./install.sh
cd ..
rm -rf fonts

# install homebrew

if ! [ -x "$(command -v brew)" ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Already done: install homebrew"
fi

# install binaries and apps

brew bundle
brew cleanup

# link dotfiles

if ! [ -L "$HOME/.gitconfig" ]; then
  rm -f "$HOME/.gitconfig"

  if ln -s "$PWD/gitconfig" "$HOME/.gitconfig"; then
    echo "Linked: gitconfig"
  fi
fi

if ! [ -L "$HOME/.config/fish" ]; then
  rm -rf "$HOME/.config/fish"

  if ln -s "$PWD/fish" "$HOME/.config/fish"; then
    echo "Linked: .config/fish"
  fi
fi

if ! [ -L "$HOME/.config/omf" ]; then
  rm -rf "$HOME/.config/omf"

  if ln -s "$PWD/omf" "$HOME/.config/omf"; then
    echo "Linked: .config/omf"
  fi
fi

# configure macos

defaults write -g AppleInterfaceStyle -string "Dark" # set dark theme
defaults write -g AppleShowScrollBars -string "Always" # always show scrollbars
defaults write -g com.apple.sound.uiaudio.enabled -bool false # disable ui sound effects
defaults write -g com.apple.swipescrolldirection -bool false # disable natural scrolling (e.g. up motion scrolls up)
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false # disable smart dash substitution
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false # disable smart quote substitution
defaults write com.apple.dock autohide -bool true # auto-hide dock
defaults write com.apple.dock launchanim -bool false # disable opening animation from dock

# configure iterm

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$PWD/iterm2"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# generate ssh key

if ! [ -f "$HOME/.ssh/id_ed25519" ]; then
  echo "Generating SSH Key"
  echo "Enter email:"
  read -r email

  ssh-keygen -t ed25519 -C "$email"
  ln -s "$PWD/ssh/config" "$HOME/.ssh/config"
  ssh-add -K "$HOME/.ssh/id_ed25519"

  echo "SSH key generated:"
  cat "$HOME/.ssh/id_ed25519.pub"
fi

# setup fish shell

fish_path="/usr/local/bin/fish"

if ! grep -q $fish_path /etc/shells; then
  echo $fish_path | tee -a /etc/shells
  chsh -s $fish_path
fi

fish fish_setup.fish
