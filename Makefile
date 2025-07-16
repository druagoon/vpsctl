.DEFAULT_GOAL := help

SHELL := bash

# BASE_DIR := $(shell cd "`dirname "$0"`" >/dev/null 2>&1 && pwd)

##@ General

.PHONY: help
help: ## Display help messages
	@./.make/help "$(MAKEFILE_LIST)"
