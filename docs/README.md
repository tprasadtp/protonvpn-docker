<!-- markdownlint-disable MD033 -->

<!-- CI Badges -->

[![build](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/build.yml/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/build.yml)
[![release](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/release.yml/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/release.yml)
[![security](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/security.yml/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/security.yml)
[![releases](https://img.shields.io/github/v/tag/tprasadtp/protonvpn-docker?label=version&sort=semver&logo=semver&color=7f50a6&labelColor=3a3a3a)](https://github.com/tprasadtp/protonvpn-docker/releases/latest)
[![license](https://img.shields.io/github/license/tprasadtp/protonvpn-docker?logo=github&labelColor=3A3A3A)](https://github.com/tprasadtp/protonvpn-docker/blob/master/LICENSE)
![analytics](https://ga-beacon.prasadt.com/UA-101760811-3/github/protonvpn-docker)

## Docker Images

Images are published on [GitHub Container Registry][ghcr].

## Environment Variables

| Name | Required | Description
|---|---|---
| `PROTONVPN_TIER`          | Yes | Proton VPN Tier (0=Free, 1=Basic, 2=Pro, 3=Visionary)
| `PROTONVPN_USERNAME`      | Yes | OpenVPN Username. This is **NOT** your Proton Account Username.
| `PROTONVPN_PASSWORD`      | Yes | OpenVPN Password. This is **NOT** your Proton Account Password.
| `PROTONVPN_SERVER`        | Yes | ProtonVPN server to connect to. See `PROTONVPN_SERVER` for more info.
| `PROTONVPN_COUNTRY`       | *** | Only available in version 4.x and below. See `PROTONVPN_COUNTRY` for more info.
| `PROTONVPN_PROTOCOL`      | No  | Protocol to use. By default `udp` is used.
| `PROTONVPN_EXCLUDE_CIDRS` | No  | Comma separated list of CIDRs to exclude from VPN. Uses split tunnel. Default is set to `169.254.169.254/32,169.254.170.2/32`
| `PROTONVPN_DNS_LEAK_PROTECT` | No  | (Integer) Setting this to `0` will disable DNS leak protection. If you wish to specify custom DNS server via `--dns` option or running on k8s, you **MUST** set this to `0`.
| `PROTONVPN_CHECK_INTERVAL`   | No  | (Integer) Interval between internal healthcheck in seconds. Defaults to 90 if not specified or invalid.
| `PROTONVPN_IPCHECK_ENDPOINT` | No | Healthcheck endpoint to determine if you are connected via VPN. Defaults to `https://ip.prasadt.workers.dev/`. Must return Your public IP
| `PROTONVPN_FAIL_THRESHOLD`   | No  | (Integer) Number of allowed consecutive internal healthcheck failures before an attempt to reconnect is made. Defaults to 3 if invalid or not specified.

## PROTONVPN_COUNTRY

- If using v5.x use `PROTONVPN_SERVER`, as both options are merged into `PROTONVPN_SERVER`
- If using 4.x or below this value is mutually exclusive with `PROTONVPN_SERVER`. i.e Only one of them can be used.
- Set this to ProtonVPN two letter country code. This will choose the fastest server from this country.


## PROTONVPN_SERVER

- If set to `RANDOM`, a random server will be chosen which is compatible with your plan.
- If set to `P2P` will choose fastest `P2P` server. Please note that this requires setting correct plan in `PROTONVPN_TIER`.
- If none of the above are true, container will attempt to connect to this server and fail if it is not possible. Please note that `Secure Core` servers are only available with pro plan and above.
- If set to ProtonVPN supported country code, will choose the fastest server from this country. (case insensitive). For example to connect to fastest server from Netherlands, set `PROTONVPN_SERVER` to `NL`. This option is only available on versions 5.0.0 and above. on 4.x releases, set `PROTONVPN_COUNTRY`

## Run Container

- If using 5.x and above,

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
  --env PROTONVPN_SERVER=NL \
  ghcr.io/tprasadtp/protonvpn:latest
  ```

- If using version 4.x and below

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
  ghcr.io/tprasadtp/protonvpn:4.2.1
  ```

## Using VPN in other containers

You can use

```bash
docker run \
--name container-with-vpn \
--net=container:protonvpn \
my-awesome-image-name
```

## Docker-Compose

- If using 5.x and above,

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
        PROTONVPN_SERVER: ${PROTONVPN_SERVER:-NL}
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

- If using version 4.x and below

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

- It is essential to apply labels and expose port on protonvpn container instead of your application. This is because your application container shares network namespace of protonvpn container.
- If using Traefik, apply labels to protonvpn container, and expose your application ports.
- You **DO NOT** need to run the container as privileged. by passing the right tun device and adding capabilities should be sufficient.

[dockerhub]: https://hub.docker.com/r/tprasadtp/protonvpn
[ghcr]: https://ghcr.io/tprasadtp/protonvpn
[releases]: https://github.com/tprasadtp/protonvpn-docker/releases/latest
