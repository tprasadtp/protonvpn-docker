package cli

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

// ZshCompletionCmd returns a cobra command for generating zsh completion.
func NewZshCompletionCmd(programName string) *cobra.Command {
	cmd := &cobra.Command{
		Use:               "zsh",
		Args:              cobra.MaximumNArgs(1),
		SilenceUsage:      true,
		DisableAutoGenTag: true,
		Short:             "Generate autocompletion for zsh",
		Long: fmt.Sprintf(`Generate autocompletion for zsh.

To load completions in your current zsh session:
    source <(%[1]s completion zsh)

To load completions for every zsh session, execute once:
	%[1]s completion zsh --output "${fpath[1]}/_%[1]s

You will need to start a new shell for this setup to take effect.
`, programName),
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) == 0 {
				return cmd.Root().GenZshCompletion(os.Stdout)
			} else {
				if args[0] == "" || args[0] == "-" {
					return cmd.Root().GenZshCompletion(os.Stdout)
				}
				return cmd.Root().GenZshCompletionFile(args[0])
			}
		},
	}
	return cmd
}
