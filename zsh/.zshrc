# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# fzf-tab must load after compinit (oh-my-zsh handles that) but BEFORE any
# plugin that wraps ZLE widgets -- i.e. before autosuggestions/syntax-highlighting.
# Added conditionally so this file still works where fzf-tab isn't cloned.
plugins=(git)
[ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/fzf-tab" ] && plugins+=(fzf-tab)
plugins+=(zsh-autosuggestions
zsh-syntax-highlighting
sudo)

source $ZSH/oh-my-zsh.sh

# Conda
__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# neovim
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export PATH="$HOME/bin:$PATH"

# Aliases
ZLE_RPROMPT_INDENT=0
alias ls=lsd
alias cooler='sudo systemctl stop coolercontrold;sudo systemctl start coolercontrold'
alias pipthinstall='pip install -i https://pypi.tuna.tsinghua.edu.cn/simple'

export TERMINFO=/usr/share/terminfo
alias clear='/usr/bin/clear'

# Machine-specific config (proxy, nvm, etc.)
if [ -f ~/.zshrc_extra ]; then
    source ~/.zshrc_extra
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# OpenClaw Completion
[ -f "/home/chengjing/.openclaw/completions/openclaw.zsh" ] && source "/home/chengjing/.openclaw/completions/openclaw.zsh"
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------
# fzf (fuzzy finder)
#   ctrl+r  fuzzy history search
#   ctrl+t  insert file/dir path into the command line
#   alt+c   cd into a subdirectory
#   **<tab> fuzzy completion, e.g.  vim **<tab>
# Guarded so this file stays portable to machines without fzf installed.
# ---------------------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
  # Prefer fd (respects .gitignore, skips .git) when present; else plain find.
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  else
    export FZF_DEFAULT_COMMAND="find . -type f -not -path '*/.git/*' 2>/dev/null"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi

  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'
  # Preview the file under the cursor on ctrl+t (bat if installed, else cat).
  if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
  else
    export FZF_CTRL_T_OPTS="--preview 'head -200 {}'"
  fi
  # Show the full command and let ctrl+r results be sorted by recency.
  export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=down:3:hidden:wrap --bind '?:toggle-preview'"

  # --- fzf-tab: TAB becomes a fuzzy picker over completion candidates -------
  if [ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/fzf-tab" ]; then
    # fzf-tab needs its own opts; it ignores FZF_DEFAULT_OPTS height in some modes.
    zstyle ':fzf-tab:*' fzf-flags --height=45% --layout=reverse --border
    # Accept the current selection with space, like fzf's default.
    zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
    # Preview directory contents when completing cd.
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always -- "$realpath"'
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls -1 --color=always -- "$realpath"'
    # Don't re-sort git output (keeps git's own meaningful ordering).
    zstyle ':completion:*:git-checkout:*' sort false
    # Show completion group headers, and cycle groups with , / .
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':fzf-tab:*' switch-group ',' '.'
  fi

  # Shell integration. `fzf --zsh` only exists in fzf >= 0.48; distro packages
  # are older (Ubuntu 22.04 ships 0.29.0, 24.04 ships 0.44.1), so fall back to
  # the shipped example scripts on those.
  if fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  else
    for _fzf_dir in \
      /usr/share/doc/fzf/examples \
      /usr/share/fzf/shell \
      /usr/share/fzf \
      "${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}/opt/fzf/shell" \
      "$HOME/.fzf/shell"
    do
      if [ -f "$_fzf_dir/key-bindings.zsh" ]; then
        source "$_fzf_dir/key-bindings.zsh"
        [ -f "$_fzf_dir/completion.zsh" ] && source "$_fzf_dir/completion.zsh"
        break
      fi
    done
    unset _fzf_dir
  fi
fi
