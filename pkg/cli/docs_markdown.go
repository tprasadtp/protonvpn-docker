package cli

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/spf13/cobra"
	"github.com/spf13/cobra/doc"
)

// generateMarkdownDocs Generate markdown docs
// with custom front matter and summary.
func generateMarkdownDocs(cmd *cobra.Command, docsDest string) error {
	for _, c := range cmd.Commands() {
		if !c.IsAvailableCommand() || c.IsAdditionalHelpTopicCommand() {
			continue
		}
		if err := generateMarkdownDocs(c, docsDest); err != nil {
			return err
		}
	}

	basename := strings.Replace(cmd.CommandPath(), " ", "-", -1)
	filename := filepath.Join(docsDest, basename)
	f, err := os.Create(filename + ".md")
	if err != nil {
		return err
	}
	defer f.Close()

	frontMatter := fmt.Sprintf(`---
title: %s
layout: manual
summary: %s
---
`, basename, cmd.Short)

	if _, err := io.WriteString(f, frontMatter); err != nil {
		return err
	}
	if err := doc.GenMarkdownCustom(cmd, f, linkHandler); err != nil {
		return err
	}
	return nil
}

func linkHandler(name string) string {
	return fmt.Sprintf("./%s", strings.TrimSuffix(name, ".md"))
}

// NewMarkdownCmd returns a cobra command for
// generating markdown docs.
func NewMarkdownCmd(programName string) *cobra.Command {
	cmd := &cobra.Command{
		Use:               "markdown DIRECTORY",
		Aliases:           []string{"md", "website"},
		Args:              cobra.ExactArgs(1),
		SilenceUsage:      true,
		DisableAutoGenTag: true,
		Short:             "Generate markdown documentation",
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) == 1 {
				output := args[0]
				if len(strings.TrimSpace(output)) < 1 {
					return fmt.Errorf("output directory specified is empty")
				}
				return generateMarkdownDocs(cmd.Root(), output)
			}
			return fmt.Errorf("no output directory specified")
		},
	}
	return cmd
}
