#!/usr/bin/env zsh

# Exit immediately on errors and unset variables; fail pipelines fast
set -euo pipefail
trap 'echo "bootstrap.sh failed on line $LINENO" >&2' ERR

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Powerlevel10k is installed via Homebrew (see brew.sh) and sourced directly by
# .zshrc from $(brew --prefix)/share/powerlevel10k — no oh-my-zsh needed.

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
