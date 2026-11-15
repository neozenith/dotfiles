#!/usr/bin/env bash
# Template for the Claude cloud environment's setup script.
# Paste this into the environment's Setup script box and fill in the values.
# Bumping CCW_REF changes the script, which rebuilds the environment cache.
set -euo pipefail

# Cache bust: edit this date to reinstall the latest plugins without a new tag.
# 2026-11-15

CCW_REF="ccw/v1.0.0"
URL="https://raw.githubusercontent.com/neozenith/dotfiles/refs/tags/${CCW_REF}/scripts/claude/cloud-setup.sh"

# Personal values live here, not in the public repo. The setup script
# cannot read the environment's saved variables, so export them for it.
export CLAUDECLOUDWORKER_ROLE_ARN="arn:aws:iam::<account-id>:role/<role-name>"
export CCW_AWS_REGION="ap-southeast-2"

SETUP="$(mktemp)"
curl -sSfL "$URL" -o "$SETUP"
bash "$SETUP"
