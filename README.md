<div align="center">

<h1>⚡ Archy</h1>

<p><strong>A powerful TUI-based CLI tool to scaffold production-ready project structures — instantly.</strong></p>

[![Go Version](https://img.shields.io/badge/Go-1.25.3+-00ADD8?style=flat-square&logo=go)](https://golang.org/doc/install)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)](CONTRIBUTING.md)

<!-- <video src="./assets/archy-video.mp4" width="700" controls></video> -->
<br/>
<img src="./assets/archy-tui.png" alt="Archy TUI Demo" width="700"/>

</div>



## 📖 Overview

Archy eliminates the tedious boilerplate setup that slows down every new project. Through an elegant, interactive terminal interface, it guides you through selecting your language, framework, and architecture — then generates a complete, production-ready directory structure in seconds.

> Stop copy-pasting folder skeletons. Start building.

---

## ✨ Features

| Feature | Description |
|---|---|
| **Interactive TUI** | Built with Bubble Tea, Lip Gloss, and Bubbles for a premium terminal experience |
| **Smart Scaffolding** | Generates working boilerplate scripts, config files, and basic routing — not just empty folders |
| **Multi-Language Support** | JavaScript, TypeScript, Python, and Go |
| **Dual Architecture Modes** | Choose between Monolith and Microservice patterns |
| **Modular Templates** | Easily extensible template system for adding new languages or frameworks |

---

## 🌐 Language & Framework Support

### JavaScript

| Framework | Monolith | Microservice |
|---|:---:|:---:|
| Http  | ✅ | ✅ |
| Express | ✅ | ✅ |

### TypeScript

| Framework | Monolith | Microservice |
|---|:---:|:---:|
| Http | ✅ | ✅ |
| Express | ✅ | ✅ |
| Fastify | ✅ | ✅ |


### Python

| Framework | Monolith | Microservice |
|---|:---:|:---:|
| FastAPI | ✅ | ✅ |
| Flask | ✅ | ✅ |
| Django | ✅ | ✅ |

### Go

| Framework | Monolith | Microservice |
|---|:---:|:---:|
| Gin | ✅ | ✅ |
| Fiber | ✅ | ✅ |
| Echo | ✅ | ✅ |
| net/http (Standard Library) | ✅ | ✅ |
| gRPC + Protobuf | ✅ | ✅ |

---

## 🛠 Installation

### Prerequisites

- [Go](https://golang.org/doc/install) **v1.25.3 or higher**

### Install directly (Recommended)
```bash
go install github.com/sachinggsingh/Archy@latest
```

### Build from Source
```bash
# Clone the repository
git clone https://github.com/sachinggsingh/Archy.git

# Navigate into the project
cd Archy

# Build the binary
go build -o archy .
```

---

## 🚀 Usage

Run Archy directly from your terminal:

```bash
# From source
go run .

# Or run installed binary
Archy
```

Archy walks you through a simple **4-step wizard**:

```
Step 1 — Select Language     →  JavaScript, Python, or Go
Step 2 — Select Framework    →  Express / FastAPI / Flask / Django / Gin / Fiber / Echo / net/http / gRPC
Step 3 — Select Architecture →  Monolith or Microservice
Step 4 — Name Your Project   →  Enter the output directory name
```

Your scaffolded project will be generated in the current working directory. That's it — start coding.

---

## 📁 Project Structure

Archy itself follows a clean, modular internal architecture:

```
Archy/
├── main.go                 # CLI entry point (Root)
├── internal/
│   ├── brand/              # Branding & ASCII art
│   ├── components/         # Reusable TUI components (List, Input, Spinner)
│   ├── generator/          # Core scaffolding logic
│   └── tui/                # Main TUI state machine & logic
└── templates/              # Language & framework-specific project templates
    ├── templates.go        # Embedded filesystem entry point
    ├── node/               # Node.js (JS/TS) templates
    │   └── express/
    ├── python/             # Python (FastAPI/Flask/Django) templates
    └── golang/             # Go templates (Gin/Fiber/Echo/gRPC)
```

---

## 🔭 Roadmap

The following languages and ecosystems are on the radar for upcoming Archy releases. Community contributions toward these are especially welcome!

### ⚙️ C++

| Framework / Tool | Architecture | Notes |
|---|---|---|
| Crow | Monolith · Microservice | Fast C++ micro web framework inspired by Flask |
| Drogon | Monolith · Microservice | High-performance async HTTP/WebSocket framework |
| Oat++ | Monolith · Microservice | Modern C++ web framework with ORM-like features |
| CMake Project | Monolith | Bare-bones CMake + directory structure scaffold |
| gRPC (C++ server) | Microservice | Protobuf-based service scaffold with CMake integration |

### 🦀 Rust

| Framework / Tool | Architecture | Notes |
|---|---|---|
| Axum | Monolith · Microservice | Ergonomic, modular framework built on Tokio |
| Actix-Web | Monolith · Microservice | One of the fastest web frameworks in any language |
| Rocket | Monolith | Type-safe, batteries-included Rust web framework |
| Warp | Monolith · Microservice | Composable, filter-based HTTP framework |
| Tonic (gRPC) | Microservice | Async gRPC with Protobuf, built on Tokio |
| Cargo Workspace | Microservice | Multi-crate monorepo scaffold for distributed services |

> 💡 **Want to contribute one of these?** Check out the [Contributing](#-contributing) section below and open a PR — new templates are always welcome!

---

## 🤝 Contributing

Contributions are welcome and appreciated! Whether it's a new framework template, a bug fix, or a UX improvement — feel free to get involved.

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/add-rust-template`
3. Commit your changes: `git commit -m 'feat: add Rust + Axum template'`
4. Push to the branch: `git push origin feature/add-rust-template`
5. Open a Pull Request

> Please open an issue first for major changes so we can discuss the approach.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for full details.

---

<div align="center">

Made with ❤️ by [sachinggsingh](https://github.com/sachinggsingh)

*If Archy saves you time, consider giving it a ⭐ on [GitHub](https://github.com/sachinggsingh/Archy)!*

</div>