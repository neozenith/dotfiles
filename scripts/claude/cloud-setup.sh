#!/usr/bin/env bash
# Claude Code cloud environment setup (Claude Cloud Worker, "ccw").
#
# The environment's setup script is a thin stub that downloads and runs this
# file at a pinned `ccw/vX.Y.Z` tag. It runs as root, before Claude starts,
# and its result is cached as a filesystem snapshot. See README-ccw.md.
#
# This script provisions the machine only:
#   1. Claude plugins
#   2. Cloud CLIs
# Git config and other per-session state belong to the jpai-ccw plugin's
# ccw-setup skill, which runs inside the session.
#
# Environment variables. The setup script cannot read the environment's saved
# variables, so the stub exports these before running this file:
#   CLAUDECLOUDWORKER_ROLE_ARN  IAM role assumed by the "ccw" AWS profile.
#   CCW_AWS_REGION              Region for the "ccw" profile (default ap-southeast-2).
set -euo pipefail

log() { printf '[cloud-setup] %s\n' "$*"; }

# --- 1. Claude plugins ------------------------------------------------------
# The marketplace's registered name is "jpeakai", not "jpeakai-skills".
MARKETPLACE=jpeakai
PLUGINS=(jpai-essentials jpai-ccw)

claude plugin marketplace add https://github.com/jpeakai/skills.git || true
claude plugin marketplace update "$MARKETPLACE"
for plugin in "${PLUGINS[@]}"; do
  # Non-fatal: a plugin missing from the marketplace must not block sessions.
  claude plugin install "$plugin@$MARKETPLACE" || log "could not install $plugin@$MARKETPLACE"
done

# --- 2. Cloud CLIs ----------------------------------------------------------
# AWS CLI v2 is not in the base image.
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
