# dotfiles

## Installation

Pull latest version and update local dotfiles
```
mkdir Developer && cd Developer && git clone https://github.com/estensen/dotfiles.git && cd dotfiles && zsh bootstrap.sh
```

Set sensible macOS defaults
```
zsh .macos
```

Install Homebrew pkgs
```
zsh brew.sh
```

Install global npm packages (rerun after Node is set up so `npm` is available)
```
zsh bootstrap.sh
```
