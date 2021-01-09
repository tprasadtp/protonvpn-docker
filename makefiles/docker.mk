# This file is managed by diana.

# Docker Makefile. This sould be used along with base.mk
# But **AFTER** defining all variables.

# Docker build context directory. If not specified, . is assumed!
DOCKER_CONTEXT_DIR ?= .

# Full path, including filename for Dockerfile. If not specified, ./Dockerfile is assumed
DOCKERFILE_PATH    ?= ./Dockerfile

# Extra Arguments, useful to pass --build-arg.
# DOCKER_EXTRA_ARGS

# Enable Buidkit if not already disabled
DOCKER_BUILDKIT  ?= 1

# buildx settings
BUILDX_ENABLE    ?= 0
BUILDX_PUSH      ?= 0
BUILDX_PLATFORMS ?= linux/amd64,linux/arm64,linux/arm/v7

# Latest tag settings
# This toggles whether to add tag latest to all commits of default branch
# Default is disabled. By default we only tag latest if VERSION is equals
# to latest semver tag! Set this to true ONLY if repackaging from upstream
# and updates are usually handled by dependabot or bots.
IMAGE_ALWAYS_TAG_LATEST ?= false

# We need to quote this to avoid issues with command
IMAGE_BUILD_DATE := $(shell date --iso-8601=minutes --universal)

# Get Latest semver tag.
# This may not be latest tag! This is latest smever tag given by --sort
# We will strip prefix v!!
__GIT_TAG_LATEST_SEMVER := $(subst v,,$(shell git tag --sort=v:refname | tail -1))


# Check if required vars are defined
$(call check_defined, DOCKER_IMAGES, Docker Images)
$(call check_defined, IMAGE_TITLE, Image title for OCI annotations)
$(call check_defined, IMAGE_DESC, Image description for OCI annotations)
$(call check_defined, IMAGE_URL, Image description for OCI annotations)
$(call check_defined, IMAGE_SOURCE, Image Source URL for OCI annotations)
$(call check_defined, IMAGE_LICENSES, Licenses in SPDX License Expression format)
$(call check_defined, IMAGE_DOCUMENTATION, Image Documentation URL for OCI annotations)
$(call check_defined, IMAGE_ALWAYS_TAG_LATEST, Always add tag latest if on default branch)


# If on default brach
__IMAGE_ADD_TAG_LATEST := $(shell \
if [[ $(GIT_BRANCH) == "$(DEFAULT_BRANCH)" ]] \
  && [[ $(IMAGE_ALWAYS_TAG_LATEST) == "true" ]]; then \
  echo "true"; \
elif [[ $(GIT_BRANCH) == "$(DEFAULT_BRANCH)" ]] \
  && [[ $(IMAGE_ALWAYS_TAG_LATEST) != "true" ]] \
  && [[ $(GIT_TAGGED) == "true" ]] \
  && [[ $(__GIT_TAG_LATEST_SEMVER) == $(VERSION) ]]; then \
  echo "true"; \
else \
  echo "false"; \
fi)


# Build Full Tags
DOCKER_TAGS  := $(foreach __REG,$(DOCKER_IMAGES),$(__REG):$(VERSION))

# Now start building docker tags
# If we are on default branch add tag latest
ifeq ($(__IMAGE_ADD_TAG_LATEST),true)
	DOCKER_TAGS += $(foreach __REG,$(DOCKER_IMAGES),$(__REG):latest)
endif

# Check if we have buildx enabled
ifeq ($(BUILDX_ENABLE),1)
	DOCKER_BUILD_COMMAND  := buildx build --platform $(BUILDX_PLATFORMS) $(shell if [[ "$(BUILDX_PUSH)" == "1" ]]; then echo "--push"; fi)
	DOCKER_INSPECT_ARGS   := buildx imagetools inspect --raw $(firstword $(DOCKER_TAGS)) | jq "."
else
	DOCKER_BUILD_COMMAND  := build
	DOCKER_INSPECT_ARGS   := image inspect $(firstword $(DOCKER_TAGS)) | jq ".[].Config.Labels"
endif

# Build --tag argument
DOCKER_TAG_ARGS := $(addprefix --tag ,$(DOCKER_TAGS))

# IF DOCKER_TARGET is defined, use it
ifneq ($(DOCKER_TARGET),)
	DOCKER_BUILD_COMMAND += --target "$(DOCKER_TARGET)"
endif


