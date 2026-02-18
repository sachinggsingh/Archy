package spinner

import (
	"fmt"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// Model represents a spinner component.
type Model struct {
	Frame      int
	Running    bool
	Message    string
	Frames     []string
	style      lipgloss.Style
	messageStyle lipgloss.Style
}

// TickMsg is sent to update the spinner animation.
type TickMsg struct{}

// New creates a new spinner model.
func New(message string) Model {
	return Model{
		Message: message,
		Running: true,
		Frames: []string{
			"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏",
		},
		style: lipgloss.NewStyle().
			Foreground(lipgloss.Color("252")), // Consistent color
		messageStyle: lipgloss.NewStyle().
			Foreground(lipgloss.Color("252")), // Consistent color
	}
}

// Tick returns a command that sends a tick message.
func Tick() tea.Cmd {
	return tea.Tick(120*time.Millisecond, func(time.Time) tea.Msg {
		return TickMsg{}
	})
}

// Update handles messages for the spinner component.
func (m Model) Update(msg tea.Msg) (Model, tea.Cmd) {
	switch msg.(type) {
	case TickMsg:
		if m.Running {
			m.Frame = (m.Frame + 1) % len(m.Frames)
			return m, Tick()
		}
	}
	return m, nil
}

// View renders the spinner component.
func (m Model) View() string {
	if !m.Running {
		return ""
	}
	frame := m.Frames[m.Frame%len(m.Frames)]
	return fmt.Sprintf("%s %s", m.style.Render(frame), m.messageStyle.Render(m.Message))
}

// SetRunning sets whether the spinner is running.
func (m *Model) SetRunning(running bool) {
	m.Running = running
}

// SetMessage updates the spinner message.
func (m *Model) SetMessage(message string) {
	m.Message = message
}
