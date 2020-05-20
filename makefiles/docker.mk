# BEGIN-DOCKER-TEMPLATE

# Docker Makefile. This sould be used along with help.mk
# But AFTER defining all variables.

# Docker build context directory. If not specified, WATCHTOWER_BASE/ is assumed!
DOCKER_CONTEXT_DIR ?= $(WATCHTOWER_BASE)

# Full path, including filename for Dockerfile. If not specified, WATCHTOWER_BASE/Dockerfile is assumed
DOCKERFILE_PATH ?= $(WATCHTOWER_BASE)/Dockerfile

# Squash Image Layers
DOCKER_SQUASH ?= 0

# Extra Arguments, useful to pass --build-arg.
# DOCKER_EXTRA_ARGS

# Enable Buidkit if not already disabled
DOCKER_BUILDKIT ?= 1

# Assign default docker user
DOCKER_USER ?= tprasadtp

# Set this to true if its a fork
UPSTREAM_PRESENT ?= false

# We MUST also set below two variables, if UPSTREAM_PRESENT is true
# UPSTREAM_AUTHOR
# UPSTREAM_PRESENT

# Use buildx
BUILDX_ENABLE    ?= 0
BUILDX_PUSH      ?= 0
BUILDX_PLATFORMS ?= linux/amd64,linux/arm64,linux/arm/v7

# Builder metadata
IMAGE_VENDOR  ?= Prasad Tengse<tprasadtp@users.noreply.github.com>

# We need to quote this to avoid issues with command
IMAGE_BUILD_DATE := $(shell date --rfc-3339=seconds)

ifeq ($(GITHUB_ACTIONS),true)
	# We are running in GITHUB CI,
	# Parse GITHUB_REF and GITHUB_SHA
	# We will extract the
	#  - Branch name in branch push builds
	#  - Tagname in tag push builds
	#  - Pull request number in PR builds.
	GIT_REF            := $(strip $(shell echo "$${GITHUB_REF}" | sed -r 's/refs\/(heads|tags|pull)\///g;s/[\/\*\#]+/-/g'))
	GITHUB_SHA_SHORT   := $(shell echo "$${GITHUB_SHA:0:7}")
	GIT_DIRTY          := false
	IMAGE_BUILD_SYSTEM := actions
	IMAGE_BUILD_HOST   := $(shell hostname -f)
else
	# If in detached head state this will give HEAD, just keep it in your HEAD :P
	GIT_BRANCH := $(strip $(shell git rev-parse --abbrev-ref HEAD | sed -r 's/[\/\*\#]+/-/g'))

	# Get latest tag. This will be empty if there are no tags pointing at HEAD
	# on actions build, tag triggers a separate build, GITHUB_REF handles it.
	GIT_TAG := $(strip $(shell git describe --exact-match --tags $(git log -n1 --pretty='%h') 2> /dev/null))

	# Generate GITHUB_* vars on local build
	GITHUB_ACTIONS     := false
	GITHUB_SHA         := $(shell git log -1 --pretty=format:"%H")
	GITHUB_SHA_SHORT   := $(shell git log -1 --pretty=format:"%h")
	IMAGE_BUILD_HOST   := localhost
	IMAGE_BUILD_SYSTEM := localhost

	# Get list of changes files
	GIT_UNTRACKED_CHANGES := $(shell git status --porcelain --untracked-files=no)

	# GIT_REF
	# In local builds, if we have a tag pointing at HEAD && our git tree is not dirty, set GIT_REF to GIT_TAG.
	# Otherwise set this to GIT_BRANCH
	GIT_REF    := $(shell if [[ "$(GIT_UNTRACKED_CHANGES)" == "" ]] && [[ "$(GIT_TAG)" != "" ]]; then echo "$(GIT_TAG)"; else echo "$(GIT_BRANCH)"; fi )
	GIT_DIRTY  := $(shell if [[ "$(GIT_UNTRACKED_CHANGES)" == "" ]]; then echo "false"; else echo "true"; fi)
endif

