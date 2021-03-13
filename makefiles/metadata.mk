# This file is managed by diana.

# If SHELL is sh change it to bash
ifeq ($(SHELL),/bin/sh)
	SHELL := /bin/bash
endif

# Make Sure that REPO_ROOT is defined.
$(call check_defined, REPO_ROOT, Repository Root)

# Software/Binary/Docker Image Vendor
# Used in docker tagging and os packages.
VENDOR ?= Prasad Tengse <tprasadtp@users.noreply.github.com>

# Default branch name
GIT_DEFAULT_BRANCH ?= master

# Check optional variables are not empty
$(call check_defined, \
	GIT_DEFAULT_BRANCH \
	VENDOR, \
	Optional Variable is empty or undefined)

# Builder variables
# -------------------------------------

ifeq ($(shell git -c log.showSignature=false rev-parse --is-inside-work-tree),true)
	GIT_COMMIT            := $(shell git -c log.showSignature=false show --format='%H' HEAD --quiet)
	GIT_COMMIT_SHORT      := $(shell git -c log.showSignature=false show --format='%h' HEAD --quiet)
	GIT_TREE_STATE        := $(shell test -n "`git status --porcelain`" && echo "dirty" || echo "clean")
	GIT_BRANCH            := $(shell git -c log.showSignature=false rev-parse --abbrev-ref HEAD --quiet)

	# Commit Time
	COMMIT_UNIX_TIMESTAMP := $(shell git -c log.showSignature=false show --format='%ct' HEAD --quiet)
	COMMIT_UNIX_TIMESTAMP := @$(COMMIT_UNIX_TIMESTAMP)

	GIT_COMMIT_TIMESTAMP  := $(shell date --date='${COMMIT_UNIX_TIMESTAMP}' --universal --iso-8601=s)
else
# DONT INDENT THIS!
$(call fail,not a git repository)
endif

ifeq ($(GITHUB_ACTIONS),true)
	# Builder Details
	BUILD_NUMBER      := $(GITHUB_RUN_NUMBER)
	BUILD_SYSTEM      := $(shell echo "actions-$(GITHUB_WORKFLOW)" | tr '[:upper:]' '[:lower:]')
	BUILD_HOST        := $(shell hostname -f)
else
	# Builder details
	BUILD_NUMBER      := 0
	BUILD_SYSTEM      := local
	BUILD_HOST        := localhost
endif

# Nearest git tag reference
GIT_TAG_NEAREST   := $(shell git -c log.showSignature=false describe --tags --abbrev=0 2> /dev/null)
# IF: there are no tags in repository GIT_TAG_NEAREST is empty!. Usualy happens on a fresh git repo
#     with no tags present.
ifeq ($(GIT_TAG_NEAREST),)
	GIT_TAG_NEAREST := 0.0.0
endif

export GIT_TAG_NEAREST

# Version handler
# -------------------------------------
# If commit is tagged and git tree is clean,
# sets it to git tag minus prefix v
# otherwide sets it to nearest tag-short-commit-SNAPSHOT
# Also strips prefix v if any.

ifeq ($(VERSION),)
	VERSION_FROM_GIT := true
	VERSION := $(subst v,,$(shell \
		if [ ! -z $(GIT_TAG) ] && [ $(GIT_TREE_STATE) == "clean" ]; then \
			echo $(GIT_TAG); \
		else \
			echo $(GIT_TAG_NEAREST)-$(GIT_COMMIT_SHORT)-SNAPSHOT; \
		fi))
else
	VERSION_FROM_GIT := false
endif

# Make sure variables are non empty
$(call check_defined, VERSION VERSION_FROM_GIT, Version Builder)

# Export varaibles
export VERSION
export VERSION_FROM_GIT

# -------------------------------------

# Validate Auto Populated variables are not empty
$(call check_defined, \
	BUILD_NUMBER \
	BUILD_SYSTEM \
	BUILD_HOST \
	GIT_COMMIT \
	GIT_COMMIT_SHORT \
	GIT_BRANCH \
	GIT_COMMIT_TIMESTAMP, \
	Auto-populated Variable)


# Export all
export DEFAULT_BRANCH
export VENDOR

export GIT_BRANCH
export GIT_COMMIT
export GIT_COMMIT_SHORT

export GIT_TREE_STATE
export GIT_COMMIT_TIMESTAMP

# Build system info
export BUILD_HOST
export BUILD_NUMBER
export BUILD_SYSTEM

# Project Metadata
export PROJECT_TITLE
export PROJECT_DESC
export PROJECT_URL
export PROJECT_SOURCE
export PROJECT_LICENSE

# GitHub Metadata
export GITHUB_REPO
export GITHUB_OWNER


# Debug Stuff for base make template
# -------------------------------------

.PHONY: show-vars-base
show-vars-base: ## Show Base variables
	@echo "VERSION              : $(VERSION)"
	@echo "VERSION_FROM_GIT     : $(VERSION_FROM_GIT)"
	@echo ""

	@echo "-------------- GIT VARIABLES ------------------"
	@echo "GIT_BRANCH           : $(GIT_BRANCH)"
	@echo "GIT_COMMIT           : $(GIT_COMMIT)"
	@echo "GIT_COMMIT_SHORT     : $(GIT_COMMIT_SHORT)"
	@echo "GIT_COMMIT_TIMESTAMP : $(GIT_COMMIT_TIMESTAMP)"
	@echo "GIT_DEFAULT_BRANCH   : $(GIT_DEFAULT_BRANCH)"
	@echo ""
	@echo "GIT_TREE_STATE       : $(GIT_TREE_STATE)"
	@echo "GIT_TAG_NEAREST      : $(GIT_TAG_NEAREST)"
	@echo "GIT_TAG              : $(GIT_TAG)"


	@echo "----------- BASE BUILD VARIABLES --------------"
	@echo "BUILD_HOST           : $(BUILD_HOST)"
	@echo "BUILD_NUMBER         : $(BUILD_NUMBER)"
	@echo "BUILD_SYSTEM         : $(BUILD_SYSTEM)"
	@echo "GITHUB_OWNER         : $(GITHUB_OWNER)"
	@echo "GITHUB_REPO          : $(GITHUB_REPO)"

	@echo "----------- ACTION VARIABLES -----------------"
	@echo "GITHUB_ACTIONS       : $(GITHUB_ACTIONS)"
	@echo "GITHUB_WORKFLOW      : $(GITHUB_WORKFLOW)"
	@echo "GITHUB_RUN_NUMBER    : $(GITHUB_RUN_NUMBER)"
	@echo "GITHUB_REF           : $(GITHUB_REF)"


# diana:{diana_version}:{remote}:{source}:{version}:{remote_path}:{type}
# diana:0.2.7:github:tprasadtp/templates::golang/client-server/makefiles/docker.mk:static
