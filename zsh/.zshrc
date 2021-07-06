# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

DOTFILE_DIR="$HOME/dotfiles"
EXTRA_SCRIPTS="${DOTFILE_DIR}/zsh/scripts"
scripts=(
  "aliases_common.sh"
  "aliases_git.sh"
  "aliases_nvim.sh"
  "aliases_work.sh"
  "function_parse_git_prompt.sh"
  "function_parse_kubectl_prompt.sh"
  "function_parse_python_prompt.sh"
)
for sc in $scripts ; do
  [ ! -e "${EXTRA_SCRIPTS}/$sc" ] && echo "Missing: $sc"
  [ -e "${EXTRA_SCRIPTS}/$sc" ] && source "${EXTRA_SCRIPTS}/$sc"
done

ZSH_THEME="joshpeak"
export ZSH="$HOME/.oh-my-zsh"
[ ! -d $ZSH ] && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM=$HOME/dotfiles/zsh/
export ZSH_CUSTOM_PLUGINS=$ZSH_CUSTOM/plugins

# TODO: If needing to auto install more plugins refactor this to a method
[ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM_PLUGINS/zsh-autosuggestions

plugins=(
  git
  zsh-autosuggestions
  aws
  kubectl
  osx
)
source $ZSH/oh-my-zsh.sh
setopt PROMPT_SUBST

