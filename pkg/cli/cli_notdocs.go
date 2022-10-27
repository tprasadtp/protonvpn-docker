//go:build !docs && !doc

package cli

import "github.com/spf13/cobra"

// getDocsCmd returns nil on builds not tagged docs
// otherwise it returns command implementing docs
// command with subcommands generating manpages and markdown
// documentation.
func getDocsCmd(programName string) *cobra.Command {
	return nil
}
