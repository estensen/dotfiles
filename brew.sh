#!/usr/bin/env bash

# Install and upgrade Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

brew install act
brew install cargo-binstall
brew install clang-format
brew install cmake
brew install doxygen
brew install gh
brew install git-lfs
brew install gnuplot
brew install go
brew install go-task/tap/go-task
brew install graphviz
brew install jq
brew install just
brew install localstack/tap/localstack-cli
brew install node
brew install postgresql
brew install pre-commit
brew install protobuf
brew install sccache
brew install redis
brew install ripgrep
brew install powerlevel10k
brew install tree
brew install wget

# YubiKey
brew install gnupg yubikey-personalization hopenpgp-tools ykman pinentry-mac

brew install --cask docker
brew install --cask dropbox
brew install --cask firefox
brew install --cask google-chrome
brew install --cask ghostty
brew install --cask rectangle
brew install --cask slack
brew install --cask spotify
brew install --cask visual-studio-code

brew tap homebrew/cask-fonts
brew install --cask font-fira-code

# Remove outdated versions from the cellar.
brew cleanup
