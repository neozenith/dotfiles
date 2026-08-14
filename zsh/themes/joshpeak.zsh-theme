NL=$'\n'
JOSHPEAK_PROMPT_BIN=${JOSHPEAK_PROMPT_BIN:-$HOME/dotfiles/joshpeak-prompt/bin/joshpeak-prompt}
PROMPT='${NL}%{$fg[magenta]%}$(current_hostname)%{$reset_color%} %{$fg[cyan]%}%~%{$reset_color%}$("$JOSHPEAK_PROMPT_BIN" prompt)'
PROMPT+="${NL}λ "

ZSH_THEME_GIT_PROMPT_PREFIX="${NL}%{$fg_bold[blue]%}⎇  %{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%} %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}"
