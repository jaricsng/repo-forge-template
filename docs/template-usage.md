# Using This Template

This guide walks you from "I want to start a new service" to a repository
with the same guardrails as this template: CI, security scanning, signed
commits, branch protection, and an audit trail. Budget ~15 minutes.

For running or integrating with the resulting service, see
[`user-guide.md`](user-guide.md) and [`runbook.md`](runbook.md).

## 1. Create your repository

**Recommended — "Use this template":** on the GitHub repo page, click
**Use this template → Create a new repository**. This gives you a clean
history (none of this template's commits) owned by you.

**Alternative — clone and re-init:**

```bash
git clone git@github.com:jaricsng/repo-forge-template.git my-service
cd my-service
rm -rf .git && git init            # start fresh history
git remote add origin git@github.com:<you>/my-service.git
```

## 2. Rename the Go module

The scaffold's module path is `github.com/jaric/repo-forge-template`. Point
it at your repository so imports, build metadata, and `go install` resolve
correctly:

```bash
OLD=github.com/jaric/repo-forge-template
NEW=github.com/<you>/my-service

go mod edit -module "$NEW"
# Rewrite import paths and the Makefile ldflags. GNU sed shown;
# on macOS/BSD use: sed -i '' "s|...|...|g"
grep -rl "$OLD" --include='*.go' . | xargs sed -i "s|$OLD|$NEW|g"
sed -i "s|$OLD|$NEW|g" Makefile

go mod tidy
go build ./... && go test ./...   # confirm the rename is clean
```

## 3. Install local tooling

Everything is also enforced in CI, so this is only for fast local feedback:

```bash
# Go 1.26+ (the version is pinned in go.mod)
pip install pre-commit && pre-commit install
# Optional local security/policy checks (also run in CI):
#   conftest, gosec, govulncheck, gitleaks, syft
```

## 4. Build, run, and verify

```bash
make build          # ./bin/app with version metadata
make run            # starts on :8080
curl localhost:8080/healthz     # {"status":"alive"}
make test           # unit tests
```

## 5. Set up commit signing

Branch protection (next step) requires **verified signatures**, so configure
signing before you push to a protected branch. Follow the
**Branch protection & commit signing** section in the
[README](../README.md#branch-protection--commit-signing) — SSH signing with
your existing key is the least-friction path.

## 6. Push and apply branch protection

```bash
git add -A && git commit -S -m "chore: initialize from template"
git push -u origin main

# Team repo (admins subject to the rules):
./scripts/apply-branch-protection.sh <you>/my-service
# Or, solo maintainer (admins may self-merge):
SOLO_DEV=1 ./scripts/apply-branch-protection.sh <you>/my-service
```

This turns on the required status checks, required Code Owner review,
signed commits, and conversation-resolution rules. See
`scripts/apply-branch-protection.sh` for the exact ruleset.

## 7. Make it yours

Replace the scaffold specifics with your project's:

| Change | Where |
|---|---|
| Business logic (replace the health handlers) | `internal/service/service.go` |
| Config schema, defaults, validation | `internal/config/config.go`, `config.example.yaml` |
| **Code owners — change `@jaricsng` to your handle** | `.github/CODEOWNERS` |
| License and third-party attribution | `LICENSE`, `NOTICE` |
| Security contact and disclosure window | `SECURITY.md` |
| Project name, badges, description | `README.md` |
| Docs and Mermaid diagrams | `docs/` |

Keep the security headers middleware and the health/config/graceful-shutdown
scaffolding — that's the reusable part.

## What you get

Once branch protection is applied, every pull request must pass, before it
can merge:

- **CI** — lint, unit tests (with coverage), e2e tests, build
- **SAST** — CodeQL and gosec
- **Secret scanning** — gitleaks
- **Dependency audit** — govulncheck (on the latest patched Go toolchain)
- **Policy as code** — OPA/Conftest over workflows and the Dockerfile
- **Governance** — Conventional Commit PR titles and verified signatures

Plus, out of band: a weekly OWASP ZAP DAST scan, SBOM generation, an
immutable audit ledger on the `audit-log` branch, and Dependabot updates
(dependencies + SHA-pinned actions) grouped into tidy PRs.

## Adoption checklist

- [ ] Repo created (template or fresh history)
- [ ] Go module renamed; `go build ./...` and `go test ./...` pass
- [ ] Commit signing configured and key registered on GitHub
- [ ] Pushed to your remote; branch protection applied
- [ ] `.github/CODEOWNERS` points at your GitHub handle
- [ ] `SECURITY.md`, `LICENSE`, `README.md` updated for your project
- [ ] Health handlers replaced with your service logic
