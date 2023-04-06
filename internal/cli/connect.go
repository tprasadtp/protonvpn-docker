package cli

import "github.com/spf13/cobra"

// Provides connect command
func ConnectCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "connect",
		Aliases: []string{"c"},
		Short:   "Connect to a server",
		Args:    cobra.ExactArgs(1),
		GroupID: "Manage Connection",
	}

	return cmd
}
