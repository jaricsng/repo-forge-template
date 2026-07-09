package service

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

// TestSecurityHeaders verifies the middleware sets the hardening headers that
// test/security/zap-rules.tsv marks as FAIL-if-absent, so the DAST scan and
// this unit test stay in agreement.
func TestSecurityHeaders(t *testing.T) {
	inner := http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
	})
	rec := httptest.NewRecorder()
	securityHeaders(inner).ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/healthz", nil))

	want := map[string]string{
		"Content-Security-Policy":   "default-src 'none'; frame-ancestors 'none'",
		"Strict-Transport-Security": "max-age=63072000; includeSubDomains",
		"X-Content-Type-Options":    "nosniff",
		"X-Frame-Options":           "DENY",
		"Referrer-Policy":           "no-referrer",
	}
	for header, expected := range want {
		if got := rec.Header().Get(header); got != expected {
			t.Errorf("%s = %q, want %q", header, got, expected)
		}
	}
}
