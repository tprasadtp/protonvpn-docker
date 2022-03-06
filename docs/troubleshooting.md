# Troubleshooting

If you are unable to run the container as desired, please try the following before opening an issue
on GitHub.

## Issues on 32 bit ARM Host

If you are running on 32 bit ARM hosts (Raspberry Pi/NAS)
you might be affected by [moby#40734](https://github.com/moby/moby/issues/40734). Its recommended that you use 64 bit images. In case its not possible see following options.

#### Option 1

Manually install an updated version of the library with dpkg.

```bash
wget http://ftp.us.debian.org/debian/pool/main/libs/libseccomp/libseccomp2_2.4.4-1~bpo10+1_armhf.deb
sudo dpkg -i libseccomp2_2.4.4-1~bpo10+1_armhf.deb
```
> This url may have been updated. Find the latest by browsing [here](http://ftp.us.debian.org/debian/pool/main/libs/libseccomp/).

#### Option 2

Add the backports repository for Debian Buster.

```bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC 648ACFD622F3D138
echo "deb http://deb.debian.org/debian buster-backports main" | sudo tee -a /etc/apt/sources.list.d/buster-backports.list
sudo apt update
sudo apt install -t buster-backports libseccomp2
```

## Troubleshooting with default compose file

1. Stop and delete existing containers named `protonvpn` and `pyload` (if any).
1. Please export credentials as environment variables `PROTONVPN_USERNAME` and `PROTONVPN_PASSWORD` and optionally `PROTONVPN_TIER`.
This depends on your shell. Please consult your shell's manpage/docs for how to export environment variables.
1. Get your debugging [compose file][] and create a temporary folder required to save pyload downloads.
  - If using 4.x
    ```bash
    curl -sSfLO https://tprasadtp.github.io/protonvpn-docker/manifests/deprecated/docker-compose.yml
    mkdir -p ./downloads
    ```
  - If using 5.x or above
    ```bash
    curl -sSfLO https://tprasadtp.github.io/protonvpn-docker/manifests/docker-compose.yml
    mkdir -p ./downloads
    ```
1. Try to run downloaded [compose file][]
    ```bash
    docker-compose up
    ```
1. We intentionally do not expose `pyload` to outside world. Depending on your system and runtime constraints, IP address of your container will vary. To obtain IP address/URL of your `pyload` service,run
    ```bash
    docker inspect --format='{{range .NetworkSettings.Networks}}{{printf "http://%s:8000\\n" .IPAddress}}{{end}}' protonvpn
    ```
1. Visit the link in your browser.

## DNS and Healthcheck

- Healthchecks use `https://ip.prasadt.workers.dev/` service. If your DNS or gateway is blocking it.
- This healthcheck endpoint is running on Cloudflare workers.
- You can host your own if you wish.

[compose file]: https://tprasadtp.github.io/protonvpn-docker/manifests/docker-compose.yml
