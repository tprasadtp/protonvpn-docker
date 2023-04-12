## FAQ

## Why automatic server selection is not supported

- This is caused by API changes ProtonVPN.
- To automatic server selection, it requires authenticating  to proton API via username and password!.
There are no scoped oauth tokens and minted access tokens have full access to Proton API including payments and Email!!.
- Fastest server selection also depends on geo-location and latency info to populate server `.Score`.
Due to lack of documentation on how `.Score` is computed, automatic server selection is not supported.

## How to check if an address is being routed via VPN via CLI

- Run `ip route get <ip-address>`
- If response is something like `<ip-address> dev protonwire0 table 51821 src 10.2.0.2 uid 0`,
then the IP address will be routed via VPN.

## How to check if systemd-resolved is in use

- If you are using Ubuntu/Fedora with defaults you are most likely using systemd-resolved for local DNS.
- Run `resolvectl status --no-pager`. If it has `resolv.conf mode: stub`.  you are using `systemd-resolved`.

## What with route table 51821 and 51822

- We keep route table separate (`51821` for wireguard routing and `51822` for killswitch).
- By default we _include_ following subnets in the route table.
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
- For IPV6 we _include_ `2000::/3` as it excludes almost all _reserved_ addresses.

## NAT and KeepAlive packets

WireGuard is not a chatty protocol. However for _most_ if not all use cases, end user devices are using some form of NAT via docker, Kubernetes, home router or some other means. So _Keep alive_ is enabled and set to 20 seconds which should be enough for almost all NAT firewalls.

## Split horizon DNS

- This is only possible with `systemd-resolved`. After connecting to VPN (`protonwire connect`) You can verify split dns configuration via `resolvectl query <domain>` and check the interface being used to resolve it.
Please ensure to use stub resolver mode as many statically built programs (Especially go/rust programs) do not use `nss-resolve` and directly read `/etc/resolv.conf`.
- Please ensure that your DHCP server/router or VPN gateway advertises search domains. They will be automatically picked up if using NetworkManager(most desktops) or `systemd-networkd` (most servers) or `ifupdown`.

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

- If other VPN routes only private subnets you don't need to do anything! It just works! Just make sure there search domain/routing domains are set on your corporate/other VPN interface (`resolvectl domain`) so that DNS queries for those domains will be resolved correctly.

## How can I see WireGuard settings

```bash
wg show
```

## Non reachable LAN hosts

Following addresses on local network or other VPNs **cannot** be reached when ProtonVPN is active. This is the way ProtonVPN is setup on server side and **CANNOT** be changed!
Also these addresses cannot belong to any __other__ interfaces on the machine/container running protonwire.
- 10.2.0.1 (used by server and as DNS server)
- 10.2.0.2 (used by client)

## IP check endpoints

You can use any of the following services for verification as they return your _public_ IP address.
  * https://icanhazip.com/
  * https://api.ipify.org/
  * https://checkip.amazonaws.com/

> **Warning**
>
> Do not use ip.me, as they seem to do user agent whitelisting and return html page
> when user agent does not contain `curl` or `wget` or `requests`. (Sigh!)
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
>

## Metadata updates

Metadata updates includes updating server IPs, feature flags on servers, exit IPs and their public keys.
It also applies some workarounds to API quirks or bugs. Usually it should be automatic.
But Proton API and libraries are in constant state of ~~chaos~~ flux
and documentation is virtually non-existent or incorrect. So stuff might break.
Bulk of the work is done via `scripts/generate-server-metadata`

## Known Issues

- Running multiple instances of this __outside of containers__ is not supported.

## Known Bugs in Upstream API/libraries

> Proton API and libraries are in constant state of ~~chaos~~ ~~broken~~ ~~borderline usable~~
~~evolution~~ ~~upgrade~~ ~~development~~ ~~buggy~~ ~~flux~~ ~~inconsistency~~
unstability and documentation is ~~virtually~~ actually non-existent or incorrect.

- Some servers appear to  rename themselves and flip flop between ONLINE and OFFLINE state in loop (like every hour), appear and disappear randomly (sometimes just two servers weirdly appearing and disappearing every hour or so).
- Server's Entry IP sometimes appears to be its ExitIP and sometimes Exit IP of some other
server is the assigned public IP.
- Some ExitIPs do not appear **anywhere** in the response returned by `/logicals` (Yes, this is after authenticating)
- Proton libraries use all sorts of weird things like weird singletons, deeply nested wrappers
for simplest of things and are incredibly inconsistent. The auth library is is just useless.
