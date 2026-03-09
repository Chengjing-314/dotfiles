# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

plugins=(git
zsh-autosuggestions
sudo)

source $ZSH/oh-my-zsh.sh

__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
# . "$HOME/miniconda3/etc/profile.d/conda.sh"  # commented out by conda initialize
    else
# export PATH="$HOME/miniconda3/bin:$PATH"  # commented out by conda initialize
    fi
fi
unset __conda_setup



if [ -f ~/.zshrc_extra ]; then
    source ~/.zshrc_extra
fi





source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

ZLE_RPROMPT_INDENT=0
alias ls=lsd
alias cooler='sudo systemctl stop coolercontrold;sudo systemctl start coolercontrold'
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/chengjingyuan/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/chengjingyuan/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/chengjingyuan/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/chengjingyuan/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# Added by Windsurf
export PATH="/Users/chengjingyuan/.codeium/windsurf/bin:$PATH"

# Added by Windsurf
export PATH="/Users/chengjingyuan/.codeium/windsurf/bin:$PATH"

# Added by Windsurf
export PATH="/Users/chengjingyuan/.codeium/windsurf/bin:$PATH"

# Added by Windsurf
export PATH="/Users/chengjingyuan/.codeium/windsurf/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"

# OpenClaw Completion
source "/Users/chengjingyuan/.openclaw/completions/openclaw.zsh"
