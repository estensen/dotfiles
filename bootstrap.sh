# Exit immediately on errors and unset variables; fail pipelines fast
set -euo pipefail
trap 'echo "bootstrap.sh failed on line $LINENO" >&2' ERR

# Install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  export RUNZSH=no
  export KEEP_ZSHRC=yes
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  unset RUNZSH
  unset KEEP_ZSHRC
fi

# Install powerlevel10k theme if not already installed
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

rsync --exclude ".git/" \
	--exclude ".DS_Store" \
	--exclude ".macos" \
	--exclude "bootstrap.sh" \
	--exclude "README.md" \
	-avh --no-perms . ~;

export DISABLE_UPDATE_PROMPT=true
if command -v zsh >/dev/null 2>&1; then
  zsh -ic 'exit'
fi
unset DISABLE_UPDATE_PROMPT

install_global_npm_package() {
  local package="$1"
  if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found; skipping global install of ${package}. Install Node (via nvm) and rerun bootstrap." >&2
    return 0
  fi

  if npm list -g --depth=0 "${package}" >/dev/null 2>&1; then
    echo "Global package ${package} already installed."
  else
    npm install -g "${package}"
  fi
}

install_global_npm_package "@microsoft/rush"
install_global_npm_package "@openai/codex"
