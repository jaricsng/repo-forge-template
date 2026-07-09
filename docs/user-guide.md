# User Guide

This guide is for anyone consuming or integrating with the service —
not for operators running it (see `runbook.md` for that).

## What the service does

A minimal HTTP service exposing liveness and readiness endpoints, intended
as a starting skeleton. Replace `internal/service/service.go` handlers
with your actual business logic; the health/config/graceful-shutdown
scaffolding stays as-is.

## Endpoints

| Method | Path | Purpose | Response |
|---|---|---|---|
| GET | `/healthz` | Liveness probe — is the process running? | `200 {"status":"alive"}` |
| GET | `/readyz` | Readiness probe — can it serve traffic? | `200 {"status":"ready"}` |

All responses are `application/json` and carry baseline security headers
(`Content-Security-Policy`, `Strict-Transport-Security`,
`X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`), applied by
the `securityHeaders` middleware.

## Configuration

Configuration is layered: environment variables override `config.yaml`,
which overrides built-in defaults.

| Key | Env var | Default | Description |
|---|---|---|---|
| `port` | `APP_PORT` | `8080` | HTTP listen port |
| `environment` | `APP_ENVIRONMENT` | `dev` | One of `dev`, `staging`, `production` |
| `log_level` | `APP_LOG_LEVEL` | `info` | Structured (JSON) log verbosity |

Example `config.yaml`:

```yaml
port: 8080
environment: production
log_level: warn
```

## Versioning

Releases follow [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`.
Breaking API/behavior changes bump `MAJOR`. Check `CHANGELOG.md` (generated
by goreleaser from Conventional Commit messages) before upgrading across a
major version.

## Getting help

Open an issue using the Bug Report template, or see `SECURITY.md` if the
issue is a vulnerability rather than a functional bug.
