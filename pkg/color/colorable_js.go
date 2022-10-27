//go:build js
package color

import (
	"golang.org/x/term"
)

func isColorable(colorMode string, isTerminal bool) bool {
	return false
}
