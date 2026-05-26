

function parse_gcloud_prompt() {
  local OUTPUT=""
  local DARK="%F{052}"
  local BRIGHT="%F{166}"
  local VALID="%F{022}"
  local NORM="%F{rc}%K{rc}"
  local DEFAULT_CLOUDSDK_CONFIG="$HOME/.config/gcloud"
  local CURRENT_CLOUDSDK_CONFIG="$(gcloud info --format='value(config.paths.global_config_dir)' 2>/dev/null)"
  local CURRENT_ACCOUNT="$(gcloud info --format='value(config.account)' 2>/dev/null)"
  local CURRENT_PROJECT="$(gcloud info --format='value(config.project)' 2>/dev/null)"

  # Seconds until the cached access token expires (negative = already expired,
  # empty = no cached token for this account). gcloud stores token_expiry as a
  # UTC ISO timestamp in access_tokens.db; julianday('now') is also UTC.
  local CURRENT_TOKEN_DELTA_SECS=""
  if [[ -n "$CURRENT_ACCOUNT" && -f "$CURRENT_CLOUDSDK_CONFIG/access_tokens.db" ]]; then
    local ESC_ACCOUNT="${CURRENT_ACCOUNT//\'/\'\'}"
    CURRENT_TOKEN_DELTA_SECS="$(sqlite3 "$CURRENT_CLOUDSDK_CONFIG/access_tokens.db" \
      "SELECT CAST((julianday(token_expiry) - julianday('now')) * 86400 AS INTEGER) FROM access_tokens WHERE account_id='$ESC_ACCOUNT';" 2>/dev/null)"
  fi

  local FROM_ENV="🌳"
  local FROM_CFG="📄"
  local CONFIG_SOURCE="" ACCOUNT_SOURCE="" PROJECT_SOURCE=""

  # Determine if each of the current values are from a defined environment variable or from the config file
  if [[ -n "$CURRENT_CLOUDSDK_CONFIG" ]]; then
    if [[ -n "$CLOUDSDK_CONFIG" && "$CLOUDSDK_CONFIG" == "$CURRENT_CLOUDSDK_CONFIG" ]]; then
      CONFIG_SOURCE="$FROM_ENV"
    else
      CONFIG_SOURCE="$FROM_CFG"
    fi
  fi
  if [[ -n "$CURRENT_ACCOUNT" ]]; then
    if [[ -n "$CLOUDSDK_CORE_ACCOUNT" && "$CLOUDSDK_CORE_ACCOUNT" == "$CURRENT_ACCOUNT" ]]; then
      ACCOUNT_SOURCE="$FROM_ENV"
    else
      ACCOUNT_SOURCE="$FROM_CFG"
    fi
  fi
  if [[ -n "$CURRENT_PROJECT" ]]; then
    if [[ -n "$CLOUDSDK_CORE_PROJECT" && "$CLOUDSDK_CORE_PROJECT" == "$CURRENT_PROJECT" ]]; then
      PROJECT_SOURCE="$FROM_ENV"
    else
      PROJECT_SOURCE="$FROM_CFG"
    fi
  fi

  if [[ "$CURRENT_CLOUDSDK_CONFIG" == "$DEFAULT_CLOUDSDK_CONFIG" ]]; then
    OUTPUT=" ${DARK}☁️ gcloud-default${CONFIG_SOURCE}${NORM}"
  else
    OUTPUT=" ${BRIGHT}☁️ ${CURRENT_CLOUDSDK_CONFIG/#$HOME/~}${CONFIG_SOURCE}${NORM}"
  fi

  if [[ -n "$CURRENT_ACCOUNT" || -n "$CURRENT_PROJECT" ]]; then
    OUTPUT+=" ${DARK}(${CURRENT_ACCOUNT:-no-account}${ACCOUNT_SOURCE} ⚡ ${CURRENT_PROJECT:-no-project}${PROJECT_SOURCE})${NORM}"
  fi

  if [[ -n "$CURRENT_ACCOUNT" ]]; then
    local AUTH_LABEL="" AUTH_COLOR="$DARK"
    if [[ -z "$CURRENT_TOKEN_DELTA_SECS" ]]; then
      AUTH_LABEL="no token"
    else
      local abs=${CURRENT_TOKEN_DELTA_SECS#-}
      local human
      if (( abs < 60 )); then       human="${abs}s"
      elif (( abs < 3600 )); then   human="$((abs/60))m"
      elif (( abs < 86400 )); then  human="$((abs/3600))h"
      else                          human="$((abs/86400))d"
      fi
      if (( CURRENT_TOKEN_DELTA_SECS < 0 )); then
        AUTH_LABEL="expired ${human} ago"
      else
        AUTH_LABEL="${human} left"
        AUTH_COLOR="$VALID"
      fi
    fi
    OUTPUT+=" ${AUTH_COLOR}🔑 ${AUTH_LABEL}${NORM}"
  fi

  echo -e $OUTPUT
}
