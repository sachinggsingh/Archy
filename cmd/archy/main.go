package main

import (
	"os"

	"github.com/mattn/go-isatty"
	"github.com/sachinggsingh/archy/internal/brand"
	"github.com/sachinggsingh/archy/internal/tui"
)

func main() {
	// Bubble Tea needs a real interactive terminal. If Archy is run in a non-TTY
	// context (pipes/redirects/CI), fail gracefully with a helpful message.
	if !isatty.IsTerminal(os.Stdin.Fd()) || !isatty.IsTerminal(os.Stdout.Fd()) {
		_, _ = os.Stdout.WriteString(brand.Banner() + "\n\n")
		_, _ = os.Stderr.WriteString("Archy needs an interactive TTY to run the UI.\n")
		_, _ = os.Stderr.WriteString("Run it directly in a terminal (don’t pipe/redirect stdin/stdout).\n")
		os.Exit(1)
	}

	if err := tui.Run(); err != nil {
		// Keep stderr clean: Bubble Tea manages screen state.
		_, _ = os.Stderr.WriteString("error running TUI: " + err.Error() + "\n")
		os.Exit(1)
	}
}
