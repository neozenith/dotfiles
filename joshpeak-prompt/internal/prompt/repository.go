package prompt

import (
	"context"
	"strings"
)

type repositorySnapshot struct {
	Branch             string
	PullRequestBranch  string
	Worktree           string
	Status             string
	CredentialUsername string
}

type repositoryCall struct {
	done     chan struct{}
	snapshot repositorySnapshot
}

func loadRepositorySnapshot(ctx context.Context, runner Runner) repositorySnapshot {
	shared, _ := ctx.Value(sharedRunsKey{}).(*sharedRuns)
	if shared == nil {
		return collectRepositorySnapshot(ctx, runner)
	}
	shared.mu.Lock()
	call := shared.repository
	owner := false
	if call == nil {
		call = &repositoryCall{done: make(chan struct{})}
		shared.repository = call
		owner = true
	}
	shared.mu.Unlock()
	if owner {
		call.snapshot = collectRepositorySnapshot(ctx, runner)
		close(call.done)
		return call.snapshot
	}
	select {
	case <-call.done:
		return call.snapshot
	case <-ctx.Done():
		return repositorySnapshot{}
	}
}

func collectRepositorySnapshot(ctx context.Context, runner Runner) repositorySnapshot {
	var branchOutput, worktree, status, remoteURL string
	runParallel(
		func() { branchOutput = runSharedWithSpan(ctx, runner, "detect branch", "git", "branch") },
		func() {
			worktree = runSharedWithSpan(ctx, runner, "check worktree", "git", "rev-parse", "--is-inside-work-tree")
		},
		func() {
			status = runSharedWithSpan(ctx, runner, "inspect worktree", "git", "status", "--short", "--untracked-files")
		},
		func() {
			remoteURL = runSharedWithSpan(ctx, runner, "read origin", "git", "remote", "get-url", "origin")
		},
	)
	if remoteURL == "" {
		remoteURL = "https://github.com/"
	}
	credentialUsername := runSharedWithSpan(ctx, runner, "read credential username", "git", "config", "--get-urlmatch", "credential.username", remoteURL)
	branch := selectedBranch(branchOutput)
	return repositorySnapshot{
		Branch:             branch,
		PullRequestBranch:  pullRequestBranch(branch),
		Worktree:           worktree,
		Status:             status,
		CredentialUsername: credentialUsername,
	}
}

func pullRequestBranch(branch string) string {
	if strings.HasPrefix(branch, "(HEAD detached ") || strings.HasPrefix(branch, "(no branch, ") {
		return "HEAD"
	}
	return branch
}
