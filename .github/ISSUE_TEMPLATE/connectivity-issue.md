
## Debugging with default compose file

1. Stop and delete existing containers named `protonvpn` and `pyload` (if any).
1. Please export credentials as environment variables `PROTONVPN_USERNAME` and `PROTONVPN_PASSWORD` and optionally `PROTONVPN_TIER`.
This depends on your shell. Please consult your shell's manpage/docs for how to export environment variables.
1. Get your debugging [compose file][] and create a temporary folder required to save pyload downloads.
    ```bash
    curl -sSfLO https://raw.githubusercontent.com/tprasadtp/protonvpn-docker/master/k8s/docker-compose.yml
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

## Runtime configuration

1. I am running with following configuration
    - Version of `protonvpn-docker` :
    - Host architecture:

1. I have following connected containers:
    - Image:
    - Version(Optional):


## Docker configuration

- [ ] Using custom runtime
- [ ] Using user namespaces
- [ ] Using rootless containers
- [ ] Using with podman
- [ ] Using with k8s/Kubernetes/Openshift

## Redacted PII & Credential validation

- [ ] I have redacted any personally identifying information like public IP address, hostnames, usernames and passwords if they are present in the output.
- [ ] I have verfied that my VPN credentials are valid.

[compose file]: https://raw.githubusercontent.com/tprasadtp/protonvpn-docker/master/k8s/docker-compose.yml
