#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Claude Code status line.

Claude Code pipes a JSON session payload to stdin and renders the first line of
stdout as the status line. Rendering is a pure function of that payload so it is
directly unit-testable; see test_statusline.py.

Current output shape::

    vX.Y.Z[ [N% 5h | N% 7d]][Model] I:148k|O:2k | ~/path | branch[ stats]

In a linked worktree the path segment becomes ``WT: <path relative to the main
repo root>`` — the prefix is the "you are in a worktree" signal, so the
worktree's own name never has to be spelled out.

Git markers, in render order: ``!`` conflicts, ``+`` staged, ``*`` modified,
``?`` untracked, ``↑`` ahead of upstream, ``↓`` behind upstream, ``M↓`` behind
the remote default branch (needs resync), ``@3h`` last-fetch age once stale,
``git?`` a failed git call.

Payload reference
=================

Fields as documented at https://code.claude.com/docs/en/statusline (captured
2026-07-23). Sourced from the docs, not from observed payloads, except where a
comment says otherwise. Fields this script reads are marked ``[used]``.

Identity and session
    ``session_id``              Unique session identifier. ``[used]``
    ``session_name``            ``--name`` / ``/rename`` value, else the
                                AI-generated title. ABSENT for the default
                                display name such as ``my-app-3f``. ``[used]``
    ``prompt_id``               UUID of the prompt being processed. ABSENT
                                until the first user input.
    ``transcript_path``         Path to the conversation transcript jsonl.
    ``version``                 Claude Code version. ``[used]``
    ``output_style.name``       Current output style.
    ``agent.name``              ABSENT unless running with ``--agent`` or
                                configured agent settings.
    ``vim.mode``                ``NORMAL`` | ``INSERT`` | ``VISUAL`` |
                                ``VISUAL LINE``. ABSENT unless vim mode is on.

Model and inference
    ``model.id``                e.g. ``claude-opus-4-8``.
    ``model.display_name``      e.g. ``Opus 4.8 (1M context)``. ``[used]``
    ``fast_mode``               Whether fast mode is enabled.
    ``thinking.enabled``        Whether extended thinking is enabled.
    ``effort.level``            ``low`` | ``medium`` | ``high`` | ``xhigh`` |
                                ``max``, live including mid-session ``/effort``.
                                ABSENT when the model has no effort parameter.

Directories
    ``cwd``                     Current working directory. ``[used]``
    ``workspace.current_dir``   Same value as ``cwd``; preferred for symmetry
                                with ``project_dir``.
    ``workspace.project_dir``   Where Claude Code was launched. Differs from
                                ``cwd`` once the working directory changes.
    ``workspace.added_dirs``    From ``/add-dir`` / ``--add-dir``. ``[]`` if none.

Git
    ``workspace.git_worktree``  Worktree NAME when cwd is inside a linked
                                worktree from ``git worktree add``. ABSENT in
                                the main tree. Populated for ANY git worktree,
                                unlike ``worktree.*``. ``[used]``
    ``workspace.repo.host``     e.g. ``github.com``, parsed from ``origin``.
    ``workspace.repo.owner``    e.g. ``anthropics``.
    ``workspace.repo.name``     e.g. ``claude-code``. The whole ``repo`` object
                                is ABSENT outside a repo or with no ``origin``.
    ``pr.number``, ``pr.url``   Open PR for the current branch. ABSENT until one
                                is found, outside a repo, or once it closes.
    ``pr.review_state``         ``approved`` | ``pending`` | ``changes_requested``
                                | ``draft``. May be absent while ``pr`` is present.

    NOTE: there is no branch field for ordinary sessions. This script reads
    ``.git/HEAD`` directly, and shells out for everything the index knows.

Harness worktrees (``--worktree`` / ``/worktree`` sessions ONLY)
    ``worktree.name``           Name of the active worktree. ``[used]``
    ``worktree.path``           Absolute path to the worktree directory. Wins
                                over ``cwd`` when resolving the repo. ``[used]``
    ``worktree.branch``         e.g. ``worktree-my-feature``. ABSENT for
                                hook-based worktrees. ``[used]``
    ``worktree.original_cwd``   Directory Claude was in before entering.
    ``worktree.original_branch`` Branch checked out before entering. ABSENT for
                                hook-based worktrees.

