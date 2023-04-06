package cli

import (
	"github.com/spf13/cobra"
	"github.com/tprasadtp/pkg/cli/factory"
)

// CLI root command.
func RootCmd() *cobra.Command {
	root := &cobra.Command{
		Use:   "protonwire [OPTIONS]",
		Short: "ProtonVPN CLI client",
	}
	root.AddCommand(
		factory.NewCompletionCmd(),
		factory.NewDocsCmd(),
		factory.NewVersionCmd(),
		ConnectCmd(),
	)
	return root
}
