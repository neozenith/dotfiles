
#! /bin/bash



parse_conda_prompt() {
  
  local CONDA_ENV=""
  local CONDA=`conda --help 2> /dev/null`
  if [[ -n $CONDA ]]; then
    CONDA_ENV=`conda info --envs | grep \* | cut -d ' ' -f1 2> /dev/null`

    # If env exists then decorate
    if [[ -n $CONDA_ENV ]]; then
      local ESC_CODE="\e"
      [[ $OSTYPE == darwin* ]] && ESC_CODE="\033"

      local GREEN="$ESC_CODE[32m"
      local GRAY="$ESC_CODE[37m"
      local NORM="$ESC_CODE[0m"
      CONDA_ENV="\n${GREEN}🐍${NORM}($GRAY$CONDA_ENV$NORM)"
    fi
  fi

  echo -e "$CONDA_ENV"
}
# Export bash function to work as command line command as well
export -f parse_conda_prompt

# export PS1="\e[0;32m\w\e[m"
# export PS1="$PS1 \$(parse_conda_prompt)"
# Git bash use this version
# export PS1="$PS1 $(parse_conda_prompt)"
# export PS1="$PS1\nλ "
