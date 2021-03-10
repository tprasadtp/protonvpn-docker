FROM python:3.9.2-slim-buster

# Overlay defaults
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1 \
    S6_KILL_GRACETIME=10000

# Proton defaults
ENV PROTONVPN_DNS_LEAK_PROTECT=1 \
    PROTONVPN_PROTOCOL=udp \
    PROTONVPN_EXCLUDE_CIDRS="169.254.169.254/32,169.254.170.2/32" \
    PROTONVPN_CHECK_INTERVAL=60 \
    PROTONVPN_FAIL_THRESHOLD=3


ARG S6_OVERLAY_VERSION="2.2.0.3"

# Install Packages
# hadolint ignore=DL3008
RUN apt-get -qq -o=Dpkg::Use-Pty=0 update \
    && apt-get -qq -o=Dpkg::Use-Pty=0 install --no-install-recommends --yes \
        curl \
        jq \
        procps \
        iptables \
        iputils-ping \
        net-tools \
        openvpn \
        bind9-host \
        dialog \
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

COPY root/ /

# Install Proton CLI
RUN pip3 install \
    --progress-bar=off \
    --upgrade \
    --no-cache-dir \
    --no-cache-dir \
    --disable-pip-version-check \
    -r requirements.txt

ENTRYPOINT ["/init"]
