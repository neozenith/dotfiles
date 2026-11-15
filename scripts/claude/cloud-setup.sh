#!/usr/bin/env bash
# Claude Code cloud environment setup.
#
# The environment's setup script is a thin stub that downloads and runs this
# file, so changes here reach every new cloud session without editing the
# environment. It runs as root, from the directory that holds the repository
# checkouts, before Claude starts.
#
# Environment variables. The setup script cannot read the environment's saved
# variables, so the stub exports these before running this file:
#   CCW_GIT_NAME              Commit author name for every checked-out repo.
#   CCW_GIT_EMAIL             Commit author email for every checked-out repo.
#   CLAUDECLOUDWORKER_ROLE_ARN  IAM role assumed by the "ccw" AWS profile.
#   CCW_AWS_REGION            Region for the "ccw" profile (default ap-southeast-2).
set -euo pipefail

log() { printf '[cloud-setup] %s\n' "$*"; }

# --- Claude plugins ---------------------------------------------------------
# The marketplace's registered name is "jpeakai", not "jpeakai-skills".
claude plugin marketplace add https://github.com/jpeakai/skills.git || true
claude plugin marketplace update jpeakai
claude plugin install jpai-essentials@jpeakai

# --- AWS CLI v2 (not in the base image) -------------------------------------
if ! command -v aws >/dev/null 2>&1; then
  log "installing AWS CLI v2"
  AWS_TMP="$(mktemp -d)"
  curl -sSfo "$AWS_TMP/awscliv2.zip" https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
  unzip -q -o "$AWS_TMP/awscliv2.zip" -d "$AWS_TMP"
  "$AWS_TMP/aws/install" --update
  rm -rf "$AWS_TMP"
fi

if [ -n "${CLAUDECLOUDWORKER_ROLE_ARN:-}" ]; then
  aws configure set profile.ccw.role_arn "$CLAUDECLOUDWORKER_ROLE_ARN"
  aws configure set profile.ccw.credential_source Environment
  aws configure set profile.ccw.region "${CCW_AWS_REGION:-ap-southeast-2}"
else
  log "CLAUDECLOUDWORKER_ROLE_ARN unset, skipping ccw AWS profile"
fi

# --- Git identity for every checked-out repo --------------------------------
# Commit as the maintainer, not the agent. Repo-local config overrides the
# container's global git identity.
if [ -n "${CCW_GIT_NAME:-}" ] && [ -n "${CCW_GIT_EMAIL:-}" ]; then
  for gitdir in ./*/.git; do
    [ -e "$gitdir" ] || continue
    repo="$(dirname "$gitdir")"
    git -C "$repo" config user.name "$CCW_GIT_NAME"
    git -C "$repo" config user.email "$CCW_GIT_EMAIL"
    log "git identity set for ${repo#./}"
  done
else
  log "CCW_GIT_NAME or CCW_GIT_EMAIL unset, skipping git identity"
fi
