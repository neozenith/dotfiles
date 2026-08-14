package prompt

import (
	"context"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"sync"
	"time"
)

const (
	norm = "%F{rc}%K{rc}"
)

var (
	osHostname = os.Hostname
	osGetwd    = os.Getwd
)

type Section interface {
	Name() string
	Render(context.Context) string
}

type Result struct {
	Name        string
	Output      string
	StartOffset time.Duration
	Duration    time.Duration
	Spans       []Span
}

type Report struct {
	Results     []Result
	SharedSpans []Span
}

type Renderer struct {
	Sections []Section
	Now      func() time.Time
}

func (r Renderer) Render(ctx context.Context) Report {
	now := r.Now
	if now == nil {
		now = time.Now
	}
	invocationStart := now()
	shared := &sharedRuns{
		calls:    make(map[string]*sharedCall),
		recorder: &spanRecorder{origin: invocationStart, now: now},
	}
	ctx = withSharedRuns(ctx, shared)
	results := make([]Result, len(r.Sections))
	var wg sync.WaitGroup
	for i, section := range r.Sections {
		wg.Add(1)
		go func() {
			defer wg.Done()
			start := now()
			recorder := &spanRecorder{origin: invocationStart, now: now}
			output := section.Render(withSpanRecorder(ctx, recorder))
			results[i] = Result{
				Name:        section.Name(),
				Output:      output,
				StartOffset: start.Sub(invocationStart),
				Duration:    now().Sub(start),
				Spans:       recorder.snapshot(),
			}
		}()
	}
	wg.Wait()
	return Report{Results: results, SharedSpans: shared.recorder.snapshot()}
}

func DefaultSections(runner Runner, env func(string) string, home string, tokens TokenReader) []Section {
	return []Section{
		Git{Runner: runner},
		GitHub{Runner: runner, Env: env},
		Kubernetes{Runner: runner},
		Python{Runner: runner, Env: env, Home: home},
		AWS{Env: env},
		GCloud{Runner: runner, Env: env, Home: home, Tokens: tokens},
	}
}

func Compose(results []Result) string {
	values := make(map[string]string, len(results))
	for _, result := range results {
		values[result.Name] = result.Output
	}
	return values["git"] + values["gh"] + " " + values["kubernetes"] + " " +
		values["python"] + " " + values["aws"] + " " + values["gcloud"]
}

func FormatTimings(w io.Writer, results []Result) {
	ordered := append([]Result(nil), results...)
	sort.SliceStable(ordered, func(i, j int) bool {
		return ordered[i].Duration > ordered[j].Duration
	})
	fmt.Fprintln(w, "Module       Start       Duration")
	for _, result := range ordered {
		fmt.Fprintf(w, "%-12s +%-10s %s\n", result.Name, formatDuration(result.StartOffset), formatDuration(result.Duration))
	}
}

func FormatMermaidTimings(w io.Writer, results []Result) {
	fmt.Fprintln(w, "```mermaid")
	fmt.Fprintln(w, "gantt")
	fmt.Fprintln(w, "    title joshpeak-prompt timing trace")
	fmt.Fprintln(w, "    dateFormat x")
	fmt.Fprintln(w, "    axisFormat %S.%L")
	fmt.Fprintln(w, "    tickInterval 1millisecond")
	fmt.Fprintln(w, "    section Prompt sections")
	for _, result := range results {
		fmt.Fprintf(w, "    %-12s :%d, %dms\n", result.Name, mermaidMilliseconds(result.StartOffset, false), mermaidMilliseconds(result.Duration, true))
	}
	fmt.Fprintln(w, "```")
}

func FormatDetailedMermaidTimings(w io.Writer, report Report) {
	fmt.Fprintln(w, "```mermaid")
	fmt.Fprintln(w, "gantt")
	fmt.Fprintln(w, "    title joshpeak-prompt detailed timing trace")
	fmt.Fprintln(w, "    dateFormat x")
	fmt.Fprintln(w, "    axisFormat %S.%L")
	fmt.Fprintln(w, "    tickInterval 1millisecond")
	if len(report.SharedSpans) > 0 {
		fmt.Fprintln(w, "    section shared git pre-step")
		for _, span := range report.SharedSpans {
			fmt.Fprintf(w, "    %-28s :%d, %dms\n", span.Operation, mermaidMilliseconds(span.StartOffset, false), mermaidMilliseconds(span.Duration, true))
		}
	}
	for _, result := range report.Results {
		fmt.Fprintf(w, "    section %s\n", result.Name)
		fmt.Fprintf(w, "    %-28s :%d, %dms\n", result.Name+" total", mermaidMilliseconds(result.StartOffset, false), mermaidMilliseconds(result.Duration, true))
		for _, span := range result.Spans {
			fmt.Fprintf(w, "    %-28s :%d, %dms\n", span.Operation, mermaidMilliseconds(span.StartOffset, false), mermaidMilliseconds(span.Duration, true))
		}
	}
	fmt.Fprintln(w, "```")
}

func mermaidMilliseconds(duration time.Duration, minimumOne bool) int64 {
	if duration <= 0 {
		if minimumOne {
			return 1
		}
		return 0
	}
	milliseconds := duration.Milliseconds()
	if minimumOne && duration%time.Millisecond != 0 {
		milliseconds++
	}
	return milliseconds
}

func formatDuration(duration time.Duration) string {
	if duration < time.Microsecond {
		return fmt.Sprintf("%dns", duration.Nanoseconds())
	}
	if duration < time.Millisecond {
		return fmt.Sprintf("%.1fµs", float64(duration)/float64(time.Microsecond))
	}
	return fmt.Sprintf("%.1fms", float64(duration)/float64(time.Millisecond))
}

func Hostname() string {
	hostname, err := osHostname()
	if err != nil {
		return ""
	}
	if index := strings.IndexByte(hostname, '.'); index >= 0 {
		return hostname[:index]
	}
	return hostname
}

func WorkingDirectory(home string) string {
	directory, err := osGetwd()
	if err != nil {
		return ""
	}
	if directory == home {
		return "~"
	}
	if relative, err := filepath.Rel(home, directory); err == nil && relative != "." && !strings.HasPrefix(relative, "..") {
		return filepath.Join("~", relative)
	}
	return directory
}
