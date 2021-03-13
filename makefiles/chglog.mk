# This file is managed by diana.

# If SHELL is sh change it to bash
ifeq ($(SHELL),/bin/sh)
	SHELL := /bin/bash
endif

# Make Sure that REPO_ROOT is defined.
$(call check_defined, REPO_ROOT, Repository Root)

.PHONY: changelog
changelog: ## Generate changelog
	$(REPO_ROOT)/scripts/changelog.sh \
		--debug \
		--oldest-tag 4.0.0 \
		--footer-file $(REPO_ROOT)/.chglog/FOOTER.md \
		--output $(REPO_ROOT)/CHANGELOG.md \
		--changelog

.PHONY: release-notes
release-notes: ## Generate release-notes
	$(REPO_ROOT)/scripts/changelog.sh \
		--debug \
		--output $(REPO_ROOT)/RELEASE_NOTES.md \
		--release-notes
