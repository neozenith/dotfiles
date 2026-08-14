package prompt

import (
	"bytes"
	"context"
	"os/exec"
)

// Runner isolates the remaining CLIs whose behaviour is part of a prompt section.
type Runner interface {
	LookPath(name string) string
	Run(context.Context, string, ...string) string
}

type ExecRunner struct{}

func (ExecRunner) LookPath(name string) string {
	path, err := exec.LookPath(name)
	if err != nil {
		return ""
	}
	return path
}

func (ExecRunner) Run(ctx context.Context, name string, args ...string) string {
	var stdout bytes.Buffer
	cmd := exec.CommandContext(ctx, name, args...)
	cmd.Stdout = &stdout
	_ = cmd.Run()
	return string(bytes.TrimRight(stdout.Bytes(), "\n"))
}
