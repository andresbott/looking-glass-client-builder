SHELL := /bin/bash

# ======================================================================================
default: help;

.PHONY: build
build: ## build the binary
	@docker build --progress=plain ./ -t looking-glass-builder
	@./copy.sh

help: ## Show this help
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m·%-20s\033[0m %s\n", $$1, $$2}'
