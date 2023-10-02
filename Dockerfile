#syntax=docker/dockerfile:1.2
FROM debian:bookworm-20230919-slim as base

FROM base

RUN rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/buildkit-cache

# Install Packages
# hadolint ignore=DL3008,DL3009
RUN --mount=type=cache,sharing=private,target=/var/lib/apt \
    --mount=type=cache,sharing=private,target=/var/cache/apt \
    apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes \
        ca-certificates \
        curl \
        netcat-openbsd \
        bind9-host \
        wireguard-tools \
        procps \
        util-linux \
        jq \
        libcap2-bin \
        iproute2 \
        htop

COPY --chown=root:root \
    --chmod=0755 \
    protonwire \
    /usr/bin/protonwire

# Provide a symlink
RUN ln -s /usr/bin/protonwire /usr/bin/protonvpn

CMD [ "/usr/bin/protonwire", "connect", "--container" ]
