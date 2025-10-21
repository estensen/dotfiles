# dotfiles

Automated macOS development environment setup with sensible defaults.

## Quick Start

**One-command setup for a new Mac:**

```bash
mkdir -p ~/Developer && cd ~/Developer && \
git clone https://github.com/estensen/dotfiles.git && \
cd dotfiles && \
chmod +x setup.sh && \
./setup.sh
```

That's it! The script will guide you through the rest.

## What Gets Installed

### Core Tools
- **Xcode Command Line Tools** - Installed automatically
- **SSH Key** - Generated and configured automatically (ed25519)
- **Homebrew** - Package manager for macOS
- **Oh My Zsh** - Enhanced terminal with Powerlevel10k theme

### Development Tools
- **nvm** - Node Version Manager
- **Node.js LTS** - Latest long-term support version
- **Git** - Version control with LFS support
- **Docker** - Container platform
- **PostgreSQL** - Database
- **Redis** - In-memory data store

### CLI Utilities
- coreutils, wget, tree, jq, ripgrep
- gh (GitHub CLI), pre-commit
- go, cmake, protobuf
- Claude Code CLI, Codex CLI

### Applications
- Firefox, Google Chrome
- Visual Studio Code
- Docker Desktop
- Slack, Spotify, Dropbox, Notion
- Ghostty (terminal)
- Rectangle (window management)

### Fonts
- Fira Code (with ligatures)

## Manual Installation Steps

If you prefer to run individual steps:

### 1. Sync dotfiles
```bash
zsh bootstrap.sh
```

### 2. Install Homebrew packages
```bash
zsh brew.sh
```

### 3. Apply macOS settings
```bash
zsh .macos
```

## Post-Installation

After setup completes:

1. **Restart your terminal** or run `exec zsh`
2. **Configure Powerlevel10k**: Run `p10k configure`
3. **Verify installations**:
   ```bash
   node --version
   npm --version
   claude --version
   codex --version
   ```

## What the Scripts Do

- **setup.sh** - Main orchestration script (recommended)
- **bootstrap.sh** - Installs Oh My Zsh, Powerlevel10k, syncs dotfiles
- **brew.sh** - Installs Homebrew and all packages/casks
- **.macos** - Configures macOS system preferences

## Customization

Edit the scripts before running to customize:
- Packages in `brew.sh`
- Dotfiles (`.zshrc`, `.gitconfig`, `.aliases`, `.vimrc`)
- macOS settings in `.macos`

## Troubleshooting

**SSH key not working?**
- Ensure you added the public key to GitHub: https://github.com/settings/ssh/new
- Test connection: `ssh -T git@github.com`

**Homebrew installation fails?**
- Check internet connection
- Ensure Xcode CLT is installed: `xcode-select -p`

**Node/npm not found?**
- Load nvm: `source ~/.zshrc` or restart terminal
- Verify: `nvm --version`

## License

MIT
