WATCHTOWER_BASE := $(strip $(patsubst %/, %, $(dir $(realpath $(firstword $(MAKEFILE_LIST))))))
# Set Help, default goal and WATCHTOWER_BASE
include $(WATCHTOWER_BASE)/makefiles/help.mk

# OCI Metadata
IMAGE_TITLE             := ProtonVPN
IMAGE_DESC              := ProtonVPN Linux Client
IMAGE_URL               := https://hub.docker.com/r/tprasadtp/protonvpn-docker
IMAGE_SOURCE            := https://github.com/tprasadtp/protonvpn
IMAGE_LICENSES          := GPLv3
IMAGE_DOCUMENTATION     := https://github.com/tprasadtp/protonvpn-docker
UPSTREAM_PRESENT        := true
UPSTREAM_AUTHOR         := Proton Technologies AG
UPSTREAM_URL            := https://github.com/ProtonVPN/linux-cli

# Name of and docker image
IMAGE_NAME  := protonvpn
VERSION     := 2.2.2-hotfix-5

include $(WATCHTOWER_BASE)/makefiles/docker.mk

.PHONY: shellcheck
shellcheck: ## Runs shellcheck
	@echo -e "\033[92m➜ $@ \033[0m"
	shellcheck -e SC1008 $(WATCHTOWER_BASE)/root/etc/cont-init.d/*
	shellcheck -e SC1008 $(WATCHTOWER_BASE)/root/etc/services.d/*/run
	shellcheck -e SC1008 $(WATCHTOWER_BASE)/root/usr/local/bin/*
