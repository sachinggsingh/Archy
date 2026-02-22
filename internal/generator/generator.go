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
	case "js", "javascript", "ts", "typescript", "node", "nodejs":
		return GenerateTheNodeProject(lang, frameWork, arch, project)
	case "python", "py":
		return GenerateThePythonProject(frameWork, arch, project)
	case "go", "golang":
		return GenerateTheGoProject(frameWork, arch, project)
	default:
		return fmt.Errorf("language %q not supported", lang)
	}
}

// findTemplatePath looks for the template script in candidate directories.
func findTemplatePath(lang, framework, arch string) (string, string, error) {
	exePath, _ := os.Executable()
	var candidates []string
	if exePath != "" {
		candidates = append(candidates, filepath.Dir(exePath))
	}
	if cwd, err := os.Getwd(); err == nil {
		candidates = append(candidates, cwd)
	}

	ar := arch
	switch ar {
	case "micro":
		ar = "microservice"
	case "mono":
		ar = "monolith"
	}

	// Try common locations
	for _, base := range candidates {
		// Try exact lang/framework/arch path
		p := filepath.Join(base, "templates", lang, framework, ar, "generate.sh")
		if _, err := os.Stat(p); err == nil {
			return base, p, nil
		}

		// Try capitalized framework (for Go)
		capitalizedFW := strings.Title(framework)
		p = filepath.Join(base, "templates", lang, capitalizedFW, ar, "generate.sh")
		if _, err := os.Stat(p); err == nil {
			return base, p, nil
		}
	}

	return "", "", fmt.Errorf("template script not found for %s/%s/%s", lang, framework, ar)
}

// GenerateTheNodeProject generates a Node.js project.
func GenerateTheNodeProject(language, frameWork, arch, project string) error {
	lang := "js"
	if strings.Contains(strings.ToLower(language), "typescript") || strings.ToLower(language) == "ts" {
		lang = "ts"
	}

	baseDir, scriptPath, err := findTemplatePath(filepath.Join("node", lang), frameWork, arch)
	if err != nil {
		return err
	}

	return runTemplateScript(baseDir, scriptPath, project, "npm")
}

// GenerateTheGoProject generates a Go project.
func GenerateTheGoProject(frameWork, arch, project string) error {
	baseDir, scriptPath, err := findTemplatePath("golang", frameWork, arch)
	if err != nil {
		return err
	}

	return runTemplateScript(baseDir, scriptPath, project, "go")
}

func GenerateThePythonProject(frameWork, arch, project string) error {
	baseDir, scriptPath, err := findTemplatePath("python", frameWork, arch)
	if err != nil {
		return err
	}

	return runTemplateScript(baseDir, scriptPath, project, "python")
}

func runTemplateScript(baseDir, scriptPath, project, langType string) error {
	content, err := os.ReadFile(scriptPath)
	if err != nil {
		return fmt.Errorf("failed to read template script: %w", err)
	}

	scriptWithProject := strings.ReplaceAll(string(content), "{{.Project}}", project)
	// Some Go templates might use {{.ProjectName}}, let's handle both
	scriptWithProject = strings.ReplaceAll(scriptWithProject, "{{.ProjectName}}", project)

	tmpName := fmt.Sprintf("generate-%d.sh", time.Now().UnixNano())
	tmpPath := filepath.Join(baseDir, tmpName)

	if err := os.WriteFile(tmpPath, []byte(scriptWithProject), 0o755); err != nil {
		return fmt.Errorf("failed to write temp script: %w", err)
	}
	defer os.Remove(tmpPath)

	cmd := exec.Command("bash", tmpPath)
	cmd.Dir = baseDir
	cmd.Stdout = nil
	cmd.Stderr = nil
	cmd.Stdin = nil

	env := os.Environ()
	env = append(env,
		"GIT_CONFIG_GLOBAL=/dev/null",
		"GIT_CONFIG_SYSTEM=/dev/null",
		"GIT_TERMINAL_PROMPT=0",
		"CI=true",
	)

	switch langType {
	case "npm":
		env = append(env, "npm_config_fund=false", "npm_config_audit=false", "npm_config_progress=false")
	case "python":
		env = append(env, "PIP_NO_COLOR=1", "PIP_QUIET=1")
	}

	cmd.Env = env

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to run template script: %w", err)
	}

	return nil
}
