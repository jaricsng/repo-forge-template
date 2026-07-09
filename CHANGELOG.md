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
  PR titles, audit log (append-only ledger on the `audit-log` branch).
- Baseline security headers (CSP, HSTS, `X-Content-Type-Options`,
  `X-Frame-Options`, `Referrer-Policy`) on all service responses.
- Supply-chain hardening: all GitHub Actions pinned to full commit SHAs,
  scoped workflow permissions, and Dependabot (gomod / actions / docker)
  with grouped updates.
- Branch-protection script with a `SOLO_DEV` mode, and SSH commit-signing
  setup documented in the README.
- Documentation: README, template-usage guide, user guide, operations
  runbook, architecture doc with Mermaid diagrams.
