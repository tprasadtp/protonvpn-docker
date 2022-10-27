package cli_test

import (
	"bytes"
	"io"
	"testing"

	"github.com/tprasadtp/pkg/cli"
)

func TestVersionCommand(t *testing.T) {
	cmd := cli.NewVersionCmd("test")
	b := bytes.NewBufferString("")
	cmd.SetOut(b)

	err := cmd.Execute()
	out, _ := io.ReadAll(b)
	if err != nil {
		t.Errorf("expected=nil, got=%e", err)
	}
	if out == nil {
		t.Error("expected=some output, got empty!")
	}
}
