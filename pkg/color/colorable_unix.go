//go:build unix

package color

import (
	"os"
	"strings"
)

func isColorable(colorMode string, isTerminal bool) bool {
	switch strings.TrimSpace(strings.ToLower(colorMode)) {
	case "never":
		return false
	case "force", "always":
		return true
	}

	// CLICOLOR_FORCE != 0 and CLICOLOR_FORCE is not empty
	if os.Getenv("CLICOLOR_FORCE") != "0" &&
		len(strings.TrimSpace(os.Getenv("CLICOLOR_FORCE"))) > 0 {
		return true
	}

	// CLICOLOR == 0 or NO_COLOR is set and not empty
	if len(strings.TrimSpace(os.Getenv("NO_COLOR"))) > 0 ||
		os.Getenv("CLICOLOR") == "0" {
		return false
	}

	// If term is dumb or linux or screen,  colors are disabled
	switch t := os.Getenv("TERM"); {
	// Technically linux console supports 16 bit color
	// but we will ignore it as its mostly used in tty's and
	// should not be colored for better readability.
	case t == "linux":
		return false
	case t == "dumb":
		return false
	case strings.HasPrefix(t, "screen"):
		return false
	}

	return isTerminal
}
