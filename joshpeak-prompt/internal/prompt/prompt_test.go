package prompt

import (
	"bytes"
	"context"
	"database/sql"
	"errors"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"sync"
	"testing"
	"time"
)

type fakeRunner struct {
	paths map[string]string
	lines map[string]string
}

type concurrentRunner struct {
	paths             map[string]string
	lines             map[string]string
	delay             time.Duration
	mu                sync.Mutex
	calls             map[string]int
	active, maxActive int
}

func (r *concurrentRunner) LookPath(name string) string { return r.paths[name] }
func (r *concurrentRunner) Run(_ context.Context, name string, args ...string) string {
	key := commandKey(name, args...)
	r.mu.Lock()
	r.calls[key]++
	r.active++
	if r.active > r.maxActive {
		r.maxActive = r.active
	}
	r.mu.Unlock()
	time.Sleep(r.delay)
	r.mu.Lock()
	r.active--
	r.mu.Unlock()
	return r.lines[key]
}

type blockingRunner struct {
	started chan struct{}
	release chan struct{}
}

type repositoryBlockingRunner struct {
	started chan struct{}
	release chan struct{}
	once    sync.Once
}

func (*repositoryBlockingRunner) LookPath(string) string { return "" }
func (r *repositoryBlockingRunner) Run(_ context.Context, name string, args ...string) string {
	if commandKey(name, args...) == commandKey("git", "branch") {
		r.once.Do(func() { close(r.started) })
		<-r.release
		return "* main"
	}
	return ""
}

func (blockingRunner) LookPath(string) string { return "" }
func (r blockingRunner) Run(context.Context, string, ...string) string {
	close(r.started)
	<-r.release
	return "shared"
}

func (f fakeRunner) LookPath(name string) string { return f.paths[name] }
func (f fakeRunner) Run(_ context.Context, name string, args ...string) string {
	return f.lines[commandKey(name, args...)]
}

func commandKey(name string, args ...string) string {
	return strings.Join(append([]string{name}, args...), "\x00")
}

func env(values map[string]string) func(string) string {
	return func(name string) string { return values[name] }
}

func TestAWS(t *testing.T) {
	tests := []struct {
		profile string
		want    string
	}{
		{"", " %F{052}☁️  aws_profile_not_set%F{rc}%K{rc}"},
		{"production", " %F{166}☁️ production%F{rc}%K{rc}"},
	}
	for _, test := range tests {
		got := (AWS{Env: env(map[string]string{"AWS_PROFILE": test.profile})}).Render(context.Background())
		if got != test.want {
			t.Fatalf("AWS output = %q, want %q", got, test.want)
		}
	}
	if (AWS{}).Name() != "aws" {
		t.Fatal("unexpected AWS section name")
	}
}

func TestPythonPermutations(t *testing.T) {
	tests := []struct {
		name, path, virtual, wantLocation string
	}{
		{"system", "/usr/bin/python3", "", "system"},
		{"intel homebrew", "/usr/local/bin/python3", "", "homebrew"},
		{"arm homebrew", "/opt/homebrew/bin/python3", "", "homebrew"},
		{"pyenv", "/Users/test/.pyenv/shims/python3", "", "pyenv"},
		{"virtual environment", "tmp/venv/bin/python3", "tmp/venv", "venv"},
		{"unknown", "/custom/python3", "", ""},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			runner := fakeRunner{lines: map[string]string{
				commandKey("python3", "-V"): "Python 3.14.1",
			}}
			runner.paths = map[string]string{"python3": test.path}
			section := Python{Runner: runner, Env: env(map[string]string{"VIRTUAL_ENV": test.virtual}), Home: "/Users/test"}
			want := " %F{green}🐍 " + test.wantLocation + " 3.14.1%F{rc}"
			if got := section.Render(context.Background()); got != want {
				t.Fatalf("Python output = %q, want %q", got, want)
			}
			if section.Name() != "python" {
				t.Fatal("unexpected Python section name")
			}
		})
	}
}

