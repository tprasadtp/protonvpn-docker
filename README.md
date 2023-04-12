<h1 align="center">Protonwire - ProtonVPN Wireguard Client</h1>

<p align="center">
  <a href="https://protonvpn.com" target="_blank" rel="noreferrer">
    <img src="https://static.prasadt.com/logos/brands/proton/scalable/protonvpn-wide.svg" height="96" alt="protonvpn">
  </a>
</p>

<!-- Badges -->

<p align="center">
  <a href="https://github.com/tprasadtp/protonvpn-docker/actions/workflows/build.yml" target="_blank" rel="noreferrer">
    <img src="https://github.com/tprasadtp/protonvpn-docker/actions/workflows/build.yml/badge.svg" height="24" alt="badge-build">
  </a>
  <a href="https://github.com/tprasadtp/protonvpn-docker/actions/workflows/release.yml" target="_blank" rel="noreferrer">
    <img src="https://github.com/tprasadtp/protonvpn-docker/actions/workflows/release.yml/badge.svg" height="24" alt="badge-release">
  </a>
  <a href="https://github.com/tprasadtp/protonvpn-docker/releases" target="_blank" rel="noreferrer">
    <img src="https://img.shields.io/github/v/tag/tprasadtp/protonvpn-docker?label=version&sort=semver&logo=semver&labelColor=3a3a3a&include_prereleases" height="24" alt="badge-release">
  </a>
  <a href="https://github.com/tprasadtp/protonvpn-docker/blob/master/LICENSE" target="_blank" rel="noreferrer">
    <img src="https://img.shields.io/github/license/tprasadtp/protonvpn-docker?logo=github&labelColor=3A3A3A" height="24" alt="badge-license">
  </a>
  <a href="https://github.com/tprasadtp/protonvpn-docker/stargazers/" target="_blank" rel="noreferrer">
    <img src="https://img.shields.io/github/stars/tprasadtp/protonvpn-docker?logo=github&labelColor=3a3a3a" height="24" alt="badge-stars">
  </a>
</p>



<p align="center">
  <a href="https://github.com/tprasadtp/protonvpn-docker/actions/workflows/metadata.yml" target="_blank" rel="noreferrer">
    <img src="https://github.com/tprasadtp/protonvpn-docker/actions/workflows/metadata.yml/badge.svg" height="24" alt="metadata-build">
  </a>
  <a href="https://protonwire-api.vercel.app/" target="_blank" rel="noreferrer">
    <img src="https://img.shields.io/badge/dynamic/json?label=metadata&query=timestamp&url=https%3A%2F%2Fprotonwire-api.vercel.app&logo=protonvpn&labelColor=3a3a3a&logoColor=white&color=7f50a6&cacheSeconds=300" height="24" alt="badge-metadata">
  </a>
  <a href="https://protonwire-api.vercel.app/" target="_blank" rel="noreferrer">
    <img src="https://img.shields.io/badge/dynamic/json?label=servers&query=server_count&url=https%3A%2F%2Fprotonwire-api.vercel.app&logo=protonvpn&labelColor=3a3a3a&logoColor=white&color=7f50a6&cacheSeconds=300" height="24" alt="badge-server-count">
  </a>
  <a href="https://github.com/tprasadtp/protonwire-api" target="_blank" rel="noreferrer">
    <img src="https://img.shields.io/badge/dynamic/json?label=commit&query=commit&url=https%3A%2F%2Fprotonwire-api.vercel.app%2Fcommit.json&logo=git&labelColor=3a3a3a&logoColor=white&color=7f50a6&cacheSeconds=300" height="24" alt="badge-metadata-commit">
  </a>
</p>

## Features

- LAN, private and Tailscale networks remain accessible and are not routed over VPN.
No special configuration required!
- Supports split horizon DNS **automatically**, if `systemd-resolved` is in use.
- Supports running as systemd unit (natively and as podman container)
- Supports roaming clients

