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
  "function_path_tools.sh"
)
for sc in $scripts ; do
  [ ! -e "${EXTRA_SCRIPTS}/$sc" ] && echo "Missing: $sc"
  [ -e "${EXTRA_SCRIPTS}/$sc" ] && source "${EXTRA_SCRIPTS}/$sc"
done

# Auto-install oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
[ ! -d $ZSH ] && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_THEME="joshpeak"
ZSH_CUSTOM=$HOME/dotfiles/zsh/
export ZSH_CUSTOM_PLUGINS=$ZSH_CUSTOM/plugins

[ ! -d "~/.oh-my-zsh/themes/joshpeak.zsh-theme" ] && cp ~/dotfiles/zsh/themes/joshpeak.zsh-theme ~/.oh-my-zsh/themes

#Auto-install plugins
# TODO: If needing to auto install more plugins refactor this to a method
[ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM_PLUGINS/zsh-autosuggestions

plugins=(
  git
  poetry
  zsh-autosuggestions
  aws
  kubectl
  macos
)


source $ZSH/oh-my-zsh.sh
setopt PROMPT_SUBST
alias ll="ls -laFGh"
# QT_PATH="$HOME/Qt5.12.12/5.12.12/clang_64/bin"
# [ -d "$QT_PATH" ] && inject_path $QT_PATH
PYENV_PATH="$HOME/.pyenv/bin"
[ -d "$PYENV_PATH" ] && inject_path $PYENV_PATH
eval "$(pyenv init --path)"

WORK_TOOLS_PATH="$HOME/.work/bin"
[ ! -d "$WORK_TOOLS_PATH" ] && mkdir -p $WORK_TOOLS_PATH
[ -d "$WORK_TOOLS_PATH" ] && inject_path $WORK_TOOLS_PATH 
