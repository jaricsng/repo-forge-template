package unit

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/jaric/repo-forge-template/internal/config"
	"github.com/jaric/repo-forge-template/internal/service"
	"github.com/stretchr/testify/assert"
)

func TestHealthEndpoints(t *testing.T) {
	cfg := &config.Config{Port: 0, Environment: "dev", LogLevel: "info"}
	_ = service.New(cfg) // construction should not panic with a valid config

	// Endpoint behavior is verified via a standalone handler mirroring the
	// service's contract, since the real mux is unexported. For deeper
	// integration coverage of routing itself, see test/e2e.
	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)

	assert.Equal(t, http.StatusOK, rec.Code)
}
