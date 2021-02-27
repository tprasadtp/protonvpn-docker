# This file is managed by diana.

# Docker Makefile. This sould be used along with base.mk
# But **AFTER** defining all variables.

# Docker build context directory. If not specified, . is assumed!
DOCKER_BUILD_CONTEXT ?= .

# Full path, including filename for Dockerfile. If not specified, ./Dockerfile is assumed
DOCKER_FILE_PATH ?= ./Dockerfile

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
# Default is disabled. Set this to true ONLY if repackaging from upstream
# and updates are usually handled by dependabot or other bots.
IMAGE_ALWAYS_TAG_LATEST ?= false

# We need to quote this to avoid issues with command
IMAGE_BUILD_DATE := $(shell date --universal --iso-8601=s)

# This is used for repackaging or forks
# Defaults to false overrider this by setting either UPSTREAM_VERSION or
# UPSTREAM_URL.
UPSTREAM_PRESENT ?= false
UPSTREAM_ARGS    :=


export IMAGE_ALWAYS_TAG_LATEST
export DOCKER_FILE_PATH
export DOCKER_BUILD_TARGET
export DOCKER_BUILD_CONTEXT

# Check for common Project vars
$(call check_defined, PROJECT_TITLE, Project title for OCI annotations)
$(call check_defined, PROJECT_DESC, Project description for OCI annotations)
$(call check_defined, PROJECT_URL, Project description for OCI annotations)
$(call check_defined, PROJECT_SOURCE, Project Source URL for OCI annotations)
$(call check_defined, PROJECT_LICENSES, Project License in SPDX License Expression format)
$(call check_defined, PROJECT_DOCUMENTATION, Project Documentation URL for OCI annotations)

# Check if required vars are defined
$(call check_defined, DOCKER_IMAGES, Docker Images)

# Optional
$(call check_defined, IMAGE_ALWAYS_TAG_LATEST, Always add tag latest if on default branch)
$(call check_defined, DOCKER_FILE_PATH, Full path to Dockerfile (default=./Dockerfile))
$(call check_defined, DOCKER_BUILD_CONTEXT, Docker build context (default=.))

# Will add tag latest if,
#   a. Commit is not tagged, branch is master, Git tree is clean and IMAGE_ALWAYS_TAG_LATEST is set to true
# 	b. Commit is tagged, and latest tag is same as version (version bulding handles git tree state,
#      so if tree is dirty, latest tag wont be added)
ADD_LATEST_TAG := $(shell \
if [[ "$(GIT_TAG_PRESENT)" != "true" ]] && [[ "$(GIT_BRANCH)" == master ]] \
	&& [[ "$(IMAGE_ALWAYS_TAG_LATEST)" == "true" ]] && [[ $(GIT_TREE_STATE) == "clean" ]]; then \
	echo "true"; \
elif [[ "$(GIT_TAG_PRESENT)" == "true" ]] && [[ "$(VERSION)" == "$(LATEST_SEMVER)" ]]; then \
	echo "true"; \
else \
	echo "false"; \
fi)

# Latest tag setting
$(call check_defined, ADD_LATEST_TAG, Add Latest Tag(Auto-populated))

# Build Full Tags
DOCKER_TAGS  := $(foreach __REG,$(DOCKER_IMAGES),$(__REG):$(VERSION))

# Now start building docker tags
# If we are on default branch add tag latest
ifeq ($(ADD_LATEST_TAG),true)
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

# IF DOCKER_BUILD_TARGET is defined, use it
ifneq ($(DOCKER_BUILD_TARGET),)
	DOCKER_BUILD_COMMAND += --target "$(DOCKER_BUILD_TARGET)"
endif

ifeq ($(GITHUB_ACTIONS)-$(BUILDX_ENABLE),true-1)
	DOCKER_BUILD_COMMAND += --progress=plain
endif

# UPSTREAM_VERSION is defined use it
# and set upstream present to true
ifneq ($(UPSTREAM_VERSION),)
	UPSTREAM_PRESENT := true
	UPSTREAM_ARGS    += --label io.github.tprasadtp.metadata.upstream.version="$(UPSTREAM_VERSION)"
	UPSTREAM_ARGS    += --label io.github.tprasadtp.metadata.upstream.url="$(UPSTREAM_URL)"
