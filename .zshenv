# Environment variables for all shells (interactive and non-interactive)

# Machine-specific env (secrets, work config — not tracked by git)
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# Claude Code: use 400k context window to reduce prompt cache miss costs
export CLAUDE_CODE_AUTO_COMPACT_WINDOW=400000

# GNU coreutils
if [[ -d "/opt/homebrew/opt/coreutils/libexec/gnubin" ]]; then
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
elif [[ -d "/usr/local/opt/coreutils/libexec/gnubin" ]]; then
  export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
fi
