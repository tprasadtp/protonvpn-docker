# This file is managed by diana.

# This file is managed by petra.
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

$(call check_defined, REPO_ROOT, REPO_ROOT MUST be defined for relative paths to work properly)

# diana:{diana_urn_flavor}:{remote}:{source}:{version}:{remote_path}:{type}
# diana:2:github:tprasadtp/templates::makefiles/help.mk:static
