export ZSH="/Users/caires.santos/.oh-my-zsh"
ZSH_THEME="lambda"

plugins=(
  git
  dotenv
  osx
)

source $ZSH/oh-my-zsh.sh

export EDITOR=vim
export PATH=$HOME/.bin:/sbin:$PATH
HISTSIZE=1000
HISTFILESIZE=2000

export GOPATH=$HOME/go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin

export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/libxml2/bin:$PATH"
export PATH="/usr/local/opt/libxslt/bin:$PATH"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
