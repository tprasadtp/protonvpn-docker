// Package version is a helper for processing
// VCS, build, and runtime information of the binary.
// This is not meant to be used directly except for injecting
// build information.
// You can inject build time and runtime info via ld flags.
package version

import (
	"fmt"
	"runtime"
	"strings"
)

// Can override these at compile time
var (
	// version is usually the git tag. SHOULD be semver compatible.
	//
	// You can override at build time using
	// 		-X github.com/pkg/version.version = "your-desired-version"
	version string = "v0.0.0+undefined"
	// commit is git commit sha1 hash
	//
	// You can override at build time using
	// 		-X github.com/pkg/version.commit = "commit-hash"
	commit string = "da39a3ee5e6b4b0d3255bfef95601890afd80709"
	// buildDate is build date.
	// For reproducible builds, set this to source epoch or commit date.
	//
	// You can override at build time using
	// 		-X github.com/pkg/version.buildDate = "build-date-in-format"
	buildDate string = "1970-01-01T00:00+00:00"
	// HTTP user agent if used. This should be precomputed at build time.
	// Defaults to 'go/<go-version>/GOOS/GOARCH'
	//
	// You can override at build time using
	// 		-X github.com/pkg/version.userAgent = "user-agent"
	userAgent string = fmt.Sprintf("go/%s/%s/%s", runtime.Version(), runtime.GOOS, runtime.GOARCH)
)

// Info describes the build, revision and runtime information.
type Info struct {
	// Version  indicates which version of the binary is running.
	// In most cases this should be semver compatible string.
	Version string `json:"version" yaml:"version"`
	// GitCommit indicates which git sha1 commit hash.
	GitCommit string `json:"gitCommit" yaml:"gitCommit"`
	// BuildDate date of the build.
	// You can set this to CommitDate to get truly reproducible and verifiable builds.
	BuildDate string `json:"buildDate" yaml:"buildDate"`
	// GoVersion version of Go runtime.
	GoVersion string `json:"goVersion" yaml:"goVersion"`
	// OperatingSystem this is operating system in GOOS
	Os string `json:"os" yaml:"os"`
	// Architecture this is system architecture in GOARCH
	Arch string `json:"arch" yaml:"arch"`
	// Compiler Go compiler. This is useful in determining if binary
	// was built using CGO.
	Compiler string `json:"compiler" yaml:"compiler"`
}

// Get returns version information. This usually relies on
// build tools injecting version info via ld flags.
func Get() Info {
	return Info{
		Version:   strings.TrimPrefix(version, "v"),
		GitCommit: commit,
		BuildDate: buildDate,
		GoVersion: runtime.Version(),
		Os:        runtime.GOOS,
		Arch:      runtime.GOARCH,
		Compiler:  runtime.Compiler,
	}
}

// GetShort returns just the version information.
// usually in semver compatible <git-tag>+<build-medatata> format.
func GetShort() string {
	return strings.TrimPrefix(version, "v")
}

// GetUserAgent returns HTTP User-Agent string.
func GetUserAgent() string {
	return userAgent
}
