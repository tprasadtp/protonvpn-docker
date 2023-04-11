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

## tmpfs or `/tmp` issues with containers

Please use `tmpfs` mounts for `/tmp`

- For docker use `--mount type=tmpfs,destination=/tmp`
- For docker-compose see [docker-compse-volumes].
- For Kubernetes pods, use `emptyDir` with `emptyDir.medium` field to `Memory` See [emptyDir] for more info.

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

- Try to run as `root` and ensure /etc/resolv.conf is writable.

## Transport endpoint is not connected errors when using systemd

- Turn off `DynamicUser` and `RemoveIPC` from you unit configuration and reload systemd.

## Manually Disabling Kill-Switch

```bash
ip -4 route flush table 51822
ip -4 rule | grep 51822 | cut -f 1 -d ':' | xargs ip rule del priority
ip -6 route flush table 51822
ip -6 rule | grep 51822 | cut -f 1 -d ':' | xargs ip rule del priority
```

## Manually Disconnecting from VPN

Please use `protonwire disconnect` as it handles things properly. If not possible, try the following.

```bash
resolvectl revert protonwire0   # only if using systemd-resolved
resolvconf -f -d protonwire0.wg # only if not using systemd-resolved
ip -4 rule del not fwmark 51821 table 51821
ip -6 rule del not fwmark 51821 table 51821
ip -4 route flush table 51821
ip -6 route flush table 51821
ip link del protonwire0
```

[emptyDir]: https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
[docker-compse-volumes]: https://docs.docker.com/compose/compose-file/compose-file-v3/#long-syntax-3
