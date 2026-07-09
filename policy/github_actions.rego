package policy.github_actions

# Governance rules for GitHub Actions workflow files, evaluated in CI
# against every file under .github/workflows/*.yml via Conftest.
#
# NOTE: run Conftest with --all-namespaces; these rules live in the
# policy.github_actions package, not the default 'main' namespace.

# Workflow triggers. YAML 1.1 parses the bareword key `on` as the boolean
# true, so Conftest exposes the triggers under the key "true"; a quoted
# "on" stays as "on". Normalise both so the trigger rules below actually
# evaluate (a plain `input.on` reference silently never matches).
triggers := object.get(input, "true", object.get(input, "on", {}))

# Deny any action not pinned to a full 40-character commit SHA. Mutable
# tags (e.g. @v4) can be repointed by an attacker who compromises the
# action's repository, so every action — first- or third-party — must be
# pinned. Local actions (./path) live in this repo and are exempt.
deny[msg] {
	some job_name
	step := input.jobs[job_name].steps[_]
	uses := step.uses
	not startswith(uses, "./")
	not regex.match(`@[0-9a-f]{40}$`, uses)
	msg := sprintf("step in job '%s' uses unpinned action '%s'; pin to a full commit SHA", [job_name, uses])
}

# Deny write-all permissions at workflow scope.
deny[msg] {
	input.permissions == "write-all"
	msg := "workflow must not request 'write-all' permissions; scope permissions per job"
}

# Deny write-all permissions at job scope.
deny[msg] {
	some job_name
	input.jobs[job_name].permissions == "write-all"
	msg := sprintf("job '%s' must not request 'write-all' permissions; scope permissions explicitly", [job_name])
}

# Deny the pull_request_target trigger, map form:
#   on: { pull_request_target: ... }
deny[msg] {
	triggers.pull_request_target
	msg := "pull_request_target is disallowed; use pull_request with restricted permissions instead"
}

# Deny the pull_request_target trigger, list form:
#   on: [ ..., pull_request_target ]
deny[msg] {
	triggers[_] == "pull_request_target"
	msg := "pull_request_target is disallowed; use pull_request with restricted permissions instead"
}
