package templates

import "embed"

// FS is the embedded filesystem containing all templates.
//
//go:embed all:*
var FS embed.FS
