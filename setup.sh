#!/usr/bin/env bash

# Dotfiles Setup Script
# Orchestrates complete macOS development environment setup
# Exit immediately on errors and unset variables; fail pipelines fast
set -euo pipefail
trap 'echo "❌ setup.sh failed on line $LINENO" >&2' ERR

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Email for SSH key generation
SSH_EMAIL="haavard.ae@gmail.com"

# Helper functions
print_step() {
  echo -e "\n${BLUE}==>${NC} ${1}"
}

print_success() {
  echo -e "${GREEN}✓${NC} ${1}"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC}  ${1}"
}

print_error() {
  echo -e "${RED}✗${NC} ${1}"
}

print_header() {
  echo -e "\n${GREEN}================================${NC}"
  echo -e "${GREEN}  Dotfiles Setup${NC}"
  echo -e "${GREEN}================================${NC}\n"
}

# Check if running on macOS
check_macos() {
  if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script is designed for macOS only."
    exit 1
  fi
}

# Check and install Xcode Command Line Tools
install_xcode_clt() {
  print_step "Checking Xcode Command Line Tools..."

  if xcode-select -p &>/dev/null; then
    print_success "Xcode Command Line Tools already installed"
    return 0
  fi

  print_warning "Xcode Command Line Tools not found. Installing..."

  # Trigger installation
  xcode-select --install &>/dev/null || true

  # Wait for installation to complete
  print_warning "Please complete the Xcode Command Line Tools installation in the dialog."
  print_warning "Press Enter after installation completes..."
  read -r

  # Verify installation
  if xcode-select -p &>/dev/null; then
    print_success "Xcode Command Line Tools installed successfully"

    # Accept license if needed
    if ! sudo xcodebuild -license status &>/dev/null; then
      print_warning "Accepting Xcode license..."
      sudo xcodebuild -license accept
    fi
  else
    print_error "Xcode Command Line Tools installation failed"
    exit 1
  fi
}

# Setup SSH key
setup_ssh_key() {
  print_step "Checking SSH configuration..."

  local ssh_dir="${HOME}/.ssh"
  local ssh_key="${ssh_dir}/id_ed25519"
  local ssh_pub="${ssh_key}.pub"
  local ssh_config="${ssh_dir}/config"

  # Test GitHub SSH connection first - if it works, skip setup
  print_step "Testing SSH connection to GitHub..."
  if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    print_success "SSH already configured and working with GitHub"
    return 0
  fi

  # SSH not working, proceed with setup
  print_warning "SSH not configured or not working with GitHub, setting up..."

  # Create .ssh directory if it doesn't exist
  mkdir -p "${ssh_dir}"
  chmod 700 "${ssh_dir}"

  # Check if SSH key already exists
  if [[ -f "${ssh_key}" ]]; then
    print_success "SSH key already exists at ${ssh_key}"
  else
    print_warning "Generating new SSH key with email: ${SSH_EMAIL}"
    ssh-keygen -t ed25519 -C "${SSH_EMAIL}" -f "${ssh_key}" -N ""
    print_success "SSH key generated successfully"
  fi

  # Ensure proper permissions on key files
  chmod 600 "${ssh_key}"
  chmod 644 "${ssh_pub}"

  # Create or update SSH config (idempotent check)
  local needs_config_update=false

  if [[ ! -f "${ssh_config}" ]]; then
    needs_config_update=true
  else
    # Check if ALL required settings are present (more robust check)
    if ! grep -q "AddKeysToAgent yes" "${ssh_config}" || \
       ! grep -q "UseKeychain yes" "${ssh_config}" || \
       ! grep -q "IdentityFile.*id_ed25519" "${ssh_config}"; then
      needs_config_update=true
    fi
  fi

  if [[ "${needs_config_update}" == "true" ]]; then
    print_warning "Creating/updating SSH config..."

    # Backup existing config if it exists
    if [[ -f "${ssh_config}" ]]; then
      cp "${ssh_config}" "${ssh_config}.backup.$(date +%s)"
      print_warning "Backed up existing SSH config"
    fi

    # Check if our config block already exists
    if [[ -f "${ssh_config}" ]] && grep -q "# Dotfiles SSH configuration" "${ssh_config}"; then
      print_success "SSH config already has dotfiles configuration"
    else
      # Append our configuration
      cat >> "${ssh_config}" << 'EOF'

# Dotfiles SSH configuration
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
      chmod 600 "${ssh_config}"
      print_success "SSH config updated"
    fi
  else
    print_success "SSH config already properly configured"
  fi

  # Check if key is already in keychain before adding
  if ssh-add -l 2>/dev/null | grep -q "${ssh_key}"; then
    print_success "SSH key already in keychain"
  else
    print_warning "Adding SSH key to ssh-agent and keychain..."
    eval "$(ssh-agent -s)" >/dev/null
    ssh-add --apple-use-keychain "${ssh_key}" 2>/dev/null || ssh-add -K "${ssh_key}" 2>/dev/null
    print_success "SSH key added to keychain"
  fi

  # Display public key and instructions
  echo -e "\n${YELLOW}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${YELLOW}║  SSH Key Setup - Action Required                          ║${NC}"
  echo -e "${YELLOW}╚════════════════════════════════════════════════════════════╝${NC}\n"

  echo -e "Your SSH public key:\n"
  cat "${ssh_pub}"

  # Copy to clipboard
  cat "${ssh_pub}" | pbcopy
  echo -e "\n${GREEN}✓${NC} Public key copied to clipboard!"

  echo -e "\n${YELLOW}Next steps:${NC}"
  echo -e "1. Open GitHub SSH settings: ${BLUE}https://github.com/settings/ssh/new${NC}"
  echo -e "2. Paste the key (already in clipboard)"
  echo -e "3. Give it a title (e.g., 'MacBook Pro')"
  echo -e "4. Click 'Add SSH key'\n"

  echo -e "${YELLOW}Press Enter once you've added the SSH key to GitHub...${NC}"
  read -r

  # Test SSH connection again
  print_step "Testing SSH connection to GitHub..."
  if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    print_success "SSH connection to GitHub successful!"
  else
    print_warning "Could not verify GitHub SSH connection."
    print_warning "You may need to add the SSH key to GitHub manually."
    print_warning "Continuing anyway..."
  fi
}

