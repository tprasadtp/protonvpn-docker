# ProtonVPN - Docker

[![actions](https://github.com/tprasadtp/protonvpn-docker/workflows/build/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions?workflow=build)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/tprasadtp/protonvpn-docker?label=version&logo=github&sort=semver)](https://github.com/tprasadtp/protonvpn-docker/releases/latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/tprasadtp/protonvpn?color=0db7ed&label=hub.docker.com&logo=docker&logoColor=0db7ed)](https://hub.docker.com/r/tprasadtp/protonvpn)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/tprasadtp/protonvpn/latest?color=0db7ed&logo=docker&logoColor=0db7ed)](https://hub.docker.com/r/tprasadtp/protonvpn)
[![dependabot](https://api.dependabot.com/badges/status?host=github&repo=tprasadtp/protonvpn-docker)](https://app.dependabot.com)
![Analytics](https://ga-beacon.prasadt.com/UA-101760811-3/github/protonvpn-docker?pink&useReferer)

Images are published on,

- [DockerHub](https://hub.docker.com/r/tprasadtp/protonvpn-docker/tags)
- [GitHub Package registry](https://github.com/users/tprasadtp/packages/container/package/protonvpn)

> GitHub container registry is preferred. Though currently there is no plan to discontinue updating images on DockerHub, its advised that you switch to GitHub registry.

## Environment Variables

| Name | Default | Required | Description
|------|---------|----------|-------------
| `PROTONVPN_TIER`          | None   | Yes | Proton VPN Tier (0=Free, 1=Basic, 2=Pro, 3=Visionary)
| `PROTONVPN_USERNAME`      | None   | Yes | OpenVPN Username. This is NOT your Proton Account Username.
| `PROTONVPN_PASSWORD`      | None   | Yes | OpenVPN Password. This is NOT your Proton Account Password.
| `PROTONVPN_SERVER`        | Exclusive | No  | ProtonVPN server to connect to. This value is mutually exclusive with `PROTONVPN_COUNTRY`. Only one of them can be used.
| `PROTONVPN_COUNTRY`       | Exclusive |     | ProtonVPN two letter country code. This will choose the fastest server from this country.
This value is mutually exclusive with `PROTONVPN_SERVER`. Only one of them can be used.
| `PROTONVPN_PROTOCOL`      | `udp`  | No  | Protocol to use
| `PROTONVPN_EXCLUDE_CIDRS` | see footnotes | No | Comma separated list of CIDRs to exclude from VPN. Uses split tunnel.
| `PROTONVPN_DNS_LEAK_PROTECT` |  `1`  | No  | Setting this to `0` will disable DNS leak protection. If you wish to specify custom DNS server via `--dns` option you **MUST** set this to `0`.

> By default AWS IPs are in exclude list. Default CIDR includes `169.254.169.264/32,169.254.169.123/32,169.254.170.2/32`

## Run Container

```bash
# Pull Image
docker pull ghcr.io/tprasadtp/protonvpn:2.2.6
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
ghcr.io/tprasadtp/protonvpn:2.2.6
```

## Using VPN in other containers

You can use

```console
docker run \
--name conrainer-with-vpn \
--net=container:vpn \
<container>:<tag>
```

## Health-checks

There is a `healthcheck` script available under /usr/local/bin (Added in 2.2.2-hotfix2). It will use `https://ipinfo.io` to verify the country to which VPN is connected. By default service will keep checking every `LIVE_PROBE_INTERVAL` _(default = 60)_ seconds using the same api endpoint, script is only added for convenience.

## Known issues

- Kill switch is **NOT** reliable. This is due to the way protonvpn cli works because on issuing reconnect they remove
re-initialize iptable rules which removes block on outgoing connections for a short duration until iptable rules are applied again.

## Kubernetes

This is currently not tested on Kubernetes!. If you are interested in testing the container on k8s
Open an issue to start the discussion. You may need to tweak your `PROTONVPN_EXCLUDE_CIDRS` and **MUST** disable dns leak protection.
