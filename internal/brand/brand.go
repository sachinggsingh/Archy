package brand

import "strings"

// Banner is the ASCII art shown when Archy starts.
func Banner() string {
	// Clean, modern ASCII art banner
	return strings.TrimSpace(`
 █████╗ ██████╗  ██████╗██╗  ██╗██╗   ██╗
██╔══██╗██╔══██╗██╔════╝██║  ██║╚██╗ ██╔╝
███████║██████╔╝██║     ███████║ ╚████╔╝ 
██╔══██║██╔══██╗██║     ██╔══██║  ╚██╔╝  
██║  ██║██║  ██║╚██████╗██║  ██║   ██║   
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   
`)
}