func TestKubernetesPermutations(t *testing.T) {
	tests := []struct {
		name, context, want string
		exists              bool
	}{
		{"missing CLI", "", "", false},
		{"missing context", "", "", true},
		{"docker desktop", "docker-desktop", "%F{023}☸|%F{017}docker-desktop%F{rc}%K{rc}%F{023}|%F{rc}%K{rc}", true},
		{"remote", "prod-au", "%F{023}☸|%F{016}%K{019}prod-au%F{rc}%K{rc}%F{023}|%F{rc}%K{rc}", true},
	}
	for _, test := range tests {
		path := ""
		if test.exists {
			path = "/usr/local/bin/kubectl"
		}
		runner := fakeRunner{paths: map[string]string{"kubectl": path}, lines: map[string]string{
			commandKey("kubectl", "config", "current-context"): test.context,
		}}
		section := Kubernetes{Runner: runner}
		if got := section.Render(context.Background()); got != test.want {
			t.Errorf("%s output = %q, want %q", test.name, got, test.want)
		}
		if section.Name() != "kubernetes" {
			t.Fatal("unexpected Kubernetes section name")
		}
	}
}

func TestGitNoBranch(t *testing.T) {
	section := Git{Runner: fakeRunner{lines: map[string]string{}}}
	if got := section.Render(context.Background()); got != "" {
		t.Fatalf("Git output = %q", got)
	}
	if section.Name() != "git" {
		t.Fatal("unexpected Git section name")
	}
}

func TestGitComplexOutput(t *testing.T) {
	lines := map[string]string{
		commandKey("git", "branch"):                      "  main\n* feature/prompt",
		commandKey("git", "remote", "get-url", "origin"): "git@github.com:joshpeak/dotfiles.git",
		commandKey("git", "config", "--get-urlmatch", "credential.username", "git@github.com:joshpeak/dotfiles.git"): "joshpeak",
		commandKey("git", "config", "user.email"):                              "josh@example.com",
		commandKey("git", "status", "--short", "--untracked-files"):            "?? new\n M modified\n D deleted\nA  added\nUU conflict",
		commandKey("git", "cherry", "feature/prompt", "master"):                "+ a",
		commandKey("git", "cherry", "feature/prompt", "main"):                  "+ main",
		commandKey("git", "remote"):                                            "origin upstream",
		commandKey("git", "cherry", "origin/feature/prompt", "feature/prompt"): "+ a\n+ b",
		commandKey("git", "cherry", "feature/prompt", "origin/feature/prompt"): "+ c",
		commandKey("git", "cherry", "feature/prompt", "origin/master"):         "+ d",
		commandKey("git", "cherry", "feature/prompt", "origin/main"):           "+ e\n+ f",
	}
	section := Git{Runner: fakeRunner{lines: lines}}
	got := section.Render(context.Background())
	want := "\n%F{240}(joshpeak <josh@example.com>)%F{rc}%K{rc} " +
		"%F{magenta}M→%F{green}%F{rc}%K{rc}%F{magenta}M→%F{green}%F{rc}%K{rc}%F{red}⎇ feature/prompt%F{rc}%K{rc} " +
		"[%F{red}!1%F{rc}%K{rc}%F{magenta}?1%F{rc}%K{rc}%F{yellow}~1%F{rc}%K{rc}%F{red}-1%F{rc}%K{rc}%F{green}+1%F{rc}%K{rc}] " +
		"%F{magenta}origin%F{magenta}|M↓%F{green}1%F{rc}%K{rc}%F{magenta}|M↓%F{green}2%F{rc}%K{rc}|%F{blue}↑2%F{magenta}/%F{green}↓1%F{magenta}|%F{rc}%K{rc}"
	if got != want {
		t.Fatalf("Git output mismatch\n got: %q\nwant: %q", got, want)
	}
}

func TestGitFallbackIdentityAndCleanBranch(t *testing.T) {
	section := Git{Runner: fakeRunner{lines: map[string]string{
		commandKey("git", "branch"):                                 "* main",
		commandKey("git", "config", "user.email"):                   "person@example.com",
		commandKey("git", "status", "--short", "--untracked-files"): "",
		commandKey("git", "cherry", "main", "master"):               "+ local",
	}}}
	want := "\n%F{240}(<person@example.com>)%F{rc}%K{rc} %F{magenta}M→%F{green}%F{rc}%K{rc}%F{blue}⎇ main%F{rc}%K{rc}"
	if got := section.Render(context.Background()); got != want {
		t.Fatalf("Git output = %q, want %q", got, want)
	}
}

