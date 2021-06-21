echo -n "🕒"
function loading_progress(){
  echo -n "."
}

loading_progress

# Setup App Tokens
# https://github.com/settings/tokens

# Unix Reference Links
  # http://www.ee.surrey.ac.uk/Teaching/Unix/
# Navigation
alias ll="ls -laGHh"
alias cdp="cd ~/play"
alias cdw="cd ~/work"
alias cdW="cd ~/work/ppr/ppr-compute-service"
alias cdd="cd ~/dotfiles"
# WSL equivalents
alias cdww="cd /mnt/c/Users/\$(whoami)/work"
alias cddw="cd /mnt/c/Users/\$(whoami)/dotfiles"

# TMUX
alias t2="tmux -2u"
alias tt2="tmux new-session \; split-window -h \; selectp -t 0 \;"
alias ttt2="tmux new-session \; split-window -h \; split-window -v \; selectp -t 0 \;"
alias tpsh="tmux new-session -d \; send-keys 'pipenv shell' C-m \; split-window -h \; send-keys 'pipenv shell' C-m \; attach-session -d \;"
alias psh="pipenv shell"

# Containers: Docker 
alias d="docker"
alias dps="docker ps -a"
alias ds="docker stop \$(docker ps -aq) 2> /dev/null"
alias dpi="docker image prune -f"
alias dpc="docker container prune -f"
alias dpv="docker volume prune -f"
alias dP="docker container prune -f; docker image prune -f; docker volume prune -f"
# Containers: Kubernetes
# https://kubernetes.io/docs/reference/kubectl/cheatsheet/#bash
source <(kubectl completion bash)
alias k="kubectl"
complete -F __start_kubectl k
alias kudd="kubectl config use-context docker-desktop"
function klogs() {
  echo "$1"
  echo "$2"
  echo "$3"
  kubectl logs $2 $3 `kubectl get pods $2 -o json | jq -r .items[0].metadata.name | grep $1`
}
alias ecr-login="aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 979037402244.dkr.ecr.us-west-2.amazonaws.com"


###############################################################################
# EXPORTED FUNCTIONS:
###############################################################################
# TODO: DOTFILE_DIR should not be hard coded but resolve the symlink from SCRIPT_DIR
# SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILE_DIR="$HOME/dotfiles"
SCRIPTS="
aliases_work.sh
aliases_git.sh
aliases_nvim.sh
aliases_heroku.sh
function_parse_git_prompt.sh
function_parse_kubectl_prompt.sh
function_parse_conda_prompt.sh
function_inject_path.sh
"
for s in $SCRIPTS; do
  SCRIPT="${DOTFILE_DIR}/bash-scripts/$s"
  source $SCRIPT 
done

loading_progress

###############################################################################
# Prompt & Paths:
###############################################################################
export PS1="\e[0;32m\w\e[m"
if [[ $OSTYPE == msys* ]]; then
  export PS1="$PS1 \`parse_conda_prompt\` \`parse_git_prompt\` \`parse_k8s_prompt\`"
elif [[ $OSTYPE == darwin* ]]; then
  export PS1="$PS1 \$(parse_conda_prompt) \$(parse_git_prompt) \$(parse_k8s_prompt)"
else
  export PS1="$PS1 \$(parse_conda_prompt) \$(parse_git_prompt) \$(parse_k8s_prompt)"
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

inject_path "$HOME/scripts/ssh-connections"
inject_path "$HOME/scripts/sql-connections"
inject_path "$HOME/.npm-packages/bin"

loading_progress

# DevTools Paths
[ -d "/usr/local/go/bin" ] && prepend_path "/usr/local/go/bin"
[ -n "$(which go 2> /dev/null)" ] && [ -z "$(go env GOPATH)" ] && export GOPATH="$HOME/go"
[ -n "$(which go 2> /dev/null)" ] && inject_path "$(go env GOPATH)/bin"
[ -d "$HOME/.cargo/bin" ] && inject_path "$HOME/.cargo/bin"
[ -d "$HOME/.wasm/bin" ] && prepend_path "$HOME/.wasm/bin"

