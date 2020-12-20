#! /bin/bash
parse_k8s_prompt() {
    local ESC_CODE="\e"
    [[ $OSTYPE == darwin* ]] && ESC_CODE="\033"

    local PURPLE="$ESC_CODE[2;49;94m"
    local NORM="$ESC_CODE[0m"
  local K8S_CONTEXT=`kubectl config current-context 2> /dev/null`
  echo -e "\n${PURPLE}${K8S_CONTEXT}${NORM}"
}
export -f parse_k8s_prompt
