#!/usr/bin/env zsh

# Mute startup sound
sudo nvram StartupMute=%01

# Finder settings
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.Finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Screenshots
mkdir -p ~/screenshots
defaults write com.apple.screencapture location ~/screenshots/
defaults write com.apple.screencapture type png

cd ~ && ln -s dotfiles/.zshrc .zshrc
cd ~ && ln -s dotfiles/.wezterm.lua .wezterm.lua
cd ~ && ln -s dotfiles/.gitconfig .gitconfig
