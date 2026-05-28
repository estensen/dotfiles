# Skip interactive setup when no TTY (e.g., Claude Code, IDE subshells)
[[ ! -t 0 ]] && return

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Add Homebrew completions to FPATH before oh-my-zsh loads
FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"

# Completion settings (before oh-my-zsh)
zstyle ':completion:*' matcher-list '' \
'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
'+l:|?=** r:|?=**'
zstyle ':completion:*' menu select

# Completion system. Rebuild the dump (with security audit) at most once a day;
# otherwise fast-load the cached dump with -C.
autoload -Uz compinit bashcompinit
() {
  emulate -L zsh
  local zdump="${ZDOTDIR:-$HOME}/.zcompdump"
  local -a fresh=( "$zdump"(Nmh-24) )   # dump modified within the last 24h
  if (( $#fresh )); then compinit -C -d "$zdump"; else compinit -i -d "$zdump"; fi
}
bashcompinit

# History (matches the old oh-my-zsh lib/history.zsh defaults)
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history hist_expire_dups_first hist_ignore_dups hist_ignore_space \
       hist_verify inc_append_history share_history

# Interactive options + directory navigation (oh-my-zsh parity)
setopt interactive_comments auto_pushd pushd_ignore_dups pushd_silent
alias ..='cd ..' ...='cd ../..' ....='cd ../../..'
alias md='mkdir -p'

# Key bindings (Home/End/Delete/word-nav — previously from oh-my-zsh)
bindkey '^[[H' beginning-of-line '^[OH' beginning-of-line '^[[1~' beginning-of-line
bindkey '^[[F' end-of-line       '^[OF' end-of-line       '^[[4~' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word   '^[[1;5D' backward-word
bindkey '^[[Z' reverse-menu-complete
bindkey '^?' backward-delete-char

# Powerlevel10k prompt, sourced directly (brew install powerlevel10k)
for _p10k_dir in /opt/homebrew/share/powerlevel10k /usr/local/share/powerlevel10k; do
  [[ -r "$_p10k_dir/powerlevel10k.zsh-theme" ]] && { source "$_p10k_dir/powerlevel10k.zsh-theme"; break }
done
unset _p10k_dir

# History search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

if [[ -f ~/.aliases ]]; then
  . ~/.aliases
fi

# Lazy-load nvm: define placeholder functions that source nvm on first call
export NVM_DIR="${HOME}/.nvm"
if [[ -s "${NVM_DIR}/nvm.sh" ]]; then
  _lazy_load_nvm() {
    unset -f nvm node npm npx
    source "${NVM_DIR}/nvm.sh"
    [[ -s "${NVM_DIR}/bash_completion" ]] && source "${NVM_DIR}/bash_completion"
  }
  nvm()  { _lazy_load_nvm; nvm "$@"; }
  node() { _lazy_load_nvm; node "$@"; }
  npm()  { _lazy_load_nvm; npm "$@"; }
  npx()  { _lazy_load_nvm; npx "$@"; }
fi

# Rust build cache
if command -v sccache >/dev/null 2>&1; then
  export RUSTC_WRAPPER="sccache"
fi

# Codex wrapper
cdx() {
  if [[ "$1" == "update" ]]; then
    npm install -g @openai/codex@latest
  else
    codex --enable multi_agent --yolo \
      -m "${CODEX_MODEL:-gpt-5.4}" \
      -c model_reasoning_effort="${CODEX_REASONING:-xhigh}" \
      -c model_reasoning_summary_format=experimental \
      --search "$@"
  fi
}

# Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Claude Code subagent default model — set to Haiku so mechanical Agent
# dispatches run cheap by default. Skills with `model:` frontmatter and
# Agent calls with explicit `model:` override this. A machine can override
# or `unset` this in ~/.zshrc.local below.
export CLAUDE_CODE_SUBAGENT_MODEL=claude-haiku-4-5-20251001

# Machine-specific overrides (not tracked by git). Sourced LAST so local
# settings win over everything above.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
