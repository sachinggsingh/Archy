package tui

import (
	"fmt"
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/list"
	bubblespinner "github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/sachinggsingh/Archy/internal/brand"
	"github.com/sachinggsingh/Archy/internal/components/input"
	listcomponent "github.com/sachinggsingh/Archy/internal/components/list"
	"github.com/sachinggsingh/Archy/internal/components/spinner"
	"github.com/sachinggsingh/Archy/internal/generator"
)

var (
	languageItems = []list.Item{
		listcomponent.Item("JavaScript"),
		listcomponent.Item("TypeScript"),
		listcomponent.Item("Python"),
		listcomponent.Item("Golang"),
		listcomponent.Item("Exit Archy"),
	}

	frameworkItems = map[string][]list.Item{
		"javascript": {
			listcomponent.Item("Http"),
			listcomponent.Item("Express"),
		},
		"typescript": {
			listcomponent.Item("Http"),
			listcomponent.Item("Express"),
			listcomponent.Item("Fastify"),
		},
		"golang": {
			listcomponent.Item("Http"),
			listcomponent.Item("Gin"),
			listcomponent.Item("Echo"),
			listcomponent.Item("Fiber"),
			listcomponent.Item("gRPC"),
		},
		"python": {
			listcomponent.Item("Http"),
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

type model struct {
	step int // 0: language, 1: framework, 2: architecture, 3: project name

	lang string
	fw   string
	arch string

	projectName string
	docker      bool

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

	// Label style for selection summaries
	labelStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("205")) // Bright pink

	// Value style for selection summaries
	valueStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("81")). // Cyan
			Italic(true)

	// Screen style for fallback rendering
	screenStyle = lipgloss.NewStyle().Foreground(textColor)

	// Banner style - colorful pink/magenta
	bannerStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("213")).
			MarginLeft(4)

	// Header style for exit messages
	headerStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("#87CEEB")).
			MarginLeft(4)
)

type generatedMsg struct {
	err error
}

type quitMsg struct{}

type resetMsg struct{}

type structureCreatedMsg struct {
	langType string
	project  string
	err      error
}

// creating the folder
func (m model) createStructureCmd(lang, framework, arch, project string, docker bool) tea.Cmd {
	return func() tea.Msg {
		langType, proj, err := generator.CreateProjectStructure(lang, framework, arch, project, docker)

		return structureCreatedMsg{langType: langType, project: proj, err: err}
	}
}

