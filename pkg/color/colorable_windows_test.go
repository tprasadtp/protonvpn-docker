//go:build windows

package color

import (
	"os"
	"testing"
)

func TestConditions(t *testing.T) {
	t.Parallel()
	origNoColor, origNoColorSet := os.LookupEnv("NO_COLOR")
	origClicolor, origClicolorSet := os.LookupEnv("CLICOLOR")
	origClicolorForce, origClicolorForceSet := os.LookupEnv("CLICOLOR_FORCE")
	origTerm, origTermSet := os.LookupEnv("TERM")

	t.Cleanup(func() {
		if origNoColorSet {
			os.Setenv("NO_COLOR", origNoColor)
		} else {
			os.Unsetenv("NO_COLOR")
		}

		if origClicolorSet {
			os.Setenv("CLICOLOR", origClicolor)
		} else {
			os.Unsetenv("CLICOLOR")
		}

		if origTermSet {
			os.Setenv("CLICOLOR_FORCE", origClicolorForce)
		} else {
			os.Unsetenv("CLICOLOR_FORCE")
		}
	})

	for _, tc := range colorableTestCases {
		t.Run(tc.Name, func(t *testing.T) {
			if tc.CLICOLOR_FORCE == "empty" {
				os.Unsetenv("CLICOLOR_FORCE")
			} else {
				os.Setenv("CLICOLOR_FORCE", tc.CLICOLOR_FORCE)
			}

			if tc.CLICOLOR == "empty" {
				os.Unsetenv("CLICOLOR")
			} else {
				os.Setenv("CLICOLOR", tc.CLICOLOR)
			}

			if tc.NO_COLOR == "empty" {
				os.Unsetenv("NO_COLOR")
			} else {
				os.Setenv("NO_COLOR", tc.NO_COLOR)
			}

			val := isColorable(tc.ColorMode, tc.Terminal)
			if tc.Expect != val {
				t.Errorf("%s => got=%v, want=%v", tc.Name, val, tc.Expect)
			}
		})
	}
}
