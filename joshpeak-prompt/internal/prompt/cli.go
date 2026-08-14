package prompt

import (
	"context"
	"fmt"
	"io"
	"os"
)

var userHomeDir = os.UserHomeDir

func Main(ctx context.Context, args []string, stdout, stderr io.Writer) int {
	home, _ := userHomeDir()
	sections := DefaultSections(ExecRunner{}, os.Getenv, home, SQLiteTokenReader{})
	return RunCLI(ctx, args, stdout, stderr, Renderer{Sections: sections}, home)
}

func RunCLI(ctx context.Context, args []string, stdout, stderr io.Writer, renderer Renderer, home string) int {
	command := "prompt"
	if len(args) > 0 {
		command = args[0]
	}
	switch command {
	case "prompt":
		report := renderer.Render(ctx)
		fmt.Fprintln(stdout, Compose(report.Results))
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
		for _, section := range renderer.Sections {
			if section.Name() == command {
				fmt.Fprintln(stdout, section.Render(ctx))
				return 0
			}
		}
	default:
		fmt.Fprintf(stderr, "unknown command %q\n", command)
		fmt.Fprintln(stderr, "usage: joshpeak-prompt [prompt [--timings]|timings [--mermaid [--detail]]|hostname|directory|git|gh|kubernetes|python|aws|gcloud]")
		return 2
	}
	return 2
}
