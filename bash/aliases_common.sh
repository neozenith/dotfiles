# Unix Reference Links
  # http://www.ee.surrey.ac.uk/Teaching/Unix/
# Navigation
alias ll="ls -laGHh"
alias cdp="cd ~/play"
alias cdw="cd ~/work"
alias cdd="cd ~/dotfiles"
# WSL equivalents
alias cdww="cd /mnt/c/Users/\$(whoami)/work"
alias cddw="cd /mnt/c/Users/\$(whoami)/dotfiles"

# TMUX
alias t2="tmux -2u"
alias tt2="tmux new-session \; split-window -h \; selectp -t 0 \;"
alias ttt2="tmux new-session \; split-window -h \; split-window -v \; selectp -t 0 \;"
alias tpsh="tmux new-session -d \; send-keys 'pipenv shell' C-m \; split-window -h \; send-keys 'pipenv shell' C-m \; attach-session -d \;"
alias psh="pipenv shell"

# Containers: Docker 
alias d="docker"
alias dps="docker ps -a"
alias ds="docker stop \$(docker ps -aq) 2> /dev/null"
alias dpi="docker image prune -f"
alias dpc="docker container prune -f"
alias dpv="docker volume prune -f"
alias dP="docker container prune -f; docker image prune -f; docker volume prune -f"
# Containers: Kubernetes
# https://kubernetes.io/docs/reference/kubectl/cheatsheet/#bash
source <(kubectl completion bash)
alias k="kubectl"
complete -F __start_kubectl k
alias kudd="kubectl config use-context docker-desktop"
function klogs() {
  echo "$1"
  echo "$2"
  echo "$3"
  kubectl logs $2 $3 `kubectl get pods $2 -o json | jq -r .items[0].metadata.name | grep $1`
}
alias ecr-login="aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 979037402244.dkr.ecr.us-west-2.amazonaws.com"
