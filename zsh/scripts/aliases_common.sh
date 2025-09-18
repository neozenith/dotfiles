# Navigation
alias ll="ls -laGHh"
alias cdp="cd ~/play"
alias cdw="cd ~/work"
alias cdd="cd ~/dotfiles"

alias awswho="aws sts get-caller-identity | jq .Arn"
# alias awssso="aws sso login && eval \"$$(aws configure export-credentials --profile $$AWS_PROFILE --format env)\""

# Python New aka PEW 😉
alias pew="uv init --vcs git --build-backend uv"

alias tfa="terraform apply -auto-approve"
alias tfd="terraform destroy -auto-approve"
alias tff="terraform fmt && terraform validate && terraform graph | dot -Tsvg > graph.svg"

alias pvup="python3 -m venv .venv && .venv/bin/python3 -m pip install --upgrade pip && .venv/bin/python3 -m pip install -r requirements.txt && . ./.venv/bin/activate"

# USAGE: eval "$(xenv 2>&1)"
xenv() {
  curl -fsSL https://raw.githubusercontent.com/neozenith/python-onboarding-guide/refs/heads/main/scripts/exportenv.py | python3
}
