package generator

import (
	"bytes"
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
	case "js", "javascript", "node", "nodejs":
		return GenerateTheNodeProject(frameWork, arch, project)
	case "python", "py":
		return GenerateThePythonProject(frameWork, arch, project)
	case "go", "golang":
		return GenerateTheGoProject(frameWork, arch, project)
	default:
		return fmt.Errorf("language %q not supported", lang)
	}
}

// GenerateTheNodeProject generates a Node.js project using the template scripts.
func GenerateTheNodeProject(frameWork, arch, project string) error {
	fw := strings.ToLower(strings.TrimSpace(frameWork))
	ar := strings.ToLower(strings.TrimSpace(arch))
	proj := strings.TrimSpace(project)

	// Normalize architecture names
	switch ar {
	case "micro":
		ar = "microservice"
	case "mono":
		ar = "monolith"
	}

	if proj == "" {
		return fmt.Errorf("project name cannot be empty")
	}

	if fw != "express" {
		return fmt.Errorf("node framework %q not supported yet (only express is implemented)", frameWork)
	}

	if ar != "micro" && ar != "mono" && ar != "microservice" && ar != "monolith" {
		return fmt.Errorf("architecture %q not supported (use microservice or monolith)", arch)
	}

	// Find base directory that contains the templates.
	exePath, err := os.Executable()
	if err != nil {
		return fmt.Errorf("Not able to find the exePath: %w", err)
	}
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

	// Suppress all output - we'll show a nice loading screen instead
	cmd.Stdout = nil // Suppress stdout
	cmd.Stderr = nil // Suppress stderr (including git hints and npm messages)
	cmd.Stdin = nil  // No interactive input needed

	// Set environment to suppress git hints and npm funding messages
	env := os.Environ()
	env = append(env,
		"GIT_CONFIG_GLOBAL=/dev/null",
		"GIT_CONFIG_SYSTEM=/dev/null",
		"GIT_TERMINAL_PROMPT=0",
		"npm_config_fund=false",     // Disable funding messages
		"npm_config_audit=false",    // Disable audit messages
		"npm_config_progress=false", // Disable progress bars
		"CI=true",                   // Some tools are quieter in CI mode
	)
	cmd.Env = env

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to run node template script: %w", err)
	}

	return nil
}

// TODO: Implement Go templates when available.
func GenerateTheGoProject(frameWork, arch, project string) error {
	fmt.Println("Go project generation is not implemented yet.")
	return nil
}

func GenerateThePythonProject(frameWork, arch, project string) error {
	fw := strings.ToLower(strings.TrimSpace(frameWork))
	ar := strings.ToLower(strings.TrimSpace(arch))
	proj := strings.TrimSpace(project)

	// Normalize architecture names
	if ar == "micro" {
		ar = "microservice"
	} else if ar == "mono" {
		ar = "monolith"
	}

	if proj == "" {
		return fmt.Errorf("project name cannot be empty")
	}

	// Supported Python frameworks
	supportedFrameworks := map[string]bool{
		"flask":   true,
		"fastapi": true,
		"django":  true,
	}
	if !supportedFrameworks[fw] {
		return fmt.Errorf("python framework %q not supported (use flask, fastapi, or django)", frameWork)
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
		p := filepath.Join(base, "templates", "python", fw, ar, "generate.sh")
		if _, err := os.Stat(p); err == nil {
			baseDir = base
			scriptPath = p
			break
		}
	}

	if scriptPath == "" {
		return fmt.Errorf("template script not found for python framework %q and architecture %q", fw, ar)
	}

	// Read script content and substitute project placeholder.
	content, err := os.ReadFile(scriptPath)
	if err != nil {
		return fmt.Errorf("failed to read template script: %w", err)
	}

	// Replace {{.Project}} placeholder with actual project name
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

	// Capture stderr to see errors, but suppress stdout for cleaner output
	var stderr bytes.Buffer
	cmd.Stdout = nil     // Suppress stdout
	cmd.Stderr = &stderr // Capture stderr to see errors
	cmd.Stdin = nil      // No interactive input needed

	// Set environment to suppress git hints and pip messages
	env := os.Environ()
	env = append(env,
		"GIT_CONFIG_GLOBAL=/dev/null",
		"GIT_CONFIG_SYSTEM=/dev/null",
		"GIT_TERMINAL_PROMPT=0",
		"PIP_NO_COLOR=1", // Disable pip colors
		"PIP_QUIET=1",    // Quiet pip output
		"CI=true",        // Some tools are quieter in CI mode
	)
	cmd.Env = env

	if err := cmd.Run(); err != nil {
		errMsg := stderr.String()
		if errMsg != "" {
			return fmt.Errorf("failed to run python template script: %w\nstderr: %s", err, errMsg)
		}
		return fmt.Errorf("failed to run python template script: %w", err)
	}

	return nil
}
