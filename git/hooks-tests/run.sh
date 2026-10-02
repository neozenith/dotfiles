#!/usr/bin/env bash
# Test suite for ../hooks. Zero dependencies beyond bash and git.
# Usage: git/hooks-tests/run.sh [name-filter]   (HOOKS_DIR=... to test another copy)
set -uo pipefail
# Job control gives each test its own process group, so a hung hook chain can be killed whole.
set -m

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOKS_DIR="${HOOKS_DIR:-$(cd "$TESTS_DIR/../hooks" && pwd)}"
RUN_DIR="$TESTS_DIR/tmp/run-$(date +%Y%m%d-%H%M%S)-$$"
FILTER="${1:-}"
TEST_TIMEOUT="${TEST_TIMEOUT:-10}"
mkdir -p "$RUN_DIR"

# Isolate from the user's real config: hooks under test, no signing, fixed identity.
export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL="$RUN_DIR/gitconfig"
cat > "$GIT_CONFIG_GLOBAL" <<EOF
[user]
	name = Test User
	email = test@example.com
[core]
	hooksPath = $HOOKS_DIR
[commit]
	gpgsign = false
[init]
	defaultBranch = main
EOF

PASS=0
FAIL=0
FAILED=()
CURRENT=""

fail() {
	echo "    ✗ $*"
	return 1
}

assert_eq() { # actual expected
	[ "$1" = "$2" ] || fail "expected:"$'\n'"$2"$'\n'"--- got ---"$'\n'"$1"
}

new_repo() { # -> path of a fresh repo named after the current test
	local repo="$RUN_DIR/$CURRENT"
	git init -q "$repo"
	echo "$repo"
}

last_msg() { # repo
	git -C "$1" log -1 --format=%B
}

local_hook() { # repo hook-name body
	printf '#!/bin/sh\n%s\n' "$3" > "$1/.git/hooks/$2"
	chmod +x "$1/.git/hooks/$2"
}

run_test() { # name
	CURRENT="$1"
	[ -n "$FILTER" ] && [[ "$1" != *"$FILTER"* ]] && return
	# Not inside `if`: bash disables set -e in conditions, which would mask failures.
	( set -e; "$1" ) &
	local pid=$! ticks=0 rc
	while kill -0 "$pid" 2>/dev/null; do
		if [ "$ticks" -ge $((TEST_TIMEOUT * 10)) ]; then
			echo "    ✗ timed out after ${TEST_TIMEOUT}s"
			kill -KILL -- "-$pid" 2>/dev/null
			break
		fi
		sleep 0.1
		ticks=$((ticks + 1))
	done
	wait "$pid" 2>/dev/null
	rc=$?
	if [ "$rc" -eq 0 ]; then
		echo "  ✓ $1"
		PASS=$((PASS + 1))
	else
		echo "  ✗ $1"
		FAIL=$((FAIL + 1))
		FAILED+=("$1")
	fi
}

# --- commit-msg: stripping ---------------------------------------------------

test_strips_claude_coauthor() {
	local r; r="$(new_repo)"
	git -C "$r" commit -q --allow-empty -m "feat: thing

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
	assert_eq "$(last_msg "$r")" "feat: thing"
}

test_strips_case_insensitive() {
	local r; r="$(new_repo)"
	git -C "$r" commit -q --allow-empty -m "feat: thing

co-authored-by: claude <noreply@anthropic.com>
CO-AUTHORED-BY: CLAUDE SONNET <x@y.z>"
	assert_eq "$(last_msg "$r")" "feat: thing"
}

test_strips_anthropic_noreply_any_name() {
	local r; r="$(new_repo)"
	git -C "$r" commit -q --allow-empty -m "feat: thing

Co-Authored-By: Some Bot <noreply@anthropic.com>"
	assert_eq "$(last_msg "$r")" "feat: thing"
}

test_strips_generated_with_line() {
	local r; r="$(new_repo)"
	git -C "$r" commit -q --allow-empty -m "feat: thing

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
	assert_eq "$(last_msg "$r")" "feat: thing"
}

test_keeps_human_coauthor() {
	local r; r="$(new_repo)"
	git -C "$r" commit -q --allow-empty -m "feat: thing

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Co-authored-by: Jane Doe <jane@example.com>"
	assert_eq "$(last_msg "$r")" "feat: thing

Co-authored-by: Jane Doe <jane@example.com>"
}

test_keeps_body_mentioning_claude() {
	local r; r="$(new_repo)"
	local msg="fix: claude config loader

Claude Code settings were ignored."
	git -C "$r" commit -q --allow-empty -m "$msg"
	assert_eq "$(last_msg "$r")" "$msg"
}

test_no_trailing_blank_lines() {
	local r; r="$(new_repo)"
	git -C "$r" commit -q --allow-empty -m "feat: thing

Body.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
	assert_eq "$(git -C "$r" cat-file commit HEAD | tail -n 1)" "Body."
}

