package cli

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

// BashCompletionCommand returns a cobra command for generating bash completion.
func NewBashCompletionCmd(programName string) *cobra.Command {
	cmd := &cobra.Command{
		Use:               "bash [FILE]",
		Args:              cobra.MaximumNArgs(1),
		SilenceUsage:      true,
		DisableAutoGenTag: true,
		Short:             "Generate autocompletion for bash",
		Long: fmt.Sprintf(`Generate autocompletion for bash.

To load completions in your current bash session:
    source <(%[1]s completion bash)

To load completions for every bash session, execute once:
- Linux:
    %[1]s completion bash /etc/bash_completion.d/%[1]s
- MacOS:
    %[1]s completion bash /usr/local/etc/bash_completion.d/%[1]s
`, programName),
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) == 0 {
				return cmd.Root().GenBashCompletionV2(os.Stdout, true)
			} else {
				if args[0] == "" || args[0] == "-" {
					return cmd.Root().GenBashCompletionV2(os.Stdout, true)
				}
				return cmd.Root().GenBashCompletionFileV2(args[0], true)
			}
		},
	}
	return cmd
}
