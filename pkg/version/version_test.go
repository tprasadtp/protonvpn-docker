package version

import (
	"encoding/json"
	"testing"
)

func TestJSON(t *testing.T) {
	t.Parallel()
	v := Get()
	out, err := json.MarshalIndent(v, "", "\t")
	if err != nil {
		t.Error("Failed to marshal JSON")
	}
	if out == nil {
		t.Error("JSON Marshal is empty")
	}
}

func TestGetshort(t *testing.T) {
	t.Parallel()
	want := "0.0.0+undefined"
	version = "v0.0.0+undefined"
	got := GetShort()
	if got != want {
		t.Errorf("got=%s, want=%s", got, want)
	}
}

func TestGetUA(t *testing.T) {
	t.Parallel()
	got := GetUserAgent()
	if got == "" {
		t.Error("got empty string for user agent")
	}
}

func TestGetShortOverride(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name    string
		version string
		expect  string
	}{
		{
			name:    "with-prefix",
			version: "v1.22.333+dev",
			expect:  "1.22.333+dev",
		},
		{
			name:    "without-prefix",
			version: "1.22.333+dev",
			expect:  "1.22.333+dev",
		},
		{
			name:    "empty",
			version: "",
			expect:  "",
		},
		{
			name:    "non-semver",
			version: "2022-01-31.2",
			expect:  "2022-01-31.2",
		},
		{
			name:    "non-semver-with-prefix",
			version: "v2022-01-31.2",
			expect:  "2022-01-31.2",
		},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			version = tc.version
			got := GetShort()
			if got != tc.expect {
				t.Errorf("got=%v, expected=%v", got, tc.expect)
			}
		})
	}
}
