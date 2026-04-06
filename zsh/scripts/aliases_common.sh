# Navigation
alias ll="ls -laGHh"
alias cdp="cd ~/play"
alias cdw="cd ~/work"
alias cdd="cd ~/dotfiles"
alias cdf="cd ~/foss"

alias awswho="aws sts get-caller-identity | jq .Arn"
# alias awssso="aws sso login && eval \"$$(aws configure export-credentials --profile $$AWS_PROFILE --format env)\""

# Python New aka PEW 😉
alias pew="uv init --vcs git --build-backend uv"
alias aic="git clone https://github.com/neozenith/agentic-dotfiles/ .claude"
alias ccdsp="claude --dangerously-skip-permissions"

alias mmdr="~/dotfiles/scripts/render_mermaid.sh"

alias v2ai="npx skills add ~/work/agent-capabilites"
alias jpai="npx skills add ~/play/agentic-dotfiles"


alias tfa="terraform apply -auto-approve"
alias tfd="terraform destroy -auto-approve"
alias tff="terraform fmt && terraform validate && terraform graph | dot -Tsvg > graph.svg"

# USAGE: eval "$(xenv 2>&1)"
xenv() {
  curl -fsSL https://raw.githubusercontent.com/neozenith/python-onboarding-guide/refs/heads/main/scripts/exportenv.py | python3
}
