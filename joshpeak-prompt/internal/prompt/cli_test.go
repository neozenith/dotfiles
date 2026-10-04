package prompt

import (
	"bytes"
	"context"
	"strings"
	"sync/atomic"
	"testing"
	"time"
)

func TestRunCLI(t *testing.T) {
	sections := []Section{
		fakeSection{"git", "G"}, fakeSection{"gh", "H"}, fakeSection{"kubernetes", "K"},
		fakeSection{"python", "P"}, fakeSection{"aws", "A"}, fakeSection{"gcloud", "C"},
	}
	renderer := Renderer{Sections: sections, Now: func() time.Time { return time.Unix(0, 0) }}
	tests := []struct {
		args       []string
		code       int
		stdoutPart string
		stderrPart string
	}{
		{nil, 0, "GH K P A C\n", ""},
		{[]string{"prompt", "--timings"}, 0, "GH K P A C\n", "Module"},
		{[]string{"timings"}, 0, "Module", ""},
		{[]string{"timings", "--detail"}, 0, "Module", ""},
		{[]string{"timings", "--mermaid"}, 0, "```mermaid\n", ""},
		{[]string{"timings", "--mermaid", "--detail"}, 0, "detailed timing trace", ""},
		{[]string{"aws"}, 0, "A\n", ""},
		{[]string{"hostname"}, 0, "\n", ""},
		{[]string{"directory"}, 0, "", ""},
		{[]string{"unknown"}, 2, "", "unknown command"},
	}
	for _, test := range tests {
		var stdout, stderr bytes.Buffer
		code := RunCLI(context.Background(), test.args, &stdout, &stderr, renderer, "/not/the/home")
		if code != test.code || !strings.Contains(stdout.String(), test.stdoutPart) || !strings.Contains(stderr.String(), test.stderrPart) {
			t.Fatalf("RunCLI(%v) = code %d stdout %q stderr %q", test.args, code, stdout.String(), stderr.String())
		}
	}
}

func TestMainUnknownCommand(t *testing.T) {
	var stdout, stderr bytes.Buffer
	if code := Main(context.Background(), []string{"unknown"}, &stdout, &stderr); code != 2 {
		t.Fatalf("Main code = %d", code)
	}
}

func TestRunCLIMissingNamedSection(t *testing.T) {
	var stdout, stderr bytes.Buffer
	code := RunCLI(context.Background(), []string{"aws"}, &stdout, &stderr, Renderer{}, "")
	if code != 2 {
		t.Fatalf("missing section code = %d", code)
	}
}

func TestMainIgnoresHomeLookupFailure(t *testing.T) {
	original := userHomeDir
	defer func() { userHomeDir = original }()
	userHomeDir = func() (string, error) { return "", context.Canceled }
	var stdout, stderr bytes.Buffer
	if code := Main(context.Background(), []string{"unknown"}, &stdout, &stderr); code != 2 {
		t.Fatalf("Main code = %d", code)
	}
}

type countedSection struct {
	name  string
	calls *atomic.Int32
}

func (s countedSection) Name() string { return s.name }
func (s countedSection) Render(context.Context) string {
	s.calls.Add(1)
	return strings.ToUpper(s.name)
}

func TestSectionDisableFlags(t *testing.T) {
	var gitCalls, cloudCalls atomic.Int32
	renderer := Renderer{Sections: []Section{
		countedSection{"git", &gitCalls}, countedSection{"gcloud", &cloudCalls},
	}}
	run := func(args ...string) (int, string, string) {
		var stdout, stderr bytes.Buffer
		code := RunCLI(context.Background(), args, &stdout, &stderr, renderer, "")
		return code, stdout.String(), stderr.String()
	}
	t.Setenv("JOSHPEAK_PROMPT__DISABLE_GCLOUD", "1")
	if code, out, _ := run("prompt"); code != 0 || out != "GIT\n" || cloudCalls.Load() != 0 {
		t.Fatalf("environment disable = %d %q, cloud calls %d", code, out, cloudCalls.Load())
	}
	if code, out, _ := run("--disable-git"); code != 0 || out != "\n" || gitCalls.Load() != 1 {
		t.Fatalf("all disabled = %d %q, git calls %d", code, out, gitCalls.Load())
	}
	if code, out, _ := run("timings", "--disable-git"); code != 0 || strings.Contains(out, "git ") || cloudCalls.Load() != 0 {
		t.Fatalf("disabled timings = %d %q", code, out)
	}
	if code, out, _ := run("gcloud", "--disable-gcloud"); code != 0 || out != "" {
		t.Fatalf("disabled named section = %d %q", code, out)
	}
	if code, out, err := run("--disable-unknown"); code != 2 || out != "" || !strings.Contains(err, "unknown section") {
		t.Fatalf("invalid disable flag = %d %q %q", code, out, err)
	}
	t.Setenv("JOSHPEAK_PROMPT__DISABLE_GCLOUD", "0")
	if code, out, _ := run("prompt", "--disable-git"); code != 0 || out != "GCLOUD\n" || cloudCalls.Load() != 1 {
		t.Fatalf("CLI disable = %d %q, cloud calls %d", code, out, cloudCalls.Load())
	}
}

func TestDebugTimingsTurnOffNextRun(t *testing.T) {
	renderer := Renderer{Sections: []Section{fakeSection{"git", "G"}}, Now: func() time.Time { return time.Unix(0, 0) }}
	var stdout, stderr bytes.Buffer
	t.Setenv("JOSHPEAK_PROMPT__DEBUG_TIMINGS", "1")
	if code := RunCLI(context.Background(), nil, &stdout, &stderr, renderer, ""); code != 0 || stdout.String() != "G [git 0ns] [total 0ns]\n" {
		t.Fatalf("debug prompt = %d %q", code, stdout.String())
	}
	stdout.Reset()
	t.Setenv("JOSHPEAK_PROMPT__DEBUG_TIMINGS", "")
	if code := RunCLI(context.Background(), nil, &stdout, &stderr, renderer, ""); code != 0 || stdout.String() != "G    \n" {
		t.Fatalf("normal prompt = %d %q", code, stdout.String())
	}
	stdout.Reset()
	t.Setenv("JOSHPEAK_PROMPT__DEBUG_TIMINGS", "1")
	if code := RunCLI(context.Background(), []string{"--disable-git"}, &stdout, &stderr, renderer, ""); code != 0 || stdout.String() != "[total 0ns]\n" {
		t.Fatalf("all disabled debug prompt = %d %q", code, stdout.String())
	}
}
