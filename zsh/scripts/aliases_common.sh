# Navigation
alias ll="ls -laGHh"
alias cdp="cd ~/play"
alias cdw="cd ~/work"
alias cdd="cd ~/dotfiles"

alias awswho="aws sts get-caller-identity | jq .Arn"

alias tfa="terraform apply -auto-approve"
alias tfd="terraform destroy -auto-approve"
alias tff="terraform fmt && terraform validate && terraform graph | dot -Tsvg > graph.svg"

alias pvup="python3 -m venv .venv && .venv/bin/python3 -m pip install -U pip -r requirements.txt && . ./.venv/bin/activate"

