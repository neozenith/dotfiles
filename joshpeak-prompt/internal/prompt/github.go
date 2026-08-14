package prompt

import (
	"context"
	"fmt"
	"strconv"
	"strings"
)

type GitHub struct {
	Runner Runner
	Env    func(string) string
}

func (GitHub) Name() string { return "gh" }

func (g GitHub) Render(ctx context.Context) string {
	if g.Runner.LookPath("gh") == "" {
		return ""
	}
	var repository repositorySnapshot
	var username string
	runParallel(
		func() { repository = loadRepositorySnapshot(ctx, g.Runner) },
		func() { username = g.configuredAccount(ctx) },
	)
	if repository.Worktree == "" || username == "" {
		return ""
	}
	const (
		dark   = "%F{240}"
		green  = "%F{green}"
		red    = "%F{red}"
		yellow = "%F{yellow}"
		purple = "%F{magenta}"
	)
	output := " " + dark + "gh:" + username + norm
	if repository.CredentialUsername != "" && repository.CredentialUsername != username {
		output = " \x1b[97m\x1b[48;5;1mgit:" + repository.CredentialUsername + " != gh:" + username + "\x1b[0m"
	}
	branch := repository.PullRequestBranch
	if branch == "" || branch == "main" || branch == "master" || branch == "HEAD" {
		return legacyEcho(output)
	}
	line := runWithSpan(ctx, g.Runner, "read pull request", "gh", "pr", "view", "--json", "number,state,isDraft,statusCheckRollup", "--jq", ghQuery)
	if line == "" {
		return legacyEcho(output)
	}
	parts := strings.Split(line, "\t")
	if len(parts) < 6 {
		parts = append(parts, make([]string, 6-len(parts))...)
	}
	number, state, draft := parts[0], parts[1], parts[2]
	passed, _ := strconv.Atoi(parts[3])
	failed, _ := strconv.Atoi(parts[4])
	total, _ := strconv.Atoi(parts[5])
	label, colour := titleCase(state), purple
	if draft == "true" {
		label, colour = "Draft", dark
	} else if state == "OPEN" {
		label, colour = "Open", green
	}
	output += " " + colour + "⑃ #" + number + " " + label + norm
	if total > 0 {
		checks := ""
		if passed > 0 {
			checks += fmt.Sprintf("%s✓%d%s", green, passed, norm)
		}
		if failed > 0 {
			checks += fmt.Sprintf("%s✗%d%s", red, failed, norm)
		}
		if pending := total - passed - failed; pending > 0 {
			checks += fmt.Sprintf("%s•%d%s", yellow, pending, norm)
		}
		if checks != "" {
			output += " " + checks
		}
	}
	return legacyEcho(output)
}

func (g GitHub) configuredAccount(ctx context.Context) string {
	if g.Env != nil && (g.Env("GH_TOKEN") != "" || g.Env("GITHUB_TOKEN") != "") {
		return runWithSpan(ctx, g.Runner, "resolve environment account", "gh", "api", "user", "--jq", ".login")
	}
	return runWithSpan(ctx, g.Runner, "read configured account", "gh", "config", "get", "user", "--host", "github.com")
}

func titleCase(value string) string {
	lower := strings.ToLower(value)
	if lower == "" {
		return ""
	}
	return strings.ToUpper(lower[:1]) + lower[1:]
}

const ghQuery = `
    def passed: (.conclusion == "SUCCESS") or (.state == "SUCCESS");
    def failed: (.conclusion | IN("FAILURE","TIMED_OUT","CANCELLED","STARTUP_FAILURE","ACTION_REQUIRED")) or (.state | IN("FAILURE","ERROR"));
    [ .number,
      .state,
      (.isDraft | tostring),
      ([.statusCheckRollup[] | select(passed)] | length),
      ([.statusCheckRollup[] | select(failed)] | length),
      (.statusCheckRollup | length)
    ] | @tsv`
