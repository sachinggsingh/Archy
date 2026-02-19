package tui

import (
	"fmt"
	"strings"

	bubblespinner "github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/sachinggsingh/archy/internal/brand"
	"github.com/sachinggsingh/archy/internal/components/input"
	"github.com/sachinggsingh/archy/internal/components/spinner"
	"github.com/sachinggsingh/archy/internal/generator"
)

// model holds the state for the Bubble Tea TUI.
type model struct {
	step int // 0: language, 1: framework, 2: architecture, 3: project name

	lang string
	fw   string
	arch string

	project string

	input   input.Model
	spinner spinner.Model

	width  int
	height int

	quitting   bool
	generating bool
	done       bool
	errMsg     string
}

// base styles
var (
	// Consistent text color for everything
	textColor = lipgloss.Color("251") // Light gray/white

	// Text style used throughout
	textStyle = lipgloss.NewStyle().Foreground(textColor)

	// Screen style for fallback rendering
	screenStyle = lipgloss.NewStyle().Foreground(textColor)

	// Banner style - colorful pink/magenta
	bannerStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("213")).
			Align(lipgloss.Center)

	// Header style for exit messages
	headerStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("213")).
			Align(lipgloss.Center)
)

type generatedMsg struct {
	err error
}

// getOrPlaceholder returns the value if not empty, otherwise returns placeholder text
func getOrPlaceholder(value string) string {
	if value == "" {
		return "..."
	}
	return value
}

func generateCmd(lang, fw, arch, project string) tea.Cmd {
	return func() tea.Msg {
		err := generator.GenerateProject(lang, fw, arch, project)
		return generatedMsg{err: err}
	}
}

func initialModel() model {
	return model{
		step:    0,
		input:   input.New("", 20),
		spinner: spinner.New("Generating project", bubblespinner.Line),
	}
}

func (m model) Init() tea.Cmd {
	return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var cmds []tea.Cmd

	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		return m, nil

	case generatedMsg:
		m.generating = false
		m.spinner.Stop()
		if msg.err != nil {
			m.errMsg = msg.err.Error()
		} else {
			m.done = true
		}
		m.quitting = true
		return m, tea.Quit

	case tea.KeyMsg:
		switch msg.Type {
		case tea.KeyCtrlC, tea.KeyEsc:
			m.quitting = true
			return m, tea.Quit

		case tea.KeyEnter:
			if m.generating {
				return m, nil
			}

			trimmed := strings.TrimSpace(strings.ToLower(m.input.GetValue()))
			if trimmed == "" {
				return m, nil
			}

			switch m.step {
			case 0:
				m.lang = trimmed
			case 1:
				m.fw = trimmed
			case 2:
				m.arch = trimmed
			case 3:
				m.project = trimmed
			}

			m.input.SetValue("")
			m.step++

			if m.step >= 4 {
				m.generating = true
				m.spinner.Start()
				return m, tea.Batch(
					generateCmd(m.lang, m.fw, m.arch, m.project),
					m.spinner.Init(),
				)
			}

			return m, nil

		default:
			if !m.generating {
				var cmd tea.Cmd
				m.input, cmd = m.input.Update(msg)
				if cmd != nil {
					cmds = append(cmds, cmd)
				}
			}
		}
	}

	// Update spinner if generating
	if m.generating {
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		if cmd != nil {
			cmds = append(cmds, cmd)
		}
	}

	return m, tea.Batch(cmds...)
}

func (m model) View() string {
	renderScreen := func(content string) string {
		if m.width > 0 && m.height > 0 {
			return lipgloss.Place(
				m.width,
				m.height,
				lipgloss.Center,
				lipgloss.Center,
				content,
			)
		}
		return screenStyle.Render(content)
	}

	if m.quitting {
		if m.generating {
			return renderScreen(headerStyle.Render("Exiting Archy..."))
		}

		if m.errMsg != "" {
			banner := brand.Banner()
			content := bannerStyle.Render(banner) + "\n\n" +
				textStyle.Render("Error: "+m.errMsg)
			return renderScreen(content)
		}

		if m.done {
			banner := brand.Banner()
			content := bannerStyle.Render(banner) + "\n\n" +
				textStyle.Render(fmt.Sprintf("Project generation finished!\n\nYour project '%s' has been created successfully.", m.project))
			return renderScreen(content)
		}

		return renderScreen(headerStyle.Render("Exiting Archy..."))
	}

	var b strings.Builder

	// Banner with colorful text
	banner := brand.Banner()
	b.WriteString(bannerStyle.Render(banner) + "\n\n")

	// Always show all 4 lines to prevent shifting - reserve space for all inputs
	// Show selected values with consistent text color
	b.WriteString(textStyle.Render("Language: "+getOrPlaceholder(m.lang)) + "\n")
	b.WriteString(textStyle.Render("Framework: "+getOrPlaceholder(m.fw)) + "\n")
	b.WriteString(textStyle.Render("Architecture: "+getOrPlaceholder(m.arch)) + "\n")
	b.WriteString(textStyle.Render("Project: "+getOrPlaceholder(m.project)) + "\n")
	b.WriteString("\n")

	// Current prompt
	if m.generating {
		// Show loading screen with banner
		var loadingContent strings.Builder
		loadingContent.WriteString(bannerStyle.Render(banner) + "\n\n")
		loadingContent.WriteString(textStyle.Render("Language: "+m.lang) + "\n")
		loadingContent.WriteString(textStyle.Render("Framework: "+m.fw) + "\n")
		loadingContent.WriteString(textStyle.Render("Architecture: "+m.arch) + "\n")
		loadingContent.WriteString(textStyle.Render("Project: "+m.project) + "\n\n")
		loadingContent.WriteString(m.spinner.View() + "\n")
		loadingContent.WriteString(textStyle.Render("Creating your project structure...") + "\n")
		return renderScreen(loadingContent.String())
	}

	var prompt string
	switch m.step {
	case 0:
		prompt = "Language (go / js / python)"
	case 1:
		prompt = "Framework (e.g. gin, express, fastapi)"
	case 2:
		prompt = "Architecture (micro / mono)"
		if m.arch == "micro" {
			prompt += "service"
		}
	case 3:
		prompt = "Project name (folder to create)"
	default:
		b.WriteString(textStyle.Render("Generating your project...") + "\n")
		return renderScreen(b.String())
	}

	// Input section
	b.WriteString(textStyle.Render(prompt) + "\n\n")
	b.WriteString(m.input.View() + "\n\n")
	b.WriteString(textStyle.Render("Enter to confirm · Ctrl+C / Esc to quit") + "\n")

	return renderScreen(b.String())
}

// Run starts the Archy TUI.
func Run() error {
	p := tea.NewProgram(initialModel(), tea.WithAltScreen())
	_, err := p.Run()
	return err
}
