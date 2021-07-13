#syntax=docker/dockerfile:1.2

FROM ubuntu:focal-20210609 as upstream
FROM upstream as base

# Overlay defaults
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1 \
    S6_KILL_GRACETIME=10000

# Proton defaults
ENV PROTONVPN_DNS_LEAK_PROTECT=1 \
    PROTONVPN_PROTOCOL=udp \
    PROTONVPN_EXCLUDE_CIDRS="169.254.169.254/32,169.254.170.2/32" \
    PROTONVPN_CHECK_INTERVAL=60 \
    PROTONVPN_FAIL_THRESHOLD=3 \
    PROTONVPN_CHECK_URL="https://ipinfo.prasadt.workers.dev/" \
    PROTONVPN_CHECK_QUERY=".client.country" \
    PROTONVPN_CRON=

ARG S6_OVERLAY_VERSION="2.2.0.3"

RUN rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Install Packages
# hadolint ignore=DL3008
RUN --mount=type=tmpfs,target=/root/.gnupg/ \
    apt-get update \
    && apt-get install --no-install-recommends --yes \
    curl \
    jq \
    procps \
    iptables \
    iputils-ping \
    net-tools \
    openvpn \
    bind9-host \
    dialog \
    python3-pip \
    && ARCH="$(uname -m)" \
    && export ARCH \
    && if [ "$ARCH" = "x86_64" ]; then \
    S6_ARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
    S6_ARCH="aarch64"; \
    elif [ "$ARCH" = "armv7l" ]; then \
    S6_ARCH="armhf"; \
    else \
    exit 1; \
    fi \
    && export S6_ARCH \
    && mkdir -p /downloads \
    && curl -sSfL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}-installer" -o /downloads/s6-overlay-installer \
    && curl -sSfL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}-installer.sig" -o /downloads/s6-overlay-installer.sig \
    && apt-get -qq -o=Dpkg::Use-Pty=0 install --no-install-recommends --yes gnupg \
    && curl -sSfL https://keybase.io/justcontainers/key.asc --output /downloads/just-containers-key.asc \
    && gpg --no-tty --batch --yes --import /downloads/just-containers-key.asc \
    && gpg --no-tty --batch --yes --verify /downloads/s6-overlay-installer.sig /downloads/s6-overlay-installer \
    && apt-get -qq -o=Dpkg::Use-Pty=0 --yes purge gnupg \
    && apt-get -qq -o=Dpkg::Use-Pty=0 --yes autoremove \
    && chmod +x /downloads/s6-overlay-installer \
    && /downloads/s6-overlay-installer / \
    && rm -rf /downloads/ \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=root:root --chmod=0755 root/ /

# Install Proton CLI
# hadolint ignore=DL3042
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=cache,target=/root/.cache/wheel \
    pip3 install \
    --progress-bar=off \
    --upgrade \
    --disable-pip-version-check \
    -r requirements.txt

ENTRYPOINT ["/init"]