func TestGitHelpers(t *testing.T) {
	if selectedBranch("main") != "" || selectedBranch("* feature") != "feature" || selectedBranch("*detached") != "*detached" {
		t.Fatal("selectedBranch did not preserve legacy parsing")
	}
	if lineCount("") != 0 || lineCount("a") != 1 || lineCount("a\nb") != 2 {
		t.Fatal("lineCount mismatch")
	}
	if pullRequestBranch("feature") != "feature" || pullRequestBranch("(HEAD detached at abc123)") != "HEAD" || pullRequestBranch("(no branch, rebasing feature)") != "HEAD" {
		t.Fatal("pull request branch mismatch")
	}
	u, m, d, a, c := statusCounts("x\n?? x\nMM x\n D x\nR  x\nAU x")
	if u != 1 || m != 1 || d != 1 || a != 3 || c != 1 {
		t.Fatalf("status counts = %d %d %d %d %d", u, m, d, a, c)
	}
}

func TestGitHubEarlyReturns(t *testing.T) {
	cases := []fakeRunner{
		{paths: map[string]string{"gh": ""}},
		{paths: map[string]string{"gh": "/usr/local/bin/gh"}, lines: map[string]string{}},
		{paths: map[string]string{"gh": "/usr/local/bin/gh"}, lines: map[string]string{commandKey("git", "rev-parse", "--is-inside-work-tree"): "true"}},
	}
	for _, runner := range cases {
		if got := (GitHub{Runner: runner}).Render(context.Background()); got != "" {
			t.Fatalf("GitHub early output = %q", got)
		}
	}
}

func TestGitHubPermutations(t *testing.T) {
	base := map[string]string{
		commandKey("git", "rev-parse", "--is-inside-work-tree"):                                                  "true",
		commandKey("gh", "config", "get", "user", "--host", "github.com"):                                        "joshpeak",
		commandKey("git", "remote", "get-url", "origin"):                                                         "git@github.com:joshpeak/repo.git",
		commandKey("git", "config", "--get-urlmatch", "credential.username", "git@github.com:joshpeak/repo.git"): "joshpeak",
	}
	tests := []struct {
		name, branch, line, wantSuffix string
	}{
		{"default", "main", "", ""},
		{"detached", "(HEAD detached at abc123)", "", ""},
		{"no pull request", "feature", "", ""},
		{"draft", "feature", "12\tOPEN\ttrue\t0\t0\t0", " %F{240}⑃ #12 Draft%F{rc}%K{rc}"},
		{"open checks", "feature", "13\tOPEN\tfalse\t2\t1\t5", " %F{green}⑃ #13 Open%F{rc}%K{rc} %F{green}✓2%F{rc}%K{rc}%F{red}✗1%F{rc}%K{rc}%F{yellow}•2%F{rc}%K{rc}"},
		{"merged malformed counts", "feature", "14\tMERGED\tfalse\tx\t0", " %F{magenta}⑃ #14 Merged%F{rc}%K{rc}"},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			lines := copyMap(base)
			lines[commandKey("git", "branch")] = "* " + test.branch
			lines[commandKey("gh", "pr", "view", "--json", "number,state,isDraft,statusCheckRollup", "--jq", ghQuery)] = test.line
			got := (GitHub{Runner: fakeRunner{paths: map[string]string{"gh": "/usr/local/bin/gh"}, lines: lines}}).Render(context.Background())
			want := " %F{240}gh:joshpeak%F{rc}%K{rc}" + test.wantSuffix
			if got != want {
				t.Fatalf("GitHub output = %q, want %q", got, want)
			}
		})
	}
}

