package metadata

import (
	"context"
	"net/netip"
	"strings"
)

type Server struct {
	Name        string `json:"name" yaml:"name"`
	DNS         string `json:"dns" yaml:"dns"`
	ExitCountry string `json:"exit_country" yaml:"exit_country"`
	Tier        int    `json:"tier,omitempty" yaml:"tier,omitempty"`
	Nodes       []Node `json:"nodes,omitempty" yaml:"nodes,omitempty"`
	Online      bool   `json:"online,omitempty" yaml:"online,omitempty"`
}

type Node struct {
	Endpoint  netip.Addr `json:"endpoint" yaml:"endpoint"`
	PublicKey string     `json:"public_key" yaml:"public_key"`
	Online    bool       `json:"online,omitempty" yaml:"online,omitempty"`
}

type Features struct {
	Streaming  bool `json:"streaming,omitempty" yaml:"streaming,omitempty"`
	P2P        bool `json:"p2p,omitempty" yaml:"p2p,omitempty"`
	IPv6       bool `json:"ipv6,omitempty" yaml:"ipv6,omitempty"`
	Tor        bool `json:"tor,omitempty" yaml:"tor,omitempty"`
	SecureCore bool `json:"secure_core,omitempty" yaml:"secure_core,omitempty"`
}

// Fetch metadata and refresh cache.
func Fetch(ctx context.Context, endpoint, server string) {
	server = strings.ReplaceAll(server, "#", "-")
}
