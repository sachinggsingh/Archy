# Archy ✨

**Your Architect Assistant** – A powerful TUI-based CLI tool to scaffold production-ready project structures with ease.

![Archy TUI](https://raw.githubusercontent.com/sachinggsingh/archy/main/assets/banner.png) *(Placeholder for your actual banner/screenshot)*

## 🚀 Overview

Archy is designed to help developers skip the repetitive boilerplate setup and jump straight into coding. It provides a beautiful, interactive terminal interface to select your preferred language, framework, and architecture, then generates a complete, clean directory structure for you.

## ✨ Features

- **Interactive TUI**: Built with Bubble Tea, Lip Gloss, and Bubbles for a premium terminal experience.
- **Smart Scaffolding**: Not just empty folders - it generates working boilerplate scripts, configuration files, and basic routing.
- **Multi-Language Support**:
  - **JavaScript**: Express (Monolith & Microservice)
  - **Python**: FastAPI, Flask, Django (Monolith & Microservice)
- **Modular Templates**: Easily extensible template system.

## 🛠 Installation

### Prerequisites
- [Go](https://golang.org/doc/install) (version 1.25.3 or higher recommended)

### Build from source
```bash
git clone https://github.com/sachinggsingh/archy.git
cd archy
go build ./cmd/archy
```

## 📖 Usage

Run Archy directly from your terminal:

```bash
go run ./cmd/archy/main.go
```

Follow the 4-step wizard:
1.  **Select Language**: Choose between JavaScript and Python.
2.  **Select Framework**: Pick your favorite framework (e.g., Express, FastAPI).
3.  **Select Architecture**: Choose between Monolith (standard) or Microservice (distributed).
4.  **Project Name**: Enter the directory name for your new project.

## 📁 Project Structure

Archy follows a clean and modular internal architecture:

```text
archy/
├── cmd/archy/        # CLI Entry point
├── internal/
│   ├── brand/       # Branding and ASCII art
│   ├── components/  # Reusable TUI components (List, Input, Spinner)
│   ├── generator/   # Scaffolding logic
│   ├── tui/         # Main TUI state and logic
├── templates/       # Language-specific project templates
```

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to add new templates or improve the TUI.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