func TestGitHubIdentityMismatchAndFallbackRemote(t *testing.T) {
	lines := map[string]string{
		commandKey("git", "rev-parse", "--is-inside-work-tree"):                                     "true",
		commandKey("gh", "config", "get", "user", "--host", "github.com"):                           "github-user",
		commandKey("git", "config", "--get-urlmatch", "credential.username", "https://github.com/"): "git-user",
		commandKey("git", "branch"): "* HEAD",
	}
	want := " \x1b[97m\x1b[48;5;1mgit:git-user != gh:github-user\x1b[0m"
	if got := (GitHub{Runner: fakeRunner{paths: map[string]string{"gh": "/usr/local/bin/gh"}, lines: lines}}).Render(context.Background()); got != want {
		t.Fatalf("GitHub mismatch output = %q, want %q", got, want)
	}
	if titleCase("") != "" || titleCase("CLOSED") != "Closed" || (GitHub{}).Name() != "gh" {
		t.Fatal("GitHub helpers mismatch")
	}
}

func TestGitHubEnvironmentTokenAccount(t *testing.T) {
	for _, variable := range []string{"GH_TOKEN", "GITHUB_TOKEN"} {
		t.Run(variable, func(t *testing.T) {
			runner := &concurrentRunner{
				paths: map[string]string{"gh": "/usr/local/bin/gh"},
				lines: map[string]string{
					commandKey("git", "rev-parse", "--is-inside-work-tree"): "true",
					commandKey("git", "branch"):                             "* main",
					commandKey("gh", "api", "user", "--jq", ".login"):       "environment-user",
				},
				calls: make(map[string]int),
			}
			section := GitHub{Runner: runner, Env: env(map[string]string{variable: "set"})}
			want := " %F{240}gh:environment-user%F{rc}%K{rc}"
			if got := section.Render(context.Background()); got != want {
				t.Fatalf("environment account output = %q, want %q", got, want)
			}
			runner.mu.Lock()
			defer runner.mu.Unlock()
			if runner.calls[commandKey("gh", "api", "user", "--jq", ".login")] != 1 || runner.calls[commandKey("gh", "config", "get", "user", "--host", "github.com")] != 0 {
				t.Fatalf("environment account calls = %#v", runner.calls)
			}
		})
	}
}

func TestGitAndGitHubUseOneParallelRepositorySnapshot(t *testing.T) {
	branchKey := commandKey("git", "branch")
	worktreeKey := commandKey("git", "rev-parse", "--is-inside-work-tree")
	statusKey := commandKey("git", "status", "--short", "--untracked-files")
	remoteKey := commandKey("git", "remote", "get-url", "origin")
	credentialKey := commandKey("git", "config", "--get-urlmatch", "credential.username", "git@github.com:joshpeak/repo.git")
	accountKey := commandKey("gh", "config", "get", "user", "--host", "github.com")
	oldAuthKey := commandKey("gh", "auth", "status", "--active", "--hostname", "github.com", "--json", "hosts", "--jq", `.hosts."github.com"[].login`)
	runner := &concurrentRunner{
		paths: map[string]string{"gh": "/usr/local/bin/gh"},
		lines: map[string]string{
			branchKey:     "* main",
			remoteKey:     "git@github.com:joshpeak/repo.git",
			credentialKey: "joshpeak",
			worktreeKey:   "true",
			accountKey:    "joshpeak",
		},
		delay: 5 * time.Millisecond,
		calls: make(map[string]int),
	}
	report := (Renderer{Sections: []Section{Git{Runner: runner}, GitHub{Runner: runner}}}).Render(context.Background())
	if got, want := Compose(report.Results), "\n%F{240}(joshpeak)%F{rc}%K{rc} %F{blue}⎇ main%F{rc}%K{rc} %F{240}gh:joshpeak%F{rc}%K{rc}    "; got != want {
		t.Fatalf("parallel output = %q, want %q", got, want)
	}
	runner.mu.Lock()
	defer runner.mu.Unlock()
	if runner.calls[remoteKey] != 1 || runner.calls[credentialKey] != 1 {
		t.Fatalf("shared calls = origin %d, credential %d", runner.calls[remoteKey], runner.calls[credentialKey])
	}
	if runner.calls[branchKey] != 1 || runner.calls[worktreeKey] != 1 || runner.calls[statusKey] != 1 {
		t.Fatalf("pre-step calls = branch %d, worktree %d, status %d", runner.calls[branchKey], runner.calls[worktreeKey], runner.calls[statusKey])
	}
	if runner.calls[accountKey] != 1 || runner.calls[oldAuthKey] != 0 {
		t.Fatalf("configured account calls = %#v", runner.calls)
	}
	if runner.calls[commandKey("git", "rev-parse", "--abbrev-ref", "HEAD")] != 0 {
		t.Fatal("GitHub started its former duplicate branch probe")
	}
	if runner.maxActive < 3 {
		t.Fatalf("maximum concurrent calls = %d, want at least 3", runner.maxActive)
	}
	if len(report.SharedSpans) != 5 {
		t.Fatalf("shared spans = %#v", report.SharedSpans)
	}
}

