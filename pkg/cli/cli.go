// Package cli provides a wrapper around github.com/spf13/cobra
// which handles common tasks like version command, help text,
// command completion, manpages and documentation generation
// and common flags.
package cli

import (
	"github.com/spf13/cobra"
	"github.com/tprasadtp/pkg/version"
)

// New returns a new CLI with all bells and whistles attached.
// If built with docs tag, this root command includes hidden command
// 'docs' and subcommands manpages and markdown which can be used
// to generate manpages and documentation. Its best to let go generate
// generate these. You can use snippet below in you 'main.go' file.
// Please ensure to have directories already created, as docs sub commands
// will not do it fo you.
//
//		// go:generate go run -tags docs main.go completion bash completion/<name>.bash
//		// go:generate go run -tags docs main.go completion fish completion/<name>.fish
//		// go:generate go run -tags docs main.go completion zsh completion/<name>.zsh
//		// go:generate go run -tags docs main.go completion pwsh completion/<name>.ps1
//
//	  	// Generate Manpages and Markdown docs
//		// go:generate go run -tags docs main.go docs manpages manpages
//		// go:generate go run -tags docs main.go docs markdown docs/content/manual
func New(name, shortDesc, longDesc string, hasCompletionCmd bool, commands ...*cobra.Command) *cobra.Command {
	rootCmd := &cobra.Command{
		// Let sub commands handle each shell.
		// its better for documentation.
		CompletionOptions: cobra.CompletionOptions{
			DisableDefaultCmd: true,
		},
		Use:               name,
		Version:           version.GetShort(),
		Short:             shortDesc,
		Long:              longDesc,
		DisableAutoGenTag: true,
		Args:              cobra.NoArgs,
	}

	if len(commands) > 0 {
		rootCmd.AddCommand(commands...)
	}
	if hasCompletionCmd {
		rootCmd.AddCommand(NewCompletionCmd(name, false))
	}
	// This changes based on build tag.
	// If used with build tag docs, returns cobra command
	// which implements two subcommands, otherwise returns nil.
	if docsCmd := getDocsCmd(name); docsCmd != nil {
		rootCmd.AddCommand(docsCmd)
	}
	rootCmd.AddCommand(NewVersionCmd(name))
	return rootCmd
}
