# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"

# History search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# Allow for autocomplete to be case insensitive
zstyle ':completion:*' matcher-list '' \
'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
'+l:|?=** r:|?=**'
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select

setopt COMPLETE_ALIASES

if [ -f ~/.aliases ]; then
. ~/.aliases
fi

# GNU coreutils (replace macOS outdated utilities with GNU versions)
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX=$(brew --prefix)
  if [[ -d "${BREW_PREFIX}/opt/coreutils/libexec/gnubin" ]]; then
    export PATH="${BREW_PREFIX}/opt/coreutils/libexec/gnubin:$PATH"
  fi
fi

# Go binaries
export GOPATH=$HOME/go
export PATH="$PATH:$GOPATH/bin"
if command -v sccache >/dev/null 2>&1; then
  export RUSTC_WRAPPER="sccache"
fi
