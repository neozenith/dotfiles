# Navigation
alias ll="ls -laGHh"
alias cdp="cd ~/play"
alias cdj="cd ~/jpai/"
alias cdjp="cd ~/jpai/jpai-platform"
alias cdja="cd ~/jpai/jpai-admin"
alias cdw="cd ~/work"
alias cdv="cd ~/work/v2-platform"
alias cdd="cd ~/dotfiles"
alias cdf="cd ~/foss"

alias cafe="caffeinate -dimsu -t 3600"

alias awswho="aws sts get-caller-identity | jq .Arn"
# alias awssso="aws sso login && eval \"$$(aws configure export-credentials --profile $$AWS_PROFILE --format env)\""

# Python New aka PEW 😉
alias pew="uv init --vcs git --build-backend uv"

# AI-SDLC-ish
# cd into a .claude repo and hardcode the git config to me despite any conditional configs

alias aicc="git -C .claude config --local user.name neozenith && git -C .claude config --local user.email joshpeak05@gmail.com"

alias ainz="git clone https://github.com/neozenith/agentic-dotfiles/ .claude"
alias aic="git clone https://github.com/jpeakai/skills/ .claude"

alias aisnz="npx skills@latest add neozenith/agentic-dotfiles/"
alias aisc="npx skills@latest add jpeakai/skills/"
alias aisce="npx skills@latest add EveryInc/compound-engineering-plugin"
alias aisu="npx skills@latest update"

# Claude
alias ccdsp="claude --dangerously-skip-permissions"
alias ccpma="claude --permission-mode auto"
alias ccn="claude --permission-mode auto --name"

#Codex
alias coa="codex --approve-for-me --model 'gpt-5.6-terra'"
alias coas="codex --approve-for-me --model 'gpt-5.6-sol'"
alias coml="codex mcp login"

# Custom Tools
alias mmdr="~/dotfiles/scripts/render_mermaid.sh"

alias v2ai="npx skills add ~/work/agent-capabilities/ --agent claude-code codex github-copilot"
alias jpai="npx skills add ~/jpai/jpai-ai/jpai-skills/ --agent claude-code codex github-copilot"
alias jpai-init="mkdir -p ~/jpai/; cd ~/jpai/; git clone https://github.com/jpeakai/jpai.git .;"

alias cv2ai="code ~/work/agent-capabilities/"
alias cjpai="code ~/jpai/jpai-ai/jpai-skills/"

# dbt Cloud
alias dbtc="/opt/homebrew/bin/dbt"
# dbt Fusion
alias dbtf="/Users/joshpeak/.local/bin/dbt"


alias tfa="terraform apply -auto-approve"
alias tfd="terraform destroy -auto-approve"
alias tff="terraform fmt && terraform validate && terraform graph | dot -Tsvg > graph.svg"

# Append agent/tooling dirs to this repo's git exclude (skip any already present).
# Extra patterns can be passed as args: git_exclude_ai 'node_modules/'
git_exclude_ai() {
  local exclude pattern
  exclude="$(git rev-parse --git-path info/exclude)" || return 1
  mkdir -p "$(dirname "$exclude")" && touch "$exclude"
  for pattern in '.claude/' '.codex/' '.agents/' 'tmp/' '.*_cache/' '.playwright*/' 'node_modules/' "$@"; do
    grep -qxF -- "$pattern" "$exclude" || printf '%s\n' "$pattern" >> "$exclude"
  done
}
alias aii="git_exclude_ai"

# USAGE: eval "$(xenv 2>&1)"
xenv() {
  curl -fsSL https://raw.githubusercontent.com/neozenith/python-onboarding-guide/refs/heads/main/scripts/exportenv.py | python3
}
