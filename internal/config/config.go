// Package config loads and validates runtime configuration.
//
// Configuration precedence (highest to lowest):
//  1. Environment variables (prefixed APP_)
//  2. config.yaml in the working directory
//  3. Defaults defined below
package config

import (
	"fmt"

	"github.com/spf13/viper"
)

// Config holds all runtime configuration for the service.
type Config struct {
	Port        int    `mapstructure:"port"`
	Environment string `mapstructure:"environment"` // dev | staging | production
	LogLevel    string `mapstructure:"log_level"`
}

// Load reads configuration from file and environment, applies defaults,
// and validates the result before returning it.
func Load() (*Config, error) {
	v := viper.New()
	v.SetDefault("port", 8080)
	v.SetDefault("environment", "dev")
	v.SetDefault("log_level", "info")

	v.SetConfigName("config")
	v.SetConfigType("yaml")
	v.AddConfigPath(".")
	v.SetEnvPrefix("APP")
	v.AutomaticEnv()

	if err := v.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			return nil, fmt.Errorf("reading config file: %w", err)
		}
	}

	var cfg Config
	if err := v.Unmarshal(&cfg); err != nil {
		return nil, fmt.Errorf("unmarshalling config: %w", err)
	}

	if err := cfg.validate(); err != nil {
		return nil, fmt.Errorf("invalid configuration: %w", err)
	}

	return &cfg, nil
}

func (c *Config) validate() error {
	if c.Port < 1 || c.Port > 65535 {
		return fmt.Errorf("port must be between 1 and 65535, got %d", c.Port)
	}
	validEnvs := map[string]bool{"dev": true, "staging": true, "production": true}
	if !validEnvs[c.Environment] {
		return fmt.Errorf("environment must be one of dev|staging|production, got %q", c.Environment)
	}
	return nil
}
