# Changelog

All notable changes to this project are documented here. Entries from
`v0.1.0` onward are generated automatically by `goreleaser` from
Conventional Commit messages (see `.goreleaser.yml` `changelog` section) —
do not hand-edit past entries.

## [Unreleased]

### Added
- Initial project scaffold: HTTP service with health/readiness endpoints,
  layered configuration, graceful shutdown.
- Full CI/CD pipeline: lint, unit tests with coverage gate, e2e tests,
  build.
- Security pipeline: CodeQL, gosec, gitleaks, govulncheck, OPA/Conftest
  policy checks, OWASP ZAP baseline DAST.
- SBOM generation (SPDX) attached to releases.
- Governance automation: signed-commit verification, Conventional Commit
  PR titles, audit log.
- Documentation: README, user guide, operations runbook, architecture doc
  with Mermaid diagrams.
