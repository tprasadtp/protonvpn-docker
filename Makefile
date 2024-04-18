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
		--extended-analysis=true \
		/protonwire

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

.PHONY: update-readme
update-readme: ## Update README
	sed -i '/<!--diana::dynamic:protonwire-help:begin-->/,/<!--diana::dynamic:protonwire-help:end-->/!b;//!d;/<!--diana::dynamic:protonwire-help:end-->/e echo "<pre>" && ./protonwire --help && echo "</pre>"' README.md
	sed -i '/<!--diana::dynamic:protonwire-sample-compose-file:begin-->/,/<!--diana::dynamic:protonwire-sample-compose-file:end-->/!b;//!d;/<!--diana::dynamic:protonwire-sample-compose-file:end-->/e echo "\\\`\\\`\\\`yaml" && cat docs/examples/docker/docker-compose.yml && echo "\\\`\\\`\\\`"' README.md
