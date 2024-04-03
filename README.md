
<div align="center">

# Protonwire - ProtonVPN Wireguard Client

[![actions-build](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/build.yml/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/build.yml)
[![actions-docs](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/docs.yml/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/docs.yml)
[![actions-release](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/release.yml/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/release.yml)
[![version](https://img.shields.io/github/v/tag/tprasadtp/protonvpn-docker?label=version&sort=semver&logo=semver&labelColor=3a3a3a&include_prereleases)](https://github.com/tprasadtp/protonvpn-docker/releases)
[![license](https://img.shields.io/github/license/tprasadtp/protonvpn-docker?logo=github&labelColor=3A3A3A)](https://github.com/tprasadtp/protonvpn-docker/blob/master/LICENSE)
[![stars](https://img.shields.io/github/stars/tprasadtp/protonvpn-docker?logo=github&labelColor=3a3a3a&style=flat)](https://github.com/tprasadtp/protonvpn-docker/stargazers/)
[![actions-metadata](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/metadata.yml/badge.svg)](https://github.com/tprasadtp/protonvpn-docker/actions/workflows/metadata.yml)
[![metadata-refresh](https://img.shields.io/badge/dynamic/json?label=metadata&query=timestamp&url=https%3A%2F%2Fprotonwire-api.vercel.app&logo=protonvpn&labelColor=3a3a3a&logoColor=white&color=7f50a6)](https://protonwire-api.vercel.app/)
[![metadata-servers](https://img.shields.io/badge/dynamic/json?label=servers&query=server_count&url=https%3A%2F%2Fprotonwire-api.vercel.app&logo=protonvpn&labelColor=3a3a3a&logoColor=white&color=7f50a6)](https://protonwire-api.vercel.app/)

</div>

## Features

- LAN, private and CGNAT networks remain accessible and are not routed over VPN.
**No special configuration required**.
- Supports systemd integration when running via podman
- Supports roaming clients

## Container Images

> [!WARNING]
>
> [gVisor](https://gvisor.dev) and cgroup v1 are **NOT** supported!

Images are published at [ghcr.io/tprasadtp/protonwire][ghcr].

## Linux Kernel Requirements

> [!IMPORTANT]
>
> If running as a container, Wireguard **MUST** be installed on the host, **not** the container.

- If using Debian 11 (Buster) or later, Raspberry Pi OS (Buster) or later, Fedora, ArchLinux, Linux Mint 20.x or later, RHEL 9 or later, Alma Linux 9 or later, CentOS 9 Stream, Ubuntu 20.04 or later have the required kernel module built-in.
- Kernel versions 5.6 or later.
- If **NONE** of the above conditions can be satisfied, install WireGuard. Your distribution might already package DKMS module or provide signed kernels with WireGuard built-in. Visit https://www.wireguard.com/install/ for more info.
- To check current kernel version run,
    ```bash
    uname -r
    ```

## Generating WireGuard Private Key

> [!IMPORTANT]
>
> It is recommended to use unique private key for each instance of the the VPN container.

- Log in to ProtonVPN and go to **Downloads** → **WireGuard configuration**.
- Enter a name for the key, and select features to enable like NetShield and VPN Accelerator & click create.
  Some users have reported issues (#236,#211) when NetShield is set to `Block malware, ads and trackers`.
  Please see [Troubleshooting] for a work-around.
- Generated config might look something like below,
    ```ini
    [Interface]
    # Key for <name>
    # VPN Accelerator = on
    PrivateKey = KLjfIMiuxPskM4+DaSUDmL2uSIYKJ9Wap+CHvs0Lfkw=
    Address = 10.2.0.2/32
    DNS = 10.2.0.1

    [Peer]
    # NL-FREE#128
    PublicKey = jbTC1lYeHxiz1LNSJHQMKDTq6sHgcWxkBwXvt7GWo1E=
    AllowedIPs = 0.0.0.0/0
    Endpoint = 91.229.23.180:51820
    ```
- You will `PrivateKey` and optionally `Endpoint`(without port part) from the above config.
- See https://protonvpn.com/support/wireguard-configurations/ for more info.

## Environment Variables & Config

- CLI arguments will always take precedence over environment variables.
- Environment variables takes precedence over any config file.
- If private key is not specified via CLI or environment variable, it is searched
in following locations.
  - `/etc/protonwire/private-key`
  - `/run/secrets/protonwire-private-key`
  - `/run/secrets/protonwire/private-key`
  - `${CREDENTIALS_DIRECTORY}/private-key` (Only if `$CREDENTIALS_DIRECTORY` is set)
  - `${CREDENTIALS_DIRECTORY}/protonwire-private-key` (Only if `$CREDENTIALS_DIRECTORY` is set)

> [!IMPORTANT]
>
> Private key file **MUST NOT** be world-readable.


| Name | Default/Required | Description
|---|---|---
| `PROTONVPN_SERVER` | REQUIRED | (String) ProtonVPN server to connect to.
| `WIREGUARD_PRIVATE_KEY` | Required if not specified via mount or secrets  | (String) Wireguard Private key
| `IPCHECK_URL` | https://protonwire-api.vercel.app/v1/client/ip  | (String) URL to check client IP.
| `IPCHECK_INTERVAL` | `60` | (Integer) Interval between internal health-checks in seconds. Set this to `0` to disable IP checks.
| `SKIP_DNS_CONFIG` | false | (Boolean) Set this to `1` or `true` to skip configuring DNS.
| `KILL_SWITCH`     | false | (Boolean) Enable KillSwitch (Experimental)

## PROTONVPN_SERVER

This should be server DNS name like, `node-nl-01.protonvpn.net` or IP address like
`91.229.23.180`. Server name like `NL#1`(or `NL-1`) may work for pro servers, it is
_not recommended_.

> [!IMPORTANT]
>
> Script cannot validate if specified server is available under your plan.
> It is user's responsibility to ensure that server specified is available
> under your subscription and supports required features, like P2P, Streaming etc.
> Use `--p2p`, `--streaming`, `--secure-core` flags to enable client side validations.

## KillSwitch

> [!WARNING]
>
> This feature is experimental and is **NOT** covered by semver compatibility guarantees.

Kill-Switch is not a hard kill-switch but more of an _internet_ kill-switch.
LAN addresses, Link-Local addresses and CGNAT (also Tailscale) addresses
remain reachable. Unlike most VPN containers, kill-switch is implemented via
routing policies, routing priorities and custom route tables rather than
firewall rules.

- Kill-switch **WILL NOT** be disabled during reconnects.
- Kill-switch **WILL NOT** be disabled when running `protonwire disconnect` unless `--kill-switch`
flag is **ALSO** specified.

## Usage

<!--diana::dynamic:protonwire-help:begin-->
<pre>

ProtonVPN WireGuard Client

Usage: protonwire [OPTIONS...]
or: protonwire [OPTIONS...] c|connect [SERVER]
or: protonwire [OPTIONS...] d|disconnect
or: protonwire [OPTIONS...] check
or: protonwire [OPTIONS...] disable-killswitch
or: protonwire [OPTIONS...] server-info [SERVER]

Options:
  -k, --private-key FILE|KEY    Wireguard private key or
                                file containing private key
      --container               Run as container
      --metadata-url URL        Server metadata endpoint URL
      --check-interval INT      IP check interval in seconds (default 60)
      --check-url URL           IP check endpoint URL
      --skip-dns-config         Skip configuring DNS.
                                (Useful for Kubernetes and Consul)
      --kill-switch             Enable killswitch (Experimental)
      --p2p                     Verify if specified server supports P2P
      --streaming               Verify if specified server supports streaming
      --tor                     Verify if specified server supports Tor
      --secure-core             Verify if specified server supports secure core
  -q, --quiet                   Show only errors
  -v, --verbose                 Show debug logs
  -h, --help                    Display this help and exit
      --version                 Display version and exit

Examples:
  protonwire connect nl-1       Connect to server nl-1
  protonwire d --kill-switch    Disconnect from current server and disable kill-switch
  protonwire verify [SERVER]    Check if connected to a server

Files:
  /etc/protonwire/private-key   WireGuard private key

Environment:
  WIREGUARD_PRIVATE_KEY         WireGuard private key or file
  PROTONVPN_SERVER              ProtonVPN server
  IPCHECK_INTERVAL              Custom IP check interval in seconds (default 60)
  IPCHECK_URL                   IP check endpoint URL (must be https://)
  SKIP_DNS_CONFIG               Set to '1' to skip configuring DNS
  KILL_SWITCH                   Set to '1' to enable killswitch (Experimental)
  DEBUG                         Set to '1' to enable debug logs
</pre>
<!--diana::dynamic:protonwire-help:end-->

## Health-checks

- Script supports `healthcheck` sub-command. By default, when running as a service,
script will keep checking every `IPCHECK_INTERVAL` _(default=60)_ seconds using the
`IPCHECK_URL` api endpoint. To disable healthchecks entirely set `IPCHECK_INTERVAL` to `0`
- Use `protonwire healthcheck --silent --container` as the `HEALTHCHECK` command.
Same can be used as liveness probe and readiness probe for Kubernetes.

## Docker Compose

If entire stack is in a single compose file, then `network_mode: service:protonwire`
on the services which should be routed via VPN. If the VPN stack is **NOT** in same
compose file use `network_mode: container:<protonwire-container-name>`.

As an example, run caddy web-server, proxying https://ip.me, via VPN using the compose
config given below. Once the stack is up, visiting the http://localhost:8000, or
`curl -s http://localhost:8000` should show VPN's country and IP address.

<!--diana::dynamic:protonwire-sample-compose-file:begin-->
```yaml
version: '2.3'
services:
  protonwire:
    container_name: protonwire
    # Use semver tags or sha256 hashes of manifests.
    # using latest tag can lead to issues when used with
    # automatic image updaters like watchtower/podman.
    image: ghcr.io/tprasadtp/protonwire:latest
    init: true
    restart: unless-stopped
    environment:
      # Quote this value as server name can contain '#'.
      PROTONVPN_SERVER: "node-nl-96.protonvpn.net"  # NL-FREE#100070
      # Set this to 1 to show debug logs for issue forms.
      DEBUG: "0"
      # Set this to 0 to disable kill-switch.
      KILL_SWITCH: "1"
    # NET_ADMIN capability is mandatory!
    cap_add:
      - NET_ADMIN
    # sysctl net.ipv4.conf.all.rp_filter is mandatory!
    # net.ipv6.conf.all.disable_ipv6 disables IPv6 as protonVPN does not support IPv6.
    # 'net.*' sysctls are not required on application containers,
    # as they share network stack with protonwire container.
    sysctls:
      net.ipv4.conf.all.rp_filter: 2
      net.ipv6.conf.all.disable_ipv6: 1
    volumes:
      - type: tmpfs
        target: /tmp
      - type: bind
        source: private.key
        target: /etc/protonwire/private-key
        read_only: true
    ports:
      - 8000:80
  # This is sample application which will be routed over VPN
  # Replace this with your preferred application(s).
  caddy_proxy:
    image: caddy:latest
    network_mode: service:protonwire
    command: |
      caddy reverse-proxy \
          --change-host-header \
          --from :80 \
          --to https://ip.me:443
```
<!--diana::dynamic:protonwire-sample-compose-file:end-->


> [!IMPORTANT]
>
> - It is **essential** to expose/publish port(s) _on protonwire container_, instead
> of application container.
> - **SHOULD NOT** run the container as privileged. Adding capability `CAP_NET_ADMIN`
> **AND** defined `sysctls` should be sufficient.
> - Value for `PROTONVPN_SERVER` must be enclosed within quotes as server name can
> contain '#'

## Podman

This section covers running containers via podman. But for deployments use
[podman's systemd integration][podman-systemd].

- Create a podman secret for private key

    ```console
    podman secret create protonwire-private-key <PRIVATE_KEY|PATH_TO_PRIVATE_KEY>
    ```

- Run _protonwire_ container.

    ```console
    podman run \
        -it \
        --rm \
        --init \
        --replace \
        --tz=local \
        --tmpfs=/tmp \
        --name=protonwire \
        --secret="protonwire-private-key,mode=600" \
        --env=PROTONVPN_SERVER="nl-free-127.protonvpn.net" \
        --env=DEBUG=0 \
        --env=KILL_SWITCH=1 \
        --cap-add=NET_ADMIN \
        --sysctl=net.ipv4.conf.all.rp_filter=2 \
        --sysctl=net.ipv6.conf.all.disable_ipv6=1 \
        --publish=8000:8000 \
        --health-start-period=20s \
        --health-cmd="protonwire check --container --silent" \
        --health-interval=120s \
        --health-on-failure=stop \
        ghcr.io/tprasadtp/protonwire:7
    ```

- Create app(s) sharing network namespace with `protonwire` container. As an example,
we are using caddy to proxy website which shows IP info. Replace these with your application
container(s) like [pyload](https://github.com/pyload/pyload#docker-images), [firefox](https://docs.linuxserver.io/images/docker-firefox) etc.

    ```console
    podman run \
        -it \
        --rm \
        --tz=local \
        --name=protonwire-demo-app \
        --network=container:protonwire \
        docker.io/library/caddy:latest \
        caddy reverse-proxy --change-host-header --from :8000 --to https://ip.me:443
    ```

- Verify that application containers are using VPN by visiting http://<hostname or IP>:8000.

> [!IMPORTANT]
>
> * The above example publishes container port 8000 to host port 8000.
> You **MUST** change these to match your application container(s).
> * To publish additional ports from other containers using this VPN
> (usually done via argument `--publish <host-port>:<container-port>`),
> it **MUST** be done on _protonwire_ container.
> * `--sysctl` flags are important! without these, container cannot
> create/manage WireGuard interface.
> * `mode=600` in secret mount is important, as script refuses to use
> private key with insecure permissions.
> * If using pods, sysctls **MUST** be defined on the pod no the protonwire container.

## Docker

- Pull docker image (if required)
    ```bash
    docker pull ghcr.io/tprasadtp/protonwire:latest
    ```
- Run the VPN container. Assuming that a container which needs to be routed via VPN, listening on container port `80` and you wish to map it to host port `8000`,
    ```console
    docker run \
        -it \
        --rm \
        --init \
        --publish 8000:80 \
        --name protonwire \
        --cap-add NET_ADMIN \
        --env PROTONVPN_SERVER=<server-name-or-dns> \
        --sysctl net.ipv4.conf.all.rp_filter=2 \
        --mount type=tmpfs,dst=/tmp \
        --mount type=bind,src=<absolute-path-to-key-file>,dst=/etc/protonwire/private-key,readonly \
        ghcr.io/tprasadtp/protonwire:latest
    ```

> [!IMPORTANT]
>
> - To publish additional ports from other containers using this VPN, it **MUST** be done
>   on the `protonwire` container!
> - `--sysctl` and `--cap-add` flags are important! without these, container cannot create
> or manage WireGuard interfaces or routing.
> - docker rootless should also work just fine for most users, but is considered experimental.

- To use VPN in other container(s), use `--net=container:protonwire` flag.
For example, we can run caddy to proxy `https://ip.me/` via VPN. Visiting http://localhost:8000, or `curl http://localhost:8000` should show VPN's country and IP address.

    ```console
    docker run \
        -it \
        --rm \
        --net=container:protonwire \
        caddy:latest \
        caddy reverse-proxy \
            --change-host-header \
            --from :80 \
            --to https://ip.me:443
    ```

## Troubleshooting & FAQ

See [Troubleshooting][] and [FAQ][]

## Building

Building requires `goreleaser`, and `docker` with `buildx` plugin.

[drop-in]: https://wiki.archlinux.org/title/systemd#Drop-in_files
[nss-resolve]: https://www.freedesktop.org/software/systemd/man/nss-resolve.html
[podman-systemd]: https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html

[systemd.exec(5)]: https://www.freedesktop.org/software/systemd/man/systemd.exec.html
[systemd.unit(5)]: https://www.freedesktop.org/software/systemd/man/systemd.unit.html
[systemd-creds]: https://www.freedesktop.org/software/systemd/man/systemd-creds.html
[resolved.conf(5)]:https://www.freedesktop.org/software/systemd/man/resolved.conf.html
[systemd.network(5)]:https://www.freedesktop.org/software/systemd/man/systemd.network.html

[PartOf]: https://www.freedesktop.org/software/systemd/man/systemd.unit.html#PartOf=
[BindsTo]: https://www.freedesktop.org/software/systemd/man/systemd.unit.html#BindsTo=
[After]: https://www.freedesktop.org/software/systemd/man/systemd.unit.html#After=
[RestrictNetworkInterfaces]: https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#RestrictNetworkInterfaces=
[systemd.resource-control(5)]: https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#RestrictNetworkInterfaces=

[ghcr]: https://ghcr.io/tprasadtp/protonwire
[releases]: https://github.com/tprasadtp/protonwire/releases/latest
[Troubleshooting]: ./docs/help.md
[FAQ]: ./docs/faq.md
