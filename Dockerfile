FROM python:3.8.7-slim-buster

ENV S6_OVERLAY_VERSION="2.1.0.2" \
    LIVE_PROBE_INTERVAL=60 \
    RECONNECT_THRESHOLD=3 \
    LANG="C.UTF-8" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -qq -y \
      --no-install-recommends \
      tzdata \
      curl \
      jq \
      procps \
      iptables \
      iputils-ping \
      net-tools \
      ca-certificates \
      openvpn \
      dialog \
    && apt-get clean \
    && pip3 install \
      --upgrade \
      --progress-bar=off \
      --upgrade \
      --no-cache-dir protonvpn-cli==2.2.6 \
    && rm -rf /var/lib/apt/lists/*

# S6 Overlay
RUN ARCH="$(uname -m)" \
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
    && curl -sSfL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.gz" -o /tmp/s6-overlay.tar.gz \
    && gunzip -c /tmp/s6-overlay.tar.gz | tar -xf - -C /  \
    && rm -f /tmp/s6-overlay.tar.gz

ENV PROTONVPN_DNS_LEAK_PROTECT=1 \
  PROTONVPN_PROTOCOL=udp \
  PROTONVPN_EXCLUDE_CIDRS="169.254.169.254/32,169.254.170.2/32"

COPY root/ /

ENTRYPOINT ["/init"]
