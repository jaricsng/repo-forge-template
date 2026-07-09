// Package version exposes build-time metadata injected via -ldflags.
// See Makefile target `build` for how these are set, and .goreleaser.yml
// for how release builds populate them automatically from git tags.
package version

var (
	// Version is the semantic version tag (e.g. v1.2.3), set at build time.
	Version = "dev"
	// Commit is the short git SHA of the build.
	Commit = "none"
	// BuildDate is the RFC3339 timestamp of the build.
	BuildDate = "unknown"
)
