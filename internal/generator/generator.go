package generator

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/sachinggsingh/Archy/templates"
)

// CreateProjectStructure creates the folder structure using the template script.
func CreateProjectStructure(lang, framework, architecture, project string, useDocker bool) (string, string, error) {
	normalized := strings.ToLower(strings.TrimSpace(lang))

	var scriptPath string
	var err error
	var langType string

	switch normalized {
	case "js", "javascript", "ts", "typescript", "node", "nodejs":
		l := "js"
		if strings.Contains(strings.ToLower(lang), "typescript") || strings.ToLower(lang) == "ts" {
			l = "ts"
		}
		scriptPath, err = findTemplatePath(filepath.Join("node", l), framework, architecture)
		langType = "npm"
	case "python", "py":
		scriptPath, err = findTemplatePath("python", framework, architecture)
		langType = "python"
	case "go", "golang":
		scriptPath, err = findTemplatePath("golang", framework, architecture)

		langType = "go"
	default:
		return "", "", fmt.Errorf("language %q not supported", lang)
	}

	if err != nil {
		return "", "", err
	}

	if err := runTemplateScript(scriptPath, project, useDocker); err != nil {
		return "", "", err
	}

	return langType, project, nil
}

// findTemplatePath looks for the template script in the embedded filesystem.
func findTemplatePath(lang, framework, arch string) (string, error) {
	ar := arch
	switch ar {
	case "micro":
		ar = "microservice"
	case "mono":
		ar = "monolith"
	}

	// Framework mapping for consistency (all lowercase now)
	fw := strings.ToLower(framework)

	p := filepath.Join(lang, fw, ar, "generate.sh")
	if _, err := templates.FS.Open(p); err == nil {
		return p, nil
	}

	return "", fmt.Errorf("template script not found for %s/%s/%s", lang, framework, ar)
}

func runTemplateScript(scriptPath, project string, useDocker bool) error {
	content, err := templates.FS.ReadFile(scriptPath)
	if err != nil {
		return fmt.Errorf("failed to read template script from embed: %w", err)
	}

	scriptWithProject := strings.ReplaceAll(string(content), "{{.Project}}", project)
	scriptWithProject = strings.ReplaceAll(scriptWithProject, "{{.ProjectName}}", project)

	// Create project directory in CWD
	cwd, err := os.Getwd()
	if err != nil {
		return fmt.Errorf("failed to get current working directory: %w", err)
	}
	projectPath := filepath.Join(cwd, project)
	if err := os.MkdirAll(projectPath, 0o755); err != nil {
		return fmt.Errorf("failed to create project directory: %w", err)
	}

	tmpName := fmt.Sprintf("generate-%d.sh", time.Now().UnixNano())
	// Use OS temp directory for the script to avoid issues with target directory permissions or cleanup
	tmpPath := filepath.Join(os.TempDir(), tmpName)

	if err := os.WriteFile(tmpPath, []byte(scriptWithProject), 0o755); err != nil {
		return fmt.Errorf("failed to write temp script: %w", err)
	}
	defer os.Remove(tmpPath)

	cmd := exec.Command("bash", tmpPath)
	cmd.Dir = projectPath
	cmd.Env = append(os.Environ(),
		fmt.Sprintf("PROJECT_NAME=%s", project),
		fmt.Sprintf("USE_DOCKER=%t", useDocker),
	)

	return cmd.Run()
}
