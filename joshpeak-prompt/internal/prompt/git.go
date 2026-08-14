package prompt

import (
	"context"
	"fmt"
	"strconv"
	"strings"
)

type Git struct {
	Runner Runner
}

func (Git) Name() string { return "git" }

func (g Git) Render(ctx context.Context) string {
	var repository repositorySnapshot
	var email string
	runParallel(
		func() { repository = loadRepositorySnapshot(ctx, g.Runner) },
		func() { email = runWithSpan(ctx, g.Runner, "read user email", "git", "config", "user.email") },
	)
	branch := repository.Branch
	if branch == "" {
		return ""
	}

	const (
		dark   = "%F{240}"
		red    = "%F{red}"
		green  = "%F{green}"
		yellow = "%F{yellow}"
		blue   = "%F{blue}"
		purple = "%F{magenta}"
	)

	var localMaster, localMain, remoteOutput string
	runParallel(
		func() {
			if branch != "master" {
				localMaster = runWithSpan(ctx, g.Runner, "compare local master", "git", "cherry", branch, "master")
			}
		},
		func() {
			if branch != "main" {
				localMain = runWithSpan(ctx, g.Runner, "compare local main", "git", "cherry", branch, "main")
			}
		},
		func() { remoteOutput = runWithSpan(ctx, g.Runner, "list remotes", "git", "remote") },
	)

	statusColour := blue
	cacheStatus := ""
	if repository.Status != "" {
		statusColour = yellow
		untracked, modified, deleted, added, conflicted := statusCounts(repository.Status)
		if modified > 0 || untracked > 0 || deleted > 0 || conflicted > 0 {
			statusColour = red
		}
		if untracked > 0 {
			cacheStatus += purple + "?" + strconv.Itoa(untracked) + norm
		}
		if modified > 0 {
			cacheStatus += yellow + "~" + strconv.Itoa(modified) + norm
		}
		if deleted > 0 {
			cacheStatus += red + "-" + strconv.Itoa(deleted) + norm
		}
		if added > 0 {
			cacheStatus += green + "+" + strconv.Itoa(added) + norm
		}
		if conflicted > 0 {
			cacheStatus = red + "!" + strconv.Itoa(conflicted) + norm + cacheStatus
		}
		if cacheStatus != "" {
			cacheStatus = " [" + cacheStatus + "]"
		}
	}

	// The legacy script accidentally prints an unset REBASE_DELTA for local
	// main/master comparisons. Preserve that empty count for byte compatibility.
	localRebase := ""
	if branch != "master" && lineCount(localMaster) > 0 {
		localRebase += purple + "M→" + green + norm
	}
	if branch != "main" && lineCount(localMain) > 0 {
		localRebase += purple + "M→" + green + norm
	}
	branchStatus := localRebase + statusColour + "⎇ " + branch + norm

	remotes := strings.Fields(remoteOutput)
	type remoteResult struct {
		up, down, master, main int
	}
	remoteResults := make([]remoteResult, len(remotes))
	remoteTasks := make([]func(), 0, len(remotes)*4)
	for index, remote := range remotes {
		remoteLabel := fmt.Sprintf("remote %d", index+1)
		remoteTasks = append(remoteTasks,
			func() {
				remoteResults[index].up = lineCount(runWithSpan(ctx, g.Runner, remoteLabel+" compare ahead", "git", "cherry", remote+"/"+branch, branch))
			},
			func() {
				remoteResults[index].down = lineCount(runWithSpan(ctx, g.Runner, remoteLabel+" compare behind", "git", "cherry", branch, remote+"/"+branch))
			},
		)
		if branch != "master" {
			remoteTasks = append(remoteTasks, func() {
				remoteResults[index].master = lineCount(runWithSpan(ctx, g.Runner, remoteLabel+" compare master", "git", "cherry", branch, remote+"/master"))
			})
		}
		if branch != "main" {
			remoteTasks = append(remoteTasks, func() {
				remoteResults[index].main = lineCount(runWithSpan(ctx, g.Runner, remoteLabel+" compare main", "git", "cherry", branch, remote+"/main"))
			})
		}
	}
	runParallel(remoteTasks...)

	remoteStatus := ""
	for index, remote := range remotes {
		up, down := remoteResults[index].up, remoteResults[index].down
		remoteDelta := ""
		if up > 0 || down > 0 {
			remoteDelta = "|" + blue + "↑" + strconv.Itoa(up) + purple + "/" + green + "↓" + strconv.Itoa(down)
		}
		masterStatus, mainStatus := "", ""
		masterDelta, mainDelta := remoteResults[index].master, remoteResults[index].main
		if branch != "master" {
			if masterDelta > 0 {
				masterStatus = purple + "|M↓" + green + strconv.Itoa(masterDelta) + norm
			}
		}
		if branch != "main" {
			if mainDelta > 0 {
				mainStatus = purple + "|M↓" + green + strconv.Itoa(mainDelta) + norm
			}
		}
		if up > 0 || down > 0 || masterDelta > 0 || mainDelta > 0 {
			remoteStatus += " " + purple + remote + masterStatus + mainStatus + remoteDelta + purple + "|" + norm
		}
	}

	identity := repository.CredentialUsername
	if email != "" {
		if identity != "" {
			identity += " "
		}
		identity += "<" + email + ">"
	}
	return legacyEcho("\n" + dark + "(" + identity + ")" + norm + " " + branchStatus + cacheStatus + remoteStatus)
}

func selectedBranch(output string) string {
	for _, line := range strings.Split(output, "\n") {
		if strings.HasPrefix(line, "*") {
			return strings.TrimPrefix(line, "* ")
		}
	}
	return ""
}

func statusCounts(status string) (untracked, modified, deleted, added, conflicted int) {
	for _, line := range strings.Split(status, "\n") {
		if len(line) < 2 {
			continue
		}
		x, y := line[0], line[1]
		if x == '?' && y == '?' {
			untracked++
		}
		if (x == 'M' || x == 'D' || x == 'A' || x == ' ') && y == 'M' {
			modified++
		}
		if x == ' ' && y == 'D' {
			deleted++
		}
		if x == 'M' || x == 'D' || x == 'A' || x == 'R' {
			added++
		}
		if y == 'U' {
			conflicted++
		}
	}
	return
}

func lineCount(output string) int {
	if output == "" {
		return 0
	}
	return len(strings.Split(output, "\n"))
}
