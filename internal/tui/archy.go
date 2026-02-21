package tui

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	bubblespinner "github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/sachinggsingh/archy/internal/brand"
	"github.com/sachinggsingh/archy/internal/components/input"
	listcomponent "github.com/sachinggsingh/archy/internal/components/list"
	"github.com/sachinggsingh/archy/internal/components/spinner"
	"github.com/sachinggsingh/archy/internal/generator"
)

var (
	languageItems = []list.Item{
		listcomponent.Item("JavaScript"),
		listcomponent.Item("Python"),
	}

	frameworkItems = map[string][]list.Item{
		"javascript": {
			listcomponent.Item("Express"),
		},
		"python": {
			listcomponent.Item("Django"),
			listcomponent.Item("FastAPI"),
			listcomponent.Item("Flask"),
		},
	}

	architectureItems = []list.Item{
		listcomponent.Item("Monolith"),
		listcomponent.Item("Microservice"),
	}
)

// model holds the state for the Bubble Tea TUI.
type model struct {
	step int // 0: language, 1: framework, 2: architecture, 3: project name

	lang string
	fw   string
	arch string

	project string

	input   input.Model
	list    listcomponent.Model
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
	textStyle = lipgloss.NewStyle().Foreground(textColor).Bold(true)

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

func generateCmd(lang, fw, arch, project string) tea.Cmd {
	return func() tea.Msg {
		err := generator.GenerateProject(lang, fw, arch, project)
		return generatedMsg{err: err}
	}
}

func initialModel() model {
	m := model{
		step:    0,
		input:   input.New("my-awesome-project", 40),
		list:    listcomponent.New(languageItems, "Select Language"),
		spinner: spinner.New("Generating project", bubblespinner.Line),
	}
	m.input.SetFocus(true)
	return m
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
		m.list.SetWidth(msg.Width)
		m.list.SetHeight(msg.Height - 18) // Account for banner (~12) + prompts + help
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

			if m.step == 3 {
				trimmed := strings.TrimSpace(m.input.GetValue())
				if trimmed == "" {
					return m, nil
				}
				m.project = trimmed
				m.generating = true
				m.spinner.Start()
				return m, tea.Batch(
					generateCmd(m.lang, m.fw, m.arch, m.project),
					m.spinner.Init(),
				)
			}
		}
	}

	if m.generating {
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		return m, cmd
	}

	if m.step < 3 {
		var cmd tea.Cmd
		updatedList, cmd := m.list.Update(msg)
		m.list = updatedList.(listcomponent.Model)
		if cmd != nil {
			cmds = append(cmds, cmd)
		}

		if m.list.HasChoice() {
			choice := m.list.GetChoice()
			m.list.ClearChoice()
			switch m.step {
			case 0:
				m.lang = strings.ToLower(choice)
				fwItems := frameworkItems[m.lang]
				m.list = listcomponent.New(fwItems, "Select Framework")
			case 1:
				m.fw = strings.ToLower(choice)
				m.list = listcomponent.New(architectureItems, "Select Architecture")
			case 2:
				m.arch = strings.ToLower(choice)
			}
			m.step++
			m.list.SetWidth(m.width)
			m.list.SetHeight(m.height - 18)
		}
	} else if m.step == 3 {
		var cmd tea.Cmd
		m.input, cmd = m.input.Update(msg)
		if cmd != nil {
			cmds = append(cmds, cmd)
		}
	}

	return m, tea.Batch(cmds...)
}

func (m model) View() string {
	renderScreen := func(content string) string {
		if m.width > 0 && m.height > 0 {
			// Calculate if content is taller than screen
			contentLines := strings.Count(content, "\n") + 1
			vert := lipgloss.Center
			if contentLines >= m.height {
				vert = lipgloss.Top
			}

			return lipgloss.Place(
				m.width,
				m.height,
				lipgloss.Center,
				vert,
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
	banner := brand.Banner()
	b.WriteString(bannerStyle.Render(banner) + "\n\n")

	if m.generating {
		b.WriteString(m.spinner.Spinner.View() + " " + textStyle.Render("Generating project") + "\n")
		return renderScreen(b.String())
	}

	var prompt string
	var inputView string
	switch m.step {
	case 0:
		prompt = "Select Language"
		inputView = m.list.View()
	case 1:
		prompt = "Select Framework"
		b.WriteString(textStyle.Render("Language: "+m.lang) + "\n\n")
		inputView = m.list.View()
	case 2:
		prompt = "Select Architecture"
		b.WriteString(textStyle.Render("Language:  "+m.lang) + "\n")
		b.WriteString(textStyle.Render("Framework: "+m.fw) + "\n\n")
		inputView = m.list.View()
	case 3:
		prompt = "Project name (folder to create)"
		b.WriteString(textStyle.Render("Language:     "+m.lang) + "\n")
		b.WriteString(textStyle.Render("Framework:    "+m.fw) + "\n")
		b.WriteString(textStyle.Render("Architecture: "+m.arch) + "\n\n")
		inputView = m.input.View()
	}

	b.WriteString(textStyle.Render(prompt) + "\n\n")
	b.WriteString(inputView + "\n\n")
	b.WriteString(textStyle.Render("Enter to confirm · Ctrl+C / Esc to quit") + "\n")

	return renderScreen(b.String())
}

// Run starts the Archy TUI.
func Run() error {
	p := tea.NewProgram(initialModel(), tea.WithAltScreen())
	_, err := p.Run()
	return err
}
