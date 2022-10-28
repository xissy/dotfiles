# homebrew
export PATH=$PATH:/opt/homebrew/bin
eval "$(/opt/homebrew/bin/brew shellenv)"

# oh-my-posh
eval "$(oh-my-posh init zsh --config ~/.config.omp.json)"

# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

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

# go
export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin

# java
. ~/.asdf/plugins/java/set-java-home.zsh

# direnv
eval "$(direnv hook zsh)"

# zsh history
setopt sharehistory
export HISTSIZE=10000000
export SAVEHIST=10000000

