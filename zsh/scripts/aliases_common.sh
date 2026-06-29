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
alias aicc="git -C .claude config --local user.name neozenith && git -C .claude config --local user.email joshpeak05@gmail.com"
alias ais="npx skills@latest add neozenith/agentic-dotfiles/ --agent claude-code --skills '*' --yes"
alias ccdsp="claude --dangerously-skip-permissions"
alias ccpma="claude --permission-mode auto"

alias mmdr="~/dotfiles/scripts/render_mermaid.sh"

alias v2ai="npx skills add ~/work/agent-capabilities/ --agent claude-code codex github-copilot"
alias jpai="npx skills add ~/play/agentic-dotfiles/ --agent claude-code codex github-copilot"

alias cv2ai="code ~/work/agent-capabilities/"
alias cjpai="code ~/play/agentic-dotfiles/"

# dbt Cloud
alias dbtc="/opt/homebrew/bin/dbt"
# dbt Fusion
alias dbtf="/Users/joshpeak/.local/bin/dbt"


alias tfa="terraform apply -auto-approve"
alias tfd="terraform destroy -auto-approve"
alias tff="terraform fmt && terraform validate && terraform graph | dot -Tsvg > graph.svg"

# Append .claude/ and tmp/ to this repo's git exclude (skip if already present)
alias aii="[ -z \"\$(grep -xF '.claude/' .git/info/exclude)\" ] && printf '%s\n' '.claude/' >> .git/info/exclude; [ -z \"\$(grep -xF 'tmp/' .git/info/exclude)\" ] && printf '%s\n' 'tmp/' >> .git/info/exclude"

# USAGE: eval "$(xenv 2>&1)"
xenv() {
  curl -fsSL https://raw.githubusercontent.com/neozenith/python-onboarding-guide/refs/heads/main/scripts/exportenv.py | python3
}