type fakeTokens struct {
	delta string
	err   error
}

func (f fakeTokens) ExpiryDeltaSeconds(context.Context, string, string) (string, error) {
	return f.delta, f.err
}

func TestGCloudPermutations(t *testing.T) {
	const home = "/Users/test"
	tests := []struct {
		name, config, account, project, delta string
		environment                           map[string]string
		want                                  string
	}{
		{"missing CLI", "", "", "", "", map[string]string{}, " %F{166}☁️ %F{rc}%K{rc}"},
		{"default no identity", home + "/.config/gcloud", "", "", "", map[string]string{}, " %F{052}☁️ gcloud-default📄%F{rc}%K{rc}"},
		{"environment no token", "tmp/cloud", "a@example.com", "", "", map[string]string{"CLOUDSDK_CONFIG": "tmp/cloud", "CLOUDSDK_CORE_ACCOUNT": "a@example.com"}, " %F{166}☁️ tmp/cloud🌳%F{rc}%K{rc} %F{052}(a@example.com🌳 ⚡ no-project)%F{rc}%K{rc} %F{052}🔑 no token%F{rc}%K{rc}"},
		{"home config expired", home + "/cloud", "a@example.com", "project", "-59", map[string]string{}, " %F{166}☁️ ~/cloud📄%F{rc}%K{rc} %F{052}(a@example.com📄 ⚡ project📄)%F{rc}%K{rc} %F{052}🔑 expired 59s ago%F{rc}%K{rc}"},
		{"minutes left", "tmp/cloud", "a", "p", "3599", map[string]string{}, " %F{166}☁️ tmp/cloud📄%F{rc}%K{rc} %F{052}(a📄 ⚡ p📄)%F{rc}%K{rc} %F{022}🔑 59m left%F{rc}%K{rc}"},
		{"hours left", "tmp/cloud", "a", "p", "3600", map[string]string{}, " %F{166}☁️ tmp/cloud📄%F{rc}%K{rc} %F{052}(a📄 ⚡ p📄)%F{rc}%K{rc} %F{022}🔑 1h left%F{rc}%K{rc}"},
		{"days left", "tmp/cloud", "", "p", "86400", map[string]string{}, " %F{166}☁️ tmp/cloud📄%F{rc}%K{rc} %F{052}(no-account ⚡ p📄)%F{rc}%K{rc}"},
		{"invalid token", "tmp/cloud", "a", "p", "bad", map[string]string{}, " %F{166}☁️ tmp/cloud📄%F{rc}%K{rc} %F{052}(a📄 ⚡ p📄)%F{rc}%K{rc} %F{052}🔑 no token%F{rc}%K{rc}"},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			runner := fakeRunner{lines: map[string]string{
				commandKey("gcloud", "info", "--format=value(config.paths.global_config_dir)"): test.config,
				commandKey("gcloud", "info", "--format=value(config.account)"):                 test.account,
				commandKey("gcloud", "info", "--format=value(config.project)"):                 test.project,
			}}
			got := (GCloud{Runner: runner, Env: env(test.environment), Home: home, Tokens: fakeTokens{delta: test.delta, err: errors.New("ignored")}}).Render(context.Background())
			if got != test.want {
				t.Fatalf("GCloud output = %q, want %q", got, test.want)
			}
		})
	}
	if (GCloud{}).Name() != "gcloud" || source("", "") != "" || humanDuration(60) != "1m" || humanDuration(86400) != "1d" {
		t.Fatal("GCloud helpers mismatch")
	}
}

