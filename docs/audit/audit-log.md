# Audit Log

Immutable, append-only record of merges to `main` and published releases.
Entries are appended automatically by `.github/workflows/audit-log.yml` to
the dedicated **`audit-log`** branch — kept off `main` so the ledger never
needs to bypass branch protection and cannot be rewritten through a normal
PR. This copy documents the schema; see the `audit-log` branch for live
entries. Do not edit past entries manually — append only, so the record
remains a trustworthy compliance artifact.

| Timestamp (UTC) | Actor | Event | Commit SHA | Ref |
|---|---|---|---|---|
