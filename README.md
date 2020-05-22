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
| `PROTONVPN_TIER`     | None   | Yes | Proton VPN Tier
| `PROTONVPN_USERNAME` | None   | Yes | OpenVPN Username. This is NOT your Proton Account Username.
| `PROTONVPN_PASSWORD` | None   | Yes | OpenVPN Password. This is NOT your Proton Account Password.
| `PROTONVPN_PROTOCOL` | `udp`  | No  | Protocol to use
| `PROTONVPN_SERVER`   |        | No  | ProtonVPN server to connect to.
| `PROTONVPN_CHECK_MODE`| `gateway`| No  | Self Check Mode, because proton cli does not come with a daemon to check itself. See [#28](https://github.com/ProtonVPN/linux-cli/issues/28). can be `country` or `gateway`.
| `PROTONVPN_COUNTRY`  | `NL`   | No  | ProtonVPN Country. This will chose the faster server from the country. This wil also be used to check if you are connected to the correct VPN and reconnect if necessary. So when specifying `PROTONVPN_SERVER` also specify this to match the country, if `PROTONVPN_CHECK_MODE` is set to `country`

## Run

```bash
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
tprasadtp/protonvpn:2.2.2
```

## Healthcheck

There is a `healthcheck` script available under /usr/local/bin (Added in 2.2.2-hotfix2)
