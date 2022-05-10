NL=$'\n'
PROMPT='${NL}%{$fg[cyan]%}%~%{$reset_color%}$(parse_git_prompt) $(parse_k8s_prompt) $(parse_python_prompt)'
PROMPT+="${NL}λ "

ZSH_THEME_GIT_PROMPT_PREFIX="${NL}%{$fg_bold[blue]%}⎇  %{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%} %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}"
