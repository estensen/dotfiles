# Environment variables for all shells (interactive and non-interactive)

# Keep PATH duplicate-free as the entries below (and the rc files) prepend to it.
# First occurrence wins, so ordering is preserved.
typeset -U path PATH

# Machine-specific env (secrets, work config — not tracked by git)
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# Claude Code: auto-compact at 1M to use the full 1M context window
export CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000

# Claude Code: enable the 1M-context SKU on Opus
export CLAUDE_CODE_DISABLE_1M_CONTEXT=0

# GNU coreutils
if [[ -d "/opt/homebrew/opt/coreutils/libexec/gnubin" ]]; then
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
elif [[ -d "/usr/local/opt/coreutils/libexec/gnubin" ]]; then
  export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
fi
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

export PATH="$PATH:$HOME/.foundry/bin"
