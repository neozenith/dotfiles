echo -n "🕒"
function loading_progress(){
  echo -n "."
}

loading_progress

# Setup App Tokens
# https://github.com/settings/tokens

###############################################################################
# EXPORTED FUNCTIONS:
###############################################################################
# SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILE_DIR="$HOME/dotfiles"
SCRIPTS="
aliases_common.sh
aliases_work.sh
aliases_git.sh
aliases_nvim.sh
aliases_heroku.sh
function_parse_git_prompt.sh
function_parse_kubectl_prompt.sh
function_parse_python_prompt.sh
function_parse_conda_prompt.sh
function_inject_path.sh
"
for s in $SCRIPTS; do
  SCRIPT="${DOTFILE_DIR}/bash/$s"
  [ -e $SCRIPT ] && source $SCRIPT 
done

loading_progress

###############################################################################
# Prompt & Paths:
###############################################################################
export PS1="\e[0;32m\w\e[m"
if [[ $OSTYPE == msys* ]]; then
  export PS1="$PS1 \`parse_python_prompt\` \`parse_git_prompt\` \`parse_k8s_prompt\`"
elif [[ $OSTYPE == darwin* ]]; then
  export PS1="$PS1 \$(parse_python_prompt) \$(parse_git_prompt) \$(parse_k8s_prompt)"
else
  export PS1="$PS1 \$(parse_python_prompt) \$(parse_git_prompt) \$(parse_k8s_prompt)"
fi
export PS1="$PS1\nλ "

# ZSH style tab auto complete first option instead of BELL
# Then tabl cycle through other ambiguous options
# https://superuser.com/a/835047/454665
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

loading_progress

###############################################################################
# PATH and ENV Variables :
###############################################################################

loading_progress

# DevTools Paths
[ -d "/usr/local/go/bin" ] && prepend_path "/usr/local/go/bin"
[ -n "$(which go 2> /dev/null)" ] && [ -z "$(go env GOPATH)" ] && export GOPATH="$HOME/go"
[ -n "$(which go 2> /dev/null)" ] && inject_path "$(go env GOPATH)/bin"
[ -d "$HOME/.cargo/bin" ] && inject_path "$HOME/.cargo/bin"
[ -d "$HOME/.wasm/bin" ] && prepend_path "$HOME/.wasm/bin"


loading_progress

###############################################################################
# OS Specific Paths
###############################################################################
if [[ $OSTYPE == msys* ]]; then 
  inject_path "${DOTFILE_DIR}/msys64/bin"
fi

if [[ $OSTYPE == darwin* ]]; then
  # inject_path "~/Qt5.8.0/5.8/clang_64/bin"
  inject_path "/usr/local/opt/openssl/bin"

fi

if [[ $OSTYPE == linux* ]]; then
  prepend_path "$HOME/opt/node/bin"
fi


loading_progress

###############################################################################
# COMPLETIONS 
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

loading_progress

###############################################################################
# MISC 
###############################################################################

echo -e "!"

