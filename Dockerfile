#syntax=docker/dockerfile:1.2
FROM alpine:3.18.0 as base

FROM base

# hadolint ignore=DL3008,DL3009
RUN --mount=type=cache,sharing=private,target=/var/cache/apk \
    apk update \
    && apk add \
        bash \
        flock \
        curl \
        iproute2-minimal \
        libcap \
        flock \
        procps \
        netcat-openbsd \
        openresolv \
        jq \
        htop \
        bind-tools \
        wireguard-tools-wg

COPY --chown=root:root \
    --chmod=0755 \
    protonwire \
    /usr/bin/protonwire

# Provide a symlink
RUN ln -s /usr/bin/protonwire /usr/bin/protonvpn

CMD [ "/usr/bin/protonwire", "connect", "--container" ]
