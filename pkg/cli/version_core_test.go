package cli_test

import (
	"runtime"
	"testing"
)

func TestTemplateValid(t *testing.T) {
	t.Parallel()
	tests := []struct {
		name     string
		template string
		expect   string
	}{
		{
			name:     "Version",
			template: "{{.Version}}",
			expect:   "v0.0.0+dev",
		},
		{
			name:     "GitCommit",
			template: "{{.GitCommit}}",
			expect:   "da39a3ee5e6b4b0d3255bfef95601890afd80709",
		},
		{
			name:     "BuildDate",
			template: "{{.BuildDate}}",
			expect:   "1970-01-01T00:00+00:00",
		},
		{
			name:     "GitTreeState",
			template: "{{.GitTreeState}}",
			expect:   "unknown",
		},
		{
			name:     "Compiler",
			template: "{{.Compiler}}",
			expect:   runtime.Compiler,
		},
		{
			name:     "GoVersion",
			template: "{{.GoVersion}}",
			expect:   runtime.Version(),
		},
		{
			name:     "Os",
			template: "{{.Os}}",
			expect:   runtime.GOOS,
		},
		{
			name:     "Arch",
			template: "{{.Arch}}",
			expect:   runtime.GOARCH,
		},
		{
			name:     "NO_VARIABLES",
			template: "NO_VARIABLES",
			expect:   "NO_VARIABLES",
		},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {

		})
	}
}

func TestTemplateInvalid(t *testing.T) {
	t.Parallel()
	tests := []struct {
		name     string
		template string
		expect   string
	}{
		{
			name:     "Unclosed Bracket",
			template: "{{.Version}",
		},
		{
			name:     "No doT",
			template: "{{GitCommit}}",
		},
		{
			name:     "Empty",
			template: "",
		},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
		})
	}
}
