# Health-check

- There is a `healthcheck.py` script available under /usr/local/bin. It will use `PROTONVPN_IPCHECK_ENDPOINT` (`https://ip.prasadt.workers.dev/` by default) to verify the IP address matches with one of the logical servers. By default service will keep checking every `PROTONVPN_CHECK_INTERVAL` _(default = 90)_ seconds using the same api endpoint.

- `https://ip.prasadt.workers.dev/` Service runs as a cloudflare worker and is fast, as it sits at their edge network. It is very simple, It returns your public IP and nothing else.

- You can use any of the following services by setting the variable (or host your own) as they too return your public IP address. These can also be used if default endpoint is rate limited or unavailable.
  * https://ip.prasadt.workers.dev/
  * https://icanhazip.com/
  * https://checkip.amazonaws.com/
  * https://api.ipify.org/

- Version 4.x and below use `https://ipinfo.io` as healthcheck endpoint and check for connected country. This endpoint be changed. If you are hitting rate limits, you should upgrade to v5.0.0+ or reduce check interval via `PROTONVPN_CHECK_INTERVAL` to 180 seconds or more.

## Hosting your own ip worker

- Signup for [Cloudflare workers](https://dash.cloudflare.com/sign-up/workers)
- Create a new worker
- Code for worker is extremely dumb and simple its less than 10 lines of code. You can simply copy paste the following snipet, or look under worker folder.
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
-. Hit save and deploy. Please note that the preview is not available in the cloudflare console,
as the script uses CF-* headers which are not availablein preview.
