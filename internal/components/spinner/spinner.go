package spinner

import (
	"fmt"

	bubblespinner "github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type Model struct {
	Spinner bubblespinner.Model
	Message string
	Running bool

	spinnerStyle lipgloss.Style
	textStyle    lipgloss.Style
}

func New(message string, s bubblespinner.Spinner) Model {

	sp := bubblespinner.New()
	sp.Spinner = s

	return Model{
		Spinner: sp,
		Message: message,
		Running: true,

		spinnerStyle: lipgloss.NewStyle().
			Foreground(lipgloss.Color("#1E90FF")), // dodger blue

		textStyle: lipgloss.NewStyle().
			Foreground(lipgloss.Color("#87CEEB")), // sky blue
	}
}

func (m Model) Init() tea.Cmd {
	if m.Running {
		return m.Spinner.Tick
	}
	return nil
}

func (m Model) Update(msg tea.Msg) (Model, tea.Cmd) {

	if !m.Running {
		return m, nil
	}

	var cmd tea.Cmd
	m.Spinner, cmd = m.Spinner.Update(msg)

	return m, cmd
}

func (m Model) View() string {

	if !m.Running {
		return ""
	}

	m.Spinner.Style = m.spinnerStyle

	return fmt.Sprintf(
		"%s %s",
		m.Spinner.View(),
		m.textStyle.Render(m.Message),
	)
}

func (m *Model) Stop() {
	m.Running = false
}

func (m *Model) Start() {
	m.Running = true
}

func (m *Model) SetMessage(msg string) {
	m.Message = msg
}
