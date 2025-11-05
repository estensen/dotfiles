# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Add Homebrew completions to FPATH before oh-my-zsh loads
if command -v brew >/dev/null 2>&1; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Completion settings (before oh-my-zsh)
zstyle ':completion:*' matcher-list '' \
'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
'+l:|?=** r:|?=**'
zstyle ':completion:*' menu select

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# History search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# Shell completions for installed tools
# GitHub CLI
if command -v gh >/dev/null 2>&1; then
  eval "$(gh completion -s zsh)"
fi

# Docker (if installed via Docker Desktop, completions may already be available)
# Node/npm completions are already provided by Homebrew
# Go completions are built into zsh
# Rust/cargo completions would need rustup, which installs them automatically

if [ -f ~/.aliases ]; then
. ~/.aliases
fi

# Node version manager
export NVM_DIR="${HOME}/.nvm"
if [ -s "${NVM_DIR}/nvm.sh" ]; then
  source "${NVM_DIR}/nvm.sh"
  if [ -s "${NVM_DIR}/bash_completion" ]; then
    source "${NVM_DIR}/bash_completion"
  fi

  autoload -U add-zsh-hook
  load-nvmrc() {
    local nvmrc_path node_version
    nvmrc_path="$(nvm_find_nvmrc)"
    if [[ -n "${nvmrc_path}" ]]; then
      node_version="$(nvm version "$(cat "${nvmrc_path}")")"
      if [[ "${node_version}" == "N/A" ]]; then
        nvm install
      elif [[ "${node_version}" != "$(nvm version)" ]]; then
        nvm use "${node_version}" >/dev/null
      fi
    elif [[ "$(nvm version)" != "$(nvm version default)" ]]; then
      nvm use default >/dev/null
    fi
  }
  add-zsh-hook chpwd load-nvmrc
  load-nvmrc
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
