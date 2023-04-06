package config

import (
	"context"
	"errors"
	"fmt"
	"net"
	"net/url"

	"github.com/tprasadtp/protonwire/internal/ipcheck"
)

const DefaultMetadataEndpoint = "https://protonwire-api.vercel.app/v1/server/"

const DefaultIPCheckEndpoint = "https://protonwire-api.vercel.app/v1/client/ip"

const DefaultIPCheckInterval uint = 120

type Config struct {
	Server              string      `json:"server,omitempty" yaml:"server,omitempty"`
	WireguardPrivateKey string      `json:"wireguard_private_key,omitempty" yaml:"wireguard_private_key,omitempty"`
	WireguardInterface  string      `json:"wireguard_interface,omitempty" yaml:"wireguard_interface,omitempty"`
	IPCheckEndpoint     string      `json:"ip_check_endpoint,omitempty" yaml:"ip_check_endpoint,omitempty"`
	IPCheckInterval     uint        `json:"ip_check_interval,omitempty" yaml:"ip_check_interval,omitempty"`
	MetadataEndpoint    string      `json:"metadata_endpoint,omitempty" yaml:"metadata_endpoint,omitempty"`
	EnableKillSwitch    bool        `json:"enable_kill_switch,omitempty" yaml:"enable_kill_switch,omitempty"`
	ExcludeNetworks     []net.IPNet `json:"exclude_networks,omitempty" yaml:"exclude_networks,omitempty"`
	IsService           bool        `json:"is_service,omitempty" yaml:"is_service,omitempty"`
	SkipDnsConfig       bool        `json:"skip_dns_config,omitempty" yaml:"skip_dns_config,omitempty"`
	SkipRouteConfig     bool        `json:"skip_route_config,omitempty" yaml:"skip_route_config,omitempty"`
	IsTor               bool        `json:"is_tor,omitempty" yaml:"is_tor,omitempty"`
	IsStreaming         bool        `json:"is_streaming,omitempty" yaml:"is_streaming,omitempty"`
	IsP2P               bool        `json:"is_p_2_p,omitempty" yaml:"is_p_2_p,omitempty"`
	IsSecureCore        bool        `json:"is_secure_core,omitempty" yaml:"is_secure_core,omitempty"`
}

func (c *Config) Validate(ctx context.Context) error {
	var err error
	if _, e := url.Parse(c.IPCheckEndpoint); e != nil {
		err = errors.Join(err, e)
	}

	if _, e := url.Parse(c.MetadataEndpoint); e != nil {
		err = errors.Join(err, e)
	}

	if err != nil {
		return fmt.Errorf("protonwire(config): invalid config: %w", err)
	}

	_, err = ipcheck.Invoke(ctx, c.IPCheckEndpoint)
	if err != nil {
		err = errors.Join(err)
	}

	if err != nil {
		return fmt.Errorf("protonwire(config): invalid config: %w", err)
	}
	return nil
}
