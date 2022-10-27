package color

import (
	"os"

	"golang.org/x/term"
)

// IsStderrColorable detects whether true colored(24 bit) output
// can be enabled for [os.Stdout].
//
// This supports both [CLICOLOR] and [NO_COLOR] standards
//
//   - Argument 'colorMode' always takes priority.
//   - If colorMode is 'never', returns 'false'
//   - If colorMode is 'always' or 'force', returns 'true'
//   - You should probably map this variable to your cli's --color flag.
//
// [NO_COLOR]: https://no-color.org/
// [CLICOLOR]: https://bixense.com/clicolors/
func IsStdoutColorable(colorMode string) bool {
	return isColorable(colorMode, term.IsTerminal(int(os.Stdout.Fd())))
}

// IsStderrColorable detects whether true color(24 bit) output
// can be enabled for [os.Stderr].
//
// This supports both "[CLICOLOR]" and "[NO_COLOR]" standards
//
//   - Argument 'colorMode' always takes priority.
//   - If colorMode is 'never', returns 'false'
//   - If colorMode is 'always' or 'force', returns 'true'
//   - You should probably map this variable to your cli's --color flag.
//   - If you specify colorMode string to other than above specified, it is ignored.
//
// [NO_COLOR]: https://no-color.org/
// [CLICOLOR]: https://bixense.com/clicolors/
func IsStderrColorable(colorMode string) bool {
	return isColorable(colorMode, term.IsTerminal(int(os.Stderr.Fd())))
}
