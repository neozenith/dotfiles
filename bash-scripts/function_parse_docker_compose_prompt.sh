#! /bin/bash

parse_docker_compose_prompt() {


  local DOCKER_COMPOSE=`which docker-compose 2> /dev/null`
  if [ -n "$DOCKER_COMPOSE" ]; then
    local CONTAINERS=`docker-compose ps 2> /dev/null | wc -l | tr -d '[:space:]'`
    if [[ $CONTAINERS > 2 ]]; then
      CONTAINERS=$(expr $CONTAINERS - 2)
      echo -e "${CONTAINERS}x🐳"
    fi
  fi
  
  
}
# Export bash function to work as command line command as well
export -f parse_docker_compose_prompt

# export PS1="\e[0;32m\w\e[m"
# export PS1="$PS1 \$(parse_git_prompt)"
# export PS1="$PS1\nλ "

