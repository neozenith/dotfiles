# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

DOTFILE_DIR="$HOME/dotfiles"
EXTRA_SCRIPTS="${DOTFILE_DIR}/zsh/scripts"
source "${EXTRA_SCRIPTS}/aliases_common.sh"
source "${EXTRA_SCRIPTS}/aliases_git.sh"
source "${EXTRA_SCRIPTS}/aliases_nvim.sh"
source "${EXTRA_SCRIPTS}/function_parse_git_prompt.sh"
source "${EXTRA_SCRIPTS}/function_parse_kubectl_prompt.sh"
source "${EXTRA_SCRIPTS}/function_parse_python_prompt.sh"

ZSH_THEME="joshpeak"
export ZSH="$HOME/.oh-my-zsh"
[ ! -d $ZSH ] && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM=$HOME/dotfiles/zsh/
export ZSH_CUSTOM_PLUGINS=$ZSH_CUSTOM/plugins
[ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM_PLUGINS/zsh-autosuggestions


# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-autosuggestions
  aws
  kubectl
  osx
)
source $ZSH/oh-my-zsh.sh

setopt PROMPT_SUBST

export PYENV_ROOT="$HOME/.pyenv"
eval "$(pyenv init --path)"

