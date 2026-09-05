### Guide

#### Update system packages

```bash
sudo apt update && sudo apt upgrade -y
```

#### Install GNU Stow & common tools

```bash
sudo apt install stow lsd xclip -y
```

#### Clone dotfiles

```bash
git clone git@github.com:Chengjing-314/dotfiles.git ~/dotfiles
cd ~/dotfiles
git checkout ubuntu_24_04work
```

#### Set up directories

```bash
mkdir -p ~/bin ~/.local/bin
```

#### Install Zsh & [Oh My Zsh](https://ohmyz.sh/#install)

```bash
sudo apt install zsh -y
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Install [auto suggestions](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md), [syntax highlighting](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md)

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

Stow zsh config (removes default .zshrc first):

```bash
rm ~/.zshrc
cd ~/dotfiles && stow zsh
```

Create `~/.zshrc_extra` for machine-specific config (proxy, nvm, etc.):

```bash
touch ~/.zshrc_extra
```

#### Install [Neovim](https://github.com/neovim/neovim/blob/master/INSTALL.md)

```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
```

Stow nvim config:

```bash
cd ~/dotfiles && stow nvim
```

Install packer

```bash
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

Install `tree-sitter` CLI (required by `nvim-treesitter` v1.0+ / `main` branch
to clone and compile parsers). It needs Node.js, so install nvm + Node first:

```bash
# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
\. "$HOME/.nvm/nvm.sh"

# Node.js (LTS or current)
nvm install 24

# tree-sitter CLI
npm install -g tree-sitter-cli
tree-sitter --version   # sanity check

# Symlink into ~/.local/bin so Neovim can find it regardless of whether
# nvm has been sourced in the current shell (e.g. GUI-launched nvim).
mkdir -p ~/.local/bin
ln -sf "$(which tree-sitter)" ~/.local/bin/tree-sitter
```

A C compiler is also required to build parsers (`build-essential` provides `gcc`):

```bash
sudo apt install build-essential -y
```

Open up neovim and run `:PackerSync` to install necessary packages, then
restart neovim and run `:TSUpdate` to download and compile all configured
tree-sitter parsers:

```vim
:PackerSync
" restart nvim, then:
:TSUpdate
```

Parsers are also installed automatically on launch via
`require('nvim-treesitter').install({...})` in `init.lua`, but `:TSUpdate`
forces a synchronous-ish refresh and is the canonical way to (re)install
everything after a config change.

#### Install [Kitty](https://sw.kovidgoyal.net/kitty/binary/)

```bash
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
echo 'kitty.desktop' > ~/.config/xdg-terminals.list
```

Install JetBrains Mono (system font used by this branch):

```bash
sudo apt install fonts-jetbrains-mono -y
```

Stow kitty config and set theme:

```bash
cd ~/dotfiles && stow kitty
kitten themes --reload-in=all Catppuccin-Frappe
```

#### Install [fzf](https://github.com/junegunn/fzf) (fuzzy finder)

The `.zshrc` block is guarded, so this step is optional — but without it
`ctrl+r` / `ctrl+t` / `alt+c` do nothing.

The apt package is old (22.04 ships 0.29.0, 24.04 ships 0.44.1). The `.zshrc`
handles both, but Homebrew gets you a current build:

```bash
brew install fzf fd bat        # preferred
# or, distro package:
sudo apt install fzf fd-find bat -y
```

`fd` and `bat` are optional — they add .gitignore-aware file search and syntax-
highlighted previews. The config detects them and falls back cleanly if absent.
On apt they install as `fdfind` / `batcat`, so symlink them onto the expected
names:

```bash
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
ln -sf "$(which batcat)" ~/.local/bin/bat
```

#### Install [fzf-tab](https://github.com/Aloxaf/fzf-tab) (fuzzy TAB completion)

Makes TAB open an fzf picker over completion candidates. Optional — `.zshrc`
only adds it to `plugins` if this directory exists.

```bash
git clone --depth 1 https://github.com/Aloxaf/fzf-tab \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
```

Note: fzf-tab *filters* the candidates zsh already generated — it does not make
zsh generate more. So type the fuzzy string **inside the picker after TAB**, not
on the command line before it.

#### Stow all at once

```bash
cd ~/dotfiles && stow zsh nvim kitty
```
