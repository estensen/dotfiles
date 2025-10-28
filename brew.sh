#!/usr/bin/env bash

# Exit immediately on errors and unset variables; fail pipelines fast
set -euo pipefail
trap 'echo "brew.sh failed on line $LINENO" >&2' ERR

# Install and upgrade Homebrew
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure the current shell knows about Homebrew (handles fresh installs too)
if command -v brew >/dev/null 2>&1; then
  BREW_EXEC="$(command -v brew)"
elif [ -x "/opt/homebrew/bin/brew" ]; then
  BREW_EXEC="/opt/homebrew/bin/brew"
elif [ -x "/usr/local/bin/brew" ]; then
  BREW_EXEC="/usr/local/bin/brew"
else
  echo "Homebrew installation did not succeed; brew command not found." >&2
  exit 1
fi

eval "$(${BREW_EXEC} shellenv)"

PROFILE_FILE="${HOME}/.zprofile"
BREW_SHELLENV_LINE="eval \"\$($(dirname "${BREW_EXEC}")/brew shellenv)\""

if [ ! -f "${PROFILE_FILE}" ]; then
  touch "${PROFILE_FILE}"
fi

if ! grep -Fq "${BREW_SHELLENV_LINE}" "${PROFILE_FILE}"; then
  {
    printf '\n# Added by dotfiles brew bootstrap to set Homebrew environment\n'
    printf '%s\n' "${BREW_SHELLENV_LINE}"
  } >> "${PROFILE_FILE}"
fi

brew update
brew upgrade

install_cask() {
  local cask_name="$1"
  local app_bundle="${2:-}"

  if brew list --cask --versions "${cask_name}" >/dev/null 2>&1; then
    echo "Cask ${cask_name} already installed."
    return 0
  fi

  if brew install --cask "${cask_name}"; then
    return 0
  fi

  if [[ -n "${app_bundle}" && -d "/Applications/${app_bundle}.app" ]]; then
    echo "Skipping ${cask_name}; /Applications/${app_bundle}.app already exists."
    return 0
  fi

  echo "Failed to install cask ${cask_name}" >&2
  return 1
}

# Handle renamed cask-fonts tap
if brew tap | grep -q '^homebrew/homebrew-cask-fonts$'; then
  brew untap homebrew/homebrew-cask-fonts
fi

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
brew install coreutils
# Create sha256sum symlink if it doesn't exist
if [ ! -e "${BREW_PREFIX}/bin/sha256sum" ]; then
  ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"
fi

brew install 1password-cli
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
brew install nvm
brew install orbstack
brew install postgresql@18
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

install_cask docker Docker
install_cask dropbox Dropbox
install_cask firefox Firefox
install_cask google-chrome "Google Chrome"
install_cask notion Notion
install_cask ghostty Ghostty
install_cask rectangle Rectangle
install_cask slack Slack
install_cask spotify Spotify
install_cask visual-studio-code "Visual Studio Code"

# Install fonts (fonts are now in main homebrew-cask, no tap needed)
install_cask font-fira-code "FiraCode"

# Remove outdated versions from the cellar.
brew cleanup

# Ensure NVM directory exists when installed via Homebrew.
mkdir -p "${HOME}/.nvm"
