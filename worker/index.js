// Get CF headers and use it to return client country/ip
addEventListener('fetch', event => {
    event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
    const url = new URL(request.url)
    const data = {
        apiVersion: 1,
        country: request.cf.country,
        ip: request.headers.get("CF-Connecting-IP"),
        server: {
            serverLocation: request.cf.colo,
            serverCache: request.headers.get("CF-Cache-Status"),
            serverRayID: request.headers.get("CF-RAY")
        },
        client: {
            asn: request.cf.asn,
            ip: request.headers.get("CF-Connecting-IP"),
            continent: request.cf.continent,
            country: request.cf.country,
            region: request.cf.region,
            regionCode: request.cf.regionCode,
            city: request.cf.city,
            timezone: request.cf.timezone,
            tlsVersion: request.cf.tlsVersion,
            tlsCipher: request.cf.tlsCipher,
            httpProtocol: request.cf.httpProtocol,
            url: {
                hostname: url.hostname,
                pathname: url.pathname,
                params: url.searchParams
            }
        },
    }

    const json = JSON.stringify(data, null, 2)
    return new Response(json, {
        headers: {
            "content-type": "application/json;charset=UTF-8"
        },
    })
}
