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

###############################################################################
# ALIASES: 
###############################################################################
### Git shortcuts
  # (G)it (S)tatus
  alias gs="git status -u -s --ignore-submodules"
  # (G)it (B)ranch
  alias gb="git branch -vv"
  # (G)it (D)iff
  alias gd="git diff -v"
	# (G)it (C)ommit
	alias gc="git commit $*"
  # (G)it (M)aster
  alias gm=" git checkout master -f; git fetch -v --all --prune; git fetch --tags; git pull -v --all"
  alias gu=" git checkout $1 -f; git fetch -v --all -t -p; git pull -v --all"
  alias gpa="git pull -v --all"
	# (G)it (P)ush
	alias gp="git push"
	# (G)it (F)etch
  alias gf="git fetch -t -p"
  # (G)it (T)ree see gitconfig for full details
  alias gt="git tree"
	# (G)it (L)og, same as above but backup option if not defined in git config
	alias gl="git log --pretty=format:\"%C(bold blue)%h%x09%C(bold green)[%ad] %C(auto)%d%n%C(dim white)%an - %C(reset)%x20%s\" --graph --full-history --all --date=relative" 

  # Git changelog commands:
  alias glasttag="git describe --abbrev=0 --tags 2> /dev/null"

  # Git changelog release tag: Changelog relative to last tag on master 
  # Assumes only master is tagged for releases.
  alias gclr="last_tag=\"git describe --abbrev=0 --tags\"; git log --oneline --no-merges $last_tag..HEAD"
  # Git changelog master: Changelog between latest master release and 
  # accumulated develop branch
  alias gclm="git log --oneline --no-merges master..develop | grep -Ev (WIP:|DEBUG:|Merge)"
  # Git changelog develop: Changelog relative to accumulated develop branch,
  # and current checked out branch.
  alias gcld="git log --oneline --no-merges develop..HEAD | grep -Ev (WIP:|DEBUG:|Merge)"


###############################################################################
# EXPORTED FUNCTIONS:
###############################################################################
# ColourDiff:
cdiff() {
	if [[ $OSTYPE == darwin* ]]; then
		# Easy version from hommebrew
		# brew install colordiff
		#
		# Hard version to always have available in bash
		# http://stackoverflow.com/a/16865578/622276
		sed "s/^-/`echo -e "\x1b"`[31m-/;s/^+/`echo -e "\x1b"`[32m+/;s/^@/`echo -e "\x1b"`[34m@/;s/$/`echo -e "\x1b"`[0m/"
	else
		# apt-get install colordiff
		sed 's/^-/\x1b[31m-/;s/^+/\x1b[32m+/;s/^@/\x1b[34m@/;s/$/\x1b[0m/'
	fi
}
export -f cdiff 

ccurl() {
  ESC_CODE=""
  if [[ $OSTYPE == darwin* ]]; then
    ESC_CODE=`echo -e "\033"`
  else
    ESC_CODE=`echo -e "\e"`
  fi
  RED="$ESC_CODE\[31m"
  GREEN="$ESC_CODE\[32m"
  YELLOW="$ESC_CODE\[33m"
	BLUE="$ESC_CODE\[34m"
  PURPLE="$ESC_CODE\[36m"
  
	LRED="$ESC_CODE\[91m"
  LGREEN="$ESC_CODE\[92m"
  LYELLOW="$ESC_CODE\[93m"
	LBLUE="$ESC_CODE\[94m"
  LPURPLE="$ESC_CODE\[96m"
	NORM="$ESC_CODE\[0m"

	# curl verbose header information is piped to stderr
	# We need to pipe stderr (2>) to stdout (1>) using >&
	# Apply colourising pattern matchers
	curl -sv "$@" 2>&1 | \
		sed -E "s/^(>) (.*): (.*)$/$RED\1 $LBLUE\2: $LRED\3$NORM/g" | \
		sed -E "s/^(<) (.*): (.*)$/$GREEN\1 $LBLUE\2: $LGREEN\3$NORM/g" | \
		sed -E "s/^(\*) (.*)$/$PURPLE\1 $NORM\2$NORM/g" | \
		sed -E "s/^(<) (.*)$/$GREEN\1 $GREEN\2$NORM/g" | \
		sed -E "s/^(>) (.*)$/$RED\1 $RED\2$NORM/g"
}
export -f ccurl


