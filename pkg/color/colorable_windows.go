//go:build windows

package color

import (
	"golang.org/x/sys/windows"
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

	_, _, buildNumber := windows.RtlGetNtVersionNumbers()

	// No true color support before Windows build 14931.
	if buildNumber < 14931 {
		return true
	}

	return isTerminal
}
