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

  local BRANCH
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

  # Only care about non-default branches. Skip main/master and detached HEAD.
  [[ -z "$BRANCH" || "$BRANCH" == "main" || "$BRANCH" == "master" || "$BRANCH" == "HEAD" ]] && return

  local DARK="%F{240}"
  local GREEN="%F{green}"
  local RED="%F{red}"
  local YELLOW="%F{yellow}"
  local PURPLE="%F{magenta}"
  local NORM="%F{rc}%K{rc}"

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
  [[ -z "$LINE" ]] && return

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

  local OUTPUT=" ${PR_COLOR}⑃ #${NUMBER} ${PR_LABEL}${NORM}"

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
