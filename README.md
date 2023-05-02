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
    <img src="https://img.shields.io/badge/dynamic/json?label=metadata&query=timestamp&url=https%3A%2F%2Fprotonwire-api.vercel.app&logo=protonvpn&labelColor=3a3a3a&logoColor=white&color=7f50a6" height="24" alt="badge-metadata">
  </a>
  <a href="https://protonwire-api.vercel.app/" target="_blank" rel="noreferrer">
    <img src="https://img.shields.io/badge/dynamic/json?label=servers&query=server_count&url=https%3A%2F%2Fprotonwire-api.vercel.app&logo=protonvpn&labelColor=3a3a3a&logoColor=white&color=7f50a6" height="24" alt="badge-server-count">
  </a>
  <a href="https://github.com/tprasadtp/protonwire-api" target="_blank" rel="noreferrer">
    <img src="https://img.shields.io/badge/dynamic/json?label=commit&query=commit&url=https%3A%2F%2Fprotonwire-api.vercel.app%2Fcommit.json&logo=git&labelColor=3a3a3a&logoColor=white&color=7f50a6" height="24" alt="badge-metadata-commit">
  </a>
</p>

## Features

- LAN, private and Tailscale networks remain accessible and are not routed over VPN.
**No special configuration required**.
- Supports split horizon DNS **automatically**, if `systemd-resolved` is in use.
- Supports running as systemd unit (natively and as podman container)
- Supports roaming clients

