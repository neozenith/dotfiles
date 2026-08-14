package prompt

import (
	"context"
	"strings"
)

type AWS struct {
	Env func(string) string
}

func (AWS) Name() string { return "aws" }

func (a AWS) Render(context.Context) string {
	profile := a.Env("AWS_PROFILE")
	if profile == "" {
		return " %F{052}☁️  aws_profile_not_set" + norm
	}
	return legacyEcho(" %F{166}☁️ " + profile + norm)
}

type Python struct {
	Runner Runner
	Env    func(string) string
	Home   string
}

func (Python) Name() string { return "python" }

func (p Python) Render(ctx context.Context) string {
	location := ""
	python := p.Runner.LookPath("python3")
	switch python {
	case "/usr/bin/python3":
		location = "system"
	case "/usr/local/bin/python3", "/opt/homebrew/bin/python3":
		location = "homebrew"
	case p.Home + "/.pyenv/shims/python3":
		location = "pyenv"
	default:
		if p.Env("VIRTUAL_ENV") != "" {
			location = "venv"
		}
	}
	version := strings.ReplaceAll(p.Runner.Run(ctx, "python3", "-V"), "Python ", "")
	return legacyEcho(" %F{green}🐍 " + location + " " + version + "%F{rc}")
}

type Kubernetes struct {
	Runner Runner
}

func (Kubernetes) Name() string { return "kubernetes" }

func (k Kubernetes) Render(ctx context.Context) string {
	if k.Runner.LookPath("kubectl") == "" {
		return ""
	}
	current := k.Runner.Run(ctx, "kubectl", "config", "current-context")
	if current == "" {
		return ""
	}
	colour := "%F{016}%K{019}"
	if current == "docker-desktop" {
		colour = "%F{017}"
	}
	return legacyEcho("%F{023}☸|" + colour + current + norm + "%F{023}|" + norm)
}
