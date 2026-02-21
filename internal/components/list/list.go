package list

import (
	"fmt"
	"io"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

const listHeight = 14

var (
	titleStyle        = lipgloss.NewStyle().MarginLeft(2)
	itemStyle         = lipgloss.NewStyle().PaddingLeft(4)
	selectedItemStyle = lipgloss.NewStyle().PaddingLeft(2).Foreground(lipgloss.Color("170"))
	paginationStyle   = list.DefaultStyles().PaginationStyle.PaddingLeft(4)
	helpStyle         = list.DefaultStyles().HelpStyle.PaddingLeft(4).PaddingBottom(1)
	quitTextStyle     = lipgloss.NewStyle().Margin(1, 0, 2, 4)
)

type Item string

func (i Item) FilterValue() string { return "" }

type itemDelegate struct{}

func (d itemDelegate) Height() int                             { return 1 }
func (d itemDelegate) Spacing() int                            { return 0 }
func (d itemDelegate) Update(_ tea.Msg, _ *list.Model) tea.Cmd { return nil }
func (d itemDelegate) Render(w io.Writer, m list.Model, index int, listItem list.Item) {
	i, ok := listItem.(Item)
	if !ok {
		return
	}

	str := fmt.Sprintf("%d. %s", index+1, i)

	fn := itemStyle.Render
	if index == m.Index() {
		fn = func(s ...string) string {
			return selectedItemStyle.Render("> " + strings.Join(s, " "))
		}
	}

	fmt.Fprint(w, fn(str))
}

type Model struct {
	list     list.Model
	choice   string
	quitting bool
}

func (m Model) Init() tea.Cmd {
	return nil
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.list.SetWidth(msg.Width)
		return m, nil

	case tea.KeyMsg:
		switch keypress := msg.String(); keypress {
		case "q", "ctrl+c":
			m.quitting = true
			return m, tea.Quit

		case "enter":
			i, ok := m.list.SelectedItem().(Item)
			if ok {
				m.choice = string(i)
			}
			// Don't quit, just set the choice
			return m, nil
		}
	}

	var cmd tea.Cmd
	m.list, cmd = m.list.Update(msg)
	return m, cmd
}

func (m Model) View() string {
	if m.choice != "" {
		return quitTextStyle.Render(fmt.Sprintf("%s? Sounds good to me.", m.choice))
	}
	if m.quitting {
		return quitTextStyle.Render("Not hungry? That’s cool.")
	}
	return m.list.View()
}

// New creates a new list model with the given items and title
func New(items []list.Item, title string) Model {
	const defaultWidth = 20
	height := len(items) + 4 // Add padding for title and help
	if height < 8 {
		height = 8 // Minimum height
	}
	if height > 20 {
		height = 20 // Maximum height
	}

	l := list.New(items, itemDelegate{}, defaultWidth, height)
	l.Title = title
	l.SetShowStatusBar(false)
	l.SetFilteringEnabled(false)
	l.Styles.Title = titleStyle
	l.Styles.PaginationStyle = paginationStyle
	l.Styles.HelpStyle = helpStyle

	return Model{list: l}
}

// SetWidth sets the width of the list
func (m *Model) SetWidth(width int) {
	m.list.SetWidth(width)
}

// SetHeight sets the height of the list
func (m *Model) SetHeight(height int) {
	m.list.SetHeight(height)
}

// SelectedItem returns the currently selected item
func (m Model) SelectedItem() list.Item {
	return m.list.SelectedItem()
}

// HasChoice returns true if the user has made a choice
func (m Model) HasChoice() bool {
	return m.choice != ""
}

// GetChoice returns the user's choice
func (m Model) GetChoice() string {
	return m.choice
}

// ClearChoice clears the choice
func (m *Model) ClearChoice() {
	m.choice = ""
}

// Run runs the list selection and returns the chosen item
func (m Model) Run() (string, error) {
	p := tea.NewProgram(m)
	finalModel, err := p.Run()
	if err != nil {
		return "", err
	}

	finalM, ok := finalModel.(Model)
	if !ok {
		return "", fmt.Errorf("unexpected model type")
	}

	if finalM.quitting && finalM.choice == "" {
		return "", fmt.Errorf("user quit without selection")
	}

	return finalM.choice, nil
}
