echo -n "🕒 ..."

# Setup App Tokens
# https://github.com/settings/tokens

# Unix Reference Links
  # http://www.ee.surrey.ac.uk/Teaching/Unix/
# Navigation
alias ll="ls -laGH"
alias t2="tmux -2u"

###############################################################################
# EXPORTED FUNCTIONS:
###############################################################################
# TODO: DOTFILE_DIR should not be hard coded but resolve the symlink from SCRIPT_DIR
# SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILE_DIR="$HOME/dotfiles"
SCRIPTS="
aliases_git.sh
aliases_nvim.sh
aliases_heroku.sh
function_parse_git_prompt.sh
function_parse_conda_prompt.sh
function_ccurl.sh
function_inject_path.sh
"
for s in $SCRIPTS; do
  SCRIPT="${DOTFILE_DIR}/bash-scripts/$s"
  source $SCRIPT 
done


###############################################################################
# Prompt & Paths:
###############################################################################
export PS1="\e[0;32m\w\e[m"
if [[ $OSTYPE == msys* ]]; then 
  export PS1="$PS1 \`parse_conda_prompt\` \`parse_git_prompt\`"
elif [[ $OSTYPE == darwin* ]]; then
  export PS1="$PS1 \$(parse_conda_prompt) \$(parse_git_prompt)"
else
  export PS1="$PS1 \$(parse_conda_prompt) \$(parse_git_prompt)"
fi
export PS1="$PS1\nλ "

# ZSH style tab auto complete first option instead of BELL
# Then tabl cycle through other ambiguous options
# https://superuser.com/a/835047/454665
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'


###############################################################################
# PATH and ENV Variables :
###############################################################################

inject_path "$HOME/scripts/ssh-connections"
inject_path "$HOME/scripts/sql-connections"
inject_path "$HOME/.npm-packages/bin"

[ -d "/usr/local/go/bin" ] && prepend_path "/usr/local/go/bin"
[ -n "$(which go 2> /dev/null)" ] && [ -z "$(go env GOPATH)" ] && export GOPATH="$HOME/go"
[ -n "$(which go 2> /dev/null)" ] && inject_path "$(go env GOPATH)/bin"

if [[ $OSTYPE == msys* ]]; then 
  inject_path "${DOTFILE_DIR}/msys64/bin"
fi

if [[ $OSTYPE == darwin* ]]; then
  # inject_path "~/Qt5.8.0/5.8/clang_64/bin"
  inject_path "/usr/local/opt/openssl/bin"

  # Use this to create symlinks from python to python3 
  # prepend_path "/usr/local/opt/python/libexec/bin"
fi

if [[ $OSTYPE == linux* ]]; then
  prepend_path "$HOME/opt/node/bin"
fi

[ -d "$HOME/.cargo/bin" ] && inject_path "$HOME/.cargo/bin"
###############################################################################
# BASH COMPLETIONS 
###############################################################################
if [[ $OSTYPE == darwin* ]]; then

  # HomeBrew Bash Completion
  [ -f $(brew --prefix)/etc/bash_completion ]; source "$(brew --prefix)/etc/bash_completion"

  # AWS Completions
  [ -n "$(which aws_completer)" ] && complete -C "$(which aws_completer)" aws

  # iTerm2 Integrations
  # then download and install 
  # curl -L https://iterm2.com/misc/install_shell_integration.sh | bash
  [ -e "${HOME}/.iterm2_shell_integration.bash" ] && source "${HOME}/.iterm2_shell_integration.bash"
  
  # MatplotLib Rendering in iTerm2
  export MPLBACKEND="module://itermplot"
  export ITERMPLOT=rv

fi

###############################################################################
# MISC 
###############################################################################
# Export NPM_TOKEN if it exists
[ -f ~/.npmrc ] && export NPM_TOKEN=`cat ~/.npmrc | grep '_authToken' | sed 's/\/\/registry.npmjs.org\/:_authToken=//g'`

# Fuzzy Finder
[ -f ~/.fzf.bash ] && source ~/.fzf.bash


# NVM
# export NVM_DIR="$HOME/.nvm"
  # . "/usr/local/opt/nvm/nvm.sh"

# added by Anaconda3 2018.12 installer
# >>> conda init >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$(CONDA_REPORT_ERRORS=false \"${HOME}/anaconda3/bin/conda\" shell.bash hook 2> /dev/null)"
if [ $? -eq 0 ]; then
    \eval "$__conda_setup"
else
    if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/anaconda3/etc/profile.d/conda.sh"
        CONDA_CHANGEPS1=false conda activate base
    else
        \export PATH="$HOME/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda init <<<

echo "😎"

