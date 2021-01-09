# ProtonVPN - Docker

[![actions](https://github.com/tprasadtp/protonvpn-docker/workflows/build/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions?workflow=build)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/tprasadtp/protonvpn-docker?label=version&logo=github&sort=semver)](https://github.com/tprasadtp/protonvpn-docker/releases/latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/tprasadtp/protonvpn?color=0db7ed&label=hub.docker.com&logo=docker&logoColor=0db7ed)](https://hub.docker.com/r/tprasadtp/protonvpn)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/tprasadtp/protonvpn/latest?color=0db7ed&logo=docker&logoColor=0db7ed)](https://hub.docker.com/r/tprasadtp/protonvpn)
[![dependabot](https://api.dependabot.com/badges/status?host=github&repo=tprasadtp/protonvpn-docker)](https://app.dependabot.com)
![Analytics](https://ga-beacon.prasadt.com/UA-101760811-3/github/protonvpn-docker?pink&useReferer)

Images are published on,

- [DockerHub](https://hub.docker.com/r/tprasadtp/protonvpn-docker/tags)
- [GitHub Package registry](https://github.com/users/tprasadtp/packages/container/package/docker-socket-proxy)

> GitHub container registry is preferred. Though currently there is no plan to discontinue updating images on DockerHub, its advised that you switch to GitHub registry.

## Environment Variables

| Name | Default | Required | Description
|------|---------|----------|-------------
| `PROTONVPN_TIER`          | None   | Yes | Proton VPN Tier (0=Free, 1=Basic, 2=Pro, 3=Visionary)
| `PROTONVPN_USERNAME`      | None   | Yes | OpenVPN Username. This is NOT your Proton Account Username.
| `PROTONVPN_PASSWORD`      | None   | Yes | OpenVPN Password. This is NOT your Proton Account Password.
| `PROTONVPN_PROTOCOL`      | `udp`  | No  | Protocol to use
| `PROTONVPN_SERVER`        |        | No  | ProtonVPN server to connect to.
| `PROTONVPN_COUNTRY`       | `NL`   | Yes if Server is specified  | ProtonVPN Country. This will choose the fastest server from the country. This wil also be used to check if you are connected to the correct VPN and reconnect if necessary. So when specifying `PROTONVPN_SERVER` also specify this to match the country
| `PROTONVPN_EXCLUDE_CIDRS` | `169.254.169.264/32,169.254.169.123/32,169.254.170.2`| No | Comma separated list of CIDRs to exclude from VPN. Uses split tunnel.
| `PROTONVPN_DNS_LEAK_PROTECT` |     | No  | Setting this to `0` or `false` will disable DNS leak protection. If you wish to specify custom DNS server via `--dns` option you **MUST** set this to `0`.

## Run Container

```bash
# Pull Image
docker pull ghcr.io/tprasadtp/protonvpn
# Run in background
docker run \
--rm \
-d \
--name=protonvpn \
--device=/dev/net/tun \
--cap-add=NET_ADMIN \
-e DEBUG=0 \
-e PROTONVPN_USERNAME="xxxx" \
-e PROTONVPN_PASSWORD="xxxx" \
-e PROTONVPN_TIER=0 \
-e PROTONVPN_PROTOCOL=udp \
-e PROTONVPN_COUNTRY=NL \
ghcr.io/tprasadtp/protonvpn
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

There is a `healthcheck` script available under /usr/local/bin (Added in 2.2.2-hotfix2). It will use `https://api.protonvpn.ch` to verify the country to which VPN is connected. By default service will keep checking every `LIVE_PROBE_INTERVAL` _(default = 60)_ seconds using the same api endpoint, script is only added for convenience.

## Known issues

- Kill switch is **NOT** reliable. This is due to the way protonvpn cli works because on issuing reconnect they remove
re-initialize iptable rules which removes block on outgoing connections for a short duration until iptable rules are applied again.

## Kubernetes

This is currently not tested on Kubernetes!. If you are interested in testing the container on k8s
Open an issue to start the discussion. You may need to tweak your `PROTONVPN_EXCLUDE_CIDRS` and **MUST** disable dns leak protection.