func TestSQLiteTokenReader(t *testing.T) {
	reader := SQLiteTokenReader{}
	ctx := context.Background()
	if delta, err := reader.ExpiryDeltaSeconds(ctx, filepath.Join(t.TempDir(), "missing.db"), "a"); err != nil || delta != "" {
		t.Fatalf("missing database = %q, %v", delta, err)
	}
	if delta, err := reader.ExpiryDeltaSeconds(ctx, "ignored", ""); err != nil || delta != "" {
		t.Fatalf("empty account = %q, %v", delta, err)
	}
	path := filepath.Join(t.TempDir(), "tokens.db")
	database, err := sql.Open("sqlite", path)
	if err != nil {
		t.Fatal(err)
	}
	if _, err = database.Exec(`CREATE TABLE access_tokens (account_id TEXT, token_expiry TEXT); INSERT INTO access_tokens VALUES ('active', datetime('now', '+2 hours')), ('null', NULL)`); err != nil {
		t.Fatal(err)
	}
	_ = database.Close()
	delta, err := reader.ExpiryDeltaSeconds(ctx, path, "active")
	if err != nil || delta == "" || strings.HasPrefix(delta, "-") {
		t.Fatalf("active token delta = %q, %v", delta, err)
	}
	for _, account := range []string{"missing", "null"} {
		if delta, err = reader.ExpiryDeltaSeconds(ctx, path, account); err != nil || delta != "" {
			t.Fatalf("%s token delta = %q, %v", account, delta, err)
		}
	}
	broken := filepath.Join(t.TempDir(), "broken.db")
	brokenDatabase, err := sql.Open("sqlite", broken)
	if err != nil {
		t.Fatal(err)
	}
	if _, err = brokenDatabase.Exec(`CREATE TABLE unrelated (value TEXT)`); err != nil {
		t.Fatal(err)
	}
	_ = brokenDatabase.Close()
	if _, err = reader.ExpiryDeltaSeconds(ctx, broken, "a"); err == nil {
		t.Fatal("database without access_tokens did not fail")
	}
	originalOpen := openSQLite
	openSQLite = func(string, string) (*sql.DB, error) { return nil, errors.New("open") }
	if _, err = reader.ExpiryDeltaSeconds(ctx, path, "active"); err == nil {
		t.Fatal("database open error was hidden")
	}
	openSQLite = originalOpen
}

type fakeSection struct{ name, output string }

func (f fakeSection) Name() string                  { return f.name }
func (f fakeSection) Render(context.Context) string { return f.output }

type tracedSection struct{ runner Runner }

func (tracedSection) Name() string { return "git" }
func (s tracedSection) Render(ctx context.Context) string {
	return runWithSpan(ctx, s.runner, "detect branch", "git", "branch")
}

func TestRunWithSpan(t *testing.T) {
	runner := fakeRunner{lines: map[string]string{commandKey("git", "branch"): "main"}}
	if got := runWithSpan(context.Background(), runner, "detect branch", "git", "branch"); got != "main" {
		t.Fatalf("untraced output = %q", got)
	}
	moments := []time.Time{
		time.Unix(0, 0),
		time.Unix(0, int64(1*time.Millisecond)),
		time.Unix(0, int64(2*time.Millisecond)),
		time.Unix(0, int64(4*time.Millisecond)),
		time.Unix(0, int64(6*time.Millisecond)),
	}
	index := 0
	report := (Renderer{
		Sections: []Section{tracedSection{runner: runner}},
		Now: func() time.Time {
			moment := moments[index]
			index++
			return moment
		},
	}).Render(context.Background())
	results := report.Results
	if got, want := results[0].Duration, 5*time.Millisecond; got != want {
		t.Fatalf("section duration = %s, want %s", got, want)
	}
	if got, want := results[0].Spans, []Span{{Operation: "detect branch", StartOffset: 2 * time.Millisecond, Duration: 2 * time.Millisecond}}; !reflect.DeepEqual(got, want) {
		t.Fatalf("spans = %#v, want %#v", got, want)
	}
}

