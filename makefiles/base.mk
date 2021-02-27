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
	BUILD_SYSTEM       := $(shell echo "actions-$(GITHUB_WORKFLOW)" | tr '[:upper:]' '[:lower:]')
	BUILD_HOST         := $(shell hostname -f)

	# Determine Git Branch
	# Returns Branch name for push builds
	# 		  pr-{number} for pull-request builds
	#         empty string otherwise
	GIT_BRANCH := $(shell \
	if [[ $(GITHUB_REF) =~ refs/heads/* ]]; then \
		echo "$${GITHUB_REF/refs\/heads\//}"; \
	elif [[ $(GITHUB_REF) =~ refs/pull/* ]]; then \
		echo "$${GITHUB_REF/refs\/pull\//}"; \
	elif [[ $(GITHUB_REF) =~ refs/tags/* ]]; then \
		echo "$${GITHUB_REF/refs\/tags\//}"; \
	else \
		echo ""; \
	fi)


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
	BUILD_SYSTEM       := local
	BUILD_HOST         := localhost

	# Determine git Branch
	GIT_BRANCH := $(strip $(shell git rev-parse --abbrev-ref HEAD))

	ifeq ($(GIT_BRANCH),HEAD)
		GIT_BRANCH := $(GIT_COMMIT_SHORT)
	endif

	GIT_TREE_STATE  := $(shell test -n "`git status --porcelain`" && echo "dirty" || echo "clean")

endif

# Get Latest semver tag (which is in master).
# This may not be latest tag!
# We will strip prefix v!!
ifeq ($(GITHUB_ACTIONS),true)
	LATEST_SEMVER := $(subst v,,$(shell git tag --merged remotes/origin/master | sort -V | tail -1))
else
	LATEST_SEMVER := $(subst v,,$(shell git tag --merged master | sort -V | tail -1))
endif

# Check if current commit is in master
ifeq ($(GITHUB_ACTIONS),true)
	__COMMIT_BRANCHES := $(subst v,,$(shell git branch --contains $(GIT_COMMIT) --all --color=never --format="%(refname)"))
else
	__COMMIT_BRANCHES := $(subst v,,$(shell git branch --contains $(GIT_COMMIT) --color=never --format="%(refname)"))
endif

GIT_REF_IN_MASTER := $(shell )

# Version Tag handler
# -------------------------------------

ifeq ($(VERSION),)
	# Get version from git tags if not already defined
	VERSION_FROM_GIT := true
	ifeq ($(GITHUB_ACTIONS),true)
		# We ignore git tree state if running on github actions
		VERSION := $(subst v,,$(shell git describe --tags --always))
	else
		VERSION := $(subst v,,$(shell git describe --tags --dirty --always --broken))
	endif
else
	VERSION_FROM_GIT  := false
endif

# Identify if commit is tagged(will return true if commit is dirty!)
GIT_TAG_PRESENT := $(shell \
	if git describe --exact-match --tags $(GIT_COMMIT) > /dev/null 2>&1; then \
		echo "true"; \
	else \
		echo "false"; \
	fi)

# https://github.community/t/feature-request-protected-tags/1742/39
# Currently disabled because it fails on github actions on tag builds
# ifneq (,$(findstring refs/heads/master,$(shell git branch --contains $(GIT_COMMIT) --color=never --format="%(refname)")))
# 	GIT_REF_IN_MASTER := true
# else
# 	GIT_REF_IN_MASTER := false
# endif


# Validate Auto Populated variables are not empty
$(call check_defined, \
	BUILD_NUMBER \
	BUILD_SYSTEM \
	BUILD_HOST \
	GIT_COMMIT \
	GIT_COMMIT_SHORT \
	GIT_TAG_PRESENT, \
	LATEST_SEMVER, \
	GIT_BRANCH, \
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
ifeq ($(VERSION_FROM_GIT),true)
$(call check_defined, VERSION, Version(From Tags))
else
$(call check_defined, VERSION, Version(Pre defined))
endif


# Export all
export DEFAULT_BRANCH
export VENDOR

export GIT_BRANCH
export GIT_COMMIT
export GIT_COMMIT_SHORT
export GIT_TAG_PRESENT
# export GIT_REF_IN_MASTER
export GIT_TREE_STATE

export VERSION
export VERSION_FROM_GIT
export LATEST_SEMVER

export BUILD_HOST
export BUILD_NUMBER
export BUILD_SYSTEM

# Debug Stuff for base make template
# -------------------------------------

.PHONY: show-vars-base
show-vars-base: ## Show Base variables like VERSION
	@echo "VERSION              : $(VERSION)"
	@echo "VERSION_FROM_GIT     : $(VERSION_FROM_GIT)"
	@echo "SHELL                : $(SHELL)"
	@echo ""

	@echo "-------------- GIT VARIABLES -----------------"
	@echo "GIT_BRANCH           : $(GIT_BRANCH)"
	@echo "GIT_COMMIT           : $(GIT_COMMIT)"
	@echo "GIT_COMMIT_SHORT     : $(GIT_COMMIT_SHORT)"
	@echo "GIT_TAG_PRESENT      : $(GIT_TAG_PRESENT)"
	@echo "GIT_TREE_STATE       : $(GIT_TREE_STATE)"
	@echo "LATEST_SEMVER        : $(LATEST_SEMVER)"
	@echo ""

	@echo "----------- BASE BUILD VARIABLES -------------"
	@echo "BUILD_HOST           : $(BUILD_HOST)"
	@echo "BUILD_NUMBER         : $(BUILD_NUMBER)"
	@echo "BUILD_SYSTEM         : $(BUILD_SYSTEM)"

	@echo "----------- ACTION VARIABLES -----------------"
	@echo "GITHUB_ACTIONS       : $(GITHUB_ACTIONS)"
	@echo "GITHUB_WORKFLOW      : $(GITHUB_WORKFLOW)"
	@echo "GITHUB_RUN_NUMBER    : $(GITHUB_RUN_NUMBER)"
	@echo "GITHUB_REF           : $(GITHUB_REF)"


# diana:{diana_urn_flavor}:{remote}:{source}:{version}:{remote_path}:{type}
# diana:2:github:tprasadtp/templates::makefiles/base.mk:static
