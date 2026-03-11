#!/usr/bin/env zsh

# Exit immediately on errors and unset variables; fail pipelines fast
set -euo pipefail
trap 'echo "bootstrap.sh failed on line $LINENO" >&2' ERR

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

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
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

# Symlink dotfiles
DOTFILES=(
  .aliases
  .gitconfig
  .gitignore_global
  .hushlogin
  .p10k.zsh
  .vimrc
  .zshenv
  .zshrc
)

for file in "${DOTFILES[@]}"; do
  target="$HOME/$file"
  source="$DOTFILES_DIR/$file"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    continue
  fi

  if [ -e "$target" ]; then
    mv "$target" "$target.backup.$(date +%s)"
    echo "Backed up $target"
  fi

  ln -s "$source" "$target"
  echo "Linked $file"
done

export DISABLE_UPDATE_PROMPT=true
if command -v zsh >/dev/null 2>&1; then
  zsh -ic 'exit'
fi
unset DISABLE_UPDATE_PROMPT
