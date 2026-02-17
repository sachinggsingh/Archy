package generator

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

// GenerateProject routes to the correct language-specific generator.
func GenerateProject(lang, frameWork, arch, project string) error {
	normalized := strings.ToLower(strings.TrimSpace(lang))

	switch normalized {
	case "go":
		return GenerateTheGoProject(frameWork, arch, project)
	case "js", "javascript", "node", "nodejs":
		return GenerateTheNodeProject(frameWork, arch, project)
	case "python", "py":
		return GenerateThePythonProject(frameWork, arch, project)
	default:
		return fmt.Errorf("language %q not supported", lang)
	}
}

// GenerateTheNodeProject generates a Node.js project using the template scripts.
func GenerateTheNodeProject(frameWork, arch, project string) error {
	fw := strings.ToLower(strings.TrimSpace(frameWork))
	ar := strings.ToLower(strings.TrimSpace(arch))
	proj := strings.TrimSpace(project)

	if proj == "" {
		return fmt.Errorf("project name cannot be empty")
	}

	if fw != "express" {
		return fmt.Errorf("node framework %q not supported yet (only express is implemented)", frameWork)
	}

	if ar != "microservice" && ar != "monolith" {
		return fmt.Errorf("architecture %q not supported (use microservice or monolith)", arch)
	}

	// Find base directory that contains the templates.
	exePath, _ := os.Executable()
	var candidates []string
	if exePath != "" {
		candidates = append(candidates, filepath.Dir(exePath))
	}
	if cwd, err := os.Getwd(); err == nil {
		if len(candidates) == 0 || candidates[0] != cwd {
			candidates = append(candidates, cwd)
		}
	}

	var (
		baseDir    string
		scriptPath string
	)

	for _, base := range candidates {
		p := filepath.Join(base, "templates", "node", "js", "express", ar, "generate.sh")
		if _, err := os.Stat(p); err == nil {
			baseDir = base
			scriptPath = p
			break
		}
	}

	if scriptPath == "" {
		return fmt.Errorf("template script not found for architecture %q", ar)
	}

	// Read script content and substitute project placeholder.
	content, err := os.ReadFile(scriptPath)
	if err != nil {
		return fmt.Errorf("failed to read template script: %w", err)
	}

	scriptWithProject := strings.ReplaceAll(string(content), "{{.Project}}", proj)

	// Write a temporary script next to the original so relative paths still work.
	tmpName := fmt.Sprintf("generate-%d.sh", time.Now().UnixNano())
	tmpPath := filepath.Join(baseDir, tmpName)

	if err := os.WriteFile(tmpPath, []byte(scriptWithProject), 0o755); err != nil {
		return fmt.Errorf("failed to write temp script: %w", err)
	}
	defer os.Remove(tmpPath) // best-effort cleanup

	cmd := exec.Command("bash", tmpPath)
	cmd.Dir = baseDir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to run node template script: %w", err)
	}

	return nil
}

// TODO: Implement Go/Python templates when available.
func GenerateTheGoProject(frameWork, arch, project string) error {
	fmt.Println("Go project generation is not implemented yet.")
	return nil
}

func GenerateThePythonProject(frameWork, arch, project string) error {
	fmt.Println("Python project generation is not implemented yet.")
	return nil
}
