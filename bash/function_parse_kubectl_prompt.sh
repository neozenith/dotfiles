#! /bin/bash
parse_k8s_prompt() {
    local ESC_CODE="\e"
    [[ $OSTYPE == darwin* ]] && ESC_CODE="\033"

    local DARK="$ESC_CODE[2;49;94m"
    local BRIGHT="$ESC_CODE[1;49;94m"
    local BRIGHTEST="$ESC_CODE[7;49;94m"
    local NORM="$ESC_CODE[0m"
    local K8S_PROMPT=""
    local KUBECTL_CMD="$(which kubectl)"    

    if [ -n "$KUBECTL_CMD" ]; then
      local K8S_CONTEXT=`kubectl config current-context 2> /dev/null`
      local K8S_COLOUR="${BRIGHTEST}"
      
      if [ -n "$K8S_CONTEXT" ]; then
        [[ "$K8S_CONTEXT" = "docker-desktop" ]] && K8S_COLOUR="${DARK}"

        K8S_PROMPT="${BRIGHT}☸|${K8S_COLOUR}${K8S_CONTEXT}${NORM}${BRIGHT}|${NORM}"
      fi
    fi
    echo -e "${K8S_PROMPT}"
}
export -f parse_k8s_prompt