[ -d "$HOME/.pyenv/libexec" ] && export PYENV_ROOT="$HOME/.pyenv" && prepend_path "$PYENV_ROOT/libexec"
# [ -z "$( echo $PATH | grep '.pyenv/shims' 2> /dev/null)" ] && [ -n "$(which pyenv 2> /dev/null)" ] && eval "$(pyenv init -)"
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"


loading_progress

# OS Specific Paths
if [[ $OSTYPE == msys* ]]; then 
  inject_path "${DOTFILE_DIR}/msys64/bin"
fi

if [[ $OSTYPE == darwin* ]]; then
  # inject_path "~/Qt5.8.0/5.8/clang_64/bin"
  inject_path "/usr/local/opt/openssl/bin"

  PYTHON_USERBASE_BIN="$(python3 -m site --user-base)/bin"
  [ -d "$PYTHON_USERBASE_BIN" ] && inject_path "$PYTHON_USERBASE_BIN"
  OSX_PY38_PATH="/Library/Frameworks/Python.framework/Versions/3.8/bin"
  [ -d "$OSX_PY38_PATH" ] && inject_path "$OSX_PY38_PATH"
  OSX_PY36_PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin"
  [ -d "$OSX_PY36_PATH" ] && inject_path "$OSX_PY36_PATH"
  OSX_PY35_PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin"
  [ -d "$OSX_PY35_PATH" ] && inject_path "$OSX_PY35_PATH"
  # Use this to create symlinks from python to python3 
  # prepend_path "/usr/local/opt/python/libexec/bin"
fi

if [[ $OSTYPE == linux* ]]; then
  prepend_path "$HOME/opt/node/bin"
fi


loading_progress

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

  # Fix arrangement of monitors alias
  # https://apple.stackexchange.com/a/380168
  # brew tap jakehilborn/jakehilborn && brew install displayplacer
  alias fixdis="displayplacer \"id:30E91884-7BB5-374F-7C8A-FF9D851FCBB4 res:1920x1080 hz:30 color_depth:8 scaling:on origin:(0,0) degree:0\" \"id:23D1133F-B303-31FB-6381-AB24109581A8 res:1920x1080 hz:30 color_depth:8 scaling:on origin:(1920,0) degree:0\""
  alias fixdis2="displayplacer \"id:30E91884-7BB5-374F-7C8A-FF9D851FCBB4 res:1920x1080 hz:30 color_depth:8 scaling:on origin:(0,0) degree:0\" \"id:52E4545F-43C4-CF1A-9005-039E6566588F res:1920x1080 hz:30 color_depth:8 scaling:on origin:(1920,0) degree:0\""
  alias fixdis31="displayplacer \"id:5E343FBE-B970-6068-8B8D-A56C7D31E1B0 res:1792x1120 hz:59 color_depth:4 scaling:on origin:(0,0) degree:0\" \"id:23D1133F-B303-31FB-6381-AB24109581A8 res:1920x1080 hz:30 color_depth:8 scaling:on origin:(1792,-1080) degree:0\" \"id:30E91884-7BB5-374F-7C8A-FF9D851FCBB4 res:1920x1080 hz:30 color_depth:8 scaling:on origin:(-128,-1080) degree:0\""
  alias fixdis3="displayplacer \"id:5E343FBE-B970-6068-8B8D-A56C7D31E1B0 res:1792x1120 hz:59 color_depth:4 scaling:on origin:(0,0) degree:0\" \"id:30E91884-7BB5-374F-7C8A-FF9D851FCBB4 res:1920x1080 hz:30 color_depth:8 scaling:on origin:(-1920,0) degree:0\" \"id:23D1133F-B303-31FB-6381-AB24109581A8 res:1920x1080 hz:30 color_depth:8 scaling:on origin:(1792,0) degree:0\""

  #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
  export SDKMAN_DIR="/Users/joshpeak/.sdkman"
  [[ -s "/Users/joshpeak/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/joshpeak/.sdkman/bin/sdkman-init.sh"


  #GraalVM
  # prepend_path "/Library/Java/JavaVirtualMachines/graalvm-ce-java8-20.2.0/Contents/Home/bin"
  # export JAVA_HOME="/Library/Java/JavaVirtualMachines/graalvm-ce-java8-20.2.0/Contents/Home"
fi

loading_progress

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



echo -e "!"

