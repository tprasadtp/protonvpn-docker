#!/usr/bin/env bash
set -eu
readonly GIT_CHGLOG_VERSION="0.10.0"
readonly GORELEASER_VERSION="0.159.0"
readonly TRIVY_VERSION="0.16.0"
readonly BUILDX_VERSION="0.5.1"

if [[ $CODESPACES != "true" ]]; then
    echo "Not running in codespaces!"
    exit 1
fi

echo "Saving assets to build"

mkdir -p build

echo "Install Trivy"
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy --yes

echo "Install Buildx"
mkdir -p "${HOME}/.docker/cli-plugins"
curl -sSfL "https://github.com/docker/buildx/releases/download/v${BUILDX_VERSION}/buildx-v${BUILDX_VERSION}.linux-amd64" \
    --output "$HOME/.docker/cli-plugins/docker-buildx"
chmod a+x "$HOME/.docker/cli-plugins/docker-buildx"

echo "Register Cross Platform Binaries"
docker run --network=none --privileged --rm tonistiigi/binfmt --install all

echo "Install Goreleaser"
curl -sSfL "https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_amd64.deb" \
    --output build/goreleaser.deb
sudo dpkg -i build/goreleaser.deb


echo "Install git-chglog"
curl -sSfL "https://github.com/git-chglog/git-chglog/releases/download/v${GIT_CHGLOG_VERSION}/git-chglog_${GIT_CHGLOG_VERSION}_linux_amd64.tar.gz" \
    --output build/git-chglog.tar.gz
sudo tar -xvf build/git-chglog.tar.gz --directory /usr/local/bin/ --wildcards git-chglog