###############################################################################
# Prompt & Paths:
###############################################################################
parse_git_branch() {
  # Get diff and status
  # if there are any unstaged diffs then colour RED
  # if there are staged but uncommited work then YELLOW
  # Route errors to stderr (2>) especially when in non-Git directories
  # Pipe sane output to sed for cleanup
  ESC_CODE=""
  if [[ $OSTYPE == darwin* ]]; then
    ESC_CODE="\033"
  else
    ESC_CODE="\e"
  fi
  RED="$ESC_CODE[31m"
  GREEN="$ESC_CODE[32m"
  YELLOW="$ESC_CODE[33m"
	BLUE="$ESC_CODE[34m"
  PURPLE="$ESC_CODE[36m"
	NORM="$ESC_CODE[0m"

  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'`
  STATUS=`git status -s 2> /dev/null`

	# https://git-scm.com/docs/git-status#_short_format
	STAT_MOD=`echo "$STATUS" | grep -e "^[MDA ]M" | wc -l | tr -d '[:space:]'`
	STAT_DEL=`echo "$STATUS" | grep -e "^ D" | wc -l | tr -d '[:space:]'`
	STAT_NEW=`echo "$STATUS" | grep -e "^??" | wc -l | tr -d '[:space:]'`
	STAT_ADD=`echo "$STATUS" | grep -e "^[MDA]." | wc -l | tr -d '[:space:]'`

  STATUS_COLOUR="$BLUE"
  if [[ -n $STATUS ]]; then
    STATUS_COLOUR="$YELLOW"
  fi

	CACHE_STATUS=""
	# If cache status changes are detected then accumulate
	if [[ $STAT_NEW > 0 ]]; then
		CACHE_STATUS="${CACHE_STATUS}$PURPLE?$STAT_NEW$NORM"
    STATUS_COLOUR="$RED"
	fi
	if [[ $STAT_MOD > 0 ]]; then
		CACHE_STATUS="${CACHE_STATUS}$YELLOW~$STAT_MOD$NORM"
    STATUS_COLOUR="$RED"
	fi
	if [[ $STAT_DEL > 0 ]]; then
		CACHE_STATUS="${CACHE_STATUS}$RED-$STAT_DEL$NORM"
    STATUS_COLOUR="$RED"
	fi
	# Staged for commit
	if [[ $STAT_ADD > 0 ]]; then
		CACHE_STATUS="${CACHE_STATUS}$GREEN+$STAT_ADD$NORM"
	fi
	# If there is a cache status accumulated then prefix with a space
	if [[ -n $CACHE_STATUS ]]; then
		CACHE_STATUS=" [${CACHE_STATUS}]"
	fi

  echo -e "$STATUS_COLOUR$BRANCH$NORM$CACHE_STATUS"
}
export -f parse_git_branch

export PS1="\e[0;32m\w\e[m"
# export PS1="$PS1\$(git-radar --bash --fetch)"
export PS1="$PS1\$(parse_git_branch)"
export PS1="$PS1\nλ "

# ZSH style tab auto complete first option instead of BELL
# Then tabl cycle through other ambiguous options
# https://superuser.com/a/835047/454665
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'


###############################################################################
# PATH and ENV Variables :
###############################################################################
function inject_path () {
  # Check to see if it is already in the PATH before unnecessarily concatenating
  if [[ -z "$(echo $PATH | grep "$1")" ]]; then 
    export PATH=$PATH:$1
  fi
}

  inject_path "~/scripts/ssh-connections"
  inject_path "~/scripts/sql-connections"
  inject_path "~/.npm-packages/bin"
  inject_path "$(go env GOPATH)/bin"
if [[ $OSTYPE == darwin* ]]; then
  # inject_path "~/Qt5.8.0/5.8/clang_64/bin"
  inject_path "/usr/local/opt/openssl/bin"
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

  # iTerm2 Integrations
  # then download and install 
  # curl -L https://iterm2.com/misc/install_shell_integration.sh | bash
  test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

fi

# Fuzzy Finder
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

[ -f ~/.npmrc ] && export NPM_TOKEN=`cat ~/.npmrc | sed 's/\/\/registry.npmjs.org\/:_authToken=//g'`
