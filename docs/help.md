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

Please verify that server name is valid and is online.

Proton sometimes changes server names and thus it may be unavailable.
It is recommended to use DNS name like `node-nl-03.protonvpn.net` or
IP addresses instead of server name like `NL-FREE#343013`.

IP address of server can be obtained from `[Peer]` section of the generated
WireGuard configuration.

```ini
[Interface]
# Key for <name>
# VPN Accelerator = on
PrivateKey = KLjfIMiuxPskM4+DaSUDmL2uSIYKJ9Wap+CHvs0Lfkw=
Address = 10.2.0.2/32
DNS = 10.2.0.1

[Peer]
# NL-FREE#343013
PublicKey = MTNPR632U9GOxI+B8dMP+KgMJVEO2xQPrem2SuDfTkM=
AllowedIPs = 0.0.0.0/0
Endpoint = 89.39.107.188:51820
```

In the above example, server's IP address is `89.39.107.188`. Use it as value for `PROTONVPN_SERVER`.
If using docker-compose or kubernetes _do not forget to quote it_ to avoid any weird YAML issues.

Alternatively, you can use `server-info` sub command to get all server metadata and attributes.

> [!IMPORTANT]
>
> This Requires protonwire version `7.3.0-beta3` or later.
> This may not work for IPv6 servers and should be considered experimental.

```bash
protonwire server-info {SERVER_NAME_OR_IP}
```

```console
[•] Refresing server metadata (for node-nl-03.protonvpn.net)
[•] Successfully refreshed server metadata
[•] Server Status        : ONLINE
[•] Server Name          : NL-FREE#343013
[•] Server DNS Name      : node-nl-03.protonvpn.net
[•] Feature (Streaming)  : false
[•] Feature (P2P)        : false
[•] Feature (SecureCore) : false
[•] Exit IPs             : 89.39.107.188 89.39.107.202 89.39.107.203 89.39.107.204 89.39.107.205
[•] 89.39.107.188        : MTNPR632U9GOxI+B8dMP+KgMJVEO2xQPrem2SuDfTkM= (Public Key)
```

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

## Cannot update DNS, /etc/resolv.conf is not writable

Try to run as `root` and ensure /etc/resolv.conf is writable.

## Manually Disconnecting from VPN

Please use `protonwire disconnect --kill-switch` as it handles things properly. If not possible, try the following.

- Restore the DNS using following commands.
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
