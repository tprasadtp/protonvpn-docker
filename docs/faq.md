## FAQ

## Why automatic server selection is not supported

- This is caused by changes to ProtonVPN API, which now requires authentication.
- Upstream API uses geo-location/latency to select "best" server with least amount of load. This information is returned via API (via field `.Score` and `.Load` on every `LogicalNode`) to the caller. Because 7.0.0 and later do not make API requests to ProtonVPN directly, but to a global cache, This geo-location/latency based automatic server selection is not supported.
- It might be possible to cache server load, but if the cache becomes stale fails to update,
it might result in a single VPN server to be selected as "best" and might cause issues upstream.
- It is possible to do some client side validations that a server supports features like P2P, steaming etc. by using `--p2p`, `--streaming`, `--secure-core` flags with connect/healthcheck command.

## WireGuard interface creation fails

```log
[TRACE   ] (ip-link) RTNETLINK answers: Not supported
[ERROR   ] WireGuard interface creation failed!
```

This typically happens on a older machine or NAS/embedded devices
as Wireguard support might not be present in the kernel.
Please visit https://www.wireguard.com/install/ or contact device manufacturer.

## How to check if an address is being routed via VPN via CLI

- Run `ip route get <ip-address>`
- If response is something like `<ip-address> dev protonwire0 table 51821 src 10.2.0.2 uid 0`,
then the IP address will be routed via VPN.

## How to check if systemd-resolved is in use

- If using Ubuntu/Fedora with defaults most likely using systemd-resolved is in use for local DNS.
- Run `resolvectl status --no-pager`. If it has `resolv.conf mode: stub`.  `systemd-resolved` is in use.

## Whats with route table 51821

- This route table is kept separate to avoid cluttering main route table and avoid conflicts.
- By default following subnets are _included_ in the route table.
    - `10.2.0.1/32` (_DNS server_)
    - `0.0.0.0/5`
    - `8.0.0.0/7`
    - `11.0.0.0/8`
    - `12.0.0.0/6`
    - `16.0.0.0/4`
    - `32.0.0.0/3`
    - `64.0.0.0/3`
    - `96.0.0.0/6`
    - `100.0.0.0/10`
    - `100.128.0.0/9`
    - `101.0.0.0/8`
    - `102.0.0.0/7`
    - `104.0.0.0/5`
    - `112.0.0.0/5`
    - `120.0.0.0/6`
    - `124.0.0.0/7`
    - `126.0.0.0/8`
    - `128.0.0.0/3`
    - `160.0.0.0/5`
    - `168.0.0.0/8`
    - `169.0.0.0/9`
    - `169.128.0.0/10`
    - `169.192.0.0/11`
    - `169.224.0.0/12`
    - `169.240.0.0/13`
    - `169.248.0.0/14`
    - `169.252.0.0/15`
    - `169.255.0.0/16`
    - `170.0.0.0/7`
    - `172.0.0.0/12`
    - `172.32.0.0/11`
    - `172.64.0.0/10`
    - `172.128.0.0/9`
    - `173.0.0.0/8`
    - `174.0.0.0/7`
    - `176.0.0.0/4`
    - `192.0.0.0/9`
    - `192.128.0.0/11`
    - `192.160.0.0/13`
    - `192.169.0.0/16`
    - `192.170.0.0/15`
    - `192.172.0.0/14`
    - `192.176.0.0/12`
    - `192.192.0.0/10`
    - `193.0.0.0/8`
    - `194.0.0.0/7`
    - `196.0.0.0/6`
    - `200.0.0.0/5`
    - `208.0.0.0/4`
    - `224.0.1.0/24`
    - `224.0.2.0/23`
    - `224.0.4.0/22`
    - `224.0.8.0/21`
    - `224.0.16.0/20`
    - `224.0.32.0/19`
    - `224.0.64.0/18`
    - `224.0.128.0/17`
    - `224.1.0.0/16`
    - `224.2.0.0/15`
    - `224.4.0.0/14`
    - `224.8.0.0/13`
    - `224.16.0.0/12`
    - `224.32.0.0/11`
    - `224.64.0.0/10`
    - `224.128.0.0/9`
    - `225.0.0.0/8`
    - `226.0.0.0/7`
    - `228.0.0.0/6`
    - `232.0.0.0/5`
    - `240.0.0.0/4`
    - `2000::/3` (Only if IPv6 is enabled)

> **Warning**
>
> - You should let protonwire manage this table.
> - Any modification to this table outside of protonwire CLI
> can lead to network connectivity issues. Though a reboot/restart
> should revert the state of route tables.
> - Any modifications made to this table might be lost.

