PROJECT_ROOT := $(CURDIR)
TMP_ROOT := tmp
GO_VERSION := 1.26.4
MACHINE_ARCH := $(shell uname -m)
GO_ARCH := $(if $(filter arm64,$(MACHINE_ARCH)),arm64,$(if $(filter x86_64,$(MACHINE_ARCH)),amd64,unsupported))
GO_ARCHIVE := go$(GO_VERSION).darwin-$(GO_ARCH).tar.gz
GO_SHA256 := $(if $(filter arm64,$(GO_ARCH)),b62ad2b6d7d2464f12a5bcad7ff47f19d08325773b5efd21610e445a05a9bf53,$(if $(filter amd64,$(GO_ARCH)),05dc9b5f9997744520aaebb3d5deaa7c755371aebbfb7f97c2511a9f3367538d,unsupported))
GO ?= $(TMP_ROOT)/.go-toolchain/bin/go

export GOCACHE := $(PROJECT_ROOT)/$(TMP_ROOT)/.go-build
export GOMODCACHE := $(PROJECT_ROOT)/$(TMP_ROOT)/.go-mod
export GOPATH := $(PROJECT_ROOT)/$(TMP_ROOT)/.go-path
export TMPDIR := $(PROJECT_ROOT)/$(TMP_ROOT)/.system-tmp
export GOTMPDIR := $(TMPDIR)

BINARY := $(PROJECT_ROOT)/bin/joshpeak-prompt
COVERAGE := $(TMP_ROOT)/coverage.out

.DEFAULT_GOAL := help

.PHONY: all bootstrap build build-all check clean compat coverage fmt help install prepare race test tidy vet

all: check build ## Run all confidence checks and build the local binary.

prepare: ## Create every project-local temporary and cache directory.
	mkdir -p $(GOCACHE) $(GOMODCACHE) $(GOPATH) $(TMPDIR)

# Download and verify the pinned macOS Go toolchain when it is absent.
$(GO): | prepare
	@test "$(GO_ARCH)" != "unsupported" || (echo "unsupported macOS architecture: $(MACHINE_ARCH)" >&2; exit 1)
	mkdir -p $(TMP_ROOT)/.downloads $(TMP_ROOT)/.go-toolchain
	curl -fsSL https://go.dev/dl/$(GO_ARCHIVE) -o $(TMP_ROOT)/.downloads/$(GO_ARCHIVE)
	@test "$$(shasum -a 256 $(TMP_ROOT)/.downloads/$(GO_ARCHIVE) | awk '{print $$1}')" = "$(GO_SHA256)"
	tar -xzf $(TMP_ROOT)/.downloads/$(GO_ARCHIVE) -C $(TMP_ROOT)/.go-toolchain --strip-components 1

help: ## List the documented Make targets.
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_-]+:.*## / {printf "%-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

bootstrap: $(GO) | prepare ## Download and verify the pinned project-local Go toolchain.

fmt: | prepare $(GO) ## Format all Go source files.
	$(GO) fmt ./...

tidy: | prepare $(GO) ## Resolve dependencies and update go.mod and go.sum.
	$(GO) mod tidy

test: | prepare $(GO) ## Run the unit test suite.
	$(GO) test ./...

race: | prepare $(GO) ## Run the unit tests with the race detector.
	$(GO) test -race ./...

coverage: | prepare $(GO) ## Run tests and require 100 percent statement coverage.
	$(GO) test -covermode=atomic -coverprofile=$(COVERAGE) ./...
	$(GO) tool cover -func=$(COVERAGE)
	@test "$$($(GO) tool cover -func=$(COVERAGE) | awk '/^total:/ {print $$3}')" = "100.0%"

vet: | prepare $(GO) ## Run Go's static analysis checks.
	$(GO) vet ./...

check: fmt vet race coverage ## Format, vet, race-test, and verify full coverage.

build: | prepare $(GO) ## Build a CGO-free executable in bin/.
	mkdir -p $(dir $(BINARY))
	CGO_ENABLED=0 $(GO) build -trimpath -o $(BINARY) ./cmd/joshpeak-prompt

build-all: | prepare $(GO) ## Cross-build CGO-free binaries for both macOS architectures.
	mkdir -p $(dir $(BINARY))
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 $(GO) build -trimpath -o $(BINARY)-darwin-arm64 ./cmd/joshpeak-prompt
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 $(GO) build -trimpath -o $(BINARY)-darwin-amd64 ./cmd/joshpeak-prompt

compat: build ## Compare every live Go prompt section with its legacy zsh helper.
	zsh scripts/check-legacy.zsh

install: | prepare $(GO) ## Install the CGO-free executable into the project-local GOPATH.
	CGO_ENABLED=0 $(GO) install ./cmd/joshpeak-prompt

clean: ## Remove the project-local tmp/ tree and built binaries.
	rm -rf $(TMP_ROOT) $(PROJECT_ROOT)/bin
