# Architecture

This document is the source of truth for system structure. If you change
package boundaries or the request lifecycle, update the diagrams below in
the same PR — reviewers should treat a stale diagram as a blocking issue,
not a nitpick.

## Package structure

```mermaid
graph TD
    main["cmd/app/main.go"] --> config["internal/config"]
    main --> service["internal/service"]
    main --> version["internal/version"]
    service --> config
    testUnit["test/unit"] --> service
    testUnit --> config
    testE2E["test/e2e"] -->|builds & runs real binary| main
    testSecurity["test/security"] -->|ZAP rules against running instance| main
```

## Request lifecycle

```mermaid
sequenceDiagram
    participant Client
    participant Server as HTTP Server (service.go)
    participant Config as config.Load()

    Note over Server,Config: Startup (once)
    Server->>Config: Load()
    Config-->>Server: validated Config or error

    Note over Client,Server: Steady state
    Client->>Server: GET /healthz
    Server-->>Client: 200 {"status":"alive"}

    Client->>Server: GET /readyz
    Server-->>Client: 200 {"status":"ready"}

    Note over Server: SIGINT/SIGTERM received
    Server->>Server: context cancelled
    Server->>Server: Shutdown(ctx, timeout=15s)
```

## CI/CD pipeline

```mermaid
flowchart LR
    PR[Pull Request] --> Lint
    PR --> UnitTests[Unit Tests + Coverage Gate]
    PR --> Governance[Governance: signed commits, PR title]
    Lint --> Build
    UnitTests --> Build
    UnitTests --> E2E[E2E Tests]
    PR --> SAST[CodeQL + gosec]
    PR --> Secrets[gitleaks]
    PR --> SCA[govulncheck]
    PR --> Policy[OPA / Conftest]
    PR --> DAST[OWASP ZAP baseline]

    Build --> Merge{All checks green?}
    E2E --> Merge
    SAST --> Merge
    Secrets --> Merge
    SCA --> Merge
    Policy --> Merge
    DAST --> Merge

    Merge -->|yes, 1+ CODEOWNER approval| MainBranch[main]
    MainBranch --> AuditLog[Audit entry appended to audit-log branch]
    MainBranch -->|tag pushed| Release[goreleaser: build, sign, SBOM]
    Release --> GHRelease[GitHub Release + SBOM asset]
```

## Testing pyramid

```mermaid
graph TD
    E2E["End-to-End (test/e2e)<br/>full binary, real HTTP, slowest, fewest"]
    Security["Security (test/security, security.yml)<br/>SAST + DAST + SCA + secrets"]
    Unit["Unit (internal/**, test/unit)<br/>fast, isolated, most numerous"]

    Unit --> Security
    Security --> E2E
```

## Design decisions

- **Config precedence** (env > file > default) follows twelve-factor app
  conventions so the same binary behaves correctly across dev/staging/prod
  without code changes.
- **Distroless runtime image** (see `Dockerfile`) minimizes CVE surface —
  there's no shell or package manager to exploit post-compromise.
- **Readiness vs. liveness are separate endpoints** deliberately: a
  process can be alive but not ready (e.g., warming a cache), and
  conflating the two causes premature traffic routing during startup.
- **Security headers on every response** (`securityHeaders` middleware in
  `service.go`): CSP, HSTS, `X-Content-Type-Options`, `X-Frame-Options`,
  and `Referrer-Policy`. These are asserted by a unit test and by the
  OWASP ZAP rules (`test/security/zap-rules.tsv`), so the DAST scan and
  the code stay in agreement.
