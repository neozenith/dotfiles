package main

import (
	"context"
	"os"

	"github.com/joshpeak/joshpeak-prompt/internal/prompt"
)

var exit = os.Exit

func main() {
	exit(prompt.Main(context.Background(), os.Args[1:], os.Stdout, os.Stderr))
}
