parse_gh_prompt() {
  # Show GitHub PR + CI status for the current branch.
  #
  # NOTE: unlike parse_git_prompt (which only reads the local cache), `gh pr view`
  # makes a network call. To keep prompts snappy we bail out early on the default
  # branch and only ever hit the network on feature branches.

  # No gh CLI -> nothing to do.
  command -v gh >/dev/null 2>&1 || return

  # Not in a git repo -> nothing to do.
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

  local DARK="%F{240}"
  local GREEN="%F{green}"
  local RED="%F{red}"
  local YELLOW="%F{yellow}"
  local PURPLE="%F{magenta}"
  local NORM="%F{rc}%K{rc}"

  # GitHub CLI account for github.com. The jq filter intentionally returns
  # only the login for the active account.
  local GH_USERNAME
  GH_USERNAME=$(gh auth status --active --hostname github.com --json hosts \
    --jq '.hosts["github.com"][] | select(.active) | .login' 2>/dev/null)
  [[ -z "$GH_USERNAME" ]] && return

  local GH_OUTPUT=" ${DARK}gh:${GH_USERNAME}${NORM}"
  local GIT_REMOTE_URL
  GIT_REMOTE_URL=$(git remote get-url origin 2>/dev/null)
  [[ -z "$GIT_REMOTE_URL" ]] && GIT_REMOTE_URL="https://github.com/"

  local GIT_USERNAME
  GIT_USERNAME=$(git config --get-urlmatch credential.username "$GIT_REMOTE_URL" 2>/dev/null)
  if [[ -n "$GIT_USERNAME" && "$GIT_USERNAME" != "$GH_USERNAME" ]]; then
    # Bright white foreground on a bright red background highlights an
    # identity mismatch before a commit or GitHub operation is performed.
    local BRIGHT_WHITE=$'\033[97m'
    local BRIGHT_RED_BACKGROUND=$'\033[48;5;1m'
    local BRIGHT_RESET=$'\033[0m'
    GH_OUTPUT=" ${BRIGHT_WHITE}${BRIGHT_RED_BACKGROUND}git:${GIT_USERNAME} != gh:${GH_USERNAME}${BRIGHT_RESET}"
  fi

  local BRANCH
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

  # Only care about non-default branches. Skip main/master and detached HEAD.
  [[ -z "$BRANCH" || "$BRANCH" == "main" || "$BRANCH" == "master" || "$BRANCH" == "HEAD" ]] && echo -e "$GH_OUTPUT" && return

  # Single network call. Emit a tab-separated line: number, state, isDraft,
  # #passing, #failing, #total-checks. Uses gh's bundled jq so no external jq
  # dependency. Silenced when there is no PR / no auth / no github remote.
  local LINE
  LINE=$(gh pr view --json number,state,isDraft,statusCheckRollup --jq '
    def passed: (.conclusion == "SUCCESS") or (.state == "SUCCESS");
    def failed: (.conclusion | IN("FAILURE","TIMED_OUT","CANCELLED","STARTUP_FAILURE","ACTION_REQUIRED")) or (.state | IN("FAILURE","ERROR"));
    [ .number,
      .state,
      (.isDraft | tostring),
      ([.statusCheckRollup[] | select(passed)] | length),
      ([.statusCheckRollup[] | select(failed)] | length),
      (.statusCheckRollup | length)
    ] | @tsv' 2>/dev/null)

  # No open PR for this branch -> nothing to show.
  [[ -z "$LINE" ]] && echo -e "$GH_OUTPUT" && return

  local NUMBER STATE ISDRAFT NPASS NFAIL NTOTAL
  IFS=$'\t' read -r NUMBER STATE ISDRAFT NPASS NFAIL NTOTAL <<< "$LINE"

  # PR state: Draft (grey) vs Open (green) vs anything else (e.g. MERGED/CLOSED).
  local PR_LABEL PR_COLOR
  if [[ "$ISDRAFT" == "true" ]]; then
    PR_LABEL="Draft"
    PR_COLOR="$DARK"
  elif [[ "$STATE" == "OPEN" ]]; then
    PR_LABEL="Open"
    PR_COLOR="$GREEN"
  else
    # Title-case whatever else came back (MERGED -> Merged, CLOSED -> Closed).
    PR_LABEL="${(C)STATE:l}"
    PR_COLOR="$PURPLE"
  fi

  local OUTPUT="$GH_OUTPUT"
  OUTPUT="${OUTPUT} ${PR_COLOR}⑃ #${NUMBER} ${PR_LABEL}${NORM}"

  # CI checks summary, only when there are any checks configured.
  if [[ "${NTOTAL:-0}" -gt 0 ]]; then
    local NPENDING=$(( NTOTAL - NPASS - NFAIL ))
    local CHECKS=""
    [[ "${NPASS:-0}"    -gt 0 ]] && CHECKS="${CHECKS}${GREEN}✓${NPASS}${NORM}"
    [[ "${NFAIL:-0}"    -gt 0 ]] && CHECKS="${CHECKS}${RED}✗${NFAIL}${NORM}"
    [[ "${NPENDING:-0}" -gt 0 ]] && CHECKS="${CHECKS}${YELLOW}•${NPENDING}${NORM}"
    [[ -n "$CHECKS" ]] && OUTPUT="${OUTPUT} ${CHECKS}"
  fi

  echo -e "$OUTPUT"
}
