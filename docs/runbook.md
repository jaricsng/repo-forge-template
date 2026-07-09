# Operations Runbook

Audience: whoever is on-call for this service. Keep this file in sync with
`internal/service/service.go` and the deployment workflows — if a step
here no longer matches reality, fix the doc in the same PR that changed
the behavior.

## Service overview

- Single stateless binary, HTTP on `APP_PORT` (default 8080)
- Graceful shutdown on SIGINT/SIGTERM with a 15s drain window
  (`internal/service/service.go`)
- Structured JSON logs to stdout via `log/slog`

## Deploying a release

1. Merge to `main` triggers `ci.yml` (build+test) and `security.yml`.
2. Tag a release: `git tag -a vX.Y.Z -m "vX.Y.Z" && git push origin vX.Y.Z`.
3. Publishing the GitHub Release triggers `sbom.yml` to attach the SBOM,
   and `goreleaser` (run via a release workflow, or manually with
   `make release` for a dry run) builds and signs binaries.
4. Verify the audit trail entry was appended in `docs/audit/audit-log.md`.

## Health checks

```bash
curl -f http://<host>:<port>/healthz   # process alive
curl -f http://<host>:<port>/readyz    # ready for traffic
```

Both should return HTTP 200. A non-200 on `/readyz` while `/healthz` is
still 200 means the process is up but a dependency isn't ready — check
logs for the specific failing check before restarting anything.

## Common incidents

### Service won't start: "invalid configuration"

Cause: `internal/config/config.go` validation failed — usually an
out-of-range `APP_PORT` or an `APP_ENVIRONMENT` value outside
`dev|staging|production`.

Fix: check the exact error in the startup log line
`"failed to load configuration"`, correct the environment variable or
`config.yaml`, and restart.

### `/readyz` returns non-200 under load

Cause: readiness handler currently always returns 200 as a placeholder —
if you've wired in real dependency checks (DB, cache, etc.), this means
one of those checks is failing.

Fix: check application logs for the specific dependency error. Do not
force readiness to `true` to "fix" alerting — that hides a real outage
from the load balancer / orchestrator.

### High rate of 5xx after a deploy

1. Check the `security.yml` and `ci.yml` run for the deployed commit —
   did any required check get bypassed?
2. Roll back by redeploying the previous tagged release (binaries and
   SBOMs for all past releases are retained as GitHub Release assets).
3. Open an incident issue and begin a postmortem once stable.

## Rollback procedure

1. Identify the last known-good tag from `docs/audit/audit-log.md` or
   GitHub Releases.
2. Redeploy that tag's binary/image through your deployment tooling.
3. Confirm `/healthz` and `/readyz` return 200 post-rollback.
4. File an incident record referencing the audit-log entry of the bad
   release.

## Escalation

Security-impacting incidents: follow `SECURITY.md`'s disclosure timeline
internally as well — do not wait for the public disclosure window to
start internal remediation.
