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
	// Engine selects the repository backend. The MVP defaults to memory.
	Engine DatabaseEngine
	// URL is the primary database connection value. For SQLite this may be a
	// filesystem path or a file: DSN.
	URL string
	// SQLitePath is a SQLite-specific fallback when DATABASE_URL is not set.
	SQLitePath string
}

func Load() (Config, error) {
	engine := DatabaseEngine(os.Getenv("DB_ENGINE"))
	if engine == "" {
		engine = DatabaseEngineMemory
	}
	if !engine.IsSupported() {
		return Config{}, fmt.Errorf("unsupported DB_ENGINE %q", engine)
	}
	return Config{Database: DatabaseConfig{
		Engine:     engine,
		URL:        os.Getenv("DATABASE_URL"),
		SQLitePath: os.Getenv("SQLITE_PATH"),
	}}, nil
}

func (engine DatabaseEngine) IsSupported() bool {
	switch engine {
	case DatabaseEngineMemory, DatabaseEngineSQLite, DatabaseEngineMySQL:
		return true
	default:
		return false
	}
}