ifeq ($(GIT_DIRTY),true)
	GIT_COMMIT := $(GITHUB_SHA_SHORT)-dirty
else
	GIT_COMMIT := $(GITHUB_SHA_SHORT)
endif


# VERSION
# If we have VERSION, It means
# 1. We want to tag docker images with VERSION if we are on master branch.
# 2. We want to push those tags to the registry from CI.
# 3. Git Tags are completely independent of this VERSION, though they can be co-ordinated not to
#    clash or conflict, but we do not take care of it in the makefile.
# 4. We prefer not to push docker images on tag push builds, unless tags and VERSION
#    do not conflict or are meant for completely different purposes.
# Intended Usage:
# 1. Forks/Upstream: If we are building a docker image for upstream project and we would like to reflect upstream's
#    version in our docker tags,
# 2. Github Actions: To provide stable tagged releases yet maintain ability for internal uses to use master branch.
#    We will not push images on tags, tags will only help GitHub pull the right action.yml file.
#    - Release Workflow. All commmits to master will push images tagged with VERSION to the registry,
#      which should be the NEXT Version of the action.
#      On tag push(or after if done manually), CI/User will
#	   a. Pull/Build the current VERSION image,
#      b. Update action.yml to reflect the VERSION tag.
#      c. BUMP the VERSION to NEXT VERSION
#      d. Tag image with NEXT VERSION and push it (to avoid breaking builds which refer to repo@master)
#      e. And finally create a new commit on master which SHOULD JUST INCLUDE the version bump.
#      So that way, all tagged commit will reflect to tagged dockerfiles, and master brach will reflect NEXT VERSION.


# Now start building docker tags
# If we are on master and VERSION is set, add additional tag USERNAME/NAME:VERSION
ifeq ($(GIT_REF),master)
	DOCKER_TAGS := $(DOCKER_USER)/$(NAME):latest $(shell if [[ "$(VERSION)" != "" ]]; then echo "$(DOCKER_USER)/$(NAME):$(VERSION)"; fi )
else
	DOCKER_TAGS := $(DOCKER_USER)/$(NAME):$(GIT_REF)
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

ifeq ($(UPSTREAM_PRESENT),true)
	UPSTREAM_ARGS := --label io.github.tprasadtp.upstream.author="$(UPSTREAM_AUTHOR)"
    UPSTREAM_ARGS += --label io.github.tprasadtp.upstream.url="$(UPSTREAM_URL)"
else
	UPSTREAM_ARGS :=
endif

.PHONY: docker-lint
docker-lint: ## Runs the linter on Dockerfiles.
	@echo -e "\033[92m➜ $@ \033[0m"
	docker run --rm -i hadolint/hadolint < "$(DOCKER_CONTEXT_DIR)/Dockerfile"

