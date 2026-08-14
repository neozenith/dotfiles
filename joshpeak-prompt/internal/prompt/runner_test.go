package prompt

import (
	"context"
	"strings"
	"testing"
)

func TestExecRunner(t *testing.T) {
	runner := ExecRunner{}
	if runner.LookPath("sh") == "" || runner.LookPath("joshpeak-command-that-does-not-exist") != "" {
		t.Fatal("LookPath mismatch")
	}
	if got := runner.Run(context.Background(), "printf", "hello\n\n"); got != "hello" {
		t.Fatalf("Run output = %q", got)
	}
	if got := runner.Run(context.Background(), "joshpeak-command-that-does-not-exist"); got != "" {
		t.Fatalf("missing command output = %q", got)
	}
	cancelled, cancel := context.WithCancel(context.Background())
	cancel()
	if got := runner.Run(cancelled, "printf", strings.Repeat("x", 2)); got != "" {
		t.Fatalf("cancelled output = %q", got)
	}
}
