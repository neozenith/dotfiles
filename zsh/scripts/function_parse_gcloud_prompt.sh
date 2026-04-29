

function parse_gcloud_prompt() {
  local OUTPUT=""
  local DARK="%F{052}"
  local BRIGHT="%F{166}"
  local NORM="%F{rc}%K{rc}"
  local DEFAULT_CLOUDSDK_CONFIG="$HOME/.config/gcloud"
  local CURRENT_CLOUDSDK_CONFIG="$(gcloud info --format='value(config.paths.global_config_dir)')"
  if [[ "$CURRENT_CLOUDSDK_CONFIG" == "$DEFAULT_CLOUDSDK_CONFIG" ]]; then
    OUTPUT=" ${DARK}☁️ gcloud-default%F{rc}%K{rc}"
  else
    OUTPUT=" ${BRIGHT}☁️ $CURRENT_CLOUDSDK_CONFIG%F{rc}%K{rc}"
  fi

  echo -e $OUTPUT
}
