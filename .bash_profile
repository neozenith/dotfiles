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
alias gt="git tree"

### Subversion shortcuts
if [[ $OSTYPE == darwin* ]]; then
  # Easy version from hommebrew
  # brew install colordiff
  #
  # Hard version to always have available in bash
  # http://stackoverflow.com/a/16865578/622276
  alias colourdiff="sed \"s/^-/`echo -e \"\x1b\"`[31m-/;s/^+/`echo -e \"\x1b\"`[32m+/;s/^@/`echo -e \"\x1b\"`[34m@/;s/$/`echo -e \"\x1b\"`[0m/\""
else
  # apt-get install colordiff
  alias colourdiff="sed 's/^-/\x1b[31m-/;s/^+/\x1b[32m+/;s/^@/\x1b[34m@/;s/$/\x1b[0m/'"
fi

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
parse_git_branch() {
  # Route errors to stderr (2>) especially when in non-Git directories
  # Pipe sane output to sed for cleanup
  # Get diff and status
  # if there are any unstaged diffs then colour RED
  # if there are staged but uncommited work then YELLOW
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'`
  STATUS=`git status -s 2> /dev/null`
  DIFF=`git diff 2> /dev/null`
  STATUS_COLOUR=""
  ESC_CODE=""

  if [[ $OSTYPE == darwin* ]]; then
    ESC_CODE="\033"
  else
    ESC_CODE="\e"
  fi

  if [[ -n $STATUS ]]; then
    STATUS_COLOUR="$ESC_CODE[33m"
  fi
  if [[ -n $DIFF ]]; then
    STATUS_COLOUR="$ESC_CODE[31m"
  fi

  echo -e "$STATUS_COLOUR$BRANCH$ESC_CODE[0m"
}

export PS1="\e[0;32m\w\e[m"
# export PS1="$PS1\$(git-radar --bash --fetch)"
export PS1="$PS1\$(parse_git_branch)"
export PS1="$PS1\n\$ "


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

# OSX Specific:
if [[ $OSTYPE == darwin* ]]; then
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

fi
