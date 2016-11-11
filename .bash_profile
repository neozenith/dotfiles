# Navigation
alias ll="ls -laGHf"

# Vim shortcuts
#alias vim="/usr/local/Cellar/vim/7.4.865/bin/vim"
#alias vimdiff="/usr/local/Cellar/vim/7.4.865/bin/vimdiff"

alias ctpy="ctags -R --python-kinds=-i --languages=python --exclude=.git --exclude=log ."

### Git shortcuts
# (G)it (S)tatus
alias gs="git status -v --ignore-submodules"
# (G)it (B)ranch
alias gb="git branch -vv -a"
# (G)it (C)ondition 
alias gcon="git diff --name-only --diff-filter=U"
# (G)it (M)aster
alias gm=" git checkout master -f; git fetch -v --all --prune; git fetch --tags; git pull -v --all"
alias gpa="git pull -v --all"
alias gp="git push"
# (G)it (T)ree
alias gt="git log --graph --full-history --all --date=relative --pretty=format:\"%C(auto)%h%x09%Cgreen%ad %an%Creset%C(auto)%d%x20%s%n\""

# Docker Shortcuts
alias dkup="docker-machine start default; docker-machine regenerate-certs default -f; eval \$(docker-machine env default)"
alias dken="eval \$(docker-machine env default)"
alias dkdn="docker-machine stop default"
alias dk="docker"
alias dkm="docker-machine"
alias dkclean="docker stop \$(docker ps -aq); docker rm \$(docker ps -aq)"
alias dki="docker images"
alias dkiclean="docker rmi \$(docker images -q --filter 'dangling=true')"

# Prompt & Paths
export PS1="\e[0;32m\w\e[m"
export PS1="$PS1\$(git-radar --bash --fetch)\n\$ "


# Check to see if it is already in the PATH before unnecessarily concatenating
if [ -z "$(echo $PATH | grep "/scripts/ssh-connections")" ]; then 
  export PATH=$PATH:~/scripts/ssh-connections
  export PATH=$PATH:~/scripts/sql-connections
fi

if [ -z "$(echo $PATH | grep "/.npm-packages/bin")" ]; then 
  export PATH=$PATH:~/.npm-packages/bin 
fi

if [ -z "$(echo $PATH | grep "/.rbenv/shims/")" ]; then 
  if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
fi 

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

if [ -n "$(which aws_completer)" ]; then
  complete -C "$(which aws_completer)" aws
fi

#TODO get the following line to test first and if not present 
# then download and install 
# curl -L https://iterm2.com/misc/install_shell_integration.sh | bash
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
