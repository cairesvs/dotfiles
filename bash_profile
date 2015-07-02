export PS1="\[${COLOR_WHITE}\]∴ : \[${COLOR_GREEN}\]\W \[${COLOR_NC}\]"
export EDITOR=vim
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi
