#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pytest>=8.0"]
# ///
"""Unit tests for statusline.py.

Run: uv run ~/.claude/test_statusline.py

Git tests build real `.git` structures under tmp_path rather than mocking, so
the main-tree vs linked-worktree distinction is exercised the way git actually
lays it out on disk. Payload `cwd` values point at tmp_path for the same reason
the opposite way: outside any repo, the git segment is deterministically empty.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from pathlib import Path
from typing import Any

import pytest

sys.path.insert(0, str(Path(__file__).parent))

from statusline import (  # noqa: E402
    _duration,
    common_dir,
    compact_model,
    default_remote_branch,
    fetch_age_seconds,
    find_git_dir,
    humanize,
    parse_status,
    read_head,
    render,
    tildify,
)

# Verbatim `git status --porcelain=v2 --branch` output. `1 AM` is the case that
# matters: staged AND modified, so it must count in both columns.
PORCELAIN = """\
# branch.oid 120df8421aa54c734e19ea459f579674de2e3230
# branch.head feat/profile-badge-entra-roles
# branch.upstream origin/feat/profile-badge-entra-roles
# branch.ab +3 -2
1 A. N... 000000 100644 100644 0000000 cb2b688 .gitignore
1 AM N... 000000 100644 100644 0000000 e31f67a CLAUDE.md
1 .M N... 100644 100644 100644 dd45018 dd45018 README.md
2 R. N... 100644 100644 100644 b0962f0 b0962f0 R100 new.py\tolt.py
u UU N... 100644 100644 100644 100644 aaa bbb ccc conflicted.txt
? untracked-one.txt
? untracked-two.txt
"""

# A full payload as Claude Code emits it for a Claude.ai subscription session.
# Field names and nesting mirror the documented schema at
# https://code.claude.com/docs/en/statusline
FULL: dict[str, Any] = {
    "session_id": "464f07e1-30b1-40bc-acff-ff59075e4352",
    "session_name": "statusline-port",
    "model": {"id": "claude-opus-4-8", "display_name": "Opus 4.8"},
    "workspace": {
        "current_dir": "/Users/joshpeak/work/aurizon/aurizon-buildathon",
        "project_dir": "/Users/joshpeak/work/aurizon/aurizon-buildathon",
        "added_dirs": [],
        "repo": {"host": "github.com", "owner": "V2-Digital", "name": "x"},
    },
    "context_window": {
        "total_input_tokens": 48213,
        "total_output_tokens": 1907,
        "context_window_size": 1000000,
        "used_percentage": 23.7,
    },
    "cwd": "/nonexistent/not-a-repo",
    "version": "2.1.7",
    "rate_limits": {
        "five_hour": {"used_percentage": 41.9, "resets_at": 1738425600},
        "seven_day": {"used_percentage": 12.2, "resets_at": 1738857600},
    },
}

# An API-key session: no session name, no rate limits.
MINIMAL: dict[str, Any] = {
    "session_id": "abc-123",
    "model": {"display_name": "Sonnet 5"},
    "context_window": {
        "total_input_tokens": 0,
        "total_output_tokens": 0,
        "used_percentage": 0,
    },
    "cwd": "/nonexistent/not-a-repo",
    "version": "2.1.7",
}


# --------------------------------------------------------------------------
# Fixtures: real on-disk git layouts
# --------------------------------------------------------------------------


def _git(cwd: Path, *args: str) -> None:
    subprocess.run(
        ("git", "-c", "user.email=t@t", "-c", "user.name=T",
         "-c", "commit.gpgsign=false", *args),
        cwd=cwd, capture_output=True, timeout=30, check=True,
    )


@pytest.fixture
def main_tree(tmp_path: Path) -> Path:
    """A real main working tree on `main` with one commit.

    Built with real git rather than hand-written `.git` files: the code shells
    out to `git status`, so a synthetic directory would only ever exercise the
    failure path.
    """
    repo = tmp_path / "repo"
    repo.mkdir()
    _git(repo, "init", "-q", "-b", "main")
    (repo / "README.md").write_text("hello\n")
    _git(repo, "add", "README.md")
    _git(repo, "commit", "-qm", "initial")
    return repo


@pytest.fixture
def linked_worktree(main_tree: Path) -> Path:
    """A real linked worktree, where `.git` is a FILE, not a directory.

    Deliberately placed OUTSIDE the repo root: `git worktree add` permits it,
    so the relative location label has to survive it.
    """
    checkout = main_tree.parent / "wt-profile-identity"
    _git(main_tree, "worktree", "add", "-q", "-b", "feat/profile-identity",
         str(checkout))
    return checkout


@pytest.fixture
def nested_worktree(main_tree: Path) -> Path:
    """A linked worktree under the repo root, as `/worktree` sessions create."""
    checkout = main_tree / ".claude" / "worktrees" / "sidebar-refactor"
    _git(main_tree, "worktree", "add", "-q", "-b", "worktree-sidebar-refactor",
         str(checkout))
    return checkout


# --------------------------------------------------------------------------
# render()
# --------------------------------------------------------------------------


def test_full_payload() -> None:
    assert render(FULL) == (
        "v2.1.7 [5h:41% | 7d:12%][Opus4.8]"
        " I:48k|O:2k | /nonexistent/not-a-repo"
    )


def test_minimal_payload() -> None:
    assert render(MINIMAL) == "v2.1.7[Sonnet5] I:0|O:0 | /nonexistent/not-a-repo"


@pytest.mark.parametrize(
    ("limits", "expected"),
    [
        ({}, "v2.1.7["),
        ({"five_hour": {"used_percentage": 41.9}}, "v2.1.7 [5h:41%]["),
        ({"seven_day": {"used_percentage": 99.6}}, "v2.1.7 [7d:99%]["),
        (
            {
                "five_hour": {"used_percentage": 41.9},
                "seven_day": {"used_percentage": 12.2},
            },
            "v2.1.7 [5h:41% | 7d:12%][",
        ),
    ],
)
def test_rate_limit_suffix(limits: dict[str, Any], expected: str) -> None:
    assert render({**MINIMAL, "rate_limits": limits}).startswith(expected)


def test_missing_context_window_defaults_to_zero() -> None:
    payload = {k: v for k, v in MINIMAL.items() if k != "context_window"}
    assert "I:0|O:0" in render(payload)


def test_outside_a_repo_omits_the_git_segment() -> None:
    assert render(MINIMAL).endswith("/nonexistent/not-a-repo")


def test_main_tree_renders_bare_branch(main_tree: Path) -> None:
    assert render({**MINIMAL, "cwd": str(main_tree)}).endswith(" | main")


def test_linked_worktree_renders_the_bare_branch(linked_worktree: Path) -> None:
    """The worktree's own name is not repeated — `WT:` already said it."""
    result = render({**MINIMAL, "cwd": str(linked_worktree)})
    assert result.endswith(" | feat/profile-identity")


def test_nested_worktree_path_is_relative_to_the_main_repo_root(
    nested_worktree: Path,
) -> None:
    result = render({**MINIMAL, "cwd": str(nested_worktree)})
    assert result.endswith(
        " | WT: .claude/worktrees/sidebar-refactor | worktree-sidebar-refactor"
    )


def test_worktree_outside_the_repo_root_walks_up(linked_worktree: Path) -> None:
    """`git worktree add` allows it, so the label must not claim containment."""
    result = render({**MINIMAL, "cwd": str(linked_worktree)})
    assert " | WT: ../wt-profile-identity | " in result


def test_main_tree_keeps_the_tildified_absolute_path(main_tree: Path) -> None:
    result = render({**MINIMAL, "cwd": str(main_tree)})
    assert f" | {main_tree} | main" in result
    assert "WT:" not in result


def test_entered_worktree_resolves_from_worktree_path_not_cwd(
    linked_worktree: Path, main_tree: Path,
) -> None:
    """`--worktree` sessions keep `cwd` anchored to where Claude started.

    Resolving from `cwd` would report `main` — the branch of the directory the
    session was launched in — rather than the worktree it is actually editing.
    """
    payload = {
        **MINIMAL,
        "cwd": str(main_tree),
        "worktree": {
            "name": "my-feature",
            "path": str(linked_worktree),
            "branch": "worktree-my-feature",
            "original_cwd": str(main_tree),
            "original_branch": "main",
        },
    }
    result = render(payload)
    assert result.endswith(" | WT: ../wt-profile-identity | worktree-my-feature")


def test_entered_worktree_falls_back_to_head_for_hook_based_worktrees(
    linked_worktree: Path, main_tree: Path,
) -> None:
    """`worktree.branch` is documented as absent for hook-based worktrees."""
    payload = {
        **MINIMAL,
        "cwd": str(main_tree),
        "worktree": {"name": "hooked", "path": str(linked_worktree)},
    }
    assert render(payload).endswith(" | feat/profile-identity")


def test_absent_worktree_block_still_resolves_from_cwd(main_tree: Path) -> None:
    assert render({**MINIMAL, "cwd": str(main_tree)}).endswith(" | main")


# --------------------------------------------------------------------------
# find_git_dir() / read_head()
# --------------------------------------------------------------------------


def test_find_git_dir_in_main_tree(main_tree: Path) -> None:
    assert find_git_dir(main_tree) == (main_tree, main_tree / ".git")


def test_find_git_dir_walks_up_from_a_subdirectory(main_tree: Path) -> None:
    nested = main_tree / "src" / "deep" / "nested"
    nested.mkdir(parents=True)
    assert find_git_dir(nested) == (main_tree, main_tree / ".git")


def test_find_git_dir_follows_the_worktree_pointer_file(
    linked_worktree: Path, main_tree: Path,
) -> None:
    work_tree, git_dir = find_git_dir(linked_worktree)
    assert work_tree == linked_worktree
    assert git_dir == main_tree / ".git" / "worktrees" / "wt-profile-identity"


def test_find_git_dir_returns_none_outside_a_repo(tmp_path: Path) -> None:
    assert find_git_dir(tmp_path) is None


def test_read_head_strips_the_refs_heads_prefix(main_tree: Path) -> None:
    assert read_head(main_tree / ".git") == "main"


def test_read_head_keeps_slashes_in_branch_names(main_tree: Path) -> None:
    (main_tree / ".git" / "HEAD").write_text("ref: refs/heads/feat/a/b/c\n")
    assert read_head(main_tree / ".git") == "feat/a/b/c"


def test_read_head_shortens_a_detached_sha(main_tree: Path) -> None:
    (main_tree / ".git" / "HEAD").write_text("120df84a1b2c3d4e5f60718293a4b5c6d7e8f901\n")
    assert read_head(main_tree / ".git") == "120df84"


# --------------------------------------------------------------------------
# parse_status()
# --------------------------------------------------------------------------


def test_parse_status_counts_every_category() -> None:
    assert parse_status(PORCELAIN) == {
        "staged": 3,  # .gitignore (A.), CLAUDE.md (AM), new.py (R.)
        "modified": 2,  # CLAUDE.md (AM), README.md (.M)
        "conflicts": 1,
        "untracked": 2,
        "ahead": 3,
        "behind": 2,
    }


def test_parse_status_counts_a_file_as_both_staged_and_modified() -> None:
    """`AM` means staged-then-edited-again: it belongs in both columns."""
    counts = parse_status("1 AM N... 0 0 0 aaa bbb file.py\n")
    assert counts["staged"] == 1
    assert counts["modified"] == 1


def test_parse_status_behind_count_is_absolute() -> None:
    """git reports behind as a negative; a status line wants the magnitude."""
    assert parse_status("# branch.ab +0 -12\n")["behind"] == 12


def test_parse_status_handles_a_clean_tree() -> None:
    clean = "# branch.head main\n# branch.ab +0 -0\n"
    assert parse_status(clean) == {
        "staged": 0, "modified": 0, "conflicts": 0,
        "untracked": 0, "ahead": 0, "behind": 0,
    }


def test_parse_status_without_upstream_reports_no_divergence() -> None:
    """A branch with no upstream emits no `# branch.ab` line at all."""
    counts = parse_status("# branch.head solo\n1 .M N... 0 0 0 a b f.py\n")
    assert counts["ahead"] == 0
    assert counts["behind"] == 0
    assert counts["modified"] == 1


# --------------------------------------------------------------------------
# common_dir() / default_remote_branch() / fetch_age_seconds()
# --------------------------------------------------------------------------


def test_common_dir_is_the_git_dir_itself_in_a_main_tree(main_tree: Path) -> None:
    assert common_dir(main_tree / ".git") == main_tree / ".git"


def test_common_dir_follows_the_commondir_pointer(
    linked_worktree: Path, main_tree: Path,
) -> None:
    """A worktree's refs and FETCH_HEAD live in the parent repo's .git."""
    _, git_dir = find_git_dir(linked_worktree)
    assert git_dir != main_tree / ".git"  # per-worktree state is separate
    assert common_dir(git_dir) == (main_tree / ".git").resolve()


def test_default_remote_branch_from_the_origin_head_ref(main_tree: Path) -> None:
    head = main_tree / ".git" / "refs" / "remotes" / "origin" / "HEAD"
    head.parent.mkdir(parents=True, exist_ok=True)
    head.write_text("ref: refs/remotes/origin/main\n")
    assert default_remote_branch(main_tree / ".git") == "origin/main"


def test_default_remote_branch_reads_packed_refs_as_a_second_location(
    main_tree: Path,
) -> None:
    (main_tree / ".git" / "packed-refs").write_text(
        "# pack-refs with: peeled fully-peeled sorted\n"
        "aaa111 refs/remotes/origin/HEAD\n"
    )
    assert default_remote_branch(main_tree / ".git") == "origin/HEAD"


def test_default_remote_branch_is_none_when_origin_head_is_unresolved(
    main_tree: Path,
) -> None:
    assert default_remote_branch(main_tree / ".git") is None


def test_fetch_age_is_none_when_the_repo_has_never_fetched(main_tree: Path) -> None:
    assert fetch_age_seconds(main_tree / ".git") is None


def test_fetch_age_measures_from_fetch_head_mtime(main_tree: Path) -> None:
    fetch_head = main_tree / ".git" / "FETCH_HEAD"
    fetch_head.touch()
    os.utime(fetch_head, (time.time() - 7200, time.time() - 7200))
    assert 7100 < fetch_age_seconds(main_tree / ".git") < 7300


@pytest.mark.parametrize(
    ("seconds", "expected"),
    [(0, "0m"), (90, "1m"), (2700, "45m"), (3600, "1h"), (86_399, "23h"),
     (86_400, "1d"), (300_000, "3d")],
)
def test_duration_is_coarse(seconds: float, expected: str) -> None:
    assert _duration(seconds) == expected


# --------------------------------------------------------------------------
# humanize()
# --------------------------------------------------------------------------


@pytest.mark.parametrize(
    ("count", "expected"),
    [
        (0, "0"),
        (812, "812"),
        (999, "999"),
        (1000, "1k"),
        (1499, "1k"),  # rounds down
        (1500, "2k"),  # rounds up
        (147_558, "148k"),
        (999_499, "999k"),
        (999_500, "1.0M"),  # would round to 1000k; carries a unit instead
        (1_000_000, "1.0M"),
        (1_246_000, "1.2M"),
    ],
)
def test_humanize(count: int, expected: str) -> None:
    assert humanize(count) == expected


@pytest.mark.parametrize(
    ("display_name", "expected"),
    [
        ("Opus 4.8 (1M context)", "Opus4.8"),
        ("Opus 4.8", "Opus4.8"),
        ("Sonnet 5", "Sonnet5"),
        ("Haiku 4.5", "Haiku4.5"),
        ("Opus", "Opus"),
        ("", ""),
    ],
)
def test_compact_model(display_name: str, expected: str) -> None:
    assert compact_model(display_name) == expected


def test_compact_model_appears_in_the_rendered_line() -> None:
    payload = {**MINIMAL, "model": {"display_name": "Opus 4.8 (1M context)"}}
    assert "[Opus4.8]" in render(payload)


def test_humanize_never_emits_a_four_digit_k() -> None:
    """The 999_500..999_999 band is the only way to produce `1000k`."""
    assert not any(
        humanize(n).endswith("k") and len(humanize(n)) > 4
        for n in range(999_000, 1_000_001)
    )


# --------------------------------------------------------------------------
# tildify()
# --------------------------------------------------------------------------


def test_tildify_shortens_paths_under_home() -> None:
    assert tildify(Path.home() / "work" / "x") == "~/work/x"


def test_tildify_collapses_home_itself() -> None:
    assert tildify(Path.home()) == "~"


def test_tildify_passes_through_paths_outside_home() -> None:
    assert tildify(Path("/usr/local/bin")) == "/usr/local/bin"


def test_tildify_does_not_split_a_directory_name_mid_token() -> None:
    """A naive str.replace would mangle /Users/joshpeakOther into ~Other."""
    sibling = Path(f"{Path.home()}Other/work")
    assert tildify(sibling) == str(sibling)


# --------------------------------------------------------------------------
# Entry point
# --------------------------------------------------------------------------


def test_entrypoint_reads_stdin_and_prints_one_line() -> None:
    """The contract Claude Code actually depends on: stdin JSON -> stdout line."""
    result = subprocess.run(
        [sys.executable, str(Path(__file__).parent / "statusline.py")],
        input=json.dumps(FULL),
        capture_output=True,
        text=True,
        timeout=30,
        check=True,
    )
    assert result.stdout.rstrip("\n") == render(FULL)
    assert "\n" not in result.stdout.rstrip("\n")


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-v"]))
