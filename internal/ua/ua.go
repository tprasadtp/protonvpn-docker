package ua

import (
	"fmt"

	"github.com/tprasadtp/pkg/version"
)

// user agent cached value.
var userAgent string

//nolint:noinit // ignore
func init() {
	userAgent = buildUserAgent()
}

// Pre-build UA as it does not change
func buildUserAgent() string {
	v := version.GetInfo()
	return fmt.Sprintf("protonwire/%s/%s/%s", v.Version, v.Os, v.Arch)
}

// Returns User-Agent Header suitable fo using with Set.
func Header() (string, string) {
	return "User-Agent", userAgent
}
