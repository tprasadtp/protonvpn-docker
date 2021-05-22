<!-- markdownlint-disable MD033 -->

<h1 align="center">protonvpn-docker</h1>

<p align="center">
  <a href="https://protonvpn.com" target="_blank" rel="noreferrer">
    <img src="https://static.prasadt.com/logos/proton/scalable/protonvpn-wide.svg" height="64" alt="protonvpn">
  </a>
  <a href="https://ghcr.io/tprasadtp/protonvpn" target="_blank" rel="noreferrer">
    <img src="https://static.prasadt.com/logos/software/docker/scalable/docker-engine-wide.svg" height="64" alt="docker">
  </a>
</p>

<!-- CI Badges -->

[![build](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/build.yml/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/build.yml)
[![release](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/release.yml/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/release.yml)
[![security](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/security.yml/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/security.yml)
[![releases](https://img.shields.io/github/v/tag/tprasadtp/protonvpn-docker?label=version&sort=semver&logo=semver&color=7f50a6&labelColor=3a3a3a)](https://github.com/tprasadtp/protonvpn-docker/releases/latest)
[![license](https://img.shields.io/github/license/tprasadtp/protonvpn-docker?logo=github&labelColor=3A3A3A)](https://github.com/tprasadtp/protonvpn-docker/blob/master/LICENSE)
![analytics](https://ga-beacon.prasadt.com/UA-101760811-3/github/protonvpn-docker)

## Docker Registries

- Images are published on [GitHub Container Registry][ghcr].

## Environment Variables

| Name | Required | Description
|---|---|---
| `PROTONVPN_TIER`          | Yes | Proton VPN Tier (0=Free, 1=Basic, 2=Pro, 3=Visionary)
| `PROTONVPN_USERNAME`      | Yes | OpenVPN Username. This is **NOT** your Proton Account Username.
| `PROTONVPN_PASSWORD`      | Yes | OpenVPN Password. This is **NOT** your Proton Account Password.
| `PROTONVPN_SERVER`        | Yes | ProtonVPN server to connect to. This value is mutually exclusive with `PROTONVPN_COUNTRY`. Only one of them can be used. Set it to `RANDOM` to connect to a random server. Set it to `P2P` to connect to fastest P2P server (does not work for free accounts).
| `PROTONVPN_COUNTRY`       | Yes | ProtonVPN two letter country code. This will choose the fastest server from this country. This value is mutually exclusive with `PROTONVPN_SERVER`. Only one of them can be used.
| `PROTONVPN_PROTOCOL`      | No  | Protocol to use. By default `udp` is used.
| `PROTONVPN_EXCLUDE_CIDRS` | No  | Comma separated list of CIDRs to exclude from VPN. Uses split tunnel. Default is set to `169.254.169.254/32,169.254.170.2/32`
| `PROTONVPN_DNS_LEAK_PROTECT` | No  | Setting this to `0` will disable DNS leak protection. If you wish to specify custom DNS server via `--dns` option you **MUST** set this to `0`.
| `PROTONVPN_CHECK_INTERVAL`   | No  | (Integer) Interval between internal healthchecks in seconds. Defaults to 60 if not specified or invalid.
| `PROTONVPN_FAIL_THRESHOLD`   | No  | (Integer) Number of allowed consecutive internal healthchecks failures before an attempt to reconnect is made. Defaults to 3 if invalid or not specified.


## Run Container

```bash
# Pull Image
docker pull ghcr.io/tprasadtp/protonvpn:latest
# Run in background
docker run \
--rm \
--detach \
--name=protonvpn \
--device=/dev/net/tun \
--cap-add=NET_ADMIN \
--env PROTONVPN_USERNAME="xxxx" \
--env PROTONVPN_PASSWORD="xxxx" \
--env PROTONVPN_TIER=0 \
--env PROTONVPN_COUNTRY=NL \
ghcr.io/tprasadtp/protonvpn:latest
```

## Using VPN in other containers

You can use

```console
docker run \
--name container-with-vpn \
--net=container:protonvpn \
<container>:<tag>
```

## Docker-Compose

```yaml
version: '3.4'
services:
  protonvpn:
    container_name: protonvpn
    environment:
      # Credentials
      PROTONVPN_USERNAME: ${PROTONVPN_USERNAME}
      PROTONVPN_PASSWORD: ${PROTONVPN_PASSWORD}
      # Override these where applicable
      PROTONVPN_COUNTRY: ${PROTONVPN_COUNTRY:-NL}
      PROTONVPN_TIER: ${PROTONVPN_TIER:-0}
    # Always use semver tags, avoid using tag latest!
    image: ghcr.io/tprasadtp/protonvpn:latest
    restart: unless-stopped
    networks:
      - internet
      - proxy
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    # Expose pyload container's port here!
    expose:
      - 8000
  # Your app using the VPN
  # Here we use pyload as an example
  pyload:
    depends_on:
      - protonvpn
    container_name: pyload
    environment:
      TZ: "Europe/Berlin"
      PGID: "1000"
      PUID: "1000"
    image: linuxserver/pyload:latest
    restart: unless-stopped
    userns_mode: host
    # Do not apply any networking configs
    # on this container!
    # All networking labels and settings should be defined
    # on the vpn container.
    network_mode: service:protonvpn
    volumes:
      - config:/config
      - ./downloads/:/downloads/:rw
volumes:
  config:
networks:
  internet:
  proxy:
    internal: true
```

- It is essential to apply labels and expose port on protonvpn container instead of your application. This is because your application container shares network namepsce of protonvpn container.
- If using Traefik, apply labels to protonvpn container, and expose your application ports.

## Health-checks

There is a `healthcheck` script available under /usr/local/bin (Added in 2.2.2-hotfix2). It will use `https://ip.zxq.co` to verify the country to which VPN is connected. By default service will keep checking every `PROTONVPN_CHECK_INTERVAL` _(default = 60)_ seconds using the same api endpoint, script is only added for convenience.

## Changelog

- This project follows [Semantic Versioning 2.0.0](https://semver.org/)
- Changelogs can be found at [changelog](./docs/changelog.md)

## Troubleshooting

See [Troubleshooting](./docs/troubleshooting.md).

## Known issues

- Kill switch is **NOT** reliable. This is due to the way protonvpn cli works because on issuing reconnect they remove
re-initialize iptable rules which removes block on outgoing connections for a short duration until iptable rules are applied again.

## DNS & Split Tunneling

- To use custom DNS servers, you MUST disable DNS leak protection by setting `PROTONVPN_DNS_LEAK_PROTECT=0`
- You can specify list of CIDR blocks to exclude from VPN via `PROTONVPN_EXCLUDE_CIDRS` environment variable.
This will use split tunneling feature to exclude routing these CIDR blocks over VPN connection.
By default instance metadata IPs which are commonly used on cloud environments are excluded.
- Split tunneling can be disabled by setting `PROTONVPN_EXCLUDE_CIDRS` to empty string.


## Kubernetes

You may need to tweak your `PROTONVPN_EXCLUDE_CIDRS` to exclude your PodCIDR and ServiceCIDR. You also **MUST** disable dns leak protection. for more info see [docs/kubernetes.md](./docs/kubernetes.md).

[dockerhub]: https://hub.docker.com/r/tprasadtp/protonvpn
[ghcr]: https://ghcr.io/tprasadtp/protonvpn
[releases]: https://github.com/tprasadtp/protonvpn-docker/releases/latest
