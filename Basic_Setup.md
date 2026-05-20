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
git checkout ubuntu_24_04
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

Open up neovim and run `:PackerSync` to install necessary packages

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

Stow kitty config:

```bash
cd ~/dotfiles && stow kitty
```

#### Install MesloLGS NF (Nerd Font)

```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz
tar -xf Meslo.tar.xz
rm Meslo.tar.xz
fc-cache -fv
```

#### Set Kitty theme

```bash
kitten themes
```

Select `Mayukai` (or your preferred theme).

#### Stow all at once

```bash
cd ~/dotfiles && stow zsh nvim kitty
```
