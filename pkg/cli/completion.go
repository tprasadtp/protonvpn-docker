package cli

import (
	"github.com/spf13/cobra"
)

// NewCompletionCmd returns a cobra command named completion
// with all supported shells as subcommands.
func NewCompletionCmd(programName string, hidden bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:               "completion SHELL [FILE]",
		Short:             "Generate shell autocompletion",
		Aliases:           []string{"complete", "compgen"},
		Args:              cobra.NoArgs,
		Hidden:            hidden,
		SilenceUsage:      true,
		DisableAutoGenTag: true,
	}
	cmd.AddCommand(NewBashCompletionCmd(programName))
	cmd.AddCommand(NewFishCompletionCmd(programName))
	cmd.AddCommand(NewZshCompletionCmd(programName))
	cmd.AddCommand(NewPwshCompletionCmd(programName))
	return cmd
}
