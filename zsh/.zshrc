
. $ZDOTDIR/zsh-theme
. $ZDOTDIR/aliases
. $ZDOTDIR/local-aliases

source $ZDOTDIR/search-highlighting.zsh


# Enable up and down arrow key history search
# bindkey '^[[A' up-line-or-search
# bindkey '^[[B' down-line-or-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# configure history
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt alwaystoend
setopt autocd
setopt autopushd
setopt autoresume
setopt nocaseglob
setopt completeinword
setopt extendedhistory
setopt appendhistory
setopt histexpiredupsfirst
setopt histfindnodups
setopt histignorealldups
setopt histignoredups
setopt histignorespace
setopt histsavenodups
setopt histverify
setopt pathdirs
setopt pushdignoredups
setopt pushdsilent
setopt pushdtohome
setopt sharehistory

autoload compinit
compinit

. "$HOME/.local/bin/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

