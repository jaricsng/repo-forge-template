package policy.dockerfile

# Deny Dockerfiles that do not switch to a non-root USER before CMD/ENTRYPOINT.
# This runs in CI against every Dockerfile in the repo (see
# .github/workflows/policy.yml) using Conftest.

deny[msg] {
	input.stages[_].commands["USER"] == null
	msg := "Dockerfile must set a non-root USER before CMD/ENTRYPOINT"
}

deny[msg] {
	some cmd
	input.stages[_].commands["USER"][cmd] == "root"
	msg := "Dockerfile must not run as USER root"
}