Cost
    ``cost.total_cost_usd``     Client-side estimate; may differ from the bill.
                                Resets to $0 when ``/clear`` starts a session.
    ``cost.total_duration_ms``  Wall clock since session start.
    ``cost.total_api_duration_ms`` Time spent waiting on API responses.
    ``cost.total_lines_added``, ``cost.total_lines_removed`` Lines changed.

Context window
    ``context_window.total_input_tokens``  In context now, from the most recent
                                API response. Includes cache reads. ``[used]``
    ``context_window.total_output_tokens`` ``[used]``
    ``context_window.context_window_size`` 200000, or 1000000 for extended.
    ``context_window.used_percentage``     Pre-calculated. NULL early in a session.
    ``context_window.remaining_percentage`` Pre-calculated. NULL early in a session.
    ``context_window.current_usage``       Per-call breakdown: ``input_tokens``,
                                ``output_tokens``, ``cache_creation_input_tokens``,
                                ``cache_read_input_tokens``. NULL before the
                                first API call and after ``/compact`` until the
                                next one.
    ``exceeds_200k_tokens``     Whether the latest response exceeded 200k total
                                tokens. Fixed threshold, regardless of window size.

Rate limits (Claude.ai Pro/Max ONLY, and only after the first API response)
    ``rate_limits.five_hour.used_percentage``  0-100. ``[used]``
    ``rate_limits.seven_day.used_percentage``  0-100. ``[used]``
    ``rate_limits.five_hour.resets_at``        Unix epoch seconds.
    ``rate_limits.seven_day.resets_at``        Unix epoch seconds.
    Each window may be absent independently of the other.

