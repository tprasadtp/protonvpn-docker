#syntax=docker/dockerfile:1.2
FROM alpine:3.16.2 as base

FROM base

ENV CREDENTIALS_DIRECTORY=/run/secrets

# hadolint ignore=DL3008,DL3009
RUN --mount=type=cache,sharing=private,target=/var/cache/apk \
    apk update \
    && apk add \
        bash \
        curl \
        iproute2-minimal \
        libcap \
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

CMD [ "/usr/bin/protonwire", "--container" ]
