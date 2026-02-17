package tui

import (
	"fmt"
	"strings"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/sachinggsingh/archy/internal/generator"
)

// model holds the state for the Bubble Tea TUI.
type model struct {
	step int // 0: language, 1: framework, 2: architecture, 3: project name

	lang string
	fw   string
	arch string

	project string

	input string

	quitting   bool
	generating bool
	done       bool
	errMsg     string

	spinFrame int
}

// base styles
var (
	headerStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("213")) // pink

	subHeaderStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("244"))

	labelStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("81")) // cyan

	valueStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("120")) // green

	helpStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("244")).
			Italic(true)
)

var spinnerFrames = []string{"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}

type tickMsg struct{}

type generatedMsg struct {
	err error
}

func tickCmd() tea.Cmd {
	return tea.Tick(120*time.Millisecond, func(time.Time) tea.Msg {
		return tickMsg{}
	})
}

func generateCmd(lang, fw, arch, project string) tea.Cmd {
	return func() tea.Msg {
		err := generator.GenerateProject(lang, fw, arch, project)
		return generatedMsg{err: err}
	}
}

func (m model) inputStyle() lipgloss.Style {
	// Slightly change accent color depending on the current step.
	var bg lipgloss.Color
	switch m.step {
	case 0:
		bg = lipgloss.Color("57") // purple
	case 1:
		bg = lipgloss.Color("24") // blue
	case 2:
		bg = lipgloss.Color("22") // green
	default:
		bg = lipgloss.Color("238") // gray
	}

	return lipgloss.NewStyle().
		Foreground(lipgloss.Color("230")). // near white
		Background(bg).
		Padding(0, 1).
		Width(40)
}

func initialModel() model {
	return model{
		step:  0,
		input: "",
	}
}

func (m model) Init() tea.Cmd {
	// No initial command needed.
	return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tickMsg:
		if m.generating {
			m.spinFrame = (m.spinFrame + 1) % len(spinnerFrames)
			return m, tickCmd()
		}
		return m, nil

	case generatedMsg:
		m.generating = false
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
			// Ignore input while generating.
			if m.generating {
				return m, nil
			}

			trimmed := strings.TrimSpace(strings.ToLower(m.input))
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

			m.input = ""
			m.step++

			if m.step >= 4 {
				// Start loading state and trigger async generation.
				m.generating = true
				return m, tea.Batch(
					generateCmd(m.lang, m.fw, m.arch, m.project),
					tickCmd(),
				)
			}

			return m, nil

		case tea.KeyBackspace, tea.KeyDelete:
			if len(m.input) > 0 {
				m.input = m.input[:len(m.input)-1]
			}

		default:
			// Append regular characters to the input buffer.
			m.input += msg.String()
		}
	}

	return m, nil
}

func (m model) View() string {
	if m.quitting {
		if m.generating {
			// Shouldn't normally happen, but guard just in case.
			return headerStyle.Render("Exiting Archy...") + "\n"
		}

		if m.errMsg != "" {
			return headerStyle.Render("Archy · Project Generator") + "\n\n" +
				lipgloss.NewStyle().Foreground(lipgloss.Color("196")).Bold(true).
					Render("Error: "+m.errMsg) + "\n"
		}

		if m.done {
			return headerStyle.Render("Archy · Project Generator") + "\n\n" +
				valueStyle.Render("Project generation finished!") + "\n"
		}

		return headerStyle.Render("Exiting Archy...") + "\n"
	}

	var b strings.Builder

	title := headerStyle.Render("Archy · Project Generator")
	sub := subHeaderStyle.Render("Create a project in a few keystrokes")
	b.WriteString(title + "\n" + sub + "\n\n")

	// Previously entered values
	if m.lang != "" {
		b.WriteString(labelStyle.Render("Language: ") + valueStyle.Render(m.lang) + "\n")
	}
	if m.fw != "" {
		b.WriteString(labelStyle.Render("Framework: ") + valueStyle.Render(m.fw) + "\n")
	}
	if m.arch != "" {
		b.WriteString(labelStyle.Render("Architecture: ") + valueStyle.Render(m.arch) + "\n")
	}
	if m.project != "" {
		b.WriteString(labelStyle.Render("Project: ") + valueStyle.Render(m.project) + "\n")
	}
	if m.lang != "" || m.fw != "" || m.arch != "" || m.project != "" {
		b.WriteString("\n")
	}

	// Current prompt
	var prompt string

	if m.generating {
		frame := spinnerFrames[m.spinFrame%len(spinnerFrames)]
		b.WriteString(valueStyle.Render(fmt.Sprintf("%s Generating your project...", frame)) + "\n")
		b.WriteString("\n" + helpStyle.Render("Sit tight, Archy is working...") + "\n")
		return b.String()
	}

	switch m.step {
	case 0:
		prompt = "Language (go / js / python)"
	case 1:
		prompt = "Framework (e.g. gin, express, fastapi)"
	case 2:
		prompt = "Architecture (microservice / monolith)"
	case 3:
		prompt = "Project name (folder to create)"
	default:
		b.WriteString(valueStyle.Render("Generating your project...") + "\n")
	}

	if m.step < 4 {
		b.WriteString(labelStyle.Render(prompt) + "\n\n")
		// Styled input line
		inputLine := m.inputStyle().Render("> " + m.input)
		b.WriteString(inputLine + "\n")
	}

	b.WriteString("\n" + helpStyle.Render("Enter to confirm · Ctrl+C / Esc to quit") + "\n")

	return b.String()
}

// Run starts the Archy TUI.
func Run() error {
	p := tea.NewProgram(initialModel())
	_, err := p.Run()
	return err
}

