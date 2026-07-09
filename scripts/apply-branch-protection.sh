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

echo "Applying branch protection to ${REPO}#main ..."

gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/${REPO}/branches/main/protection" \
  -f "required_status_checks[strict]=true" \
  -f "required_status_checks[contexts][]=Lint" \
  -f "required_status_checks[contexts][]=Unit Tests" \
  -f "required_status_checks[contexts][]=End-to-End Tests" \
  -f "required_status_checks[contexts][]=Build" \
  -f "required_status_checks[contexts][]=CodeQL (SAST)" \
  -f "required_status_checks[contexts][]=gosec (Go SAST)" \
  -f "required_status_checks[contexts][]=Secret Scanning" \
  -f "required_status_checks[contexts][]=Dependency Vulnerability Audit" \
  -f "required_status_checks[contexts][]=OPA / Conftest Policy Checks" \
  -f "enforce_admins=true" \
  -f "required_pull_request_reviews[required_approving_review_count]=1" \
  -f "required_pull_request_reviews[dismiss_stale_reviews]=true" \
  -f "required_pull_request_reviews[require_code_owner_reviews]=true" \
  -f "required_conversation_resolution=true" \
  -f "required_signatures=true" \
  -f "restrictions=null" \
  -f "allow_force_pushes=false" \
  -f "allow_deletions=false"

echo "Branch protection applied. Verify at:"
echo "https://github.com/${REPO}/settings/branches"
