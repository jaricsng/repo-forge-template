package policy.github_actions

test_denies_write_all {
	deny["workflow must not request 'write-all' permissions; scope permissions per job"] with input as {"permissions": "write-all"}
}

test_denies_job_write_all {
	deny[_] with input as {"jobs": {"build": {"permissions": "write-all"}}}
}

# pull_request_target expressed under a quoted "on" key.
test_denies_pull_request_target_on_key {
	deny[_] with input as {"on": {"pull_request_target": {}}}
}

# pull_request_target as Conftest actually parses a bareword `on:` — the
# boolean-true key. This is the case the original policy silently missed.
test_denies_pull_request_target_boolean_key {
	deny[_] with input as {"true": {"pull_request_target": {}}}
}

# pull_request_target in list form: on: [push, pull_request_target].
test_denies_pull_request_target_list {
	deny[_] with input as {"true": ["push", "pull_request_target"]}
}

# A tag-pinned action must be rejected; only full SHAs are allowed.
test_denies_unpinned_action {
	deny[_] with input as {"jobs": {"x": {"steps": [{"uses": "actions/checkout@v4"}]}}}
}

# A SHA-pinned action with scoped permissions and safe triggers is clean.
test_allows_sha_pinned_action {
	count(deny) == 0 with input as {
		"permissions": {"contents": "read"},
		"on": {"pull_request": {}},
		"jobs": {"x": {"steps": [{"uses": "actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5"}]}},
	}
}

test_allows_scoped_permissions {
	count(deny) == 0 with input as {"permissions": {"contents": "read"}, "on": {"pull_request": {}}, "jobs": {}}
}
