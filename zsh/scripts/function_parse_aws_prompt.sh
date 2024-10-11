function parse_aws_prompt() {
  local OUTPUT=""
  local DARK="%F{052}"
  local BRIGHT="%F{166}"
  local NORM="%F{rc}%K{rc}"
  if [[ -z $AWS_PROFILE ]]; then
    OUTPUT=" ${DARK}☁️  aws_profile_not_set%F{rc}%K{rc}"
  else
    OUTPUT=" ${BRIGHT}☁️ $AWS_PROFILE%F{rc}%K{rc}"
  fi

  echo -e $OUTPUT
}
