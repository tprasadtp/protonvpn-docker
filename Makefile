# If SHELL is sh change it to bash
ifeq ($(SHELL),/bin/sh)
	SHELL := /bin/bash
endif

export REPO_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

ifeq ($(SHELLCHECK_VERSION),)
	SHELLCHECK_VERSION := v0.9.0
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
		--clean

.PHONY: release
release: ## Build release
	goreleaser release \
		--clean \
		--skip-publish \
		--skip-validate  \
		--skip-announce \
		--skip-sign

.PHONY: release-prod
release-prod: ## Build release and publish
	goreleaser release --clean

.PHONY: install
install: ## Install protonwire
	@if [[ ! -e /etc/polkit-1/localauthority/10-vendor.d ]]; then install -g root -o root -m 755 -d /etc/polkit-1/localauthority/10-vendor.d; fi
	install -g root -o root -m 644 systemd/polkit/protonwire.pkla /etc/polkit-1/localauthority/10-vendor.d/protonwire.pkla

	@if [[ ! -e /etc/sysctl.d ]]; then install -g root -o root -m 755 -d /etc/sysctl.d; fi
	install -g root -o root -m 644 systemd/sysctl.d/protonwire.conf /etc/sysctl.d/protonwire.conf

	@if [[ ! -e /etc/systemd/system ]]; then install -g root -o root -m 755 -d /etc/systemd/system; fi
	install -g root -o root -m 644 systemd/system/protonwire.service /etc/systemd/system/protonwire.service

	@if [[ ! -e /etc/sysusers.d ]]; then install -g root -o root -m 755 -d /etc/sysusers.d; fi
	install -g root -o root -m 644 systemd/sysusers.d/protonwire.conf /etc/sysusers.d/protonwire.conf

	@if [[ ! -e /etc/tmpfiles.d ]]; then install -g root -o root -m 755 -d /etc/tmpfiles.d; fi
	install -g root -o root -m 644 systemd/tmpfiles.d/protonwire.conf /etc/tmpfiles.d/protonwire.conf

	@if [[ ! -e /usr/local/bin ]]; then install -g root -o root -m 755 -d /usr/local/bin; fi
	install -g root -o root -m 755 protonwire /usr/local/bin/protonwire

	@if [[ ! -e /usr/local/man/man1 ]]; then install -g root -o root -m 755 -d /usr/local/man/man1; fi
	help2man --no-info --manual="ProtonWire - ProtonVPN Wireguard Client" ./protonwire | install -g root -o root -m 644 /dev/stdin /usr/local/man/man1/protonwire.1

	systemd-sysusers protonwire.conf
	/usr/lib/systemd/systemd-sysctl protonwire.conf
	systemd-tmpfiles --create protonwire.conf
	systemctl daemon-reload

.PHONY: uninstall
uninstall: ## Uninstall protonwire
	protonwire disable-killswitch || true
	systemctl disable --now protonwire || true
	rm -f /etc/polkit-1/localauthority/10-vendor.d/protonwire.pkla
	rm -f /etc/sysctl.d/protonwire.conf
	rm -f /etc/systemd/system/protonwire.service
	rm -f /etc/sysusers.d/protonwire.conf
	rm -f /etc/tmpfiles.d/protonwire.conf
	rm -f /usr/local/man/man1/protonwire.1
	rm -f /usr/local/bin/protonwire
	systemctl daemon-reload

.PHONY: clean
clean: ## clean
	rm -rf $(REPO_ROOT)/dist/
	rm -rf $(REPO_ROOT)/metadata/

.PHONY: update-readme
update-readme: ## Update README
	sed -i '/<!--diana::dynamic:protonwire-help:begin-->/,/<!--diana::dynamic:protonwire-help:end-->/!b;//!d;/<!--diana::dynamic:protonwire-help:end-->/e echo "<pre>" && ./protonwire --help && echo "</pre>"' README.md
	sed -i '/<!--diana::dynamic:protonwire-sample-compose-file:begin-->/,/<!--diana::dynamic:protonwire-sample-compose-file:end-->/!b;//!d;/<!--diana::dynamic:protonwire-sample-compose-file:end-->/e echo "\\\`\\\`\\\`yaml" && cat docs/examples/docker-compose-demo.yml && echo "\\\`\\\`\\\`"' README.md
	sed -i '/<!--diana::dynamic:protonwire-container-unit-file:begin-->/,/<!--diana::dynamic:protonwire-container-unit-file:end-->/!b;//!d;/<!--diana::dynamic:protonwire-container-unit-file:end-->/e echo "\\\`\\\`\\\`ini" && cat docs/examples/container-protonwire.service && echo "\\\`\\\`\\\`"' README.md
	sed -i '/<!--diana::dynamic:protonwire-app-unit-file:begin-->/,/<!--diana::dynamic:protonwire-app-unit-file:end-->/!b;//!d;/<!--diana::dynamic:protonwire-app-unit-file:end-->/e echo "\\\`\\\`\\\`ini" && cat docs/examples/container-protonwire-example-app.service && echo "\\\`\\\`\\\`"' README.md