.PHONY: docker
docker: ## Build docker image.
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m🐳 Building Docker Image $(DOCKER_USER)/$(NAME):$(DOCKER_TAGS)\033[0m"
	DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker \
    $(DOCKER_BUILD_COMMAND) \
    $(DOCKER_TAG_ARGS) \
    $(DOCKER_EXTRA_ARGS) \
    --build-arg GIT_COMMIT="$(GIT_COMMIT)" \
    --label org.opencontainers.image.created="$(IMAGE_BUILD_DATE)" \
    --label org.opencontainers.image.description="$(IMAGE_DESC)" \
    --label org.opencontainers.image.documentation="$(IMAGE_DOCUMENTATION)" \
    --label org.opencontainers.image.licenses="$(IMAGE_LICENSES)" \
    --label org.opencontainers.image.revision="$(GITHUB_SHA)" \
    --label org.opencontainers.image.source="$(IMAGE_SOURCE)" \
    --label org.opencontainers.image.title="$(IMAGE_TITLE)" \
    --label org.opencontainers.image.url="$(IMAGE_URL)" \
    --label org.opencontainers.image.vendor="$(IMAGE_VENDOR)" \
    --label org.opencontainers.image.version="$(VERSION)" \
    --label io.github.tprasadtp.build.system="$(IMAGE_BUILD_SYSTEM)" \
    --label io.github.tprasadtp.build.host="$(IMAGE_BUILD_HOST)" \
    --label io.github.tprasadtp.actions.workflow="$(GITHUB_WORKFLOW)" \
    --label io.github.tprasadtp.actions.build="$(GITHUB_RUN_NUMBER)" \
    --label io.github.tprasadtp.actions.actor="$(GITHUB_ACTOR)" \
    --label io.github.tprasadtp.actions.ref="$(GITHUB_REF)" \
    --label io.github.tprasadtp.git.commit="$(GIT_COMMIT)" \
    --label io.github.tprasadtp.upstream.present="$(UPSTREAM_PRESENT)" \
    $(UPSTREAM_ARGS) \
    --file $(DOCKER_CONTEXT_DIR)/Dockerfile \
    $(DOCKER_CONTEXT_DIR)

.PHONY: docker-inspect
docker-inspect:
	@echo -e "\033[92m➜ $@ \033[0m"
	docker $(DOCKER_INSPECT_ARGS)

.PHONY: docker-push
docker-push: ## Push docker image.
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m🐳 Pushing $(DOCKER_TAGS) [DockerHub]\033[0m"
	@for img in "$(DOCKER_TAGS)"; do docker push "$${img}"; done


.PHONY: debug-docker-vars
debug-docker-vars:
	@echo "WATCHTOWER_BASE      : $(WATCHTOWER_BASE)"
	@echo "NAME                 : $(NAME)"
	@echo "------------  DOCKER VARIABLES ----------------"
	@echo "DOCKER_CONTEXT_DIR   : $(DOCKER_CONTEXT_DIR)"
	@echo "DOCKERFILE_PATH      : $(DOCKERFILE_PATH)"
	@echo "DOCKER_TARGET        : $(DOCKER_TARGET)"
	@echo "DOCKER_USER          : $(DOCKER_USER)"
	@echo "DOCKER_BUILDKIT      : $(DOCKER_BUILDKIT)"
	@echo "DOCKER_TAGS          : $(DOCKER_TAGS)"
	@echo "PRIMARY_TAG          : $(firstword $(DOCKER_TAGS))"
	@echo "DOCKER_TAG_ARGS      : $(DOCKER_TAG_ARGS)"
	@echo "------------- BUILD VARIABLES ----------------"
	@echo "BUILDX_ENABLE        : $(BUILDX_ENABLE)"
	@echo "BUILDX_PUSH          : $(BUILDX_PUSH)"
	@echo "BUILDX_PLATFORMS     : $(BUILDX_PLATFORMS)"
	@echo "DOCKER_BUILD_COMMAND : $(DOCKER_BUILD_COMMAND)"
	@echo "DOCKER_INSPECT_ARGS  : $(DOCKER_INSPECT_ARGS)"
	@echo "------------- ACTION VARIABLES ----------------"
	@echo "GITHUB_ACTIONS       : $(GITHUB_ACTIONS)"
	@echo "GITHUB_WORKFLOW      : $(GITHUB_WORKFLOW)"
	@echo "GITHUB_RUN_NUMBER    : $(GITHUB_RUN_NUMBER)"
	@echo "GITHUB_REF           : $(GITHUB_REF)"
	@echo "-------------- GIT VARIABLES ------------------"
	@echo "GIT_BRANCH           : $(GIT_BRANCH)"
	@echo "GITHUB_SHA           : $(GITHUB_SHA)"
	@echo "GIT_COMMIT           : $(GIT_COMMIT)"
	@echo "GIT_REF              : $(GIT_REF)"
	@echo "GIT_TAG              : $(GIT_TAG)"
	@echo "GIT_DIRTY            : $(GIT_DIRTY)"
	@echo "------------ UPSTREAM VARIABLES ---------------"
	@echo "VERSION              : $(VERSION)"
	@echo "UPSTREAM_PRESENT     : $(UPSTREAM_PRESENT)"
	@echo "UPSTREAM_ARGS        : $(UPSTREAM_ARGS)"

# END-DOCKER-TEMPLATE
