SHELL := /bin/bash
.DEFAULT_GOAL := help

REPO_ROOT := $(shell pwd)

.PHONY: help
help: ## List available targets
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: new-lesson
new-lesson: ## Scaffold a new lesson: make new-lesson NAME=NN-slug
	@test -n "$(NAME)" || (echo "usage: make new-lesson NAME=NN-slug" && exit 1)
	@tools/new-lesson $(NAME)

.PHONY: slides-dev
slides-dev: ## Serve one lesson's deck locally on http://localhost:8000 (LESSON=NN-slug)
	@test -n "$(LESSON)" || (echo "usage: make slides-dev LESSON=NN-slug" && exit 1)
	@tools/slides-dev $(LESSON)

.PHONY: slides-build
slides-build: ## Build the static slides site into dist/
	@elixir tools/build_index/build_index.exs \
		--lessons lessons --shared shared/reveal --out dist

.PHONY: slides-docker
slides-docker: ## Build the deploy image and run it locally on http://localhost:8080
	docker build -t elixir-training-slides:local -f deploy/Dockerfile .
	@echo "starting container on http://localhost:8080  (Ctrl-C to stop)"
	docker run --rm -p 8080:8080 -e PORT=8080 elixir-training-slides:local

.PHONY: test
test: ## Run mix test in every lesson's exercises/ (skips @tag :pending)
	@tools/run-all-tests

.PHONY: test-lesson
test-lesson: ## Run mix test for one lesson: make test-lesson LESSON=NN-slug
	@test -n "$(LESSON)" || (echo "usage: make test-lesson LESSON=NN-slug" && exit 1)
	@cd lessons/$(LESSON)/exercises && mix deps.get && mix test

.PHONY: solutions-test
solutions-test: ## Run mix test in every lesson's solutions/ (must all pass)
	@tools/check-solutions

.PHONY: lint
lint: ## Run mix format --check-formatted (+ credo where declared) across lessons
	@tools/lint-all

.PHONY: ci-smoke
ci-smoke: ## End-to-end harness smoke: scaffold a lesson, compile it, lint, tear down
	@tools/test-harness
