SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

IMAGE := toolbox-aws:latest

help:
	@printf "Usage: make [target] [VARIABLE=value]\nTargets:\n"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

hooks: ## Setup pre commit.
	@pre-commit install
	@pre-commit gc

validate: ## Validate files with pre-commit hooks
	@pre-commit run --all-files

build-locally: ## Build docker container locally
	@docker build . --tag toolbox-aws
	@docker images

exec: ## Exec to docker container locally
	@docker run -it --rm $(IMAGE)

test: ## Test docker locally
	export IMAGE=$(IMAGE) && ./bin/test.sh
