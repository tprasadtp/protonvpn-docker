#syntax=docker/dockerfile:1.2
FROM debian@sha256:3d5df92588469a4c503adbead0e4129ef3f88e223954011c2169073897547cac as base

FROM base

# hadolint ignore=DL3008,DL3009
RUN --mount=type=tmpfs,target=/var/lib/apt/lists \
    --mount=type=tmpfs,target=/var/cache/apt \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install \
        --yes \
        --no-install-recommends \
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

ENTRYPOINT [ "/usr/bin/protonwire" ]

CMD [ "connect", "--container" ]