func TestSharedRunCancellationAndSpanOrdering(t *testing.T) {
	sharedContext := withSharedRuns(context.Background(), &sharedRuns{calls: make(map[string]*sharedCall)})
	runner := blockingRunner{started: make(chan struct{}), release: make(chan struct{})}
	owner := make(chan string, 1)
	go func() {
		owner <- runSharedWithSpan(sharedContext, runner, "owner", "git", "shared")
	}()
	<-runner.started
	cancelled, cancel := context.WithCancel(sharedContext)
	cancel()
	if got := runSharedWithSpan(cancelled, runner, "waiter", "git", "shared"); got != "" {
		t.Fatalf("cancelled shared output = %q", got)
	}
	close(runner.release)
	if got := <-owner; got != "shared" {
		t.Fatalf("owner shared output = %q", got)
	}
	if got := runSharedWithSpan(sharedContext, runner, "cached", "git", "shared"); got != "shared" {
		t.Fatalf("cached shared output = %q", got)
	}

	origin := time.Unix(0, 0)
	recorder := &spanRecorder{origin: origin, spans: []Span{
		{Operation: "z", StartOffset: time.Millisecond},
		{Operation: "later", StartOffset: 2 * time.Millisecond},
		{Operation: "a", StartOffset: time.Millisecond},
	}}
	if got, want := recorder.snapshot(), []Span{
		{Operation: "a", StartOffset: time.Millisecond},
		{Operation: "z", StartOffset: time.Millisecond},
		{Operation: "later", StartOffset: 2 * time.Millisecond},
	}; !reflect.DeepEqual(got, want) {
		t.Fatalf("ordered spans = %#v, want %#v", got, want)
	}
}

func TestRepositorySnapshotWaitCancellation(t *testing.T) {
	shared := &sharedRuns{calls: make(map[string]*sharedCall)}
	ctx := withSharedRuns(context.Background(), shared)
	runner := &repositoryBlockingRunner{started: make(chan struct{}), release: make(chan struct{})}
	owner := make(chan repositorySnapshot, 1)
	go func() { owner <- loadRepositorySnapshot(ctx, runner) }()
	<-runner.started
	cancelled, cancel := context.WithCancel(ctx)
	cancel()
	if got := loadRepositorySnapshot(cancelled, runner); got != (repositorySnapshot{}) {
		t.Fatalf("cancelled repository snapshot = %#v", got)
	}
	close(runner.release)
	if got := <-owner; got.Branch != "main" {
		t.Fatalf("owner repository snapshot = %#v", got)
	}
}

func TestRendererRecordsRelativeStart(t *testing.T) {
	moments := []time.Time{
		time.Unix(0, 0),
		time.Unix(0, int64(5*time.Millisecond)),
		time.Unix(0, int64(8*time.Millisecond)),
	}
	index := 0
	report := (Renderer{
		Sections: []Section{fakeSection{"aws", "AWS"}},
		Now: func() time.Time {
			moment := moments[index]
			index++
			return moment
		},
	}).Render(context.Background())
	results := report.Results
	if got, want := results[0].StartOffset, 5*time.Millisecond; got != want {
		t.Fatalf("start offset = %s, want %s", got, want)
	}
	if got, want := results[0].Duration, 3*time.Millisecond; got != want {
		t.Fatalf("duration = %s, want %s", got, want)
	}
}