func initialModel() model {
	m := model{
		step:    0,
		input:   input.New("project-name", 15),
		list:    listcomponent.New(languageItems, "Select Language"),
		spinner: spinner.New("Creating project structure", bubblespinner.Points),
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
		m.list.SetHeight(msg.Height - 22)
		return m, nil

	case structureCreatedMsg:
		if msg.err != nil {
			m.errMsg = msg.err.Error()
			m.generating = false
			m.quitting = true
			return m, tea.Tick(4*time.Second, func(t time.Time) tea.Msg {
				return resetMsg{}
			})
		}
		return m, func() tea.Msg {
			return generatedMsg{err: nil}
		}

	case generatedMsg:
		m.generating = false
		m.spinner.Stop()
		if msg.err != nil {
			m.errMsg = msg.err.Error()
			m.quitting = true
			return m, tea.Tick(4*time.Second, func(t time.Time) tea.Msg {
				return resetMsg{}
			})
		}

		m.done = true
		m.quitting = true
		return m, tea.Tick(3*time.Second, func(t time.Time) tea.Msg {
			return resetMsg{}
		})

	case quitMsg:
		return m, tea.Quit

	case resetMsg:
		m.step = 0
		m.done = false
		m.quitting = false
		m.errMsg = ""
		m.lang = ""
		m.fw = ""
		m.arch = ""
		m.projectName = ""
		m.docker = false
		m.input.SetValue("")
		m.list = listcomponent.New(languageItems, "Select Language")
		return m, nil

	case tea.KeyMsg:
		switch msg.Type {
		case tea.KeyCtrlC, tea.KeyEsc:
			m.quitting = true
			return m, tea.Quit

		case tea.KeyEnter:
			if m.generating {
				return m, nil
			}

			if m.step == 4 {
				trimmed := strings.TrimSpace(m.input.GetValue())
				if trimmed == "" {
					return m, nil
				}
				m.projectName = trimmed
				m.generating = true
				return m, tea.Batch(
					m.createStructureCmd(m.lang, m.fw, m.arch, m.projectName, m.docker),
					m.spinner.Spinner.Tick,
				)
			}

		}
	}

	if m.generating {
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		return m, cmd
	}

	if m.step < 4 {
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
				if choice == "Exit Archy" {
					m.quitting = true
					return m, tea.Quit
				}
				m.lang = strings.ToLower(choice)
				fwItems := frameworkItems[m.lang]
				m.list = listcomponent.New(fwItems, "Select Framework")
				m.step++
			case 1:
				m.fw = strings.ToLower(choice)
				m.list = listcomponent.New(architectureItems, "Select Architecture")
				m.step++
			case 2:
				m.arch = strings.ToLower(choice)
				featureItems := []list.Item{
					listcomponent.Item("Docker support"),
					listcomponent.Item("Skip and create project"),
				}
				m.list = listcomponent.New(featureItems, "Select Features")
				m.step++

			case 3:
				switch choice {
				case "Docker support":
					m.docker = true
				case "Skip and create project":
					m.docker = false
				}
				m.step++
				m.input.SetFocus(true)
			}
			m.list.SetWidth(m.width)
			if m.step == 4 {
				m.input.SetFocus(true)
			} else {
				m.list.SetHeight(m.height - 26)
			}
		}
	} else if m.step == 4 {

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
			return lipgloss.Place(
				m.width,
				m.height,
				lipgloss.Left,
				lipgloss.Top,
				content,
			)
		}
		return screenStyle.Render(content)
	}

	if m.quitting && !m.generating {
		if m.errMsg != "" {
			banner := brand.Banner()
			content := bannerStyle.Render(banner) + "\n\n" +
				headerStyle.Render("Error: "+m.errMsg)
			return renderScreen(content)
		}
		if m.done {
			banner := brand.Banner()
			content := bannerStyle.Render(banner) + "\n\n" +
				headerStyle.Render(fmt.Sprintf("Project generation finished!\n\nYour project '%s' has been created successfully.", m.projectName))
			return renderScreen(content)
		}
		return renderScreen(headerStyle.Render("Exiting Archy..."))
	}

	var b strings.Builder
	banner := brand.Banner()
	b.WriteString(bannerStyle.Render(banner) + "\n\n")

	if m.generating {
		b.WriteString(lipgloss.NewStyle().MarginLeft(4).Render(m.spinner.View()) + "\n")
		return renderScreen(b.String())
	}

	var inputView string
	mainStyle := lipgloss.NewStyle().MarginLeft(4)

	switch m.step {
	case 0:
		inputView = mainStyle.Render(m.list.View())
	case 1:
		b.WriteString(mainStyle.Render(labelStyle.Bold(true).Render("Language:     ")+valueStyle.Render(m.lang)) + "\n\n")
		inputView = mainStyle.Render(m.list.View())
	case 2:
		b.WriteString(mainStyle.Render(labelStyle.Bold(true).Render("Language:     ")+valueStyle.Render(m.lang)) + "\n")
		b.WriteString(mainStyle.Render(labelStyle.Bold(true).Render("Framework:    ")+valueStyle.Render(m.fw)) + "\n\n")
		inputView = mainStyle.Render(m.list.View())
	case 3:
		b.WriteString(mainStyle.Render(labelStyle.Bold(true).Render("Language:     ")+valueStyle.Render(m.lang)) + "\n")
		b.WriteString(mainStyle.Render(labelStyle.Bold(true).Render("Framework:    ")+valueStyle.Render(m.fw)) + "\n")
		b.WriteString(mainStyle.Render(labelStyle.Bold(true).Render("Architecture: ")+valueStyle.Render(m.arch)) + "\n\n")
		inputView = mainStyle.Render(m.list.View())
	case 4:
		b.WriteString(mainStyle.Render(labelStyle.Bold(true).Render("Language:     ")+valueStyle.Render(m.lang)) + "\n")
		b.WriteString(mainStyle.Render(labelStyle.Bold(true).Render("Framework:    ")+valueStyle.Render(m.fw)) + "\n")
		b.WriteString(mainStyle.Render(labelStyle.Bold(true).Render("Architecture: ")+valueStyle.Render(m.arch)) + "\n")
		features := "None"
		if m.docker {
			features = "Docker support"
		}
		b.WriteString(mainStyle.Render(labelStyle.Bold(true).Render("Features:     ")+valueStyle.Render(features)) + "\n\n")
		inputView = mainStyle.Render(m.input.View())
	}

	b.WriteString(inputView + "\n\n")

	helpText := "Enter to confirm | to exit press CTRL+C"
	if m.step < 3 {
		helpText = "↑/↓ move | Enter to confirm | to exit press CTRL+C"
	}
	b.WriteString(mainStyle.Render(textStyle.Faint(true).Render(helpText)) + "\n")

	return renderScreen(b.String())
}

// Run starts the Archy TUI.
func Run() error {
	p := tea.NewProgram(initialModel(), tea.WithAltScreen())
	_, err := p.Run()
	return err
}