Absence is the rule, not the exception: treat every field above as optional and
default it. Fields documented as NULL-able are present with a ``null`` value,
which ``.get(k, default)`` will NOT replace — use ``.get(k) or default``.
"""

from __future__ import annotations

import json
import math
import os
import subprocess
import sys
import time
from typing import Any
from pathlib import Path

# Beyond this, remote-tracking refs are old enough that the resync numbers
# derived from them get an explicit age marker rather than implying freshness.
STALE_FETCH_SECONDS = 15 * 60


def _pct(value: Any) -> str | None:
    """Floor a percentage to a whole number, or None when absent."""
    if value is None:
        return None
    return str(math.floor(value))


def _limits(rate_limits: dict[str, Any]) -> str:
    """Render the rate-limit suffix. Only Claude.ai subscriptions supply this."""
    five_h = _pct(rate_limits.get("five_hour", {}).get("used_percentage"))
    seven_d = _pct(rate_limits.get("seven_day", {}).get("used_percentage"))
    parts = [f"5h:{five_h}%"] if five_h else []
    if seven_d:
        parts.append(f"7d:{seven_d}%")
    return f" [{' | '.join(parts)}]" if parts else ""

def tildify(path: Path) -> str:
    """Inverse of os.path.expanduser: /Users/you/work/x -> ~/work/x"""
    home = Path.home()
    if path == home:
        return "~"
    return f"~/{path.relative_to(home)}" if path.is_relative_to(home) else str(path)


def find_git_dir(start: Path) -> tuple[Path, Path] | None:
    """Locate the repo for `start`, returning (work_tree_root, git_dir).

    Walks upward looking for `.git`. In the main working tree `.git` is a
    directory and the two paths differ only by that suffix. In a linked worktree
    `.git` is a *file* holding `gitdir: <abs path>` that points into the parent
    repo's `.git/worktrees/<name>/`, which is where that worktree's own HEAD
    lives. Returns None outside a repository.
    """
    for directory in (start, *start.parents):
        dot_git = directory / ".git"
        if dot_git.is_dir():
            return directory, dot_git
        if dot_git.is_file():
            pointer = dot_git.read_text(encoding="utf-8").strip()
            if pointer.startswith("gitdir:"):
                return directory, Path(pointer.removeprefix("gitdir:").strip())
    return None


def read_head(git_dir: Path) -> str:
    """Branch name from HEAD, or a short SHA when detached."""
    head = (git_dir / "HEAD").read_text(encoding="utf-8").strip()
    if head.startswith("ref:"):
        return head.removeprefix("ref:").strip().removeprefix("refs/heads/")
    return head[:7]


def common_dir(git_dir: Path) -> Path:
    """The shared `.git` for a repo.

    A linked worktree's git dir holds only per-worktree state (HEAD, index). The
    refs and FETCH_HEAD everyone shares live in the common dir, named by a
    `commondir` file whose contents are relative to the worktree git dir.
    """
    pointer = git_dir / "commondir"
    if not pointer.is_file():
        return git_dir
    return (git_dir / pointer.read_text(encoding="utf-8").strip()).resolve()


def worktree_label(work_tree: Path, common: Path) -> str | None:
    """``WT: <path relative to the main repo root>``, or None in a main tree.

    The common dir is the main tree's own `.git`, so its parent is that tree's
    root — the anchor every linked worktree shares. Rendering the path relative
    to it drops the repo prefix that is identical on every line of the status
    bar, and keeps the part that actually identifies the checkout. `relpath`
    rather than `Path.relative_to` because `git worktree add` is free to place a
    checkout outside the repo, which is honestly reported as `../name`.
    """
    if common.name != ".git":
        return None
    main_root = common.parent
    if work_tree == main_root:
        return None
    return f"WT: {os.path.relpath(work_tree, main_root)}"


def default_remote_branch(common: Path) -> str | None:
    """The remote's default branch, e.g. `origin/main`, from origin/HEAD.

    Set by `git clone` and refreshed by `git remote set-head`. Absent in repos
    that never had it resolved, in which case there is nothing to resync against.
    """
    head = common / "refs" / "remotes" / "origin" / "HEAD"
    if head.is_file():
        ref = head.read_text(encoding="utf-8").strip()
    else:
        packed = common / "packed-refs"
        if not packed.is_file():
            return None
        ref = next(
            (ln for ln in packed.read_text(encoding="utf-8").splitlines()
             if ln.endswith("refs/remotes/origin/HEAD")),
            "",
        )
    _, _, name = ref.partition("refs/remotes/")
    return name or None


def fetch_age_seconds(common: Path) -> float | None:
    """Seconds since the last fetch, or None if this repo has never fetched.

    Load-bearing: every number derived from a remote-tracking ref is only as
    fresh as this. A statusline must not imply it knows the remote's state.
    """
    fetch_head = common / "FETCH_HEAD"
    if not fetch_head.is_file():
        return None
    return time.time() - fetch_head.stat().st_mtime


def _run_git(work_tree: Path, *args: str) -> str:
    """Run a read-only git command in `work_tree`.

    GIT_OPTIONAL_LOCKS=0 is required, not cosmetic: `git status` would otherwise
    take the index lock to refresh stat info, and this runs on every render —
    contending with whatever git command the user or agent is running.
    """
    return subprocess.run(
        ("git", *args),
        cwd=work_tree,
        env={"PATH": os.environ.get("PATH", ""), "GIT_OPTIONAL_LOCKS": "0"},
        capture_output=True,
        text=True,
        timeout=2,
        check=True,
    ).stdout


def parse_status(porcelain: str) -> dict[str, int]:
    """Count file states and upstream divergence from `status --porcelain=v2 -b`.

    Tracked entries are `1 XY ...` (ordinary) and `2 XY ...` (renamed), where X
    is the staged state and Y the worktree state; `.` means unchanged, so a file
    can be counted in both columns. `u` marks unmerged paths and `?` untracked.
    """
    counts = {"staged": 0, "modified": 0, "conflicts": 0, "untracked": 0,
              "ahead": 0, "behind": 0}
    for line in porcelain.splitlines():
        if line.startswith("# branch.ab "):
            ahead, behind = line.split()[2:4]
            counts["ahead"], counts["behind"] = int(ahead), abs(int(behind))
        elif line.startswith(("1 ", "2 ")):
            staged, worktree = line.split()[1][:2]
            counts["staged"] += staged != "."
            counts["modified"] += worktree != "."
        elif line.startswith("u "):
            counts["conflicts"] += 1
        elif line.startswith("? "):
            counts["untracked"] += 1
    return counts


def _stats(work_tree: Path, common: Path) -> str:
    """Render working-tree and divergence counts.

    Two git invocations: one `status` for file states plus upstream ahead/behind,
    one `rev-list` for divergence from the remote default branch. The second is
    the resync signal — a branch can be fully pushed (`up to date` with its own
    upstream) while origin/main has moved well past it.
    """
    default_ref = default_remote_branch(common)
    try:
        counts = parse_status(_run_git(work_tree, "status", "--porcelain=v2", "--branch"))
        drift = 0
        if default_ref:
            left, _, _ = _run_git(
                work_tree, "rev-list", "--left-right", "--count",
                f"{default_ref}...HEAD",
            ).partition("\t")
            drift = int(left.strip() or 0)
    except (subprocess.SubprocessError, OSError, ValueError):
        return "git?"  # visible failure; never a silent blank

    parts = []
    if counts["conflicts"]:
        parts.append(f"!{counts['conflicts']}")
    if counts["staged"]:
        parts.append(f"+{counts['staged']}")
    if counts["modified"]:
        parts.append(f"*{counts['modified']}")
    if counts["untracked"]:
        parts.append(f"?{counts['untracked']}")
    if counts["ahead"]:
        parts.append(f"↑{counts['ahead']}")
    if counts["behind"]:
        parts.append(f"↓{counts['behind']}")
    if drift:
        parts.append(f"M↓{drift}")

    age = fetch_age_seconds(common)
    if parts and age is not None and age > STALE_FETCH_SECONDS:
        parts.append(f"@{_duration(age)}")
    return " ".join(parts)


def compact_model(name: str) -> str:
    """Squeeze the display name: "Opus 4.8 (1M context)" -> "Opus4.8".

    The parenthetical is a variant tag, not identity, and the window size it
    names is already available as `context_window.context_window_size`.
    """
    return name.partition("(")[0].strip().replace(" ", "")


def humanize(count: int) -> str:
    """Compact token counts: 812 -> 812, 147558 -> 148k, 1246000 -> 1.2M.

    Rounds rather than truncates, so the boundary case matters: 999_600 rounds
    to 1000k, which is really 1M and must carry up a unit rather than render a
    four-digit k.
    """
    if count < 1000:
        return str(count)
    if round(count / 1000) < 1000:
        return f"{round(count / 1000)}k"
    return f"{count / 1_000_000:.1f}M"


def _duration(seconds: float) -> str:
    """Coarse age: 45m, 3h, 2d. Precision past the unit is never actionable."""
    if seconds < 3600:
        return f"{int(seconds // 60)}m"
    if seconds < 86400:
        return f"{int(seconds // 3600)}h"
    return f"{int(seconds // 86400)}d"


def _git(data: dict[str, Any], cwd: Path) -> tuple[str, str]:
    """Render (location, git) — the path segment and the branch segment.

    They are produced together because both are answers to the same lookup: a
    linked worktree wants its path shown relative to the main repo root, which
    is only known once the repo has been resolved.

    Two unrelated ways a session ends up on a worktree, and they report
    differently:

    1. Launched inside a worktree folder. `cwd` is the worktree and
       `workspace.git_worktree` names it. Any `git worktree add` checkout.
    2. Entered mid-session via `--worktree` / `/worktree`. The harness tracks
       this out-of-band in `worktree.*` and keeps `cwd` anchored — hence
       `worktree.original_cwd`. Resolving from `cwd` alone would read the
       *original* repo and report the wrong branch, so `worktree.path` wins,
       and the location follows the branch rather than the anchored `cwd`.

    The payload carries no branch for case 1 (`worktree.branch` is populated
    only for `--worktree` sessions), so HEAD is read from disk as the default.
    """
    session_worktree = data.get("worktree") or {}
    root = Path(session_worktree["path"]) if session_worktree.get("path") else cwd

    found = find_git_dir(root)
    if found is None:
        return tildify(cwd), ""
    work_tree, git_dir = found
    common = common_dir(git_dir)
    branch = session_worktree.get("branch") or read_head(git_dir)
    stats = _stats(work_tree, common)
    location = worktree_label(work_tree, common) or tildify(cwd)
    return location, f"{branch} {stats}" if stats else branch


def render(data: dict[str, Any]) -> str:
    """Build the status line from a Claude Code session payload."""
    # session = data.get("session_name") or data.get("session_id") or ""
    model = compact_model(data.get("model", {}).get("display_name", ""))
    ctx = data.get("context_window", {})
    cwd_path = Path(data.get("cwd", ""))
    version = data.get("version", "")
    location, git = _git(data, cwd_path)

    # prefix = f"{session} " if session else ""
    counts = (
        f"I:{humanize(ctx.get('total_input_tokens', 0))}"
        f"|O:{humanize(ctx.get('total_output_tokens', 0))}"
    )
    limits = _limits(data.get("rate_limits") or {})

    return f"v{version}{limits}[{model}] {counts} | {location}" + (
        f" | {git}" if git else ""
    )


def main() -> None:
    print(render(json.load(sys.stdin)))


if __name__ == "__main__":
    main()
