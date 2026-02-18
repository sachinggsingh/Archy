package input

import (
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// Model represents an input component.
type Model struct {
	Value       string
	Placeholder string
	Focused     bool
	Width       int
	style       lipgloss.Style
	focusStyle  lipgloss.Style
}

// New creates a new input model.
func New(placeholder string, width int) Model {
	return Model{
		Placeholder: placeholder,
		Width:       width,
		Focused:    true,
		style: lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(lipgloss.Color("240")).
			Foreground(lipgloss.Color("252")).
			Padding(0, 1).
			Width(width),
		focusStyle: lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(lipgloss.Color("240")). // Same gray border, not magenta
			Foreground(lipgloss.Color("252")).      // Consistent text color
			Padding(0, 1).
			Width(width),
	}
}

// Update handles messages for the input component.
func (m Model) Update(msg tea.Msg) (Model, tea.Cmd) {
	if !m.Focused {
		return m, nil
	}

	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.Type {
		case tea.KeyBackspace, tea.KeyDelete:
			if len(m.Value) > 0 {
				m.Value = m.Value[:len(m.Value)-1]
			}
		default:
			// Handle regular character input
			if len(msg.Runes) > 0 {
				m.Value += string(msg.Runes)
			}
		}
	}

	return m, nil
}

// View renders the input component.
func (m Model) View() string {
	displayValue := m.Value
	if displayValue == "" {
		displayValue = m.Placeholder
	}

	if m.Focused {
		return m.focusStyle.Render(displayValue)
	}
	return m.style.Render(displayValue)
}

// SetValue sets the input value.
func (m *Model) SetValue(value string) {
	m.Value = value
}

// GetValue returns the current input value.
func (m Model) GetValue() string {
	return m.Value
}

// SetFocus sets the focus state.
func (m *Model) SetFocus(focused bool) {
	m.Focused = focused
}