## Whats with route table 51822

Route table 51822 is used for kill-switch in 7.0.3 and lower versions. Versions 7.1.0 and later
use single route table(51821) with route metrics for kill-switch implementation.
Script **WILL** flush this routing table automatically if found to be non empty.

## NAT and KeepAlive packets

WireGuard is not a chatty protocol. However for _most_ if not all use cases, end user devices are using some form of NAT via docker, Kubernetes, home router or some other means. So _Keep alive_ is enabled and set to 20 seconds which should be enough for almost all NAT firewalls.

## Split horizon DNS

- This is only possible with `systemd-resolved`. After connecting to VPN (via `protonwire connect <SERVER>`). Verify split dns configuration using `resolvectl query <domain>` and check the interface being used to resolve it.
- Ensure that DHCP server/router or VPN gateway advertises search domains. They will be automatically picked up if using NetworkManager(most desktops) or `systemd-networkd` (most servers) or `ifupdown` hooks.

## Running systemd unit as non-root user

- Unit **MUST** have `CAP_NET_ADMIN` capability
- Unit **MUST NOT** run as DynamicUser
- Unit **MUST NOT** use `RemoveIPC=yes`
- You **MUST** use `systemd-resolved` for DNS
- If using `systemd-resolved`, polkit rules **MUST** allow unit's user to invoke to following D-Bus actions
    - `org.freedesktop.resolve1.set-dns-servers`
    - `org.freedesktop.resolve1.set-domains`
    - `org.freedesktop.resolve1.set-default-route`
    - `org.freedesktop.resolve1.revert`
    - `org.freedesktop.resolve1.set-dnssec`

## Use with corporate/other VPN

- If other VPN routes only private subnets you don't need to do anything! It just works!
- Just make sure there search domain/routing domains are set on your corporate/other VPN interface (`resolvectl domain`) so that DNS queries for those domains will be resolved correctly.

## Use with Tailscale

Tailscale uses its own fwmark, routing table and routing rules.
Because Tailscale addresses are CGNAT addresses and have fwmark on the packets
passing via tailscale interface, it _just works_. Zero configuration changes required!

## How to see WireGuard settings

```bash
wg show
```

## Non reachable LAN hosts

Following addresses on local network or other VPNs **cannot** be reached when ProtonVPN is active. This is the way ProtonVPN is setup on server side and **CANNOT** be changed!
Also these addresses cannot belong to any __other__ interfaces on the machine/container running protonwire.
- 10.2.0.1 (used by server and as DNS server)
- 10.2.0.2 (used by client)

## IP check endpoint URLs

You can use any of the following services for verification. They **MUST RETURN ONLY your public IP address**.
  * https://protonwire-api.vercel.app/v1/client/ip (default)
  * https://icanhazip.com/
  * https://checkip.amazonaws.com/

> **Warning**
>
> Do not use ip.me as health-check endpoint, as they seem to do
> user agent whitelisting and return html page, when user agent
> does not contain string `curl` or `wget` or `requests`.
>
> ```console
> curl -si -H "User-Agent: Go-http-client/1.1" https://ip.me/ -o /dev/null -D -
> HTTP/1.1 200 OK
> Server: nginx/1.18.0
> Date: Fri, 07 Apr 2023 22:26:15 GMT
> Content-Type: text/html; charset=utf-8
> Content-Length: 14626
> Connection: keep-alive
> ```

## Metadata updates

Metadata updates includes updating server IPs, feature flags on servers, exit IPs and their public keys.
It also applies some workarounds to API quirks or bugs. Usually it should be automatic.
But Proton API and libraries are in constant state of ~~chaos~~ flux
and documentation is virtually non-existent or incorrect. So stuff might break.
Bulk of the work is done via `scripts/generate-server-metadata`

## Known Issues

- Running multiple instances of this __outside of containers__ is not supported.

## Known Bugs in Upstream API/libraries

> Proton API and libraries are in constant state of ~~chaos~~ development and documentation is ~~virtually~~ actually non-existent.

- Some servers appear to flip flop between ONLINE and OFFLINE state in loop (like every hour), appear and disappear randomly (sometimes just two servers weirdly appearing and disappearing every hour or so).
- Server's Entry IP sometimes appears to be its ExitIP and sometimes Exit IP of some other
server is the assigned public IP.
- Some ExitIPs do not appear **anywhere** in the response returned by `/vpn/logicals`