func TestRendererComposeAndTimings(t *testing.T) {
	sections := []Section{
		fakeSection{"git", "GIT"}, fakeSection{"gh", "GH"}, fakeSection{"kubernetes", "K8S"},
		fakeSection{"python", "PY"}, fakeSection{"aws", "AWS"}, fakeSection{"gcloud", "GC"},
	}
	report := (Renderer{Sections: sections}).Render(context.Background())
	results := report.Results
	if got, want := Compose(results), "GITGH K8S PY AWS GC"; got != want {
		t.Fatalf("Compose = %q, want %q", got, want)
	}
	results[0].Duration = 2 * time.Millisecond
	results[0].StartOffset = 250 * time.Microsecond
	results[0].Spans = []Span{{Operation: "detect branch", StartOffset: time.Millisecond, Duration: 500 * time.Microsecond}}
	results[1].Duration = 500 * time.Microsecond
	results[1].StartOffset = 10 * time.Nanosecond
	results[2].Duration = 12 * time.Nanosecond
	results[2].StartOffset = 0
	var output bytes.Buffer
	FormatTimings(&output, results[:3])
	if got, want := output.String(), "Module       Start       Duration\ngit          +250.0µs    2.0ms\ngh           +10ns       500.0µs\nkubernetes   +0ns        12ns\n"; got != want {
		t.Fatalf("timings = %q, want %q", got, want)
	}
	output.Reset()
	FormatMermaidTimings(&output, results[:3])
	wantMermaid := "```mermaid\ngantt\n    title joshpeak-prompt timing trace\n    dateFormat x\n    axisFormat %S.%L\n    tickInterval 1millisecond\n    section Prompt sections\n    git          :0, 2ms\n    gh           :0, 1ms\n    kubernetes   :0, 1ms\n```\n"
	if got := output.String(); got != wantMermaid {
		t.Fatalf("mermaid timings = %q, want %q", got, wantMermaid)
	}
	output.Reset()
	FormatDetailedMermaidTimings(&output, Report{
		Results:     results[:2],
		SharedSpans: []Span{{Operation: "common branch", StartOffset: 500 * time.Microsecond, Duration: 500 * time.Microsecond}},
	})
	wantDetailed := "```mermaid\ngantt\n    title joshpeak-prompt detailed timing trace\n    dateFormat x\n    axisFormat %S.%L\n    tickInterval 1millisecond\n    section shared git pre-step\n    common branch                :0, 1ms\n    section git\n    git total                    :0, 2ms\n    detect branch                :1, 1ms\n    section gh\n    gh total                     :0, 1ms\n```\n"
	if got := output.String(); got != wantDetailed {
		t.Fatalf("detailed mermaid timings = %q, want %q", got, wantDetailed)
	}
	if len(DefaultSections(fakeRunner{}, os.Getenv, "/tmp", fakeTokens{})) != 6 {
		t.Fatal("default sections mismatch")
	}
}

func TestWorkingDirectory(t *testing.T) {
	original, err := os.Getwd()
	if err != nil {
		t.Fatal(err)
	}
	defer os.Chdir(original)
	root := t.TempDir()
	child := filepath.Join(root, "a", "b")
	if err := os.MkdirAll(child, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.Chdir(root); err != nil {
		t.Fatal(err)
	}
	actualRoot, err := os.Getwd()
	if err != nil {
		t.Fatal(err)
	}
	if got := WorkingDirectory(actualRoot); got != "~" {
		t.Fatalf("root directory = %q", got)
	}
	if err := os.Chdir(child); err != nil {
		t.Fatal(err)
	}
	actualChild, err := os.Getwd()
	if err != nil {
		t.Fatal(err)
	}
	if got := WorkingDirectory(actualRoot); got != filepath.Join("~", "a", "b") {
		t.Fatalf("child directory = %q", got)
	}
	if got := WorkingDirectory(filepath.Join(actualRoot, "elsewhere")); got != actualChild {
		t.Fatalf("external directory = %q", got)
	}
	if Hostname() == "" {
		t.Fatal("hostname is empty")
	}
	originalHostname, originalGetwd := osHostname, osGetwd
	defer func() { osHostname, osGetwd = originalHostname, originalGetwd }()
	osHostname = func() (string, error) { return "host.example.test", nil }
	if got := Hostname(); got != "host" {
		t.Fatalf("short hostname = %q", got)
	}
	osHostname = func() (string, error) { return "", errors.New("hostname") }
	if got := Hostname(); got != "" {
		t.Fatalf("failed hostname = %q", got)
	}
	osGetwd = func() (string, error) { return "", errors.New("getwd") }
	if got := WorkingDirectory(actualRoot); got != "" {
		t.Fatalf("failed working directory = %q", got)
	}
}

func copyMap(source map[string]string) map[string]string {
	destination := make(map[string]string, len(source))
	for key, value := range source {
		destination[key] = value
	}
	return destination
}
