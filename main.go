package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/mattn/go-isatty"
	"github.com/sachinggsingh/Archy/internal/brand"
	"github.com/sachinggsingh/Archy/internal/generator"
	"github.com/sachinggsingh/Archy/internal/tui"
)

func main() {
	lang := flag.String("lang", "", "Programming language")
	fw := flag.String("fw", "", "Framework")
	arch := flag.String("arch", "", "Architecture (monolith/microservice)")
	project := flag.String("project", "", "Project name")
	docker := flag.Bool("docker", false, "Enable Docker support")
	skipDeps := flag.Bool("skip-deps", false, "Skip dependency installation")
	flag.Parse()

	if *lang != "" && *fw != "" && *arch != "" && *project != "" {
		fmt.Printf("Generating %s project '%s' using %s with %s architecture...\n", *lang, *project, *fw, *arch)
		langType, proj, err := generator.CreateProjectStructure(*lang, *fw, *arch, *project, *docker)

		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
		fmt.Printf("Project structure created at ./%s\n", proj)

		if !*skipDeps {
			fmt.Println("Installing dependencies...")
			if err := generator.InstallDependencies(proj, langType); err != nil {
				fmt.Fprintf(os.Stderr, "Error installing dependencies: %v\n", err)
				os.Exit(1)
			}
		} else {
			fmt.Println("Skipping dependency installation.")
		}
		fmt.Println("Project generated successfully! 🚀")
		return
	}

	// Bubble Tea needs a real interactive terminal. If Archy is run in a non-TTY
	// context (pipes/redirects/CI), fail gracefully with a helpful message.
	if !isatty.IsTerminal(os.Stdin.Fd()) || !isatty.IsTerminal(os.Stdout.Fd()) {
		_, _ = os.Stdout.WriteString(brand.Banner() + "\n\n")
		_, _ = os.Stderr.WriteString("Archy needs an interactive TTY to run the UI.\n")
		_, _ = os.Stderr.WriteString("Run it directly in a terminal (don’t pipe/redirect stdin/stdout).\n")
		_, _ = os.Stderr.WriteString("Alternatively, use flags for non-interactive mode: -lang, -fw, -arch, -project [-docker] [-tests]\n")
		os.Exit(1)
	}

	if err := tui.Run(); err != nil {
		// Keep stderr clean: Bubble Tea manages screen state.
		_, _ = os.Stderr.WriteString("error running TUI: " + err.Error() + "\n")
		os.Exit(1)
	}
}