> **Note**
>
> For old OpenVPN based container's documentation,
> See [here](https://github.com/tprasadtp/protonvpn-docker/tree/release/v5).

## Container Images

> **Warning**
>
> [gVisor](https://gvisor.dev) runtime is **NOT** supported!

Images are published at [ghcr.io/tprasadtp/protonwire][ghcr].

## Linux Kernel Requirements

- If using Debian 11 (Buster) or later, Raspberry Pi OS (Buster) or later, Fedora, ArchLinux, Linux Mint 20.x or later, RHEL 9 or later, Alma Linux 9 or later, CentOS 9 Stream, Ubuntu 20.04 or later have the required kernel module built-in.
- Kernel versions 5.6 or later.
- If **NONE** of the above conditions can be satisfied, install WireGuard. Your distribution might already package DKMS module or provide signed kernels with WireGuard built-in. Visit https://www.wireguard.com/install/ for more info.
    > **Note**
    >
    > If running as a container, Wireguard **MUST** be installed on the host, **not** the container.

- To check current kernel version run,
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
- Only thing needed from the above config is `PrivateKey`.
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

This should be server name like `NL#1`(or `NL-1`) or domain name like,
`node-nl-01.protonvpn.net` (recommended). Automatic server selection
by setting `PROTONVPN_SERVER` to `P2P`, `RANDOM` etc are **NOT SUPPORTED**.

See [this](https://github.com/tprasadtp/protonvpn-docker/blob/master/docs/faq.md#why-automatic-server-selection-is-not-supported) for more info.

> **Warning**
>
> - Script cannot validate if specified server is available under your plan.
> It is user's responsibility to ensure that server specified is available
> under your subscription and supports required features, like P2P, Streaming etc.
> Use `--p2p`, `--streaming`, `--secure-core` flags to enable client side validations.

## KillSwitch

> **Warning**
>
> This Feature is experimental and is not covered by semver compatibility guarantees.

Kill-Switch is not a hard kill-switch but more of an "internet" kill-switch.
LAN addresses, Link-Local addresses and CGNAT(also Tailscale) addresses
remain reachable. Unlike most VPN containers, kill-switch is implemented via
routing policies, rather than firewall rules.

- Kill-switch will not be disabled during reconnects or disconnect unless `--ks`
flag is also specified.
- Using kill-switch with systemd unit **AND** using `protonwire` CLI manually
in some edge cases create duplicate kill-switch routing policies.
- Using kill-switch with systemd unit **AND** using `protonwire` to manually
disable kill-switch will lead to kill-switch being re-created during service restarts.
- Using kill-switch with systemd unit **AND** using `protonwire` to manually
disable kill-switch can lead to unit-errors as conflicting route priorities
can be created.


## Usage

<!--diana::dynamic:protonwire-help:begin-->
<pre>

ProtonVPN WireGuard Client

Usage: protonwire [OPTIONS...]
or: protonwire [OPTIONS...] c|connect [SERVER]
or: protonwire [OPTIONS...] d|disconnect
or: protonwire [OPTIONS...] check
or: protonwire [OPTIONS...] disable-killswitch
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
      --p2p                     Verify if server supports P2P
      --streaming               Verify if server supports streaming
      --tor                     Verify if server supports Tor
      --secure-core             Verify if server supports secure core
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
  PROTONVPN_SERVER              ProtonVPN server name
  IPCHECK_INTERVAL              Custom IP check interval in seconds
  SKIP_DNS_CONFIG               Set to '1' to skip configuring DNS
  KILL_SWITCH                   Set to '1' to enable killswitch (Experimental)
  DEBUG                         Set to '1' to enable debug logs
</pre>
<!--diana::dynamic:protonwire-help:end-->

## Health-checks

- Script supports `healthcheck` command. By default, when running as a service script will keep checking every `IPCHECK_INTERVAL` _(default=60)_ seconds using the `IPCHECK_URL` api endpoint. To disable healthchecks entirely set `IPCHECK_INTERVAL` to `0`
- Use `protonwire healthcheck --silent --container` as the `HEALTHCHECK` command.
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
    > **Warning**
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
        --name=protonwire-demo \
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

If entire stack is in a single compose file, then `network_mode: service:protonwire` on the services which should be routed via VPN. If the VPN stack is **NOT** in same compose file use `network_mode: container:<protonwire-container-name>`.

As an example, run caddy web-server, proxying https://ip.me, via VPN using the compose config given below. Once the stack is up, visiting the http://localhost:8000, or `curl -s http://localhost:8000` should show VPN's country and IP address.

<!--diana::dynamic:protonwire-sample-compose-file:begin-->
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
    # NET_ADMIN capability is mandatory!
    cap_add:
      - NET_ADMIN
    # sysctl net.ipv4.conf.all.rp_filter is mandatory!
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


> **Note**
>
> - It is **essential** to expose/publish port(s) _on protonwire container_, instead of application container.
> - **SHOULD NOT** run the container as privileged. Adding capability `CAP_NET_ADMIN` **AND** defined `sysctls` should be sufficient.

## Podman

<p align="center">
  <a href="https://podman.io/" target="_blank" rel="noreferrer">
    <img src="https://raw.githubusercontent.com/containers/podman/a655633f2dcf3cce60bfce63d383d4e8e1ae67a2/logo/podman-logo-source.svg" height="48" alt="podman">
  </a>
</p>

> **Warning**
>
> - podman versions older than v4 (one included in Debian 11/Ubuntu 22.04 repos)
> are **NOT** supported. It might be possible to use it to run the container,
> but some flags and commands are missing(`--sysctl` flag on pod create,
> `podman secret` commands etc.) and thus cannot be __supported__,
> but may be used without those features.

- Create a podman secret for private key
    ```bash
    sudo podman secret create protonwire-private-key <PRIVATE_KEY>
    ```

- Run protonwire container
    ```bash
    sudo podman run \
        -it \
        --rm \
        --name protonwire \
        --init \
        --tz local \
        --tmpfs /tmp \
        --cap-add=NET_ADMIN \
        --sysctl=net.ipv4.conf.all.rp_filter=2 \
        --secret private-key,mode=600  \
        --env PROTONVPN_SERVER=<SERVER-NAME> \
        --publish 8000:80 \
        ghcr.io/tprasadtp/protonwire:latest
    ```

    > **Warning**
    >
    > * To publish additional ports from other containers using this VPN (usually done via argument
    > `-p host_port:container_port`), it **MUST** be done on the `protonwire` container!
    > * `--sysctl` and `--cap-add` flags are important! without these, container cannot create/manage
    > WireGuard interface.
    > * `mode=600` in secret mounting is important as script refuses to use private key with insecure
    > permissions.
    > * podman rootless should also work just fine for most users, but is considered experimental.

- To use VPN in other container(s), use `--net=container:protonwire` flag.
For example, we can run caddy to proxy `https://ip.me` via VPN. Visiting http://localhost:8000, or `curl http://localhost:8000` should show VPN's country and IP address.

    ```console
    sudo podman run \
        -it  \
        --rm \
        --name=protonwire-demo \
        --net=container:protonwire \
        caddy:latest \
        caddy reverse-proxy \
        --change-host-header \
        --from :80 \
        --to https://ip.me:443
    ```

## Run podman container as systemd unit

[podman-generate-systemd](https://docs.podman.io/en/latest/markdown/podman-generate-systemd.1.html)
can be used to generate systemd unit files for the entire pod.

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
        sudo dnf install curl jq procps-ng libcap iproute polkit util-linux wireguard-tools
        ```

    - Otherwise,
        ```console
        sudo dnf install curl jq procps-ng libcap iproute polkit util-linux wireguard-tools openresolv
        ```

- If running on  CentOS 8, RHEL 8, Rocky Linux 8, Alma Linux 8

    - If using `systemd-resolved` (NOT default),
        ```console
        sudo dnf install curl jq procps-ng libcap iproute polkit util-linux wireguard-tools
        ```

    - Otherwise,
        ```console
        sudo dnf install curl jq procps-ng libcap iproute polkit util-linux wireguard-tools openresolv
        ```

- If running on ArchLinux, Manjaro and other ArchLinux based distribution,

    - If using `systemd-resolved`,
        ```console
        sudo pacman -S curl jq procps-ng libcap iproute2 polkit util-linux wireguard-tools systemd-resolvconf
        ```

## Installation

- Install DEB or RPM packages from releases.
- Alternatively, clone this repository and run `sudo make install`

## Usage

- To connect to a server,
    ```bash
    sudo protonwire -k <KEY_FILE> connect <SERVER>
    ```
- To disconnect from server
    ```bash
    sudo protonwire disconnect
    ```
- To check/verify connection
    ```bash
    sudo protonwire check
    ```

> **Note**
>
> Add `--debug` flag to see debug logs.

## Systemd Integrations

Provides rich systemd integration. Connected server kill-switch state is displayed with
`systemctl status protonwire`.

<pre><font color="#B8BB26"><b>vagrant@debian-minimal</b></font>:<font color="#83A598"><b>~</b></font>$ systemctl status protonwire --no-pager
<font color="#B8BB26"><b>●</b></font> protonwire.service - ProtonVPN Wireguard Client
     Loaded: loaded (/usr/local/lib/systemd/system/protonwire.service; disabled; vendor preset: enabled)
     Active: <font color="#B8BB26"><b>active (running)</b></font> since Wed 2023-04-12 21:17:31 UTC; 2min 47s ago
       Docs: man:protonwire(1)
             https://github.com/tprasadtp/protonvpn-docker
   Main PID: 7298 (protonwire)
     Status: &quot;Connected to nl-free-127.protonvpn.net (via 185.107.56.83, with KillSwitch)&quot;
         IP: 36.4K in, 11.6K out
      Tasks: 2 (limit: 2336)
     Memory: 2.3M
        CPU: 2.302s
     CGroup: /system.slice/protonwire.service
             ├─7298 /bin/bash /usr/local/bin/protonwire connect --systemd --logfmt journald
             └─8236 sleep 60
</pre>

### Requirements

- **MUST** have `CAP_NET_ADMIN` capability
- **MUST** set `NotifyAccess` to `all`
- **MUST** have access to `org.freedesktop.resolve1.*`, if using `systemd-resolved`.
- **MUST NOT** use `DynamicUser`. See [systemd/systemd#22737](https://github.com/systemd/systemd/issues/22737)

### Usage

- By default unit will load environment variables from files ending with `.env` extension from `/etc/protonwire/`. This is done by systemd not the unit executable/user. See `EnvironmentFile` in [systemd.exec(5)][] for more info.

- If [`systemd-creds`][systemd-creds] is available (requires systemd version 250 or above),  use [drop-in][] units to supply credentials. see [this](https://systemd.io/CREDENTIALS/) for more info.

- If `systemd-creds` is not available, save key to in `/etc/protonwire/wireguard-private-key` or one of the search paths.

    - Create `/etc/protonwire` if it does not exist
        ```bash
        sudo mkdir -p /etc/protonwire
        ```
    - Create private key file, alternatively copy existing key file to this location.
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

- For non sensitive settings, use environment files(`.env`) in `/etc/protonwire/` They are loaded automatically be the default unit.
    ```bash
    # /etc/protonwire/settings.env
    PROTONVPN_SERVER="nl-free-127.protonvpn.net"
    ```

- Reload systemd
    ```bash
    sudo systemctl daemon-reload
    ```
- Enable protonwire service via
    ```bash
    sudo systemctl enable protonwire
    ```
- Start protonwire service via
    ```bash
    sudo systemctl start protonwire
    ```
-  Stop VPN service via
    > **Warning**
    >
    > Units bound to protonwire unit will also be stopped.

    ```bash
    sudo systemctl stop protonwire
    ```

- Check status of VPN service via
    ```bash
    systemctl status protonwire
    ```

- To check logs, use `journalctl -u protonwire`.
- Disable VPN service via
    ```bash
    sudo systemctl disable --now protonwire
    sudo protonwire disable-ks
    ```

### Watchdog

- Systemd watchdog feature is supported and enabled if `NOTIFY_SOCKET` and `WATCHDOG_USEC` are set.
- `IPCHECK_INTERVAL` or `--check-interval`, with non zero value cannot be used with watchdog as it creates conflicts.
- `WatchdogSec` cannot be less than 20 seconds.
- Default watchdog signal(`SIGABRT`) cannot be used with containers if with `--init` flag.
**MUST** set `WatchdogSignal=SIGTERM` as both `tini` (docker) and `catatonit`(podman) do not forward this signal to their children.

## systemd-resolved Split Horizon DNS

- Split horizon DNS is only supported with `systemd-resolved` **AND** when **NOT** running in a container.
- It depends on `systemd-resolved` to be up and running and `/etc/resolv.conf` to be in stub resolver mode. `nss-resolve` is buggy as most statically compiled programs (especially Go) may break DNS resolution for
link specific domains.
- It also requires specifying routing domains and/or search domains for **local/other-vpn** networks, via DHCP options or via `resolvectl`
- By default script will set default routing domain on VPN interface.
- Run the command below for status of routing domains.
    ```bash
    resolvectl status --no-pager
    ```
- Disable `systemd-resolved` integration by setting environment variable `SKIP_DNS_CONFIG` to `1`
or via `--skip-dns-config` CLI flag.

### Dependent units

Depend on `protonwire` unit by adding **ALL** the properties below to `[Unit]` section in
dependent units. See [systemd.unit(5)][] for more info.

- [`BindsTo=protonwire.service`][BindsTo]
- [`Requisite=protonwire.service`][Requisite]
- [`After=protonwire.service`][After]

This setup ensures that service depending on VPN will be **ONLY** started when `protonwire` is activated. (Dependent units still have to be enabled) If for some reason protonwire service becomes un-healthy and exits, `BindsTo` ensures that dependent unit will be stopped.

If system package already provides a systemd unit file for the service, use [drop-in][] units to configure dependencies.

> **Note**
>
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
