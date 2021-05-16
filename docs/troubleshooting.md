# Troubleshooting

If you are unable to run the container as desired, please try the following before opening an issue
on GitHub.

## Troubleshooting with default compose file

1. Stop and delete existing containers named `protonvpn` and `pyload` (if any).
1. Please export credentials as environment variables `PROTONVPN_USERNAME` and `PROTONVPN_PASSWORD` and optionally `PROTONVPN_TIER`.
This depends on your shell. Please consult your shell's manpage/docs for how to export environment variables.
1. Get your debugging [compose file][] and create a temporary folder required to save pyload downloads.
    ```bash
    curl -sSfLO https://raw.githubusercontent.com/tprasadtp/protonvpn-docker/master/docs/troubleshooting/docker-compose.yml
    mkdir -p ./downloads
    ```
1. Try to run downloaded [compose file][]
    ```bash
    docker-compose up
    ```
1. We intentionally do not expose in this config, `pyload` to outside world. depending on your system and runtime constraints IP address of your container will vary. To obtain IP address/URL of your `pyload` service,run
    ```bash
    docker inspect --format='{{range .NetworkSettings.Networks}}{{printf "http://%s:8000\\n" .IPAddress}}{{end}}' protonvpn
    ```
1. Visit the link in your browser.
1. If for some reason you get timeout errors, please specify output of following when running inside protonvpn container via `docker exec -it protonvpn bash`.
    - `ip r`
    - `curl -sSfL ipinfo.io`

## DNS and Healthchecks

- Healthchecks use `ipinfo.io` service. If your DNS or gateway is blocking it, please add it to your exceptions.
- If your are unable to do so, please open an issue so that we can find some alternatives.

[compose file]: https://raw.githubusercontent.com/tprasadtp/protonvpn-docker/master/docs/docker-compose.yml
