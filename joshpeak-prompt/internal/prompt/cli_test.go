package prompt

import (
	"bytes"
	"context"
	"strings"
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