test_strips_on_amend() {
	local r; r="$(new_repo)"
	git -C "$r" commit -q --allow-empty -m "first"
	git -C "$r" commit -q --amend --allow-empty -m "first

Co-Authored-By: Claude <noreply@anthropic.com>"
	assert_eq "$(last_msg "$r")" "first"
}

test_strips_from_message_file() {
	local r; r="$(new_repo)"
	printf 'feat: from file\n\nCo-Authored-By: Claude <noreply@anthropic.com>\n' > "$RUN_DIR/$CURRENT.msg"
	git -C "$r" commit -q --allow-empty -F "$RUN_DIR/$CURRENT.msg"
	assert_eq "$(last_msg "$r")" "feat: from file"
}

# --- chaining to repo-local hooks -------------------------------------------

test_commit_msg_chains_to_local_hook() {
	local r; r="$(new_repo)"
	local_hook "$r" commit-msg 'cp "$1" "$(git rev-parse --git-dir)/seen-msg"'
	git -C "$r" commit -q --allow-empty -m "feat: thing

Co-Authored-By: Claude <noreply@anthropic.com>"
	# Local hook runs, and sees the already-cleaned message.
	assert_eq "$(cat "$r/.git/seen-msg")" "feat: thing"
}

test_local_commit_msg_failure_aborts() {
	local r; r="$(new_repo)"
	local_hook "$r" commit-msg 'exit 1'
	! git -C "$r" commit -q --allow-empty -m "nope" 2>/dev/null || fail "commit should have been rejected"
}

test_pre_commit_delegates_to_local_hook() {
	local r; r="$(new_repo)"
	local_hook "$r" pre-commit 'touch "$(git rev-parse --git-dir)/pre-commit-ran"'
	git -C "$r" commit -q --allow-empty -m "x"
	[ -f "$r/.git/pre-commit-ran" ] || fail "local pre-commit did not run"
}

test_local_pre_commit_failure_aborts() {
	local r; r="$(new_repo)"
	local_hook "$r" pre-commit 'exit 1'
	! git -C "$r" commit -q --allow-empty -m "x" 2>/dev/null || fail "commit should have been rejected"
}

test_delegate_passes_arguments() {
	local r; r="$(new_repo)"
	local_hook "$r" prepare-commit-msg 'echo "$#:$2" > "$(git rev-parse --git-dir)/args"'
	git -C "$r" commit -q --allow-empty -m "x"
	assert_eq "$(cat "$r/.git/args")" "2:message"
}

test_no_local_hooks_succeeds() {
	local r; r="$(new_repo)"
	git -C "$r" commit -q --allow-empty -m "plain"
	assert_eq "$(last_msg "$r")" "plain"
}

test_delegates_from_linked_worktree() {
	local r; r="$(new_repo)"
	git -C "$r" commit -q --allow-empty -m "base"
	git -C "$r" worktree add -q "$RUN_DIR/$CURRENT-wt" -b wt
	local_hook "$r" pre-commit 'touch "$(git rev-parse --git-common-dir)/wt-pre-commit-ran"'
	git -C "$RUN_DIR/$CURRENT-wt" commit -q --allow-empty -m "in worktree

Co-Authored-By: Claude <noreply@anthropic.com>"
	[ -f "$r/.git/wt-pre-commit-ran" ] || fail "local pre-commit did not run from worktree"
	assert_eq "$(last_msg "$RUN_DIR/$CURRENT-wt")" "in worktree"
}

test_delegate_does_not_recurse() {
	# Regression: `git rev-parse --git-path hooks/X` honours core.hooksPath and
	# made _delegate exec itself forever. The run_test watchdog turns a hang into a failure.
	local r; r="$(new_repo)"
	git -C "$r" commit -q --allow-empty -m "x"
}

# --- layout -----------------------------------------------------------------

test_hook_links_point_to_delegate() {
	local h
	for h in pre-commit prepare-commit-msg post-commit pre-push pre-rebase post-checkout post-merge pre-merge-commit; do
		[ -L "$HOOKS_DIR/$h" ] || fail "$h is not a symlink"
		assert_eq "$(readlink "$HOOKS_DIR/$h")" "_delegate"
	done
}

test_hooks_are_executable() {
	[ -x "$HOOKS_DIR/_delegate" ] || fail "_delegate not executable"
	[ -x "$HOOKS_DIR/commit-msg" ] || fail "commit-msg not executable"
}

# --- run --------------------------------------------------------------------

echo "hooks: $HOOKS_DIR"
echo "scratch: $RUN_DIR"
for t in $(declare -F | awk '{print $3}' | grep '^test_'); do
	run_test "$t"
done

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || { printf '  failed: %s\n' "${FAILED[@]}"; exit 1; }
