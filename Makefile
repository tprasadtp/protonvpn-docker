SHELL := /bin/bash
export REPO_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# GitHub
GITHUB_OWNER := tprasadtp
GITHUB_REPO  := protonvpn-docker

# Define image names
DOCKER_IMAGES     := ghcr.io/$(GITHUB_OWNER)/protonvpn
DOCKER_IMAGE_URL  := ghcr.io/$(GITHUB_OWNER)/protonvpn
DOCKER_BUILDKIT   := 1
DOCKER_VULN_TYPES := os

# OCI Metadata
PROJECT_TITLE    := ProtonVPN
PROJECT_DESC     := ProtonVPN Linux Client
PROJECT_URL      := https://ghcr.io/tprasadtp/protonvpn
PROJECT_SOURCE   := https://github.com/tprasadtp/protonvpn-docker
PROJECT_LICENSE  := GPLv3

# Upstream Metadata
UPSTREAM_VERSION := 2.2.6
UPSTREAM_URL     := https://github.com/ProtonVPN/linux-cli


# Include makefiles
include $(REPO_ROOT)/makefiles/help.mk
include $(REPO_ROOT)/makefiles/metadata.mk
include $(REPO_ROOT)/makefiles/docker.mk
include $(REPO_ROOT)/makefiles/chglog.mk


.PHONY: shellcheck
shellcheck: ## Runs shellcheck
	@echo -e "\033[92m➜ Check cont-init.d scripts \033[0m"
	@for file in $$(find $${REPO_ROOT}/root/etc/ -type f -executable); do \
		file_basename="$$(basename $${file})"; \
		echo "- CHECKING: $${file_basename}"; \
		docker run --userns=host \
			--rm \
			--workdir=/app/ \
			--network=none \
			-v $${file}:/app/$${file_basename}:ro \
			koalaman/shellcheck:v0.7.1 \
			--exclude SC10008 \
			--color=always \
			/app/$${file_basename}; \
		done

# go releaser
.PHONY: snapshot
snapshot: ## Build snapshot
	goreleaser release --rm-dist --snapshot

.PHONY: release
release: ## Build release
	goreleaser release --rm-dist --release-notes $(REPO_ROOT)/RELEASE_NOTES.md --skip-publish

.PHONY: release-prod
release-prod: ## Build and release to production/QA
	goreleaser release --rm-dist --release-notes $(REPO_ROOT)/RELEASE_NOTES.md

.PHONY: clean
clean: ## clean
	rm -rf build/
	rm -rf dist/

# Enforce BUILDKIT
ifneq ($(DOCKER_BUILDKIT),1)
# DO NOT INDENT!
$(error ✖ DOCKER_BUILDKIT!=1. Docker Buildkit cannot be disabled on this repo!)
endif
