# Health-check

- There is a `healthcheck` script available under /usr/local/bin. It will use `https://ip.prasadt.workers.dev/` by default to verify the IP address matches with one of the logical servers. By default service will keep checking every `PROTONVPN_CHECK_INTERVAL` _(default = 90)_ seconds using the same api endpoint.

- `https://ip.prasadt.workers.dev/` Service runs as a cloudflare worker and is fast, as it sits at their edge network. It is very simple, It returns your public IP and nothing else. You can use any of the following services (or host your own) as they too return your public IP address.
  * https://ip.prasadt.workers.dev/
  * https://checkip.amazonaws.com/
  * https://icanhazip.com/
  * https://api.ipify.org/

- Version 4.x and below use `https://ipinfo.io` as healthcheck endpoint and check for connected country. This endpoint be changed. If you are hitting rate limits, you should upgrade to v5.0.0+ or reduce check interval via `PROTONVPN_CHECK_INTERVAL` to 180 seconds or more.
