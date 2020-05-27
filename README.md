# protonvpn docker image

[![actions](https://github.com/tprasadtp/protonvpn-docker/workflows/build/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions?workflow=build)
[![actions](https://github.com/tprasadtp/protonvpn-docker/workflows/labels/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions?workflow=labels)
![Docker Image Size](https://img.shields.io/docker/image-size/tprasadtp/protonvpn/latest)
![Docker Image Version](https://img.shields.io/docker/v/tprasadtp/protonvpn?sort=semver)
[![dependabot](https://api.dependabot.com/badges/status?host=github&repo=tprasadtp/protonvpn-docker)](https://app.dependabot.com)
![Analytics](https://ga-beacon.prasadt.com/UA-101760811-3/github/protonvpn-docker?pink&useReferer)

- Images are published both on
  - [DockerHub](https://hub.docker.com/r/tprasadtp/protonvpn-docker/tags) and ~~GitHub Package registry~~ [Waiting for  multi arch image support](https://github.community/t5/GitHub-API-Development-and/Handle-multi-arch-Docker-images-on-GitHub-Package-Registry/td-p/31650).

## Environment Variables

| Name | Default | Required | Description
|------|---------|----------|-------------
| `PROTONVPN_TIER`     | None   | Yes | Proton VPN Tier (0=Free, 1=Basic, 2=Pro, 3=Visionary)
| `PROTONVPN_USERNAME` | None   | Yes | OpenVPN Username. This is NOT your Proton Account Username.
| `PROTONVPN_PASSWORD` | None   | Yes | OpenVPN Password. This is NOT your Proton Account Password.
| `PROTONVPN_PROTOCOL` | `udp`  | No  | Protocol to use
| `PROTONVPN_SERVER`   |        | No  | ProtonVPN server to connect to.
| `PROTONVPN_COUNTRY`  | `NL`   | Yes if Server is specified  | ProtonVPN Country. This will choose the fastest server from the country. This wil also be used to check if you are connected to the correct VPN and reconnect if necessary. So when specifying `PROTONVPN_SERVER` also specify this to match the country

## Run

```bash
docker pull tprasadtp/protonvpn:latest
docker run \
--rm \
-d \
--name=protonvpn \
--device=/dev/net/tun \
--dns=1.1.1.3 \
--cap-add=NET_ADMIN \
-e DEBUG=0 \
-e PROTONVPN_USERNAME="xxxx" \
-e PROTONVPN_PASSWORD="xxxx" \
-e PROTONVPN_TIER=0 \
-e PROTONVPN_PROTOCOL=udp \
-e PROTONVPN_COUNTRY=NL \
tprasadtp/protonvpn:latest
```

## Healthcheck

There is a `healthcheck` script available under /usr/local/bin (Added in 2.2.2-hotfix2)


## Known issues

- Currently `--dns` argument MUST be specified as /etc/resove.conf is not editable inside containers.
- Kill switch is not reliable. This is due to the way protonvpn cli works because on issuing reconnect they remove
re-initialize iptable rules which removes block on outgoing connections for a short duration until iptable rules are applied again.
- DNS Leaks prevention cannot be enabled due to how DNS is handled in docker. I recommend using DNS over TLS or DNS over HTTP on the host
to enhance your privacy.
