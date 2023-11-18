#! /bin/bash
parse_k8s_prompt() {

    local DARK="%F{017}"
    local BRIGHT="%F{023}"
    local BRIGHTEST="%F{016}%K{019}"
    local NORM="%F{rc}%K{rc}"
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
