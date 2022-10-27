package cli

import (
	"github.com/spf13/cobra"
)

// NewDocsCmd returns commands to generate manpages and markdown docs.
func NewDocsCmd(programName string, hidden bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:               "docs",
		Aliases:           []string{"gen"},
		Args:              cobra.NoArgs,
		Hidden:            hidden,
		DisableAutoGenTag: true,
		Short:             "Generate docs, manpages etc.",
		Long: `Generates documentation, manpages and API docs (if available)
This command is typically not available unless built with docs tag,
and should only be used for development purposes and provides
no stability guarantees.
`,
	}
	cmd.AddCommand(NewManpagesCmd(programName))
	cmd.AddCommand(NewMarkdownCmd(programName))
	return cmd
}
