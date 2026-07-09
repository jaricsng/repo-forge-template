# Contributing

Thank you for contributing. This project enforces its standards mostly
through automation (CI, pre-commit, branch protection) so the process
below is deliberately lightweight — the tooling catches the rest.

## Prerequisites

- Go 1.22+
- [pre-commit](https://pre-commit.com/): `pip install pre-commit`
- [Conftest](https://www.conftest.dev/) (for local OPA policy checks)
- A GPG or SSH signing key configured with git (commits must be signed)

## One-time setup

```bash
git clone git@github.com:jaric/repo-forge-template.git
cd repo-forge-template
pre-commit install
go mod download
```

## Workflow

1. **Pull before you branch.** Always sync `main` first:
   ```bash
   git checkout main && git pull --ff-only
   git checkout -b feat/short-description
   ```
2. **Make your change.** Keep commits small and scoped. Write or update:
   - Unit tests (`internal/**/*_test.go`, `test/unit/`)
   - E2E tests (`test/e2e/`) if the change crosses a service boundary
   - Documentation and Mermaid diagrams in `docs/` if behavior or
     architecture changed — docs and code must stay in sync in the same PR
3. **Commit with sign-off:**
   ```bash
   git commit -S -m "feat: add readiness probe dependency checks"
   ```
   Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/):
   `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `security:`
4. **Pull `main` again before pushing**, in case it moved on while you worked:
   ```bash
   git fetch origin && git rebase origin/main
   ```
5. **Push and open a PR** using the provided template. CI will run lint,
   unit tests, e2e tests, security scans (SAST/DAST/secrets/dependency
   audit), and policy checks automatically.
6. **Request review.** At least one approving review from a CODEOWNER is
   required before merge (enforced by branch protection).
7. **Merge strategy:** squash-merge only, once all checks are green and
   conversations are resolved. Do not merge with failing or skipped
   required checks.

## Versioning

This project follows [Semantic Versioning](https://semver.org/). Tags are
cut via `.goreleaser.yml` from `main` — see `docs/runbook.md` for the
release procedure.

## Code of Conduct

Participation in this project is governed by our
[Code of Conduct](CODE_OF_CONDUCT.md).
