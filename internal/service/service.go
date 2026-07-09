// Package service wires up the HTTP server, health/readiness endpoints,
// and graceful shutdown lifecycle.
package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"time"

	"github.com/jaric/repo-forge-template/internal/config"
)

// Service represents the running application.
type Service struct {
	cfg    *config.Config
	server *http.Server
}

// New constructs a Service from the given configuration.
func New(cfg *config.Config) *Service {
	mux := http.NewServeMux()
	s := &Service{cfg: cfg}

	mux.HandleFunc("/healthz", s.handleLiveness)
	mux.HandleFunc("/readyz", s.handleReadiness)

	s.server = &http.Server{
		Addr:              fmt.Sprintf(":%d", cfg.Port),
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}
	return s
}

// Run starts the HTTP server and blocks until ctx is cancelled, then
// performs a graceful shutdown with a bounded timeout.
func (s *Service) Run(ctx context.Context) error {
	errCh := make(chan error, 1)
	go func() {
		slog.Info("listening", "addr", s.server.Addr)
		if err := s.server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			errCh <- err
		}
	}()

	select {
	case err := <-errCh:
		return err
	case <-ctx.Done():
		slog.Info("shutdown signal received")
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	return s.server.Shutdown(shutdownCtx)
}

func (s *Service) handleLiveness(w http.ResponseWriter, _ *http.Request) {
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(`{"status":"alive"}`))
}

func (s *Service) handleReadiness(w http.ResponseWriter, _ *http.Request) {
	// Extend this with real dependency checks (DB, cache, downstream APIs)
	// before returning 200. Returning ready too early is a common cause
	// of failed rollouts under load.
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(`{"status":"ready"}`))
}
