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
	@$(PYTHON) -c "import json; d=json.load(open('.claude-plugin/marketplace.json')); print(f'{len(d[\"plugins\"])} plugins validated')"