> **Note**
>
> If you are looking for OpenVPN based container,
> See [here](https://github.com/tprasadtp/protonvpn-docker/tree/release/v5).

## Container Images

> **Warning**
>
> [Docker Rootless](https://docs.docker.com/engine/security/rootless/), [gVisor](https://gvisor.dev), [Podman Rootless](https://github.com/containers/podman/blob/main/rootless.md) or any other container runtime using **user mode networking** are **NOT** supported!

Images are published at [ghcr.io/tprasadtp/protonwire][ghcr].

## Linux Kernel Requirements

- If using Debian 11 (Buster) or later, Raspberry Pi OS (Buster) or later, Fedora, ArchLinux, Linux Mint 20.x or later, RHEL 9 or later, Alma Linux 9 or later, CentOS 9 Stream, Ubuntu 20.04 or later you have the required kernel module built-in.
- If you have kernel versions 5.6 or later you should also be good to go.
- If **NONE** of the above conditions can be satisfied, You have to install WireGuard. Your distribution might already package DKMS module or provide signed kernels with WireGuard built-in. Visit https://www.wireguard.com/install/ for more info.
    > **Note**
    >
    > If running as a container, Wireguard **MUST** be installed on the host, not the container.

- To check your current kernel version run,
    ```bash
    uname -r
    ```

## Generating WireGuard Private Key

- Log in to ProtonVPN and go to **Downloads** → **WireGuard configuration**.
- Enter a name for the key, and select features to enable like NetShield and VPN Accelerator & click create.
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
- Only thing you need from the above config is `PrivateKey`.
- See https://protonvpn.com/support/wireguard-configurations/ for more info.

## Environment Variables & Config

- CLI arguments will always take precedence over environment variables.
- Environment variables takes precedence over any config file.
- If private key is not specified via CLI or environment variable, it is searched
in following locations.
  - `/etc/protonwire/private-key`
  - `/run/secrets/protonwire/private-key`
  - `${CREDENTIALS_DIRECTORY}/private-key` (Only if `$CREDENTIALS_DIRECTORY` is set)

| Name | Default/Required | Description
|---|---|---
| `PROTONVPN_SERVER` | REQUIRED | (String) ProtonVPN server to connect to.
| `WIREGUARD_PRIVATE_KEY` | -  | (String) Wireguard Private key
| `IPCHECK_URL` | https://protonwire-api.vercel.app/v1/client/ip  | (String) URL to check client IP.
| `IPCHECK_INTERVAL` | `60` | (Integer) Interval between internal health-checks in seconds. Set this to `0` to disable IP checks.
| `SKIP_DNS_CONFIG` | false | (Boolean) Set this to `1` or `true` to skip configuring DNS.
| `KILL_SWITCH`     | false | (Boolean) Enable KillSwitch (Experimental and can cause issues)

> **Warning**
>
> Environment variables starting with `__PROTONWIRE` are reserved for internal use.

## PROTONVPN_SERVER

This should be server name like `NL-FREE#1`(or `NL-FREE-1`) or domain name like,
`nl-free-01.protonvpn.net` (recommended).

> **Warning**
>
> Script cannot validate if specified server is available under your plan.
> Its user's responsibility to ensure that server specified is available
> under your subscription and supports required features, like P2P, Streaming etc.
> Use `--p2p`, `--streaming`, `--secure-core` flags to enable client side validations.

## KillSwitch

> **Warning**
>
> This Feature is experimental.

Kill-Switch is not a hard kill-switch but more of an "internet" kill-switch.
Your LAN addresses, Link-Local addresses and CGNAT(also Tailscale) addresses
remain reachable. Unlike most VPN containers, kill-switch is implemented via
routing policies, rather than firewall rules.

## Usage

<!--diana::dynamic:protonwire-help:begin-->
<pre>

ProtonVPN WireGuard Client

Usage: protonwire [OPTIONS...]
or: protonwire [OPTIONS...] c|connect [SERVER]
or: protonwire [OPTIONS...] d|disconnect
or: protonwire [OPTIONS...] check
or: protonwire [OPTIONS...] help

Options:
  -k, --private-key FILE|KEY    Wireguard private key or
                                file containing private key
      --container               Run as container
                                (Cannot be used with --systemd)
      --systemd                 Run as systemd service
                                (Cannot be used with --container)
      --metadata-endpoint URL   Server metadata endpoint URL
      --check-interval INT      IP check interval in seconds
      --check-endpoint URL      IP check endpoint URL
      --skip-dns-config         Skip configuring DNS.
                                (Useful for Kubernetes and Nomad)
      --kill-switch             Enable killswitch (Experimental)
      --p2p                     Check if server supports P2P
      --streaming               Check if server supports streaming
      --tor                     Check if server supports Tor
      --secure-core             Check if server supports secure core
  -q, --quiet                   Show only errors
  -v, --verbose,                Show debug logs
  -h, --help                    Display this help and exit
      --version                 Display version and exit

Examples:
  protonwire connect nl-1       Connect to server nl-1
  protonwire disconnect         Disconnect from current server
  protonwire verify [SERVER]    Check if connected to a server

Files:
  /etc/protonwire/private-key   WireGuard private key

Environment:
  WIREGUARD_PRIVATE_KEY         WireGuard private key or file
  PROTONVPN_SERVER              ProtonVPN server name
  IPCHECK_INTERVAL              Custom IP check interval in seconds
  SKIP_DNS_CONFIG               Set to '1' to skip configuring DNS
  KILL_SWITCH                   Set to '1' to enable killswitch (Experimental)
  DEBUG                         Set to '1' to enable debug logs
</pre>
<!--diana::dynamic:protonwire-help:end-->

## Health-checks

- Script supports `healthcheck` command. By default, when running as a service script will keep checking every `IPCHECK_INTERVAL` _(default=60)_ seconds using the same api endpoint. If you wish to disable healthchecks entirely set `IPCHECK_INTERVAL` to `0`
- Containers images do not have healthchecks by default. This is because OCI specs do not include healthcheck. `HEALTHCHECK` directive on Dockerfile is specific to docker.
- You can use `protonwire healthcheck --silent --container` as your healthcheck command.
Same can be used as liveness probe and readiness probe for Kubernetes.

## Docker

  <p align="center">
    <a href="https://ghcr.io/tprasadtp/protonvpn" target="_blank" rel="noreferrer">
      <img src="https://static.prasadt.com/logos/software/docker/scalable/docker-engine-wide.svg" height="64" alt="docker">
    </a>
  </p>

- Pull docker image (if required)
    ```bash
    docker pull ghcr.io/tprasadtp/protonwire:latest
    ```
- Run VPN Container. Assuming that you have have a container which needs to be routed via VPN, listening on container port `80` and you wish to map it to host port `8000`,
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
    > **Warning**
    >
    > - If you wish to publish additional ports from other containers using this VPN, you **MUST** do it
    >   here on the `protonwire` container!
    > - `--sysctl` and `--cap-add` flags are important! without these, container cannot create or manage
    >   WireGuard interfaces or routing.

- To use VPN in other container(s), use `--net=container:protonwire` flag.
For example, we can run caddy to proxy `https://api.ipify.org/` via VPN. Visiting http://localhost:8000, or `curl http://localhost:8000` should show your VPN's country and IP address.

    ```console
    docker run \
        -it \
        --net=container:protonwire \
        caddy:latest \
        caddy reverse-proxy \
            --change-host-header \
            --from :80 \
            --to https://ip.me:443
    ```

    > **Note**
    >
    > There are no port mappings done here! It should be done on the VPN container!

## Docker Compose

- If you have your entire stack in a single compose file, then `network_mode: service:protonwire` on the services which should be routed via VPN. If your VPN stack is **NOT** in same compose file use `network_mode: container:<protonwire-container-name>`.

- As an example, run caddy web-server, proxying `api.ipify.org` via VPN is shown below. Visiting http://localhost:8000, or `curl -s http://localhost:8000` should show your VPN's country and IP address.

    ```yaml
    version: '2.3'
    services:
    protonwire:
        container_name: protonwire
        image: ghcr.io/tprasadtp/protonwire:latest
        init: true
        restart: unless-stopped
        environment:
        PROTONVPN_SERVER: nl-free-127.protonvpn.net
        cap_add:
        - NET_ADMIN
        sysctls:
        net.ipv4.conf.all.rp_filter: 2
        volumes:
        - type: tmpfs
            target: /tmp
        - type: bind
            source: private.key
            target: /etc/protonwire/private-key
            read_only: true
        # MUST include all the ports of other containers as well.
        ports:
        - 8000:80

    caddy_proxy:
        image: caddy:latest
        network_mode: service:protonwire
        command: |
        caddy reverse-proxy \
            --change-host-header \
            --from :80 \
            --to https://ip.me:443
    ```

> **Note**
> - It is **essential** to expose/publish port(s) _on protonwire container_, instead of your application.
> - You **SHOULD NOT** run the container as privileged. Adding capability `CAP_NET_ADMIN` **AND** defined `sysctls` should be sufficient.

## Podman

<p align="center">
  <a href="https://podman.io/" target="_blank" rel="noreferrer">
    <img src="https://raw.githubusercontent.com/containers/podman/a655633f2dcf3cce60bfce63d383d4e8e1ae67a2/logo/podman-logo-source.svg" height="48" alt="podman">
  </a>
</p>

- Create a podman secret for private key
    ```bash
    sudo podman create secret protonwire-private-key <PRIVATE_KEY>
    ```
    > **Warning**
    >
    > podman secrets are **NOT** encrypted at rest!

- Run protonwire container
    ```bash
    sudo podman run \
    --name protonwire \
    -it \
    --init \
    --replace \
    --tz local \
    --tmpfs /tmp \
    --port 8000:80 \
    --cap-add NET_ADMIN \
    --env PROTONVPN_SERVER=<SERVER-NAME> \
    --secret protonwire-private-key \
    --sysctl net.ipv4.conf.all.rp_filter=2 \
    ghcr.io/tprasadtp/protonwire:latest
    ```

    * If you wish to publish additional ports from other containers using this VPN (usually done via argument `-p host_port:container_port`), you will need to do it here on the `protonwire` container!
    * `--sysctl` and `--cap-add` flags are important! without these, container cannot create/manage WireGuard interface.

## Run container as systemd unit

- Use `podman` instead of docker as it has better support for systemd.
- You can run `protonwire` container as usual and the generate systemd unit for it via,
    ```bash
    podman generate systemd \
        --new \
        --name protonwire \
        --after network-online.target
    ```
- See [podman-generate-systemd](https://docs.podman.io/en/latest/markdown/podman-generate-systemd.1.html) for more info.

## Dependencies

Following dependencies are **in addition** to WireGuard support in Kernel.
See https://www.wireguard.com/install/ for more info. This step is only required
if running as systemd unit outside of containers.

- If running on Ubuntu, Linux Mint, Elementary OS and other **Ubuntu** based derivatives etc.

    - If using `systemd-resolved` (default),
        ```console
        sudo apt-get install curl jq procps iproute2 libcap2-bin policykit-1 util-linux wireguard-tools
        ```
    - Otherwise,
        ```console
        sudo apt-get install curl jq procps iproute2 libcap2-bin policykit-1 util-linux wireguard-tools openresolv
        ```

- If running on Debian, Raspberry Pi OS, and other **Debian** based derivatives etc

    - If using `systemd-resolved` (**NOT** default),
        ```console
        sudo apt-get install curl jq procps iproute2 libcap2-bin policykit-1 util-linux wireguard-tools
        ```
    - Otherwise,
        ```console
        sudo apt-get install curl jq procps iproute2 libcap2-bin policykit-1 wireguard-tools openresolv
        ```

- If running on  CentOS-Stream, Fedora 34+, Amazon Linux 2022, RHEL 9, Rocky Linux 9, Alma Linux 9

    - If using `systemd-resolved`  (default),
        ```console
        sudo dnf install curl jq procps-ng libcap iproute util-linux wireguard-tools
        ```

    - Otherwise,
        ```console
        sudo dnf install curl jq procps-ng libcap iproute util-linux wireguard-tools openresolv
        ```

- If running on  CentOS 8, RHEL 8, Rocky Linux 8, Alma Linux 8

    - If using `systemd-resolved` (NOT default),
        ```console
        sudo dnf install curl jq procps-ng libcap iproute util-linux wireguard-tools
        ```

    - Otherwise,
        ```console
        sudo dnf install curl jq procps-ng libcap iproute util-linux wireguard-tools openresolv
        ```

- If running on ArchLinux, Manjaro and other ArchLinux based distribution,

    - If using `systemd-resolved`,
        ```console
        sudo pacman -S curl jq procps-ng libcap iproute2 util-linux wireguard-tools systemd-resolvconf
        ```

    - Otherwise,
        ```console
        sudo pacman -S curl jq procps-ng libcap iproute2 util-linux wireguard-tools openresolv
        ```

## Installation

- You can install DEB or RPM packages from releases.
- Alternatively, you can clone this repository and run `sudo make install`

## Usage

- To connect to a server,
    ```bash
    sudo protonwire -k <KEY_FILE> connect <SERVER>
    ```
- To disconnect from server
    ```bash
    sudo protonwire disconnect
    ```
- To check/verify your connection
    ```bash
    sudo protonwire check
    ```

> Add `--debug` flag to see debug logs.

## Systemd Integrations

Provides rich systemd integration. Connected server and last verification time is displayed with `systemctl status protonwire`,

<pre><font color="#B8BB26"><b>vagrant@debian-minimal</b></font>:<font color="#83A598"><b>~</b></font>$ systemctl status protonwire.service --no-pager
<font color="#B8BB26"><b>●</b></font> protonwire.service - ProtonVPN Wireguard Client
     Loaded: loaded (/usr/lib/systemd/system/protonwire.service; enabled; vendor preset: enabled)
     Active: <font color="#B8BB26"><b>active (running)</b></font> since Wed 2023-04-12 17:55:07 UTC; 425ms ago
       Docs: man:protonwire(1)
             https://github.com/tprasadtp/protonvpn-docker
   Main PID: 21659 (protonwire)
     Status: &quot;Connected to nl-free-127.protonvpn.net (via 185.107.56.83, with KillSwitch)&quot;
         IP: 16.4K in, 5.1K out
      Tasks: 2 (limit: 2336)
     Memory: 2.4M
        CPU: 2.939s
     CGroup: /system.slice/protonwire.service
             ├─21659 /bin/bash /usr/bin/protonwire c --systemd
             └─22085 sleep 10
</pre>

### Requirements

- **MUST** have `CAP_NET_ADMIN` capability
- **MUST** set `NotifyAccess` to `all`
- **MUST** have access to `org.freedesktop.resolve1.*`, if using `systemd-resolved`.
- **MUST NOT** use `DynamicUser`. See [systemd/systemd#22737](https://github.com/systemd/systemd/issues/22737)

### Usage

- By default unit will load environment variables from files ending with `.env` extension from `/etc/protonwire/`. This is done by systemd not the unit executable/user. See `EnvironmentFile` in [systemd.exec(5)][] for more info.

- If [`systemd-creds`][systemd-creds] is available (requires systemd version 250 or above), you can use [drop-in][] units to supply credentials. see [this](https://systemd.io/CREDENTIALS/) for more info.

- If `systemd-creds` is not available, you can save key to in `/etc/protonwire/wireguard-private-key` or one of the search paths.

    - Create `/etc/protonwire` if it does not exist
        ```bash
        sudo mkdir -p /etc/protonwire
        ```
    - Create private key file, alternatively you can copy existing key file to this location.
        ```bash
        systemd-ask-password | sudo tee -a /etc/protonwire/private-key
        ```
    - Allow `systemd-network` group to access,
        ```bash
        sudo chown root:systemd-network /etc/protonwire/private-key
        ```
    - Ensure ony `root` can write to file, members of group `systemd-network` can read the file and others have no access to file.
        ```bash
        sudo chmod 640 /etc/protonwire/private-key
        ```
    > Script will refuse to use key file, if its is readable by others.

    > If running as non-root user(default), ensure unit's user has access to the key file. Using `SupplementaryGroup=systemd-network` and giving `systemd-network` group read access to key file.

- For non sensitive settings, you can use environment files(`.env`) in `/etc/protonwire/` They are loaded automatically be the default unit.
    ```bash
    # /etc/protonwire/settings.env
    PROTONVPN_SERVER="nl-free-127.protonvpn.net"
    ```

- If you installed or modified unit files, You must reload systemd via
    ```bash
    sudo systemctl daemon-reload
    ```
- You can enable VPN service via
    ```bash
    sudo systemctl enable protonwire
    ```
- You can start VPN service via
    ```bash
    sudo systemctl start protonwire
    ```
- You can stop VPN service via
    > **Warning**
    >
    > Units bound to protonwire unit will also be stopped.

    ```bash
    sudo systemctl stop protonwire
    ```

- You can check status of VPN service via
    ```bash
    systemctl status protonwire
    ```

- To check logs, you can use `journalctl -u protonwire`. You might have to prefix command with `sudo ` if you are not a member of `adm` group or `systemd-journal` group to see the logs.

- You can disable VPN service via
    ```bash
    sudo systemctl disable --now protonwire
    ```

### Watchdog

- Systemd watchdog feature is supported and enabled if `NOTIFY_SOCKET` and `WATCHDOG_USEC` are set.
- `IPCHECK_INTERVAL` or `--check-interval`, with non zero value cannot be used with watchdog as it creates conflicts.
- `WatchdogSec` cannot be less than 20 seconds.
- Default watchdog signal(`SIGABRT`) cannot be used with containers if you are using `--init` flag. You **MUST** set `WatchdogSignal=SIGTERM`. This is because both `tini` (docker) and `catatonit`(podman) do not forward this signal to their children.

## systemd-resolved Split Horizon DNS

- Split horizon DNS is only supported with `systemd-resolved` **AND** when **NOT** running in a container.
- It depends on `systemd-resolved` to be up and running and `/etc/resolv.conf` to be in stub resolver mode. `nss-resolve` is buggy as most statically compiled programs (especially Go) may break DNS resolution for
link specific domains.
- It also requires you to specify routing domains and/or search domains for your **local/non-vpn** networks, via DHCP options or via `resolvectl`
- By default script will set default routing domain on VPN interface.
- Run the command below for status of routing domains.
    ```bash
    resolvectl status --no-pager
    ```
- You can disable this integration by setting environment variable `SKIP_DNS_CONFIG` to `1` or via `--skip-dns-config` CLI flag.

### Dependent units

You can depend on this unit by adding **ALL** the properties below to `[Unit]` section in your dependent units. See [systemd.unit(5)][] for more info.

- [`BindsTo=protonwire.service`][BindsTo]
- [`Requisite=protonwire.service`][Requisite]
- [`After=protonwire.service`][After]

This setup ensures that service depending on VPN will be **ONLY** started when `protonwire` is activated. (You still have to `enable` dependent units) If for some reason protonwire service becomes un-healthy and exits, `BindsTo` ensures that dependent unit will be stopped.

If your system package already provides a systemd unit file, you can use [drop-in][] units to configure dependencies.

> Don't forget to run `sudo systemctl daemon-reload` upon updating/installing unit files.

## Troubleshooting & FAQ

See [Troubleshooting][] and [FAQ][]

## Building

Building requires `goreleaser`(v1.9+), and `docker` with `buildx` plugin.

```
make docker
```

[drop-in]: https://wiki.archlinux.org/title/systemd#Drop-in_files
[nss-resolve]: https://www.freedesktop.org/software/systemd/man/nss-resolve.html

[systemd.exec(5)]: https://www.freedesktop.org/software/systemd/man/systemd.exec.html
[systemd.unit(5)]: https://www.freedesktop.org/software/systemd/man/systemd.unit.html
[systemd-creds]: https://www.freedesktop.org/software/systemd/man/systemd-creds.html
[resolved.conf(5)]:https://www.freedesktop.org/software/systemd/man/resolved.conf.html
[systemd.network(5)]:https://www.freedesktop.org/software/systemd/man/systemd.network.html

[Requisite]: https://www.freedesktop.org/software/systemd/man/systemd.unit.html#Requisite=
[BindsTo]: https://www.freedesktop.org/software/systemd/man/systemd.unit.html#BindsTo=
[After]: https://www.freedesktop.org/software/systemd/man/systemd.unit.html#Before=
[RestrictNetworkInterfaces]: https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#RestrictNetworkInterfaces=
[systemd.resource-control(5)]: https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#RestrictNetworkInterfaces=

[ghcr]: https://ghcr.io/tprasadtp/protonwire
[releases]: https://github.com/tprasadtp/protonwire/releases/latest
[Troubleshooting]: ./docs/help.md
[FAQ]: ./docs/faq.md
