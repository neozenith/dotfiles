
#! /bin/bash



parse_conda_prompt() {
 
  local ESC_CODE="\e"
  [[ $OSTYPE == darwin* ]] && ESC_CODE="\033"
  local GREEN="$ESC_CODE[32m"
  local GRAY="$ESC_CODE[37m"
  local NORM="$ESC_CODE[0m"
  local PIPENV_VIRTUALENV=""
  local CONDA_ENV=""
  local CONDA=`echo $CONDA_EXE`

  if [[ -n $CONDA ]]; then
    # If env exists then decorate
    [[ -n $CONDA_DEFAULT_ENV ]] && CONDA_ENV="\n${GREEN}∫${NORM}($GRAY$CONDA_SHLVL: $CONDA_DEFAULT_ENV$NORM)"
  fi

  # Tack on layered virtual environments
  if [[ -n $VIRTUAL_ENV ]]; then
    
    VENV_PATH="$(basename $VIRTUAL_ENV)"
    
    # If on a cygwin system convert the path
    [[ -n "$(which cygpath 2> /dev/null)" ]] && VENV_PATH="$(cygpath $VENV_PATH)"
    
    PIPENV_VIRTUALENV=" ${GREEN}venv${NORM}[${GRAY}$VENV_PATH$NORM]"
  fi 

  echo -e "$CONDA_ENV$PIPENV_VIRTUALENV"
}
# Export bash function to work as command line command as well
export -f parse_conda_prompt

# export PS1="\e[0;32m\w\e[m"
# export PS1="$PS1 \$(parse_conda_prompt)"
# Git bash use this version
# export PS1="$PS1 $(parse_conda_prompt)"
# export PS1="$PS1\nλ "
