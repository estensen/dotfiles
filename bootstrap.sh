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
source ~/.zshrc;
unset DISABLE_UPDATE_PROMPT
