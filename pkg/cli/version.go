package cli

import (
	"fmt"

	"github.com/spf13/cobra"
)

type versionCmdOpts struct {
	json     bool
	short    bool
	template string
}

func (o versionCmdOpts) run(cmd *cobra.Command, args []string) error {
	return nil
}

func NewVersionCmd(programName string) *cobra.Command {
	o := versionCmdOpts{}
	cmd := &cobra.Command{
		Use:               "version",
		Args:              cobra.NoArgs,
		Short:             "Show version information",
		DisableAutoGenTag: true,
		RunE:              o.run,
	}

	cmd.Long = fmt.Sprintf(`Show version of %[1]s

When using the --template flag the following properties are
available to use in the template:

- .Version contains the semantic version of %[1]s
- .GitCommit is the git commit
- .GitTreeState is the state of the git tree when %[1]s was built
- .GoVersion contains the version of Go that %[1]s was compiled with
- .Os is Operating system (GOOS)
- .Arch is system architecture (GOARCH)
- .Compiler is the Go compiler used to build the binary.

`, programName)

	cmd.Flags().StringVarP(&o.template, "template", "t", "", "output as template")
	cmd.Flags().BoolVarP(&o.json, "json", "j", false, "output as JSON")
	cmd.Flags().BoolVarP(&o.short, "short", "s", false, "only show version string")
	// Mark flags as exclusive.
	cmd.MarkFlagsMutuallyExclusive("template", "json", "short")
	return cmd
}
