# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest `main` | ✅ |
| Latest tagged release | ✅ |
| Older releases | ❌ (upgrade recommended) |

## Reporting a Vulnerability

Please **do not** open a public GitHub issue for security vulnerabilities.

1. Use [GitHub's private security advisory form](../../security/advisories/new)
   for this repository, or email the maintainer directly (see repository
   profile).
2. Include: affected version/commit, a description of the issue, and
   reproduction steps or a proof of concept if available.
3. You should receive an acknowledgement within **3 business days**.
4. We aim to issue a fix or mitigation within **30 days** for high/critical
   severity findings, and will credit reporters (unless anonymity is
   requested) in the release notes.

## Our Security Controls

This repository enforces the following automatically on every pull request
(see `.github/workflows/security.yml`), plus the DAST scan noted below:

- **SAST**: CodeQL and gosec scan every PR and push to `main`.
- **Secret scanning**: gitleaks blocks commits containing credentials.
- **Dependency audit**: govulncheck flags known-vulnerable dependencies.
- **DAST**: OWASP ZAP baseline scan (`owasp-dast.yml`) runs against a live
  instance on pushes to `main` and on a weekly schedule.
- **Policy as code**: OPA/Conftest rules block insecure GitHub Actions
  configuration and container misconfiguration before merge.
- **SBOM**: an SPDX software bill of materials is generated for every build
  and uploaded as an artifact for downstream vulnerability tracking.

## Disclosure Policy

We follow coordinated disclosure. Please give us a reasonable window to
remediate before any public disclosure.
