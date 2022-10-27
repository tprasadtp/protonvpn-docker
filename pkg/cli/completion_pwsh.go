package cli

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

// PowershellCompletionCmd returns a cobra command for
// generating PowershellCompletionCmd completion.
func NewPwshCompletionCmd(programName string) *cobra.Command {
	cmd := &cobra.Command{
		Use:               "powershell",
		Aliases:           []string{"pwsh", "ps"},
		Args:              cobra.MaximumNArgs(1),
		SilenceUsage:      true,
		DisableAutoGenTag: true,
		Short:             "Generate autocompletion for powershell",
		Long: fmt.Sprintf(`Generate autocompletion for powershell.

To load completions in your current shell session:
PS C:\> %[1]s completion powershell | Out-String | Invoke-Expression

To load completions for every new session, add the output of
the above command to your powershell profile.
`, programName),
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) == 0 {
				return cmd.Root().GenPowerShellCompletionWithDesc(os.Stdout)
			} else {
				if args[0] == "" || args[0] == "-" {
					return cmd.Root().GenPowerShellCompletionWithDesc(os.Stdout)
				}
				return cmd.Root().GenPowerShellCompletionFileWithDesc(args[0])
			}
		},
	}
	return cmd
}
