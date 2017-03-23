# Unix Reference Links
  # http://www.ee.surrey.ac.uk/Teaching/Unix/

# Navigation
alias ll="ls -laGHf"

# Vim shortcuts
#alias vim="/usr/local/Cellar/vim/7.4.865/bin/vim"
#alias vimdiff="/usr/local/Cellar/vim/7.4.865/bin/vimdiff"

# ctags
alias ctpy="ctags -R --python-kinds=-i --languages=python --exclude=.git --exclude=log ."

# TODO
# Refactor this into subscripts to be sourced
# 1. Git Shortcuts
# 2. Docker Shortcuts
# 3. Bash Completions
#   i.    Homebrew install
#   ii.   AWS
#   iii.  Docker
# 4. Bash Prompt
# 5. Colourdiff 
# 6. Path variables for custom scripts

### Git shortcuts
  # (G)it (S)tatus
  alias gs="git status -u -v --ignore-submodules"
  # (G)it (B)ranch
  alias gb="git branch -vv"
  # (G)it (D)iff
  alias gd="git diff -v --color-words"
  # (G)it (C)ondition of file 
  alias gcon="git diff --name-only --diff-filter=U"
  # (G)it (M)aster
  alias gm=" git checkout master -f; git fetch -v --all --prune; git fetch --tags; git pull -v --all"
  alias gu=" git checkout $1 -f; git fetch -v --all --prune; git fetch --tags; git pull -v --all"
  alias gpa="git pull -v --all"
  alias gp="git push"
  # (G)it (T)ree see gitconfig for full details
  alias gt="git tree"

  # Git Branch Purge
  # This deletes local branches no longer tracked on the server
  # http://stackoverflow.com/a/17987721/622276 
  alias gbpurge='git branch --merged | grep -Ev "(\*|master|develop|staging)" | xargs -n 1 git branch -d'


# ColourDiff:
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

# Docker Shortcuts:
  alias dkup="docker-machine start default; docker-machine regenerate-certs default -f; eval \$(docker-machine env default)"
  alias dken="eval \$(docker-machine env default)"
  alias dkdn="docker-machine stop default"
  alias dk="docker"
  alias dkm="docker-machine"
  alias dkclean="docker stop \$(docker ps -aq); docker rm \$(docker ps -aq)"
  alias dki="docker images"
  alias dkiclean="docker rmi \$(docker images -q --filter 'dangling=true')"
  #TODO:
  # https://codefresh.io/blog/everyday-hacks-docker/
  # Update to use Docker 1.13+ features such as `prune`

# Prompt & Paths:
parse_git_branch() {
  # Get diff and status
  # if there are any unstaged diffs then colour RED
  # if there are staged but uncommited work then YELLOW
  # Route errors to stderr (2>) especially when in non-Git directories
  # Pipe sane output to sed for cleanup

  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'`
  STATUS=`git status -s 2> /dev/null`
  DIFF=`git diff 2> /dev/null`
  ESC_CODE=""
  RED="[31m"
  YELLOW="[33m"
  BLUE="[34m"

  if [[ $OSTYPE == darwin* ]]; then
    ESC_CODE="\033"
  else
    ESC_CODE="\e"
  fi

  STATUS_COLOUR="$ESC_CODE$BLUE"
  if [[ -n $STATUS ]]; then
    STATUS_COLOUR="$ESC_CODE$YELLOW"
  fi
  if [[ -n $DIFF ]]; then
    STATUS_COLOUR="$ESC_CODE$RED"
  fi

  echo -e "$STATUS_COLOUR$BRANCH$ESC_CODE[0m"
}

export PS1="\e[0;32m\w\e[m"
# export PS1="$PS1\$(git-radar --bash --fetch)"
export PS1="$PS1\$(parse_git_branch)"
export PS1="$PS1\nλ "


# PATH and ENV Variables :
function inject_path () {
  # Check to see if it is already in the PATH before unnecessarily concatenating
  if [[ -z "$(echo $PATH | grep "$1")" ]]; then 
    export PATH=$PATH:$1
  fi
}

  inject_path "~/scripts/ssh-connections"
  inject_path "~/scripts/sql-connections"
  inject_path "~/.npm-packages/bin"

# Inject if RBEnv Shim not injected
if [[ -z "$(echo $PATH | grep '/.rbenv/shims')" ]]; then 
  HAS_RBENV=`which rbenv 2> /dev/null`
  if [[ -n "$HAS_RBENV"  ]]; then eval "$(rbenv init -)"; fi
fi

# OSX Bash Completions:
if [[ $OSTYPE == darwin* ]]; then

  # HomeBrew Bash Completion
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi

  # AWS Completions
  if [ -n "$(which aws_completer)" ]; then
    complete -C "$(which aws_completer)" aws
  fi

  # Docker Completions
  # Managed by HomeBrew but left for reference
  # DOCKER_COMPLETION_SCRIPTS="/Applications/Docker.app/Contents/Resources/etc"
  # ln -sq $DOCKER_COMPLETION_SCRIPTS/docker.bash-completion $(brew --prefix)/etc/bash_completion.d/docker 2> /dev/null
  # ln -sq $DOCKER_COMPLETION_SCRIPTS/docker-machine.bash-completion $(brew --prefix)/etc/bash_completion.d/docker-machine 2> /dev/null
  # ln -sq $DOCKER_COMPLETION_SCRIPTS/docker-compose.bash-completion $(brew --prefix)/etc/bash_completion.d/docker-compose 2> /dev/null

  # iTerm2 Integrations
  #TODO get the following line to test first and if not present 
  # then download and install 
  # curl -L https://iterm2.com/misc/install_shell_integration.sh | bash
  test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

fi
