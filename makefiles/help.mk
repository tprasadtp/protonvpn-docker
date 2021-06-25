# This file is managed by diana.
# This template MUST be the first include statement.

# If SHELL is sh change it to bash
ifeq ($(SHELL),/bin/sh)
	SHELL := /bin/bash
endif

# Set default goal to help
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this message
	@IFS=$$'\n' ; \
    help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/' | sort -u`); \
	printf "%-25s %s\n" "Target" "Info" ; \
    printf "%-25s %s\n" "-------------" "-------------" ; \
    for help_line in $${help_lines[@]}; do \
        IFS=$$':' ; \
        help_split=($$help_line) ; \
        help_command="$$(echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//')" ; \
        help_info="$$(echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//')" ; \
        printf '\033[92m'; \
        printf "↠ %-23s %s" $$help_command ; \
        printf '\033[0m'; \
        printf "%s\n" $$help_info; \
    done

# Validators & Utilities
# -------------------------------------

# func::check_defined
# Check that given variable(s) is(are) set and has(have) non-empty value.
#
# Params:
#   1. Variable(s) to test.
#   2. (optional) Error message to print.
check_defined   = $(strip $(foreach 1,$1, $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = $(if $(value $1),, $(error ✖ Undefined Variable: $1$(if $2, ($2))))


# Make Sure that REPO_ROOT is defined.
# -------------------------------------
$(call check_defined, REPO_ROOT, REPO_ROOT MUST be defined for relative paths to work properly)


# Define Defaults
# -------------------------------------

# Software/Binary/Docker Image Vendor
# Used in docker tagging and os packages.
VENDOR ?= Prasad Tengse <tprasadtp@users.noreply.github.com>

# Export Defaults
export VENDOR


# Check Required variables are defined
# -------------------------------------

# Check for common Project vars
$(call check_defined, PROJECT_TITLE, Project title for OCI annotations)
$(call check_defined, PROJECT_DESC, Project description for OCI annotations)
$(call check_defined, PROJECT_URL, Project URL for OCI annotations)
$(call check_defined, PROJECT_LICENSE, Project License in SPDX License Expression format)
$(call check_defined, PROJECT_SOURCE, Project Source URL for OCI annotations)

# Export Project Metadata
export PROJECT_TITLE
export PROJECT_DESC
export PROJECT_URL
export PROJECT_SOURCE
export PROJECT_LICENSE

# Base Git Info collector
# -------------------------------------

ifeq ($(shell git -c log.showSignature=false rev-parse --is-inside-work-tree),true)
	GIT_COMMIT            := $(shell git -c log.showSignature=false show --format='%H' HEAD --quiet)
	GIT_COMMIT_SHORT      := $(shell git -c log.showSignature=false show --format='%h' HEAD --quiet)
	GIT_TREE_STATE        := $(shell test -n "`git status --porcelain`" && echo "dirty" || echo "clean")

	COMMIT_UNIX_TIMESTAMP := $(shell git -c log.showSignature=false show --format='%ct' HEAD --quiet)
	COMMIT_UNIX_TIMESTAMP := @$(COMMIT_UNIX_TIMESTAMP)

	GIT_COMMIT_TIMESTAMP  := $(shell date --date='${COMMIT_UNIX_TIMESTAMP}' --universal --iso-8601=s)
else
# DONT INDENT THIS!
$(error ✖ not a git repository)
endif


# Checks if git is shallow cloned. Useful in CI/CD systems
ifeq ($(shell git -c log.showSignature=false rev-parse --is-shallow-repository),false)
	GIT_BRANCH            := $(shell git -c log.showSignature=false rev-parse --abbrev-ref HEAD --quiet)
else
	GIT_BRANCH            :=
endif

# Base Buidler/CI Info collector
# -------------------------------------

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


# Validate Auto Populated variables are not empty
# GIT_BRANCH is an exception as on CI systems it can be empty
# Due to shalow cloning and detached head
# -------------------------------------
$(call check_defined, \
	BUILD_NUMBER \
	BUILD_SYSTEM \
	BUILD_HOST \
	GIT_COMMIT \
	GIT_COMMIT_SHORT \
	GIT_COMMIT_TIMESTAMP, \
	Auto-populated Variable)


# Export collected Info
# -------------------------------------
export GIT_BRANCH
export GIT_COMMIT
export GIT_COMMIT_SHORT

export GIT_TREE_STATE
export GIT_COMMIT_TIMESTAMP

# Build system info
export BUILD_HOST
export BUILD_NUMBER
export BUILD_SYSTEM

# GitHub Metadata
# We are not yet enforcing GITHUB_REPO and GITHUB_OWNER requirements,
# as sources live in codecommit sometimes.
export GITHUB_REPO
export GITHUB_OWNER


.PHONY: show-vars-base
show-vars-base: ## Show Base variables
	@echo "REPO_ROOT            : $(REPO_ROOT)"
	@echo ""

	@echo "-------------- GIT VARIABLES ------------------"
	@echo "GIT_BRANCH           : $(GIT_BRANCH)"
	@echo "GIT_COMMIT           : $(GIT_COMMIT)"
	@echo "GIT_COMMIT_SHORT     : $(GIT_COMMIT_SHORT)"
	@echo "GIT_COMMIT_TIMESTAMP : $(GIT_COMMIT_TIMESTAMP)"
	@echo "GIT_DEFAULT_BRANCH   : $(GIT_DEFAULT_BRANCH)"
	@echo "GIT_TREE_STATE       : $(GIT_TREE_STATE)"

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

# diana:{diana_urn_flavor}:{remote}:{source}:{version}:{remote_path}:{type}
# diana:2:github:tprasadtp/templates::makefiles/help.mk:static
