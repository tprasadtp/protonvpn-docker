package color

// ANSIColor is a color (0-15) as defined by the ANSI Standard.
type ANSIColor uint8

// ANSI color codes
const (
	ANSIBlack ANSIColor = iota
	ANSIRed
	ANSIGreen
	ANSIYellow
	ANSIBlue
	ANSIMagenta
	ANSICyan
	ANSIWhite
	ANSIBrightBlack
	ANSIBrightRed
	ANSIBrightGreen
	ANSIBrightYellow
	ANSIBrightBlue
	ANSIBrightMagenta
	ANSIBrightCyan
	ANSIBrightWhite
)
