#!/usr/bin/env zsh

set -e

PROJECT_ROOT=${0:A:h:h}
LEGACY_ROOT=${PROJECT_ROOT:h}/zsh/scripts
BINARY=${PROJECT_ROOT}/bin/joshpeak-prompt

source ${LEGACY_ROOT}/function_parse_aws_prompt.sh
source ${LEGACY_ROOT}/function_parse_gcloud_prompt.sh
source ${LEGACY_ROOT}/function_parse_gh_prompt.sh
source ${LEGACY_ROOT}/function_parse_git_prompt.sh
source ${LEGACY_ROOT}/function_parse_kubectl_prompt.sh
source ${LEGACY_ROOT}/function_parse_python_prompt.sh

compare() {
  local command=$1
  local function_name=$2
  local legacy_output="$("${function_name}")"
  local go_output="$(${BINARY} "${command}")"

  if [[ "${legacy_output}" != "${go_output}" ]]; then
    print -u2 -- "${command}: output differs"
    print -u2 -- "legacy: ${(qqq)legacy_output}"
    print -u2 -- "go:     ${(qqq)go_output}"
    return 1
  fi
  print -- "${command}: identical"
}

compare aws parse_aws_prompt
compare gcloud parse_gcloud_prompt
compare gh parse_gh_prompt
compare git parse_git_prompt
compare kubernetes parse_k8s_prompt
compare python parse_python_prompt

original_aws_profile=${AWS_PROFILE-}
original_aws_profile_was_set=${+AWS_PROFILE}
export AWS_PROFILE='team\tprod'
compare aws parse_aws_prompt
if (( original_aws_profile_was_set )); then
  export AWS_PROFILE=${original_aws_profile}
else
  unset AWS_PROFILE
fi
