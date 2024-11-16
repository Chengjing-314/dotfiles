#!/bin/zsh

# Define paths for dotfiles and target locations
DOTFILES_DIR="$HOME/dotfiles"
ZSHRC_EXTRA="$HOME/.zshrc_extra"
NVIM_CONFIG="$HOME/.config/nvim/init.lua"
KITTY_CONFIG="$HOME/.config/kitty/kitty.conf"

# Step 1: Link .zshrc_extra
DOTFILES_ZSHRC_EXTRA="$DOTFILES_DIR/.zshrc_extra"
if [[ -f "$ZSHRC_EXTRA" && ! -L "$ZSHRC_EXTRA" ]]; then
    echo "Renaming existing .zshrc_extra to .zshrc_extra+pre-init..."
    mv "$ZSHRC_EXTRA" "$ZSHRC_EXTRA+pre-init"
fi
if [[ ! -L "$ZSHRC_EXTRA" ]]; then
    echo "Creating symbolic link for .zshrc_extra..."
    ln -s "$DOTFILES_ZSHRC_EXTRA" "$ZSHRC_EXTRA"
else
    echo "Symbolic link for .zshrc_extra already exists."
fi

# Ensure .zshrc_extra exists in dotfiles
if [[ ! -f "$DOTFILES_ZSHRC_EXTRA" ]]; then
    echo "Creating an empty .zshrc_extra in dotfiles..."
    touch "$DOTFILES_ZSHRC_EXTRA"
fi

# Step 2: Link init.lua for Neovim
DOTFILES_NVIM_INIT="$DOTFILES_DIR/init.lua"
if [[ -f "$NVIM_CONFIG" && ! -L "$NVIM_CONFIG" ]]; then
    echo "Renaming existing init.lua to init.lua+pre-init..."
    mv "$NVIM_CONFIG" "$NVIM_CONFIG+pre-init"
fi
if [[ ! -L "$NVIM_CONFIG" ]]; then
    echo "Creating symbolic link for init.lua in Neovim..."
    mkdir -p "$(dirname "$NVIM_CONFIG")"  # Ensure the parent directory exists
    ln -s "$DOTFILES_NVIM_INIT" "$NVIM_CONFIG"
else
    echo "Symbolic link for init.lua already exists."
fi

# Step 3: Link kitty.conf for Kitty
DOTFILES_KITTY_CONF="$DOTFILES_DIR/kitty.conf"
if [[ -f "$KITTY_CONFIG" && ! -L "$KITTY_CONFIG" ]]; then
    echo "Renaming existing kitty.conf to kitty.conf+pre-init..."
    mv "$KITTY_CONFIG" "$KITTY_CONFIG+pre-init"
fi
if [[ ! -L "$KITTY_CONFIG" ]]; then
    echo "Creating symbolic link for kitty.conf in Kitty..."
    mkdir -p "$(dirname "$KITTY_CONFIG")"  # Ensure the parent directory exists
    ln -s "$DOTFILES_KITTY_CONF" "$KITTY_CONFIG"
else
    echo "Symbolic link for kitty.conf already exists."
fi

# Step 4: Initialize Conda in .zshrc_extra
echo "Running conda init and directing output to .zshrc_extra..."
conda init zsh > /dev/null 2>&1

# Copy the initialization output to .zshrc_extra if conda init succeeds
if [[ $? -eq 0 ]]; then
    conda init zsh > "$DOTFILES_ZSHRC_EXTRA"
    echo "Conda initialization block added to .zshrc_extra."
else
    echo "Error: Conda initialization failed. Ensure conda is installed and accessible."
fi

# Completion message
echo "Setup completed."
