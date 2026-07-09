.PHONY: help build run test test-unit test-e2e test-security lint fmt vet \
        sbom sec-scan policy-check pre-commit release notice clean

VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT  := $(shell git rev-parse --short HEAD 2>/dev/null || echo "none")
DATE    := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
LDFLAGS := -X github.com/jaric/repo-forge-template/internal/version.Version=$(VERSION) \
           -X github.com/jaric/repo-forge-template/internal/version.Commit=$(COMMIT) \
           -X github.com/jaric/repo-forge-template/internal/version.BuildDate=$(DATE)

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'

build: ## Build the binary with version metadata embedded
	go build -ldflags "$(LDFLAGS)" -o bin/app ./cmd/app

run: build ## Build and run the service locally
	./bin/app

test: test-unit ## Alias for test-unit (fast feedback loop)

test-unit: ## Run unit tests with race detector and coverage
	go test ./internal/... ./test/unit/... -race -coverprofile=coverage.out -covermode=atomic
	go tool cover -func=coverage.out | tail -1

test-e2e: ## Run full-stack end-to-end tests against a compiled binary
	go test ./test/e2e/... -v -timeout 60s

test-security: ## Run local security checks (govulncheck + gosec), mirrors CI
	@command -v govulncheck >/dev/null || go install golang.org/x/vuln/cmd/govulncheck@latest
	govulncheck ./...
	@command -v gosec >/dev/null || go install github.com/securego/gosec/v2/cmd/gosec@latest
	gosec ./...

policy-check: ## Run OPA/Conftest policy checks locally, mirrors CI
	# --all-namespaces is required: the policies live in the policy.* packages,
	# and without it conftest only evaluates the 'main' namespace and silently
	# passes without checking anything.
	conftest test --all-namespaces --policy policy/ .github/workflows/*.yml

lint: ## Run golangci-lint
	@command -v golangci-lint >/dev/null || go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	golangci-lint run ./...

fmt: ## Format code
	gofmt -w -s .
	goimports -w .

vet: ## Run go vet
	go vet ./...

sbom: ## Generate a local SBOM (SPDX format) via Syft
	@command -v syft >/dev/null || (echo "install syft: https://github.com/anchore/syft" && exit 1)
	syft dir:. -o spdx-json=sbom.spdx.json

pre-commit: ## Run all pre-commit hooks against the full repo
	pre-commit run --all-files

release: ## Cut a release locally with goreleaser (dry run)
	goreleaser release --snapshot --clean

notice: ## Regenerate NOTICE third-party attribution summary
	go list -m all > /tmp/deps.txt
	@echo "Review /tmp/deps.txt and update NOTICE manually; SBOM is the authoritative machine-readable source."

clean: ## Remove build artifacts
	rm -rf bin/ dist/ coverage.out sbom.spdx.json
