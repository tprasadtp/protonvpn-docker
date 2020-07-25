FROM python:3.8.5-slim-buster

ENV PROTONVPN_COUNTRY="NL" \
    PROTONVPN_VERSION="2.2.2" \
    S6_OVERLAY_VERSION="2.0.0.1" \
    LANG="C.UTF-8" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -qq -y --no-install-recommends \
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
      --upgrade --progress-bar=off -U \
      --no-cache-dir protonvpn-cli=="${PROTONVPN_VERSION}" \
    && rm -rf /var/lib/apt/lists/*

# S6 Overlay and Users
RUN ARCH="$(uname -m)" \
    && export ARCH \
    && echo "Arch is $ARCH" \
    && if [ "$ARCH" = "x86_64" ]; then \
      S6_ARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
      S6_ARCH="aarch64"; \
    elif [ "$ARCH" = "armv7l" ]; then \
      S6_ARCH="armhf"; \
    else \
      echo "Error! ${ARCH} is NOT supported!"; \
      exit 1; \
    fi \
    && export S6_ARCH \
    && S6_DL_URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.gz" \
    && export S6_DL_URL \
    && echo "Downloading from $S6_DL_URL" \
    && curl -sSfL "${S6_DL_URL}" -o /tmp/s6-overlay.tar.gz \
    && gunzip -c /tmp/s6-overlay.tar.gz | tar -xf - -C /  \
    && rm -f /tmp/s6-overlay.tar.gz \
    && mkdir -p \
      /config \
      /root/.pvpn-cli

VOLUME [/root/.pvpn-cli]
COPY root/ /

ENTRYPOINT ["/init"]
