# Health-checks

- There is a `healthcheck` script available under /usr/local/bin. It will use `https://ipinfo.prasadt.workers.dev/` by default to verify the country to which VPN is connected. By default service will keep checking every `PROTONVPN_CHECK_INTERVAL` _(default = 90)_ seconds using the same api endpoint.

- `https://ipinfo.prasadt.workers.dev/` Service runs as a cloudflare worker and is fast, as it sits at their edge network. If for some reason it errors out open an issue. This is meant to be used only with this container and provides no api compatibility gurantees. Two requests are made during container startup to healthcheck endpoint. These requests do not tunnel via VPN. You can host your own, if you chose to.

- Version 4.x and below use `https://ipinfo.io` as healthcheck endpoint and it cannot be changed. If you are hitting rate limits, you should upgrade to v5.0.0+ or reduce check interval via `PROTONVPN_CHECK_INTERVAL` to 180 seconds or more.
