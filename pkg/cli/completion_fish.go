package cli

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

// FishCompletionCmd returns a cobra command for generating fish completion.
func NewFishCompletionCmd(programName string) *cobra.Command {
	cmd := &cobra.Command{
		Use:               "fish [FILE]",
		Args:              cobra.MaximumNArgs(1),
		SilenceUsage:      true,
		DisableAutoGenTag: true,
		Short:             "Generate autocompletion for fish",
		Long: fmt.Sprintf(`Generate autocompletion for fish.

To load completions in your current fish session:
    %[1]s completion fish | source
To load completions for every fish session, execute once:
    %[1]s completion fish ~/.config/fish/completions/%[1]s.fish

You will need to start a new shell for this setup to take effect.
`, programName),
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) == 0 {
				return cmd.Root().GenFishCompletion(os.Stdout, true)
			} else {
				if args[0] == "" || args[0] == "-" {
					return cmd.Root().GenFishCompletion(os.Stdout, true)
				}
				return cmd.Root().GenFishCompletionFile(args[0], true)
			}
		},
	}
	return cmd
}
