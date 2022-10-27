package cli

import (
	"fmt"
	"strings"

	"github.com/spf13/cobra"
	cobradoc "github.com/spf13/cobra/doc"
)

// NewManpagesCmd returns a cobra command for
// generating manpages.
func NewManpagesCmd(programName string) *cobra.Command {
	header := cobradoc.GenManHeader{
		Title:   strings.ToUpper(programName),
		Section: "1",
	}
	cmd := &cobra.Command{
		Use:               "manpages DIRECTORY",
		Aliases:           []string{"man"},
		Args:              cobra.ExactArgs(1),
		SilenceUsage:      true,
		DisableAutoGenTag: true,
		Short:             "Generate manpages",
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) == 1 {
				output := args[0]
				if len(strings.TrimSpace(output)) < 1 {
					return fmt.Errorf("output directory is empty")
				}
				return cobradoc.GenManTree(cmd.Root(), &header, output)
			}
			return fmt.Errorf("no output directory specified")
		},
	}
	return cmd
}
