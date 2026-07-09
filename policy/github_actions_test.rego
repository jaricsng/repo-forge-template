package policy.github_actions

test_denies_write_all {
	deny["workflow must not request 'write-all' permissions; scope permissions per job"] with input as {"permissions": "write-all"}
}

test_denies_pull_request_target {
	deny[_] with input as {"on": {"pull_request_target": {}}}
}

test_allows_scoped_permissions {
	count(deny) == 0 with input as {"permissions": {"contents": "read"}, "on": {"pull_request": {}}, "jobs": {}}
}
