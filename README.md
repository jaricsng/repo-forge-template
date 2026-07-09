# repo-forge-template

A reference Go service demonstrating a production-grade repository baseline:
CI/CD, layered testing (unit → e2e → security), policy-as-code governance,
supply-chain security (SBOM, signed releases), and documentation kept in
sync with code. Use this as the scaffold output for `repo-forge`, or clone
it directly for a new service.

## Why this exists

Starting a new repository correctly — branch protection, security scanning,
audit trails, license compliance — is easy to get wrong or skip under
deadline pressure. This template makes the correct setup the default, not
an afterthought.

## Quickstart

```bash
git clone git@github.com:jaric/repo-forge-template.git
cd repo-forge-template
pre-commit install        # enable local hooks (see .pre-commit-config.yaml)
make build                # compiles ./bin/app with version metadata
make run                  # starts the service on :8080
curl localhost:8080/healthz
```

## What's included

| Concern | Where |
|---|---|
| CI (lint, unit, e2e, build) | `.github/workflows/ci.yml` |
| Security (SAST, secrets, SCA) | `.github/workflows/security.yml` |
| Dynamic security testing (OWASP ZAP) | `.github/workflows/owasp-dast.yml` |
| SBOM generation | `.github/workflows/sbom.yml` |
| Governance (signed commits, PR title) | `.github/workflows/governance.yml` |
| Audit trail | `.github/workflows/audit-log.yml`, `docs/audit/audit-log.md` |
| Policy as code (OPA/Rego) | `policy/` |
| Pre-commit hooks | `.pre-commit-config.yaml` |
| Branch protection (applied via script) | `scripts/apply-branch-protection.sh` |
| License / attribution | `LICENSE` (MIT), `NOTICE` |
| Security disclosure policy | `SECURITY.md` |
| User guide | `docs/user-guide.md` |
| Operations runbook | `docs/runbook.md` |
| Architecture + diagrams | `docs/architecture.md` |

## Branch protection & commit signing

Apply the hardened `main` protection rules once, after pushing your repo:

```bash
# Team repo: admins are also subject to the rules.
./scripts/apply-branch-protection.sh <owner>/<repo>

# Solo repo: exempt admins so you can self-merge without a second reviewer.
SOLO_DEV=1 ./scripts/apply-branch-protection.sh <owner>/<repo>
```

This enables **required signed commits**. If you don't set up signing, every
push to `main` is rejected (`Commits must have verified signatures`) unless an
admin bypasses it — so configure signing before you rely on protection.

SSH signing is the least-friction option and reuses the SSH key you already
push with (no GPG keyring needed):

```bash
# 1. Tell git to sign commits and tags with your SSH key.
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub   # your public key
git config --global commit.gpgsign true
git config --global tag.gpgsign true

# 2. Register the SAME public key on GitHub as a *signing* key (separate from
#    the authentication key), so GitHub marks your commits "Verified".
gh auth refresh -h github.com -s admin:ssh_signing_key
gh ssh-key add ~/.ssh/id_ed25519.pub --type signing --title "commit-signing"
```

Use `--global` for all your repos, or drop it (or `git config --local ...`) to
scope signing to this repo only. Signing configuration lives in git config and
is never committed, so cloning this template never forces signing on anyone —
each user opts in with the steps above.

## Documentation-code sync policy

Every PR that changes behavior must update the relevant doc and Mermaid
diagram in the same commit (see `CONTRIBUTING.md`). `docs/architecture.md`
is the source of truth for system structure; if code and diagram disagree,
that's a bug in the PR, not just the docs.

## License

MIT — see [LICENSE](LICENSE). This is a permissive default; swap to
Apache-2.0 in `LICENSE` and `go.mod` header comments if you need an
explicit patent grant (common for enterprise/fintech-adjacent projects).
Third-party attributions are in [NOTICE](NOTICE).
