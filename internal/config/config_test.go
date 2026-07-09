package config

import "testing"

func TestValidate(t *testing.T) {
	tests := []struct {
		name    string
		cfg     Config
		wantErr bool
	}{
		{"valid config", Config{Port: 8080, Environment: "dev"}, false},
		{"port too low", Config{Port: 0, Environment: "dev"}, true},
		{"port too high", Config{Port: 70000, Environment: "dev"}, true},
		{"invalid environment", Config{Port: 8080, Environment: "prod"}, true},
		{"valid production", Config{Port: 443, Environment: "production"}, false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.cfg.validate()
			if (err != nil) != tt.wantErr {
				t.Errorf("validate() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}
