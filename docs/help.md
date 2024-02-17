# Troubleshooting

## Exit IP mismatch even though VPN connects

- ProtonVPN separates entry IP from exit IP using internal routing.
Script should take care of that by adding IPs of servers in the same pool to list of allowed IP addresses.

- However, ProtonVPN API is **inconsistent**. Sometimes, Node's `ExitIP` is **NOT** listed at all! _Sigh!_ in case that happens, disable IP checks with `--check-interval 0` or set `IPCHECK_INTERVAL` environment variable to `0`. Only ProtonVPN can fix this as it happens on server side!

    ```log
    [ERROR] Retry (3/3) after 8 seconds
    [ERROR] Your current IP address - 92.119.179.XX is not in the list for Server NL-FREE#27
    [ERROR] Your current IP address - 92.119.179.XX must belong to set (92.119.179.83 92.119.179.84 92.119.179.85 92.119.179.86 92.119.179.82)
    [ERROR] Failed to verify connection!
    ```

## Unable to verify connection/resolve DNS at https://protonwire-api.vercel.app/v1/client/ip

It appears that ProtonVPN DNS servers are blocking connection to `https://protonwire-api.vercel.app/v1/client/ip` when Netshield option is set to `Block malware, ads and trackers`.
This IP endpoint simply redirects a valid IPcheck endpoint which works for most users, currently set to `https://icanhazip.com`. It is [controlled by cloudflare and is hosted on cloudflare workers](https://major.io/p/a-new-future-for-icanhazip/). It is not a malware/tracker. Please ask Proton Support to either remove it from their blocklist, use another `IPCHECK_URL` endpoint, or set Netshield option to `Block malware only`
Following `IPCHECK_URL` endpoints can be used.

- `https://checkip.amazonaws.com/` (may not work with IPv6 servers)
- `https://api.ipify.org/`

Alternatively, you can host your own `IPCHECK_URL` endpoint on cloudflare workers using the snippet below.
The snippet below will not work in worker's preview pane as it depends on
[cf-headers](https://developers.cloudflare.com/fundamentals/get-started/reference/http-request-headers/#cf-connecting-ip), but will work just fine outside of worker's preview pane.

```js
addEventListener("fetch", (event) => {
  event.respondWith(
    handleRequest(event.request).catch(
      (err) => new Response(err.stack, { status: 500 })
    )
  );
});

async function handleRequest(request) {
  return new Response(request.headers.get("CF-Connecting-IP"))
}
```

## Failed to refresh ProtonVPN server metadata (server name is invalid or not found)

Please verify that server name is valid and is online. Proton sometimes changes server names
and thus it may be unavailable. It is recommended to use DNS name like `node-nl-03.protonvpn.net`
instead of server name like `NL-FREE#343013`.

- Log in to ProtonVPN and go to **Downloads** → **WireGuard configuration**.
- Verify that server you are trying to connect is listed, available and is online.
- Use little down arrow to copy server's DNS name to be used as `PROTONVPN_SERVER`.

## tmpfs or `/tmp` issues with containers

Please use `tmpfs` mounts for `/tmp`

- For docker use `--mount type=tmpfs,destination=/tmp`
- For docker-compose see [docker-compse-volumes].
- For Kubernetes pods, use `emptyDir` with `emptyDir.medium` field to `Memory` See [emptyDir] for more info.

## WireGuard interface creation fails

```log
[TRACE   ] (ip-link) RTNETLINK answers: Not supported
[ERROR   ] WireGuard interface creation failed!
```

This typically happens on a older machine or NAS/embedded devices
as Wireguard support might not be present in the kernel.
Please visit https://www.wireguard.com/install/ or contact device manufacturer.

## Server DNS name is not available or unknown

If for some reason you are not able to get server DNS name, and server name does not work
for you, Try using IP address as `PROTONVPN_SERVER` or as CLI argument. IP address of server
can be obtained from `[Peer]` section of the generated WireGuard configuration.

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

In the above example, server's IP address is `91.229.23.180`. Use it as value for `PROTONVPN_SERVER`.
If using docker-compose or kubernetes _do not forget to quote it_ to avoid any weird YAML issues.

> This may not work for IPv6 servers and should be considered experimental.


## DNS leak protection and Kubernetes

On Kubernetes using ProtonVPN DNS **WILL** break resolving `.cluster` domains. You can use [external-dns](https://github.com/kubernetes-sigs/external-dns) and use public DNS zones for your hosted services or use DoH or DoT on kubernetes **nodes** and use `SKIP_DNS_CONFIG` or `--skip-dns-config`.

## My public IP is not same as EndpointIP

Your public IP might be different than `Endpoint` as shown by `wg show` command. This is due to ProtonVPN's internal routing which happens on server side.

## Container is not accessible from LAN or Services within LAN are not accessible within the container

- Check if you are using IPv6 only. If yes, prefix delegation might be in use and your LAN hosts will have a Public IPv6 address. You will need to tweak `PROTONVPN_ALLOWED_SUBNETS_IPV6` to **exclude** your prefix. You can use https://www.procustodibus.com/blog/2021/03/wireguard-allowedips-calculator/
to calculate `PROTONVPN_ALLOWED_SUBNETS_IPV6`.
- Check your firewall rules.

## User namespaces and file permissions

User namespaces can cause file permission issues. If you have problem accessing mounted secret files or sharing network stack, disable user namespaces for the container.

## Systemd watchdog keeps killing the service

- Check if its `IP mismatch` error
- Try switching servers
- If you keep encountering this issue, you can disable IP checks with by setting `IPCHECK_INTERVAL` to `0` or `--check-interval 0`.

## Cannot update DNS, /etc/resolv.conf is not writable

Try to run as `root` and ensure /etc/resolv.conf is writable.

## Transport endpoint is not connected errors when using systemd

Turn off `DynamicUser` and `RemoveIPC` from you unit configuration and reload systemd.

## Systemd unit failed with some error

- Disable systemd unit `protonwire.service` for debugging.
- Run transient unit via `systemd-run`
    ```
    sudo systemd-run \
        --pty \
        --same-dir \
        --wait \
        --collect \
        --unit=protonwire-run.service \
        --service-type=notify \
        --property="Description=ProtonVPN Wireguard Client" \
        --property="Documentation=man:protonwire(1)" \
        --property="Documentation=https://github.com/tprasadtp/protonvpn-docker" \
        --property="SupplementaryGroups=systemd-network" \
        --property="NotifyAccess=all" \
        --property="User=protonwire" \
        --property="Group=protonwire" \
        --property="SupplementaryGroups=systemd-network" \
        --property="Environment=HOME=/var/lib/protonwire" \
        --property="Environment=LANG=C.UTF-8" \
        --property="EnvironmentFile=-/etc/defaults/protonwire" \
        --property="EnvironmentFile=-/etc/protonwire/*.env" \
        --property="AmbientCapabilities=CAP_NET_ADMIN" \
        --property="CapabilityBoundingSet=CAP_NET_ADMIN" \
        --property="SystemCallFilter=@system-service" \
        --property="SystemCallArchitectures=native" \
        --property="ProtectProc=invisible" \
        --property="ProtectHostname=true" \
        --property="PrivateTmp=yes" \
        --property="ProtectControlGroups=true" \
        --property="ProtectKernelModules=true" \
        --property="ProtectKernelTunables=true" \
        --property="ProtectKernelLogs=true" \
        --property="KeyringMode=private" \
        --property="RestrictNamespaces=true" \
        --property="LockPersonality=true" \
        --property="MemoryDenyWriteExecute=true" \
        --property="RestrictSUIDSGID=true" \
        --property="PrivateTmp=yes" \
        --property="ProtectSystem=full" \
        --property="StateDirectory=protonwire" \
        --property="CacheDirectory=protonwire" \
        --property="RuntimeDirectory=protonwire" \
        --property="RuntimeDirectoryPreserve=restart" \
        --property="IPAccounting=true" \
        --property="CPUAccounting=true" \
        --property="BlockIOAccounting=true" \
        --property="MemoryAccounting=true" \
        --property="TasksAccounting=true" \
        --property="WatchdogSec=20" \
        --property="TimeoutAbortSec=30" \
        --property="TimeoutStopSec=30" \
        --property="TimeoutStartSec=180" \
        protonwire connect --debug <server-name>
    ```

## Manually Disconnecting from VPN

Please use `protonwire disconnect --kill-switch` as it handles things properly. If not possible, try the following.

- Restore the DNS if using systemd-resolved via,
    ```
    resolvectl revert protonwire0
    ```
- If **NOT** using systemd-resolved (like in containers) restore the DNS using following commands.
    ```bash
    cat /etc/resolv.conf.protonwire > /etc/resolv.conf && rm /etc/resolv.conf.protonwire
    ```
- Remove routing rules and interfaces
    ```bash
    ip -4 rule del not fwmark 51821 table 51821
    ip -6 rule del not fwmark 51821 table 51821
    ip -4 route flush table 51821
    ip -6 route flush table 51821
    ip link del protonwire0
    ```

[emptyDir]: https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
[docker-compse-volumes]: https://docs.docker.com/compose/compose-file/compose-file-v3/#long-syntax-3
