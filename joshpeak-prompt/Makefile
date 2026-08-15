PROJECT_ROOT := $(CURDIR)
TMP_ROOT := tmp
GO_VERSION := 1.26.4

# Detect the host so the same Makefile bootstraps a toolchain on macOS and Linux.
MACHINE_OS := $(shell uname -s)
MACHINE_ARCH := $(shell uname -m)
GO_OS := $(if $(filter Darwin,$(MACHINE_OS)),darwin,$(if $(filter Linux,$(MACHINE_OS)),linux,unsupported))
GO_ARCH := $(if $(filter arm64 aarch64,$(MACHINE_ARCH)),arm64,$(if $(filter x86_64 amd64,$(MACHINE_ARCH)),amd64,unsupported))

# Pinned Go toolchain checksums, keyed by GOOS_GOARCH (verified against go.dev).
GO_SHA256_darwin_arm64 := b62ad2b6d7d2464f12a5bcad7ff47f19d08325773b5efd21610e445a05a9bf53
GO_SHA256_darwin_amd64 := 05dc9b5f9997744520aaebb3d5deaa7c755371aebbfb7f97c2511a9f3367538d
GO_SHA256_linux_arm64 := ef758ae7c6cf9267c9c0ef080b8965f453d89ab2d25d9eb22de4405925238768
GO_SHA256_linux_amd64 := 1153d3d50e0ac764b447adfe05c2bcf08e889d42a02e0fe0259bd47f6733ad7f

GO_ARCHIVE := go$(GO_VERSION).$(GO_OS)-$(GO_ARCH).tar.gz
GO_SHA256 := $(GO_SHA256_$(GO_OS)_$(GO_ARCH))

# macOS ships shasum; Linux ships sha256sum. Both print "<hash>  <file>".
SHA256SUM := $(if $(filter Darwin,$(MACHINE_OS)),shasum -a 256,sha256sum)

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

# Download and verify the pinned host Go toolchain when it is absent.
$(GO): | prepare
	@test "$(GO_OS)" != "unsupported" || (echo "unsupported operating system: $(MACHINE_OS)" >&2; exit 1)
	@test "$(GO_ARCH)" != "unsupported" || (echo "unsupported architecture: $(MACHINE_ARCH)" >&2; exit 1)
	mkdir -p $(TMP_ROOT)/.downloads $(TMP_ROOT)/.go-toolchain
	curl -fsSL https://go.dev/dl/$(GO_ARCHIVE) -o $(TMP_ROOT)/.downloads/$(GO_ARCHIVE)
	@test "$$($(SHA256SUM) $(TMP_ROOT)/.downloads/$(GO_ARCHIVE) | awk '{print $$1}')" = "$(GO_SHA256)"
	tar -xzf $(TMP_ROOT)/.downloads/$(GO_ARCHIVE) -C $(TMP_ROOT)/.go-toolchain --strip-components 1

help: ## List the documented Make targets.
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_-]+:.*## / {printf "%-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

bootstrap: $(GO) | prepare ## Download and verify the host's pinned project-local Go toolchain.

fmt: | prepare $(GO) ## Format all Go source files.
	$(GO) fmt ./...

tidy: | prepare $(GO) ## Resolve dependencies and update go.mod and go.sum.
	$(GO) mod tidy

test: | prepare $(GO) ## Run the unit test suite.
	$(GO) test ./...

# The Go race detector needs a 48-bit-VMA kernel on linux/arm64. The Raspberry Pi
# OS kernel ships a 39-bit layout, so probe support and fall back to plain tests
# with a loud notice rather than failing the confidence gate on that host.
race: | prepare $(GO) ## Run the unit tests with the race detector when the host supports it.
	@if $(GO) test -race -run '^$$' ./cmd/joshpeak-prompt >/dev/null 2>&1; then \
		echo "race detector supported on $(GO_OS)/$(GO_ARCH); running race tests"; \
		$(GO) test -race ./...; \
	else \
		echo "WARNING: race detector unsupported on this $(GO_OS)/$(GO_ARCH) host (e.g. 39-bit VMA kernel); running tests without -race" >&2; \
		$(GO) test ./...; \
	fi

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

build-all: | prepare $(GO) ## Cross-build CGO-free binaries for every supported OS/arch.
	mkdir -p $(dir $(BINARY))
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 $(GO) build -trimpath -o $(BINARY)-darwin-arm64 ./cmd/joshpeak-prompt
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 $(GO) build -trimpath -o $(BINARY)-darwin-amd64 ./cmd/joshpeak-prompt
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 $(GO) build -trimpath -o $(BINARY)-linux-arm64 ./cmd/joshpeak-prompt
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GO) build -trimpath -o $(BINARY)-linux-amd64 ./cmd/joshpeak-prompt

compat: build ## Compare every live Go prompt section with its legacy zsh helper.
	zsh scripts/check-legacy.zsh

install: | prepare $(GO) ## Install the CGO-free executable into the project-local GOPATH.
	CGO_ENABLED=0 $(GO) install ./cmd/joshpeak-prompt

clean: ## Remove the project-local tmp/ tree and the local unsuffixed build.
	-chmod -R u+w $(TMP_ROOT) 2>/dev/null
	rm -rf $(TMP_ROOT)
	rm -f $(BINARY)