endif

# Print Docker Tags
define print_docker_tags
	@for tag in $(DOCKER_TAGS); do echo "🐳 $${tag}"; done
endef


.PHONY: docker-lint
docker-lint: ## Runs the linter on Dockerfile.
	@echo -e "\033[92m➜ $@ \033[0m"
	docker run --rm -i hadolint/hadolint < "$(DOCKER_FILE_PATH)"


.PHONY: docker
docker: ## Build docker image.
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m🐳 Building Docker Image \033[0m"
	DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker \
		$(DOCKER_BUILD_COMMAND) \
		$(DOCKER_TAG_ARGS) \
		$(DOCKER_EXTRA_ARGS) \
		--label org.opencontainers.image.created="$(IMAGE_BUILD_DATE)" \
		--label org.opencontainers.image.description="$(PROJECT_DESC)" \
		--label org.opencontainers.image.documentation="$(PROJECT_DOCUMENTATION)" \
		--label org.opencontainers.image.licenses="$(PROJECT_LICENSES)" \
		--label org.opencontainers.image.revision="$(GIT_COMMIT)" \
		--label org.opencontainers.image.source="$(PROJECT_SOURCE)" \
		--label org.opencontainers.image.title="$(PROJECT_TITLE)" \
		--label org.opencontainers.image.url="$(PROJECT_URL)" \
		--label org.opencontainers.image.vendor="$(VENDOR)" \
		--label org.opencontainers.image.version="$(VERSION)" \
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


.PHONY: docker-tags
docker-tags: ## Show Docker Image Tags
	@echo "------------- Docker Tags --------------------"
	$(call print_docker_tags)


.PHONY: show-vars-docker
show-vars-docker: ## Show docker variables
	@echo "----------- VCS BASED VARIABLES --------------"
	@echo "VERSION              : $(VERSION)"
	@echo "GIT_BRANCH           : $(GIT_BRANCH)"
	@echo "GIT_TAG_PRESENT      : $(GIT_TAG_PRESENT)"
	@echo "GIT_TREE_STATE       : $(GIT_TREE_STATE)"
	@echo "LATEST_SEMVER        : $(LATEST_SEMVER)"
	@echo ""

	@echo "-------------- DOCKER TAGS -------------------"
	$(call print_docker_tags)
	@echo ""

	@echo "-------------- PATH VARIABLES ----------------"
	@echo "DOCKER_BUILD_CONTEXT : $(DOCKER_BUILD_CONTEXT)"
	@echo "DOCKER_FILE_PATH     : $(DOCKER_FILE_PATH)"
	@echo ""

	@echo "------------- BUILD VARIABLES ----------------"
	@echo "ALWAYS_TAG_LATEST    : $(IMAGE_ALWAYS_TAG_LATEST)"
	@echo "ADD_LATEST_TAG       : $(ADD_LATEST_TAG)"
	@echo "DOCKER_IMAGES        : $(DOCKER_IMAGES)"
	@echo "DOCKER_BUILD_TARGET  : $(DOCKER_BUILD_TARGET)"
	@echo "DOCKER_BUILDKIT      : $(DOCKER_BUILDKIT)"
	@echo "BUILDX_ENABLE        : $(BUILDX_ENABLE)"
	@echo "BUILDX_PUSH          : $(BUILDX_PUSH)"
	@echo "BUILDX_PLATFORMS     : $(BUILDX_PLATFORMS)"
	@echo "DOCKER_BUILD_COMMAND : $(DOCKER_BUILD_COMMAND)"
	@echo "DOCKER_EXTRA_ARGS    : $(DOCKER_EXTRA_ARGS)"
	@echo ""

	@echo "------------ UPSTREAM VARIABLES ---------------"
	@echo "UPSTREAM_PRESENT     : $(UPSTREAM_PRESENT)"
	@echo "UPSTREAM_ARGS        : $(UPSTREAM_ARGS)"

# diana:{diana_version}:{remote}:{source}:{version}:{remote_path}:{type}
# diana:0.2.7:github:tprasadtp/templates::makefiles/base.mk:static