.PHONY: docker-lint
docker-lint: ## Runs the linter on Dockerfiles.
	@echo -e "\033[92m➜ $@ \033[0m"
	docker run --rm -i hadolint/hadolint < "$(DOCKERFILE_PATH)"

.PHONY: docker
docker: ## Build docker image.
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m🐳 Building Docker Image \033[0m"
	DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker \
    $(DOCKER_BUILD_COMMAND) \
    $(DOCKER_TAG_ARGS) \
    $(DOCKER_EXTRA_ARGS) \
    --label org.opencontainers.image.created="$(IMAGE_BUILD_DATE)" \
    --label org.opencontainers.image.description="$(IMAGE_DESC)" \
    --label org.opencontainers.image.documentation="$(IMAGE_DOCUMENTATION)" \
    --label org.opencontainers.image.licenses="$(IMAGE_LICENSES)" \
    --label org.opencontainers.image.revision="$(GIT_COMMIT)" \
    --label org.opencontainers.image.source="$(IMAGE_SOURCE)" \
    --label org.opencontainers.image.title="$(IMAGE_TITLE)" \
    --label org.opencontainers.image.url="$(IMAGE_URL)" \
    --label org.opencontainers.image.vendor="$(VENDOR)" \
    --label org.opencontainers.image.version="$(VERSION)" \
    --label io.github.tprasadtp.metadata.version="5" \
    --label io.github.tprasadtp.metadata.buildSystem="$(BUILD_SYSTEM)" \
    --label io.github.tprasadtp.metadata.buildNumber="$(BUILD_NUMBER)" \
    --label io.github.tprasadtp.metadata.buildHost="$(BUILD_HOST)" \
    --label io.github.tprasadtp.metadata.gitCommit="$(GIT_COMMIT)" \
    --label io.github.tprasadtp.metadata.gitBranch="$(GIT_BRANCH)" \
    --label io.github.tprasadtp.metadata.gitTreeState="$(GIT_TREE_STATE)" \
    --file $(DOCKERFILE_PATH) \
    $(DOCKER_CONTEXT_DIR)

.PHONY: docker-inspect
docker-inspect: ## Inspect Labels of the container [Build First!]
	@echo -e "\033[92m➜ $@ \033[0m"
	docker $(DOCKER_INSPECT_ARGS)

.PHONY: docker-push
docker-push: ## Push docker image.
	@echo -e "\033[92m➜ $@ \033[0m"
	@for tag in $(DOCKER_TAGS); do \
		echo -e "\033[92m🐳 Pushing $${tag}\033[0m\n" \
	  docker push "$${img}"; \
		done

# Print Docker Tags
define print_docker_tags
	@for tag in $(DOCKER_TAGS); do echo "🐳 $${tag}"; done
endef


.PHONY: docker-show-tags
docker-show-tags: ## Show Docker Image Tags
	@echo "------------- Docker Tags ---------------------"
	$(call print_docker_tags)

.PHONY: docker-show-vars
docker-show-vars:
	@echo "------------  DOCKER VARIABLES ---------------"
	@echo "DOCKER_IMAGES        : $(DOCKER_IMAGES)"
	@echo "TAG_LATEST           : $(__IMAGE_ADD_TAG_LATEST)"
	@echo "--------------  DOCKER TAGS ------------------"
	$(call print_docker_tags)
	@echo "-------------- PATH VARIABLES ----------------"
	@echo "DOCKER_CONTEXT_DIR   : $(DOCKER_CONTEXT_DIR)"
	@echo "DOCKERFILE_PATH      : $(DOCKERFILE_PATH)"
	@echo "------------- BUILD VARIABLES ----------------"
	@echo "DOCKER_BUILDKIT      : $(DOCKER_BUILDKIT)"
	@echo "BUILDX_ENABLE        : $(BUILDX_ENABLE)"
	@echo "BUILDX_PUSH          : $(BUILDX_PUSH)"
	@echo "DOCKER_TARGET        : $(DOCKER_TARGET)"
	@echo "BUILDX_PLATFORMS     : $(BUILDX_PLATFORMS)"
	@echo "DOCKER_BUILD_COMMAND : $(DOCKER_BUILD_COMMAND)"
	@echo "DOCKER_EXTRA_ARGS    : $(DOCKER_EXTRA_ARGS)"
	@echo "DOCKER_INSPECT_ARGS  : $(DOCKER_INSPECT_ARGS)"

# diana:{diana_version}:{remote}:{source}:{version}:{remote_path}:{type}
# diana:0.2.7:github:tprasadtp/templates::makefiles/base.mk:static
