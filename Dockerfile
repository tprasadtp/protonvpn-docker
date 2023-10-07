#syntax=docker/dockerfile:1.2
FROM debian:bookworm-20230919-slim as base

FROM base

# Install Packages
# hadolint ignore=DL3008,DL3009
RUN --mount=type=tmpfs,target=/var/lib/apt/lists \
    --mount=type=cache,sharing=private,target=/var/cache/apt \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install \
        --yes \
        --no-install-recommends \
        --option 'Binary::apt::APT::Keep-Downloaded-Packages=true' \
        ca-certificates \
        netcat-openbsd \
        curl \
        bind9-host \
        wireguard-tools \
        procps \
        util-linux \
        jq \
        grep \
        gawk \
        libcap2-bin \
        iproute2 \
        socat \
        natpmpc \
        openresolv \
        iputils-ping \
        htop

COPY --chown=root:root --chmod=0755 protonwire /usr/bin/protonwire

RUN ln -s /usr/bin/protonwire /usr/bin/protonvpn

CMD [ "/usr/bin/protonwire", "connect", "--container" ]
