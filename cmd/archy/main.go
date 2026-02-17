package main

import (
	"fmt"
	"os"

	"github.com/sachinggsingh/archy/internal/tui"
)

// simple ANSI sequences to tint the terminal while Archy is running
const (
	archBgColor   = "\x1b[48;5;236m" // dark background
	archFgColor   = "\x1b[38;5;252m" // light foreground
	archColorOn   = archBgColor + archFgColor
	archColorReset = "\x1b[0m"
)

func main() {
	// Tint the terminal while the CLI is active.
	fmt.Print(archColorOn)
	defer fmt.Print(archColorReset)

	if err := tui.Run(); err != nil {
		fmt.Println("error running TUI:", err)
		os.Exit(1)
	}
}
