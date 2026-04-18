# Scaffoldrack blog — Makefile
# ============================
# One entry point for every Hugo operation. Everything runs in the container
# defined in Dockerfile; no Hugo on the host required.
#
# Usage:
#   make dev                           # start live-reload dev server
#   make build                         # production build to public/
#   make new POST=my-post-slug         # new draft post from archetype
#   make new-page PAGE=colophon        # new standalone page
#   make clean                         # remove build artifacts
#   make shell                         # drop into a shell in the hugo container
#   make version                       # show pinned Hugo version
#
# Implementation note: we use USER_UID/USER_GID rather than UID/GID because
# UID is a read-only built-in in bash and attempting to set it via Make's
# `VAR=value` export pattern fails noisily.

SHELL := /bin/bash

# Host UID/GID passed into the container so files the container creates
# (public/, resources/_gen/, new posts) stay owned by you on the host.
USER_UID := $(shell id -u)
USER_GID := $(shell id -g)

# Single compose invocation used by every target. The env vars here are
# read by docker-compose.yml via ${USER_UID} / ${USER_GID}.
COMPOSE := USER_UID=$(USER_UID) USER_GID=$(USER_GID) docker compose

# One-shot run (no detached server) for build/new/shell targets.
RUN_ONCE := $(COMPOSE) run --rm --no-deps

.PHONY: help
help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

.PHONY: dev
dev:  ## Start Hugo live-reload dev server at http://localhost:1313
	$(COMPOSE) up

.PHONY: dev-detached
dev-detached:  ## Start dev server in the background
	$(COMPOSE) up -d

.PHONY: down
down:  ## Stop dev server
	$(COMPOSE) down

.PHONY: build
build:  ## Production build to public/ (mirrors what CI does)
	$(RUN_ONCE) --entrypoint hugo hugo \
	  --gc --minify --environment production

.PHONY: new
new:  ## New draft post: make new POST=slug
ifndef POST
	$(error POST is required. Example: make new POST=hello-world)
endif
	$(RUN_ONCE) --entrypoint hugo hugo new content posts/$(POST).md

.PHONY: new-page
new-page:  ## New standalone page: make new-page PAGE=slug
ifndef PAGE
	$(error PAGE is required. Example: make new-page PAGE=colophon)
endif
	$(RUN_ONCE) --entrypoint hugo hugo new content $(PAGE)/_index.md

.PHONY: shell
shell:  ## Drop into a shell in the hugo container (for debugging)
	$(RUN_ONCE) --entrypoint sh hugo

.PHONY: version
version:  ## Show Hugo version in the container
	$(RUN_ONCE) --entrypoint hugo hugo version

.PHONY: clean
clean:  ## Remove build artifacts
	rm -rf public/ resources/_gen/ .hugo_build.lock

.PHONY: image-build
image-build:  ## Force rebuild the Hugo container image
	$(COMPOSE) build --no-cache
