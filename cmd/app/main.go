// Command app is the entrypoint for the service.
//
// This binary follows the project's operational contract described in
// docs/runbook.md: it reads configuration via internal/config, exposes
// health endpoints for readiness/liveness probes, and shuts down
// gracefully on SIGINT/SIGTERM.
package main

import (
	"context"
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"github.com/jaric/repo-forge-template/internal/config"
	"github.com/jaric/repo-forge-template/internal/service"
	"github.com/jaric/repo-forge-template/internal/version"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	slog.SetDefault(logger)

	slog.Info("starting service", "version", version.Version, "commit", version.Commit)

	cfg, err := config.Load()
	if err != nil {
		slog.Error("failed to load configuration", "error", err)
		os.Exit(1)
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	svc := service.New(cfg)
	if err := svc.Run(ctx); err != nil {
		slog.Error("service exited with error", "error", err)
		os.Exit(1)
	}

	slog.Info("service stopped cleanly")
}
