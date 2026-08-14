package main

import (
	"os"
	"testing"
)

func TestMain(t *testing.T) {
	originalArgs, originalExit := os.Args, exit
	defer func() {
		os.Args = originalArgs
		exit = originalExit
	}()
	os.Args = []string{"joshpeak-prompt", "unknown"}
	code := -1
	exit = func(value int) { code = value }
	main()
	if code != 2 {
		t.Fatalf("exit code = %d", code)
	}
}
