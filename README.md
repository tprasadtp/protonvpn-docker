# ProtonVPN - Docker

[![actions](https://github.com/tprasadtp/protonvpn-docker/workflows/build/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions?workflow=build)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/tprasadtp/protonvpn-docker?label=version&logo=github&sort=semver)][releases]
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/tprasadtp/protonvpn?color=2496ED&label=hub.docker.com&logo=docker&logoColor=2496ED&sort=semver)][dockerhub]
[![Docker Pulls](https://img.shields.io/docker/pulls/tprasadtp/protonvpn?color=2496ED&label=hub.docker.com&logo=docker&logoColor=2496ED)][dockerhub]
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/tprasadtp/protonvpn/latest?color=2496ED&label=size&logo=docker&logoColor=2496ED)][dockerhub]
[![dependabot](https://api.dependabot.com/badges/status?host=github&repo=tprasadtp/protonvpn-docker)](https://app.dependabot.com)
![Analytics](https://ga-beacon.prasadt.com/UA-101760811-3/github/protonvpn-docker?pink&useReferer)
[![License](https://img.shields.io/github/license/tprasadtp/protonvpn-docker?color=ee70a6)](https://github.com/tprasadtp/protonvpn-docker/blob/master/LICENSE)

Images are published on,

- [DockerHub][dockerhub]
- [GitHub Package registry][ghcr]

> GitHub container registry is preferred. Though currently there is no plan to discontinue updating images on DockerHub, its advised that you switch to GitHub registry.

## Environment Variables

| Name | Required | Description
|---|---|---
| `PROTONVPN_TIER`          | Yes | Proton VPN Tier (0=Free, 1=Basic, 2=Pro, 3=Visionary)
| `PROTONVPN_USERNAME`      | Yes | OpenVPN Username. This is NOT your Proton Account Username.
| `PROTONVPN_PASSWORD`      | Yes | OpenVPN Password. This is NOT your Proton Account Password.
| `PROTONVPN_SERVER`        | Yes | ProtonVPN server to connect to. This value is mutually exclusive with `PROTONVPN_COUNTRY`. Only one of them can be used. Set it to 'RANDOM' to connect to a random server.

| `PROTONVPN_COUNTRY`       | Yes | ProtonVPN two letter country code. This will choose the fastest server from this country. This value is mutually exclusive with `PROTONVPN_SERVER`. Only one of them can be used.
| `PROTONVPN_PROTOCOL`      | No  | Protocol to use. By default `udp` is used.
| `PROTONVPN_EXCLUDE_CIDRS` | No | Comma separated list of CIDRs to exclude from VPN. Uses split tunnel. Default is set to `169.254.169.254/32,169.254.170.2/32`
| `PROTONVPN_DNS_LEAK_PROTECT` | No  | Setting this to `0` will disable DNS leak protection. If you wish to specify custom DNS server via `--dns` option you **MUST** set this to `0`.

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
--name container-with-vpn \
--net=container:protonvpn \
<container>:<tag>
```

## Health-checks

There is a `healthcheck` script available under /usr/local/bin (Added in 2.2.2-hotfix2). It will use `https://ipinfo.io` to verify the country to which VPN is connected. By default service will keep checking every `LIVE_PROBE_INTERVAL` _(default = 60)_ seconds using the same api endpoint, script is only added for convenience.

## Known issues

- Kill switch is **NOT** reliable. This is due to the way protonvpn cli works because on issuing reconnect they remove
re-initialize iptable rules which removes block on outgoing connections for a short duration until iptable rules are applied again.

## DNS & Split Tunneling

- To use custom DNS servers, you MUST specify servers via DNS arguments AND disable DNS leak protection by setting `PROTONVPN_DNS_LEAK_PROTECT=0`
- You can specify list of CIDR blocks to exclude from VPN via `PROTONVPN_EXCLUDE_CIDRS` environment variable.
This will use split tunneling feature to exclude routing these CIDR blocks over VPN connection.
By default instance metadata IPs which are commonly used on cloud environments are excluded.
- Split tunneling can be disabled by setting `PROTONVPN_EXCLUDE_CIDRS` to empty string.

```bash
docker run \
--rm \
--detach \
--name=protonvpn \
--dns=1.1.1.3 \
--dns=1.0.0.1 \
--device=/dev/net/tun \
--cap-add=NET_ADMIN \
--env PROTONVPN_COUNTRY=NL \
--env PROTONVPN_DNS_LEAK_PROTECT=0 \
--env PROTONVPN_EXCLUDE_CIDRS="169.254.169.254/32,169,10.244.0.0/16" \
--env PROTONVPN_TIER=0 \
--env PROTONVPN_PASSWORD="xxxx" \
--env PROTONVPN_USERNAME="xxxx" \
ghcr.io/tprasadtp/protonvpn
```

## Kubernetes

If you are interested in testing the container on k8s
Open an issue to start the discussion. You may need to tweak your `PROTONVPN_EXCLUDE_CIDRS` and **MUST** disable dns leak protection.

[dockerhub]: https://hub.docker.com/r/tprasadtp/protonvpn
[ghcr]: https://ghcr.io/tprasadtp/protonvpn
[releases]: https://github.com/tprasadtp/protonvpn-docker/releases/latest
