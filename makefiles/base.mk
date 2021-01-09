# This file is managed by diana.
# This template MUST be the first include statement.

# If SHELL is sh change it to bash
ifeq ($(SHELL),/bin/sh)
	SHELL := /bin/bash
endif

# Set default goal to help
.DEFAULT_GOAL := help


.PHONY: help
help: ## Show this message (Default)
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

# Define commons
# Software/Binary/Docker Image Vendor
VENDOR ?= Prasad Tengse <tprasadtp@users.noreply.github.com>

# Default branch Name
export DEFAULT_BRANCH ?= master

# Builder variables
# -------------------------------------

ifeq ($(GITHUB_ACTIONS),true)
	# Get Commit SHA and Short SHA
  	GIT_COMMIT         := $(GITHUB_SHA)
	GIT_COMMIT_SHORT   := $(shell echo "$${GITHUB_SHA:0:7}")

	# Builder Details
	BUILD_NUMBER       := $(GITHUB_RUN_NUMBER)
	BUILD_SYSTEM       := GH-$(GITHUB_WORKFLOW)
	BUILD_HOST         := $(shell hostname -f)

	# Determine Git Branch
	# Returns Branch name for push builds
	# 		  pr-{number} for pull-request builds
	#         empty string otherwise
	GIT_BRANCH := $(shell \
	if [[ ${GITHUB_REF} == refs/heads/* ]]; then \
		echo "${GITHUB_REF}" | sed -r 's/refs\/heads\///a'; \
	elif [[ ${GITHUB_REF} == refs/pull/* ]]; then \
		echo "${GITHUB_REF}" | sed -r 's/refs\/pull\/([0-9]*)\/merge/pr-\1/a''; \
	else \
		echo ""; \
	fi\
	)

	# We are running on Github actions,
	# for sake of simplicity we ignore git tree state and assume that
	# we are not making any changes to source while running on CI.
	GIT_TREE_STATE := clean

else
	# Get Commit SHA and Short SHA
	GIT_COMMIT         := $(shell git log -1 --pretty=format:"%H")
	GIT_COMMIT_SHORT   := $(shell git log -1 --pretty=format:"%h")

	# Builder details
	BUILD_NUMBER       := 0
	BUILD_SYSTEM       := LOCAL
	BUILD_HOST         := localhost

	# Determine git Branch
	GIT_BRANCH := $(strip $(shell git rev-parse --abbrev-ref HEAD))

	ifeq ($(GIT_BRANCH),HEAD)
		GIT_BRANCH := $(GIT_COMMIT_SHORT)
	endif

	GIT_TREE_STATE  := $(shell test -n "`git status --porcelain`" && echo "dirty" || echo "clean")

endif


# Version Tag handler
# -------------------------------------

ifeq ($(VERSION),)
	# Get Version if not already defined
	VERSION_UNDEFINED  := true
	__VERSION_FROM_TAG := $(shell git describe --tags --always --dirty --broken)
	VERSION            := $(__VERSION_FROM_TAG:v%=%)
else
	VERSION_UNDEFINED  := false
endif

# Identify if commit is tagged(will return true if commit is dirty!)
GIT_TAGGED := $(shell \
	if git describe --exact-match --tags $(GIT_COMMIT) > /dev/null 2>&1; then \
		echo "true"; \
	else \
		echo "false"; \
	fi)


# Validate Auto Populated variables are not empty
$(call check_defined, \
	BUILD_NUMBER \
	BUILD_SYSTEM \
	BUILD_HOST \
	GIT_COMMIT \
	GIT_COMMIT_SHORT \
	GIT_TAGGED, \
	Auto-populated Variable)

# Check optional variables are not empty
$(call check_defined, \
	DEFAULT_BRANCH \
	VENDOR, \
	Optional Variable is empty or Undefined)

# Make Sure that NAME is defined.
$(call check_defined, NAME, Project Name)
# Make Sure that REPO_ROOT is defined.
$(call check_defined, REPO_ROOT, Repository Root)


# Check if VERSION is defined or is actually polulated
ifeq ($(VERSION_UNDEFINED),true)
$(call check_defined, VERSION, Version(From Tags))
else
$(call check_defined, VERSION, Version(Pre defined))
endif


ifeq ($(shell if [[ ! $(VERSION) =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-((0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))?(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$$ ]]; then echo "1"; fi),1)
$(error ✖ Invalid version ($(VERSION)) - expected x.y[.z], where x, y, and z are all integers.)
endif


# Export all
export GIT_BRANCH GIT_COMMIT GIT_COMMIT_SHORT GIT_TAGGED GIT_TREE_STATE

export DEFAULT_BRANCH VENDOR

export VERSION VERSION_UNDEFINED

export BUILD_HOST BUILD_NUMBER BUILD_SYSTEM

# Debug Stuff for base make template
# -------------------------------------

.PHONY: show-base-vars
show-base-vars: ## Show Base variables and VERSION
	@echo "VERSION           : $(VERSION)"
	@echo "SHELL             : $(SHELL)"
	@echo "------------ GIT VARIABLES ----------------"
	@echo "DEFAULT_BRANCH    : $(DEFAULT_BRANCH)"
	@echo "GIT_BRANCH        : $(GIT_BRANCH)"
	@echo "GIT_COMMIT        : $(GIT_COMMIT)"
	@echo "GIT_COMMIT_SHORT  : $(GIT_COMMIT_SHORT)"
	@echo "GIT_TAGGED        : $(GIT_TAGGED)"
	@echo "GIT_TREE_STATE    : $(GIT_TREE_STATE)"
	@echo "--------- BASE BUILD VARIABLES ------------"
	@echo "BUILD_HOST        : $(BUILD_HOST)"
	@echo "BUILD_NUMBER      : $(BUILD_NUMBER)"
	@echo "BUILD_SYSTEM      : $(BUILD_SYSTEM)"
	@echo "---------- ACTION VARIABLES ---------------"
	@echo "GITHUB_ACTIONS    : $(GITHUB_ACTIONS)"
	@echo "GITHUB_WORKFLOW   : $(GITHUB_WORKFLOW)"
	@echo "GITHUB_RUN_NUMBER : $(GITHUB_RUN_NUMBER)"
	@echo "GITHUB_REF        : $(GITHUB_REF)"


# diana:{diana_version}:{remote}:{source}:{version}:{remote_path}:{type}
# diana:0.2.7:github:tprasadtp/templates::makefiles/base.mk:static
