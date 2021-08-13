# This file is managed by diana.

# Docker Makefile. This sould be used along with base.mk
# But **AFTER** defining all variables.

# Docker build context directory. If not specified, . is assumed!
DOCKER_BUILD_CONTEXT ?= .

# Full path, including filename for Dockerfile. If not specified, ./Dockerfile is assumed
DOCKER_FILE_PATH ?= ./Dockerfile

# Extra Arguments, useful to pass --build-arg.
DOCKER_EXTRA_ARGS ?=


# Enable Buidkit if not already disabled
DOCKER_BUILDKIT ?= 1

# Default to os,library
DOCKER_VULN_TYPES ?= os,library

# We need to quote this to avoid issues with command
IMAGE_BUILD_DATE := $(shell date --universal --iso-8601=s)

export DOCKER_FILE_PATH
export DOCKER_BUILD_TARGET
export DOCKER_BUILD_CONTEXT

# Image URL
export DOCKER_IMAGE_URL

# Check if required vars are defined
$(call check_defined, DOCKER_IMAGES, Docker Images)
$(call check_defined, DOCKER_IMAGE_URL, Docker Image URL)

# Optional
$(call check_defined, DOCKER_FILE_PATH, Full path to Dockerfile (default=./Dockerfile))
$(call check_defined, DOCKER_BUILD_CONTEXT, Docker build context (default=.))

# Build Tags
DOCKER_TAGS  := $(foreach __REG,$(DOCKER_IMAGES),$(__REG):$(GIT_COMMIT)-DEV)

DOCKER_BUILD_COMMAND ?= build
DOCKER_INSPECT_ARGS  ?= image inspect $(firstword $(DOCKER_TAGS)) | jq ".[].Config.Labels"

# Build --tag argument
DOCKER_TAG_ARGS := $(addprefix --tag ,$(DOCKER_TAGS))

# IF: DOCKER_BUILD_TARGET is defined, use it
ifneq ($(DOCKER_BUILD_TARGET),)
	DOCKER_BUILD_COMMAND += --target "$(DOCKER_BUILD_TARGET)"
endif

# IF: running in actions and using buildx, enable plain progress bar
ifeq ($(GITHUB_ACTIONS)-$(BUILDX_ENABLE),true-1)
	DOCKER_BUILD_COMMAND += --progress=plain
endif


# IF: UPSTREAM_VERSION is defined use it and set upstream present to true
ifneq ($(UPSTREAM_VERSION),)
	UPSTREAM_PRESENT := true
	UPSTREAM_ARGS    += --label io.github.tprasadtp.metadata.upstream.version="$(UPSTREAM_VERSION)"
	UPSTREAM_ARGS    += --label io.github.tprasadtp.metadata.upstream.url="$(UPSTREAM_URL)"
else
	UPSTREAM_PRESENT := false
	UPSTREAM_URL     :=
endif

$(call check_defined, UPSTREAM_PRESENT, Upstream Medatada(default=false))

export UPSTREAM_URL
export UPSTREAM_VERSION
export UPSTREAM_PRESENT


# Print Docker Tags
define print_docker_tags
	@for tag in $(DOCKER_TAGS); do echo "🐳 $${tag}"; done
endef


.PHONY: docker-lint
docker-lint: ## Lint dockerfiles
	@echo -e "\033[92m➜ $@ \033[0m"
	docker run --network=none --rm -i hadolint/hadolint < $(DOCKER_FILE_PATH)


.PHONY: docker
docker: ## Build docker image
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m🐳 Building Docker Image \033[0m"
	DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker \
		$(DOCKER_BUILD_COMMAND) \
		$(DOCKER_TAG_ARGS) \
		$(DOCKER_EXTRA_ARGS) \
		--label org.opencontainers.image.created="$(shell date --universal --iso-8601=s)" \
		--label org.opencontainers.image.description="$(PROJECT_DESC)" \
		--label org.opencontainers.image.documentation="$(PROJECT_URL)" \
		--label org.opencontainers.image.licenses="$(PROJECT_LICENSE)" \
		--label org.opencontainers.image.revision="$(GIT_COMMIT)" \
		--label org.opencontainers.image.source="$(PROJECT_SOURCE)" \
		--label org.opencontainers.image.title="$(PROJECT_TITLE)" \
		--label org.opencontainers.image.url="$(DOCKER_IMAGE_URL)" \
		--label org.opencontainers.image.vendor="$(VENDOR)" \
		--label org.opencontainers.image.version="$(GIT_COMMIT)" \
		--label io.github.tprasadtp.metadata.version="6" \
		--label io.github.tprasadtp.metadata.build.system="$(BUILD_SYSTEM)" \
		--label io.github.tprasadtp.metadata.build.number="$(BUILD_NUMBER)" \
		--label io.github.tprasadtp.metadata.build.host="$(BUILD_HOST)" \
		--label io.github.tprasadtp.metadata.git.commit="$(GIT_COMMIT)" \
		--label io.github.tprasadtp.metadata.git.branch="$(GIT_BRANCH)" \
		--label io.github.tprasadtp.metadata.git.treeState="$(GIT_TREE_STATE)" \
		--label io.github.tprasadtp.metadata.upstream.present="$(UPSTREAM_PRESENT)" \
	        $(UPSTREAM_ARGS) \
		--file $(DOCKER_FILE_PATH) \
		$(DOCKER_BUILD_CONTEXT)


.PHONY: docker-labels
docker-labels: ## Inspect labels of the container
	@echo -e "\033[92m➜ $@ \033[0m"
	docker $(DOCKER_INSPECT_ARGS)


.PHONY: docker-tags
docker-tags: ## Show docker image tags
	$(call print_docker_tags)


.PHONY: docker-trivy
docker-trivy: ## Run trivy on image
	trivy i --light -s HIGH,CRITICAL \
		--ignore-unfixed \
		--exit-code 1 \
		--vuln-type=$(DOCKER_VULN_TYPES) \
		$(lastword $(DOCKER_TAGS))

.PHONY: show-vars-docker
show-vars-docker: ## Show docker variables
	@echo "-------------- DOCKER TAGS -------------------"
	$(call print_docker_tags)
	@echo ""

	@echo "-------------- PATH VARIABLES ----------------"
	@echo "DOCKER_BUILD_CONTEXT : $(DOCKER_BUILD_CONTEXT)"
	@echo "DOCKER_FILE_PATH     : $(DOCKER_FILE_PATH)"
	@echo ""

	@echo "------------- BUILD VARIABLES ----------------"
	@echo "DOCKER_IMAGES        : $(DOCKER_IMAGES)"
	@echo "DOCKER_BUILD_TARGET  : $(DOCKER_BUILD_TARGET)"
	@echo "DOCKER_BUILDKIT      : $(DOCKER_BUILDKIT)"
	@echo "DOCKER_BUILD_COMMAND : $(DOCKER_BUILD_COMMAND)"
	@echo "DOCKER_EXTRA_ARGS    : $(DOCKER_EXTRA_ARGS)"
	@echo "DOCKER_VULN_TYPES    : $(DOCKER_VULN_TYPES)"
	@echo ""


# diana:{diana_urn_flavor}:{remote}:{source}:{version}:{remote_path}:{type}
# diana:2:github:tprasadtp/templates::makefiles/docker.mk:static
