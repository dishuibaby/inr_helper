package config

import (
	"fmt"
	"os"
)

type DatabaseEngine string

const (
	DatabaseEngineMemory DatabaseEngine = "memory"
	DatabaseEngineSQLite DatabaseEngine = "sqlite"
	DatabaseEngineMySQL  DatabaseEngine = "mysql"
)

type Config struct {
	Database DatabaseConfig
}

type DatabaseConfig struct {
	// Engine selects the repository backend. The MVP defaults to memory;
	// sqlite/mysql are documented targets for one-click switching once their
	// adapters and migrations are added.
	Engine DatabaseEngine
}

func Load() (Config, error) {
	engine := DatabaseEngine(os.Getenv("DB_ENGINE"))
	if engine == "" {
		engine = DatabaseEngineMemory
	}
	if !engine.IsSupported() {
		return Config{}, fmt.Errorf("unsupported DB_ENGINE %q", engine)
	}
	return Config{Database: DatabaseConfig{Engine: engine}}, nil
}

func (engine DatabaseEngine) IsSupported() bool {
	switch engine {
	case DatabaseEngineMemory, DatabaseEngineSQLite, DatabaseEngineMySQL:
		return true
	default:
		return false
	}
}
