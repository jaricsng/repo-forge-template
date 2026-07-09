package policy.github_actions

# Governance rules for GitHub Actions workflow files, evaluated in CI
# against every file under .github/workflows/*.yml via Conftest.

# Deny use of unpinned third-party actions (must be pinned to a full
# commit SHA, not a mutable tag, to prevent supply-chain tampering).
deny[msg] {
	some job_name
	step := input.jobs[job_name].steps[_]
	uses := step.uses
	not startswith(uses, "actions/") # first-party actions are trusted by tag
	not regex.match(`@[0-9a-f]{40}$`, uses)
	msg := sprintf("step '%s' uses unpinned action '%s'; pin to a full commit SHA", [job_name, uses])
}

# Deny workflows that grant write-all permissions.
deny[msg] {
	input.permissions == "write-all"
	msg := "workflow must not request 'write-all' permissions; scope permissions per job"
}

# Require pull_request triggers to not run on forked-repo secrets misuse.
deny[msg] {
	input.on.pull_request_target
	msg := "pull_request_target is disallowed; use pull_request with restricted permissions instead"
}
