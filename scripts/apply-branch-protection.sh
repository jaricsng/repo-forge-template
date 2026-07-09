#!/usr/bin/env bash
# Applies main-branch protection rules matching this template's CI/governance
# workflows. Branch protection cannot be expressed as a committed file —
# GitHub only exposes it via the API/UI — so this script is the canonical,
# reviewable source of truth for what protection should look like.
#
# Usage:
#   GITHUB_TOKEN=<pat-with-repo-admin> ./scripts/apply-branch-protection.sh <owner>/<repo>
#
# Requires: gh CLI authenticated, or a GITHUB_TOKEN with repo admin scope.

set -euo pipefail

REPO="${1:?Usage: $0 <owner>/<repo>}"

# Solo maintainers can set SOLO_DEV=1 to exempt admins from these rules,
# letting the repo owner self-merge (or push directly) without a second
# reviewer. Teams should leave it unset so protection applies to everyone,
# admins included.
if [[ "${SOLO_DEV:-0}" == "1" ]]; then
  ENFORCE_ADMINS=false
  echo "SOLO_DEV=1: admins are exempt from protection (owner can self-merge)."
else
  ENFORCE_ADMINS=true
fi

echo "Applying branch protection to ${REPO}#main ..."

# The branch-protection API requires a typed JSON body (booleans, integers,
# nested objects). gh's -f flag sends everything as strings, which the API
# rejects with 422, so we build the payload as JSON and pipe it via --input.
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/${REPO}/branches/main/protection" \
  --input - <<JSON
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "Lint",
      "Unit Tests",
      "End-to-End Tests",
      "Build",
      "CodeQL (SAST)",
      "gosec (Go SAST)",
      "Secret Scanning",
      "Dependency Vulnerability Audit",
      "OPA / Conftest Policy Checks"
    ]
  },
  "enforce_admins": ${ENFORCE_ADMINS},
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true
  },
  "required_conversation_resolution": true,
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON

# required_signatures lives on a separate endpoint (it is not part of the
# protection payload above), so apply it independently.
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/${REPO}/branches/main/protection/required_signatures" >/dev/null

echo "Branch protection applied. Verify at:"
echo "https://github.com/${REPO}/settings/branches"
