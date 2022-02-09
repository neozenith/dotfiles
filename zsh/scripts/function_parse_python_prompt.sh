function parse_python_prompt() {
  CURRENT_PY="$(which python3)"
  PY_LOCATION=""

  if [[ $CURRENT_PY == "/usr/bin/python3" ]]; then
    PY_LOCATION="system"
  elif [[ $CURRENT_PY == "/usr/local/bin/python3" ]]; then
    PY_LOCATION="homebrew"
  elif [[ $CURRENT_PY == "/opt/homebrew/bin/python3" ]]; then
    PY_LOCATION="homebrew"
  elif [[ $CURRENT_PY == "$HOME/.pyenv/shims/python3" ]]; then
    PY_LOCATION="pyenv"
  else
    if [[ -n $VIRTUAL_ENV ]]; then
      PY_LOCATION="venv"
    fi
  fi

  echo -e " %F{green}🐍 $PY_LOCATION $(python3 -V | sed 's/Python //g')%F{rc}"
}
