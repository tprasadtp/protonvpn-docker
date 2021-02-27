SHELL := /bin/bash
NAME  := protonvpn-docker

export REPO_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Define image names
DOCKER_IMAGES         := ghcr.io/tprasadtp/protonvpn tprasadtp/protonvpn

# OCI Metadata
PROJECT_TITLE         := ProtonVPN
PROJECT_DESC          := ProtonVPN Linux Client
PROJECT_URL           := https://ghcr.io/tprasadtp/protonvpn
PROJECT_SOURCE        := https://github.com/tprasadtp/protonvpn-docker
PROJECT_DOCUMENTATION := https://github.com/tprasadtp/protonvpn-docker
PROJECT_LICENSES      := GPLv3

# Upstream Metadata
UPSTREAM_VERSION := 2.2.6
UPSTREAM_URL := https://github.com/ProtonVPN/linux-cli

# Include makefiles
include $(REPO_ROOT)/makefiles/base.mk
include $(REPO_ROOT)/makefiles/docker.mk


.PHONY: shellcheck
shellcheck: ## Runs shellcheck
	@echo -e "\033[92m➜ $@ \033[0m"
	shellcheck -e SC1008 $(REPO_ROOT)/root/etc/cont-init.d/*
	shellcheck -e SC1008 $(REPO_ROOT)/root/etc/services.d/*/*
	shellcheck -e SC1008 $(REPO_ROOT)/root/usr/local/bin/healthcheck
