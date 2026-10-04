package prompt

import (
	"context"
	"fmt"
	"io"
	"os"
	"strings"
)

var userHomeDir = os.UserHomeDir

func Main(ctx context.Context, args []string, stdout, stderr io.Writer) int {
	home, _ := userHomeDir()
	sections := DefaultSections(ExecRunner{}, os.Getenv, home, SQLiteTokenReader{})
	return RunCLI(ctx, args, stdout, stderr, Renderer{Sections: sections}, home)
}

func RunCLI(ctx context.Context, args []string, stdout, stderr io.Writer, renderer Renderer, home string) int {
	var filteredArgs []string
	disabled := make(map[string]bool)
	for _, section := range []string{"git", "gh", "kubernetes", "python", "aws", "gcloud"} {
		disabled[section] = os.Getenv("JOSHPEAK_PROMPT__DISABLE_"+strings.ToUpper(section)) == "1"
	}
	for _, arg := range args {
		if strings.HasPrefix(arg, "--disable-") {
			section := strings.TrimPrefix(arg, "--disable-")
			if _, valid := disabled[section]; !valid {
				fmt.Fprintf(stderr, "unknown section %q in %q\n", section, arg)
				return 2
			}
			disabled[section] = true
			continue
		}
		filteredArgs = append(filteredArgs, arg)
	}
	args = filteredArgs
	anyDisabled := false
	for _, value := range disabled {
		if value {
			anyDisabled = true
		}
	}
	if anyDisabled {
		sections := make([]Section, 0, len(renderer.Sections))
		for _, section := range renderer.Sections {
			if !disabled[section.Name()] {
				sections = append(sections, section)
			}
		}
		renderer.Sections = sections
	}
	debugTimings := os.Getenv("JOSHPEAK_PROMPT__DEBUG_TIMINGS") == "1"
	command := "prompt"
	if len(args) > 0 {
		command = args[0]
	}
	switch command {
	case "prompt":
		report := renderer.Render(ctx)
		if debugTimings || anyDisabled {
			fmt.Fprintln(stdout, ComposeSelected(report, debugTimings))
		} else {
			fmt.Fprintln(stdout, Compose(report.Results))
		}
		if len(args) > 1 && args[1] == "--timings" {
			FormatTimings(stderr, report.Results)
		}
		return 0
	case "timings":
		report := renderer.Render(ctx)
		if len(args) > 1 && args[1] == "--mermaid" {
			if len(args) > 2 && args[2] == "--detail" {
				FormatDetailedMermaidTimings(stdout, report)
			} else {
				FormatMermaidTimings(stdout, report.Results)
			}
		} else if len(args) > 1 && args[1] == "--detail" {
			FormatDetailedTimings(stdout, report)
		} else {
			FormatTimings(stdout, report.Results)
		}
		return 0
	case "hostname":
		fmt.Fprintln(stdout, Hostname())
		return 0
	case "directory":
		fmt.Fprintln(stdout, WorkingDirectory(home))
		return 0
	case "git", "gh", "kubernetes", "python", "aws", "gcloud":
		if disabled[command] {
			return 0
		}
		for _, section := range renderer.Sections {
			if section.Name() == command {
				fmt.Fprintln(stdout, section.Render(ctx))
				return 0
			}
		}
	default:
		fmt.Fprintf(stderr, "unknown command %q\n", command)
		fmt.Fprintln(stderr, "usage: joshpeak-prompt [prompt [--timings]|timings [--detail|--mermaid [--detail]]|hostname|directory|git|gh|kubernetes|python|aws|gcloud] [--disable-<section>]")
		return 2
	}
	return 2
}
