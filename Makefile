# Agents Library - Development and Validation
# ===========================================

SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c

PYTHON := python3

.PHONY: help validate-marketplace

help: ## Show this help message
	@echo "Agents Library - Development Commands"
	@echo "====================================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

validate-marketplace: ## Validate marketplace.json integrity
	@echo "Validating marketplace integrity..."
	@$(PYTHON) tools/validate-marketplace.py

# --- Hook Testing -----------------------------------------------------------

BATS_VERSION := 1.11.0
BATS_DIR     := .cache/bats-core-$(BATS_VERSION)
BATS         := $(BATS_DIR)/bin/bats

.PHONY: test test-hooks clean-test-cache

test: test-hooks ## Run all tests

test-hooks: | _check-test-deps $(BATS) ## Run hook regression tests
	@$(BATS) plugins/claude-9/tests/*.bats

_check-test-deps:
	@command -v curl >/dev/null 2>&1 || { echo "Error: curl required"; exit 1; }
	@command -v jq >/dev/null 2>&1 || { echo "Error: jq required (also needed by hooks at runtime)"; exit 1; }

$(BATS):
	@mkdir -p .cache
	@echo "Fetching bats-core v$(BATS_VERSION)..."
	@curl -fsSL "https://github.com/bats-core/bats-core/archive/refs/tags/v$(BATS_VERSION).tar.gz" \
		-o .cache/bats.tar.gz
	@tar -xzf .cache/bats.tar.gz -C .cache
	@rm .cache/bats.tar.gz
	@echo "bats-core $(BATS_VERSION) ready at $(BATS_DIR)"

clean-test-cache: ## Remove cached test dependencies
	rm -rf .cache/
