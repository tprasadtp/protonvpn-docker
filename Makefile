# If SHELL is sh change it to bash
ifeq ($(SHELL),/bin/sh)
	SHELL := /bin/bash
endif

export REPO_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

ifeq ($(SHELLCHECK_VERSION),)
	SHELLCHECK_VERSION := v0.10.0
endif

# Set default goal to help
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this message
	@printf "%-20s %s\n" "Target" "Help"
	@printf "%-20s %s\n" "-----" "-----"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: docker
docker: ## Build docker image
	DOCKER_BUILDKIT=1 docker build \
		--tag ghcr.io/tprasadtp/protonwire:dev \
		$(REPO_ROOT)

.PHONY: clean
clean: ## clean
	rm -rf $(REPO_ROOT)/dist/
	rm -rf $(REPO_ROOT)/build/
	rm -rf $(REPO_ROOT)/metadata/
