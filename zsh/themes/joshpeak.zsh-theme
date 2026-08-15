NL=$'\n'

# Resolve the prompt binary once at theme load. An explicit JOSHPEAK_PROMPT_BIN
# always wins; otherwise detect this host and select its committed per-architecture
# build, falling back to a local unsuffixed `make build` artifact.
if [[ -z ${JOSHPEAK_PROMPT_BIN} ]]; then
  _joshpeak_prompt_dir=$HOME/dotfiles/joshpeak-prompt/bin
  _joshpeak_prompt_os=${$(uname -s):l}
  case ${$(uname -m):l} in
    arm64|aarch64) _joshpeak_prompt_arch=arm64 ;;
    x86_64|amd64)  _joshpeak_prompt_arch=amd64 ;;
    *)             _joshpeak_prompt_arch= ;;
  esac
  JOSHPEAK_PROMPT_BIN=$_joshpeak_prompt_dir/joshpeak-prompt-$_joshpeak_prompt_os-$_joshpeak_prompt_arch
  if [[ -z ${_joshpeak_prompt_arch} || ! -x ${JOSHPEAK_PROMPT_BIN} ]]; then
    JOSHPEAK_PROMPT_BIN=$_joshpeak_prompt_dir/joshpeak-prompt
  fi
  unset _joshpeak_prompt_dir _joshpeak_prompt_os _joshpeak_prompt_arch
fi
PROMPT='${NL}%{$fg[magenta]%}$(current_hostname)%{$reset_color%} %{$fg[cyan]%}%~%{$reset_color%}$("$JOSHPEAK_PROMPT_BIN" prompt)'
PROMPT+="${NL}λ "

ZSH_THEME_GIT_PROMPT_PREFIX="${NL}%{$fg_bold[blue]%}⎇  %{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%} %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}"
