# Health-check

- There is a `healthcheck` script available under /usr/local/bin. It will use `PROTONVPN_IPCHECK_ENDPOINT` (`https://icanhazip.com/` by default, Operated by Cloudflare) to verify the IP address matches with one of the logical servers. By default service will keep checking every `PROTONVPN_CHECK_INTERVAL` _(default = 90)_ seconds using the same api endpoint.

- You can use any of the following services by setting the variable (or host your own) as they too return your public IP address. These can also be used if default endpoint is rate limited or unavailable.
  * https://ip.prasadt.workers.dev/
  * https://icanhazip.com/
  * https://checkip.amazonaws.com/
  * https://api.ipify.org/

## Hosting your own ip worker

- Sign-up for [Cloudflare workers](https://dash.cloudflare.com/sign-up/workers)
- Create a new worker
- Code for worker is extremely dumb and simple its ~10 lines of javascript. You can simply copy paste the following snippet, or look under worker folder.
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
- Hit save and deploy. Please note that the preview is not available in the cloudflare console,
as the script uses `CF-*` headers which are not available in preview.