# Install Homebrew and packages
install_homebrew_packages() {
  print_step "Installing Homebrew and packages..."

  # Check if brew.sh exists
  if [[ ! -f "$(dirname "$0")/brew.sh" ]]; then
    print_error "brew.sh not found in the same directory as setup.sh"
    exit 1
  fi

  # Run brew.sh
  bash "$(dirname "$0")/brew.sh"
  print_success "Homebrew packages installed"
}

# Sync dotfiles
sync_dotfiles() {
  print_step "Syncing dotfiles..."

  # Check if bootstrap.sh exists
  if [[ ! -f "$(dirname "$0")/bootstrap.sh" ]]; then
    print_error "bootstrap.sh not found in the same directory as setup.sh"
    exit 1
  fi

  # Run bootstrap.sh
  zsh "$(dirname "$0")/bootstrap.sh"
  print_success "Dotfiles synced"
}

# Setup nvm and Node.js
setup_node() {
  print_step "Setting up nvm and Node.js..."

  # Ensure NVM directory exists
  mkdir -p "${HOME}/.nvm"

  # Load nvm
  export NVM_DIR="${HOME}/.nvm"

  # Try to source nvm from Homebrew location first
  if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
    source "/opt/homebrew/opt/nvm/nvm.sh"
  elif [[ -s "/usr/local/opt/nvm/nvm.sh" ]]; then
    source "/usr/local/opt/nvm/nvm.sh"
  else
    print_error "nvm not found. Please ensure brew.sh completed successfully."
    exit 1
  fi

  print_success "nvm loaded"

  # Check if Node is already installed
  if command -v node &>/dev/null; then
    local current_version
    current_version=$(node --version)
    print_success "Node.js ${current_version} already installed"
  else
    print_warning "Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*
    print_success "Node.js LTS installed"
  fi

  # Verify npm is available
  if ! command -v npm &>/dev/null; then
    print_error "npm not available after Node installation"
    exit 1
  fi

  print_success "npm $(npm --version) available"
}

# Install global npm packages
install_npm_packages() {
  print_step "Installing global npm packages..."

  # Array of packages to install
  local packages=(
    "@microsoft/rush"
    "@openai/codex"
    "@anthropic-ai/claude-code"
  )

  for package in "${packages[@]}"; do
    if npm list -g --depth=0 "${package}" &>/dev/null; then
      print_success "${package} already installed"
    else
      print_warning "Installing ${package}..."
      npm install -g "${package}"
      print_success "${package} installed"
    fi
  done
}

# Apply macOS settings
apply_macos_settings() {
  print_step "Applying macOS settings..."

  # Check if .macos exists
  if [[ ! -f "$(dirname "$0")/.macos" ]]; then
    print_warning ".macos not found, skipping macOS settings"
    return 0
  fi

  # Ask user if they want to apply settings
  echo -e "${YELLOW}Do you want to apply macOS settings? (y/N)${NC}"
  read -r response

  if [[ "${response}" =~ ^[Yy]$ ]]; then
    zsh "$(dirname "$0")/.macos"
    print_success "macOS settings applied"
  else
    print_warning "Skipping macOS settings"
  fi
}

# Print summary
print_summary() {
  echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  Setup Complete! 🎉                                        ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}\n"

  echo -e "${BLUE}Installed:${NC}"
  echo -e "  ✓ Xcode Command Line Tools"
  echo -e "  ✓ SSH key configured"
  echo -e "  ✓ Homebrew and packages"
  echo -e "  ✓ Oh My Zsh with Powerlevel10k"
  echo -e "  ✓ Dotfiles synced"
  echo -e "  ✓ nvm and Node.js LTS"
  echo -e "  ✓ Global npm packages (rush, codex, claude-code)"

  echo -e "\n${YELLOW}Next steps:${NC}"
  echo -e "  1. Restart your terminal or run: ${BLUE}exec zsh${NC}"
  echo -e "  2. Configure Powerlevel10k: ${BLUE}p10k configure${NC}"
  echo -e "  3. Verify installations:"
  echo -e "     ${BLUE}node --version${NC}"
  echo -e "     ${BLUE}npm --version${NC}"
  echo -e "     ${BLUE}claude --version${NC}"
  echo -e "     ${BLUE}codex --version${NC}"

  echo -e "\n${GREEN}Enjoy your new development environment! 🚀${NC}\n"
}

# Main setup flow
main() {
  print_header

  # Change to script directory
  cd "$(dirname "$0")"

  check_macos
  install_xcode_clt
  setup_ssh_key
  install_homebrew_packages
  sync_dotfiles
  setup_node
  install_npm_packages
  apply_macos_settings
  print_summary
}

# Run main function
main "$@"
