

function parse_gcloud_prompt() {
  local OUTPUT=""
  local DARK="%F{052}"
  local BRIGHT="%F{166}"
  local NORM="%F{rc}%K{rc}"
  local DEFAULT_CLOUDSDK_CONFIG="$HOME/.config/gcloud"
  local CURRENT_CLOUDSDK_CONFIG="$(gcloud info --format='value(config.paths.global_config_dir)' 2>/dev/null)"
  local CURRENT_ACCOUNT="$(gcloud info --format='value(config.account)' 2>/dev/null)"
  local CURRENT_PROJECT="$(gcloud info --format='value(config.project)' 2>/dev/null)"

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

  echo -e $OUTPUT
}
