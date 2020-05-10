#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

brew install jq
brew install kubernetes-cli
brew install kubectx
brew install romkatv/powerlevel10k/powerlevel10k

brew cask install docker
brew cask install dropbox
brew cask install firefox
brew cask install goland
brew cask install google-chrome
brew cask install iterm2
brew cask install pycharm
brew cask install slack
brew cask install spectacle
brew cask install spotify
brew cask install visual-studio-code

# Remove outdated versions from the cellar.
brew cleanup
