# homebrew
export PATH=$PATH:/opt/homebrew/bin
eval "$(/opt/homebrew/bin/brew shellenv)"

# oh-my-posh
eval "$(oh-my-posh init zsh --config ~/.config.omp.json)"

# asdf
export ASDF_DATA_DIR=$HOME/.asdf
export PATH="$ASDF_DATA_DIR/shims:$PATH"


# zsh plugins
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ls color
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

# direnv
eval "$(direnv hook zsh)"

# zsh history
setopt sharehistory
export HISTSIZE=10000000
export SAVEHIST=10000000

# android
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

# bin
export PATH=$PATH:~/bin


# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

export PATH=$PATH:$HOME/.bun/bin

#alias cc="CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000 claude --dangerously-skip-permissions"
alias cc="CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude --dangerously-skip-permissions --teammate-mode tmux --verbose"
export PATH="$HOME/.local/bin:$PATH"
