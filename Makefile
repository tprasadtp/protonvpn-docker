# If SHELL is sh change it to bash
ifeq ($(SHELL),/bin/sh)
	SHELL := /bin/bash
endif

export REPO_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

ifeq ($(SHELLCHECK_VERSION),)
	SHELLCHECK_VERSION := v0.7.2
endif

# Set default goal to help
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this message
	@printf "%-20s %s\n" "Target" "Help"
	@printf "%-20s %s\n" "-----" "-----"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: shellcheck
shellcheck: ## Runs shellcheck
	docker run \
		--rm \
		--userns=host \
		--workdir=/app/ \
		--network=none \
		-v $(REPO_ROOT)/protonwire:/protonwire:ro \
		koalaman/shellcheck:$(SHELLCHECK_VERSION) \
		--color=always \
		/protonwire

.PHONY: docker
docker: ## Build docker image
	DOCKER_BUILDKIT=1 docker build \
		--tag ghcr.io/tprasadtp/protonwire:dev \
		$(REPO_ROOT)

.PHONY: snapshot
snapshot: ## Build snapshot
	goreleaser release \
		--snapshot \
		--rm-dist

.PHONY: release
release: ## Build release
	goreleaser release \
		--rm-dist \
		--skip-publish \
		--skip-validate  \
		--skip-announce \
		--skip-sign

.PHONY: release-prod
release-prod: ## Build release and publish
	goreleaser release --rm-dist

.PHONY: install
install: ## Install protonwire
	@./scripts/goreleaser-wrapper build

	@if [[ ! -e /usr/local/bin ]]; then install -g root -o root -m 755 -d /usr/local/bin; fi
	install -g root -o root -m 755 protonwire /usr/local/bin/protonwire

	install -g root -o root -m 644 systemd/polkit/protonwire.pkla /etc/polkit-1/localauthority/10-vendor.d/protonwire.pkla

	@if [[ ! -e /usr/local/lib/sysctl.d ]]; then install -g root -o root -m 755 -d /usr/local/lib/sysctl.d; fi
	install -g root -o root -m 644 systemd/sysctl.d/protonwire.conf /usr/local/lib/sysctl.d/protonwire.conf

	@if [[ ! -e /usr/local/lib/systemd/system ]]; then install -g root -o root -m 755 -d /usr/local/lib/systemd/system; fi
	install -g root -o root -m 644 systemd/system/protonwire.service /usr/local/lib/systemd/system/protonwire.service

	@if [[ ! -e /usr/local/lib/sysusers.d ]]; then install -g root -o root -m 755 -d /usr/local/lib/sysusers.d; fi
	install -g root -o root -m 644 systemd/sysusers.d/protonwire.conf /usr/local/lib/sysusers.d/protonwire.conf

	@if [[ ! -e /usr/local/man/man1 ]]; then install -g root -o root -m 755 /usr/local/man/man1; fi
	install -g root -o root -m 644 protonwire.1 /usr/local/man/man1/protonwire.1

	systemctl restart systemd-sysusers.service
	systemctl daemon-reload

.PHONY: uninstall
uninstall: ## Uninstall protonwire
	rm -f /usr/local/bin/protonwire
	rm -f /usr/local/lib/sysctl.d/protonwire.conf
	rm -f /usr/local/lib/systemd/system/protonwire.service
	rm -f /usr/local/lib/sysusers.d/protonwire.conf
	rm -f /usr/local/man/man1/protonwire.1
	systemctl daemon-reload

.PHONY: clean
clean: ## clean
	rm -rf $(REPO_ROOT)/dist/
	rm -rf $(REPO_ROOT)/metadata/
