// Package e2e runs black-box tests against a compiled binary of the
// service, exercising the full stack (config loading, HTTP server,
// signal handling) the way it behaves in production.
//
// Run with: make test-e2e
// These are excluded from `go test ./...` via the `e2e` build tag so
// unit test runs stay fast; CI runs them as a separate job.
package e2e

import (
	"fmt"
	"net/http"
	"os/exec"
	"testing"
	"time"
)

func TestHealthEndpointsE2E(t *testing.T) {
	build := exec.Command("go", "build", "-o", "/tmp/app-e2e", "../../cmd/app")
	if out, err := build.CombinedOutput(); err != nil {
		t.Fatalf("failed to build binary: %v\n%s", err, out)
	}

	cmd := exec.Command("/tmp/app-e2e")
	cmd.Env = append(cmd.Env, "APP_PORT=18080", "APP_ENVIRONMENT=dev")
	if err := cmd.Start(); err != nil {
		t.Fatalf("failed to start binary: %v", err)
	}
	defer func() {
		_ = cmd.Process.Kill()
		_ = cmd.Wait()
	}()

	// Allow the server time to bind before probing it.
	var resp *http.Response
	var err error
	for i := 0; i < 20; i++ {
		resp, err = http.Get("http://localhost:18080/healthz")
		if err == nil {
			break
		}
		time.Sleep(100 * time.Millisecond)
	}
	if err != nil {
		t.Fatalf("service did not become reachable: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected 200 from /healthz, got %d", resp.StatusCode)
	}

	readyResp, err := http.Get("http://localhost:18080/readyz")
	if err != nil {
		t.Fatalf("readyz request failed: %v", err)
	}
	defer readyResp.Body.Close()
	if readyResp.StatusCode != http.StatusOK {
		t.Fatalf("expected 200 from /readyz, got %d", readyResp.StatusCode)
	}

	fmt.Println("e2e health check suite passed")
}
