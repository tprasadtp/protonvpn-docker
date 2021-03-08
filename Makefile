SHELL := /bin/bash
export REPO_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# GitHub
GITHUB_OWNER := tprasadtp
GITHUB_REPO  := protonvpn-docker

# Define image names
# DOCKER_IMAGES    := ghcr.io/$(GITHUB_OWNER)/protonvpn tprasadtp/protonvpn
DOCKER_IMAGES    := ghcr.io/$(GITHUB_OWNER)/protonvpn
DOCKER_IMAGE_URL := ghcr.io/$(GITHUB_OWNER)/protonvpn
# We are using buildkit only features. Enable buildx
DOCKER_BUILDKIT       := 1

# OCI Metadata
PROJECT_TITLE    := ProtonVPN
PROJECT_DESC     := ProtonVPN Linux Client
PROJECT_URL      := https://ghcr.io/tprasadtp/protonvpn
PROJECT_SOURCE   := https://github.com/tprasadtp/protonvpn-docker
PROJECT_LICENSE  := GPLv3

# Upstream Metadata
UPSTREAM_VERSION := 2.2.6
UPSTREAM_URL     := https://github.com/ProtonVPN/linux-cli

# Do not regenerate changelogs for tags older than 3.1.0
# they are already in the template.
GIT_CHGLOG_OPTS  := 3.1.0..

# Include makefiles
include $(REPO_ROOT)/makefiles/help.mk
include $(REPO_ROOT)/makefiles/metadata.mk
include $(REPO_ROOT)/makefiles/docker.mk

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
	goreleaser release --rm-dist --release-notes $(REPO_ROOT)/CHANGELOG.md --snapshot

.PHONY: release
release: ## Build release
	goreleaser release --rm-dist --release-notes $(REPO_ROOT)/CHANGELOG.md --skip-publish

# DELETING MANIFESTS IS IMPORTANT!
# GORELEASES USES --amend flag on docker manifest create command!
# This will cause old images to be included in the manifest!
.PHONY: release-prod
release-prod: ## Build and release to production/QA
	@for img in $(DOCKER_IMAGES); do docker manifest rm $${img}:4.0 || true ; done
	@for img in $(DOCKER_IMAGES); do docker manifest rm $${img}:latest || true ; done
	goreleaser release --rm-dist --release-notes $(REPO_ROOT)/CHANGELOG.md

# Enforce BUILDKIT
ifneq ($(DOCKER_BUILDKIT),1)
# DO NOT INDENT!
$(error ✖ DOCKER_BUILDKIT!=1. Docker Buildkit cannot be disabled on this repo!)
endif
