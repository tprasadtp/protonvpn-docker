package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"strings"

	"github.com/Masterminds/semver/v3"
	"github.com/spf13/cobra"
)

func main() {
	ctx, _ := signal.NotifyContext(context.Background(), os.Interrupt)
	root := &cobra.Command{
		Use:               "builder",
		Short:             "Builder for protonwire docker images",
		DisableAutoGenTag: true,
		SilenceUsage:      true,
		CompletionOptions: cobra.CompletionOptions{
			DisableDefaultCmd: true,
		},
	}
	root.AddCommand(
		newSemverCmd(),
	)

	if err := root.ExecuteContext(ctx); err != nil {
		os.Exit(1)
	}
}

func newSemverCmd() *cobra.Command {
	semverCmd := &cobra.Command{
		Use:   "semver",
		Short: "Semantic version parser",
	}
	versionCmd := &cobra.Command{
		Use:   "version VERSION",
		Args:  cobra.ExactArgs(1),
		Short: "Prints semver if VERSION is valid",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runE(cmd, args, "version")
		},
	}
	isPreRelCmd := &cobra.Command{
		Use:   "is-pre-release VERSION",
		Args:  cobra.ExactArgs(1),
		Short: "Prints true if VERSION is a pre-release otherwise print false",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runE(cmd, args, "is-pre-release")
		},
	}

	semverCmd.AddCommand(
		versionCmd,
		cmdExtract("major"),
		cmdExtract("minor"),
		cmdExtract("patch"),
		cmdExtract("pre-release"),
		cmdExtract("build-version"),
		cmdBump("major"),
		cmdBump("minor"),
		cmdBump("patch"),
		isPreRelCmd,
	)

	return semverCmd
}

func cmdExtract(name string) *cobra.Command {
	cmd := &cobra.Command{
		Use:   fmt.Sprintf("%s VERSION", name),
		Short: fmt.Sprintf("Extract %s version from VERSION", name),
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return runE(cmd, args, name)
		},
	}
	return cmd
}

func cmdBump(name string) *cobra.Command {
	cmd := &cobra.Command{
		Use:   fmt.Sprintf("%s VERSION", name),
		Short: fmt.Sprintf("Bump %s version from VERSION", name),
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return runE(cmd, args, fmt.Sprintf("bump-%s", name))
		},
	}
	return cmd
}

func runE(cmd *cobra.Command, args []string, typ string) error {
	version, err := semver.NewVersion(strings.TrimPrefix(args[0], "v"))
	if err != nil {
		return fmt.Errorf("Version(%s) is invalid: %w", args[0], err)
	}

	switch typ {
	case "version":
		fmt.Fprintln(cmd.OutOrStdout(), version.String())
	case "major":
		fmt.Fprintln(cmd.OutOrStdout(), version.Major())
	case "minor":
		fmt.Fprintln(cmd.OutOrStdout(), version.Minor())
	case "patch":
		fmt.Fprintln(cmd.OutOrStdout(), version.Patch())
	case "pre-release":
		fmt.Fprintln(cmd.OutOrStdout(), version.Prerelease())
	case "build":
		fmt.Fprintln(cmd.OutOrStdout(), version.Metadata())
	case "bump-major":
		fmt.Fprintln(cmd.OutOrStdout(), version.IncMajor().String())
	case "bump-minor":
		fmt.Fprintln(cmd.OutOrStdout(), version.IncMinor().String())
	case "bump-patch":
		fmt.Fprintln(cmd.OutOrStdout(), version.IncPatch().String())
	case "is-pre-release":
		if version.Prerelease() != "" {
			fmt.Fprintln(cmd.OutOrStdout(), "true")
		} else {
			fmt.Fprintln(cmd.OutOrStdout(), "false")
		}
	default:
		return fmt.Errorf("unknown function: %s", typ)
	}
	return nil
}
