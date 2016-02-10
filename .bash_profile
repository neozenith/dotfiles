alias ll="ls -laGHf"
alias gs="git status -v --ignore-submodules"
alias gb="git branch -vv -a"
alias gcon="git diff --name-only --diff-filter=U"
alias gm=" git pull -v --all; git checkout master -f; git pull -v"
alias gpa="git pull -v --all"
alias dkup="docker-machine start default && docker-machine regenerate-certs default && eval \$(docker-machine env default)"
alias dkdn="docker-machine stop default"
alias dk="docker"
alias dkm="docker-machine"
export PS1="\e[0;32m\W\e[m"
export PS1="$PS1\$(git-radar --bash --fetch)\$ "
export PATH=$PATH:~/scripts/ssh-connections
#export PATH=$PATH:~/scripts/didit-cli-client
export PATH=$PATH:~/scripts/sql-connections
export PATH=~/.rbenv/shims:$PATH
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

