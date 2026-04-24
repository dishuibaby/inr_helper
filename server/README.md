# Server

Go/Gin API server for the warfarin INR MVP.

## Local Development

```bash
cd server
GOMODCACHE=/tmp/go/pkg/mod GOCACHE=/tmp/go-build go test ./...
go run ./cmd/api
```

The server listens on `:8080` by default and exposes `GET /healthz` plus the `/api/v1/*` MVP endpoints.

## Database Engine Strategy

Repository callers stay behind `server/internal/repository.Repository`; concrete storage is selected through `DB_ENGINE` so handlers and services do not depend on a database package.

Supported engine values:

- `memory` — default; volatile process-local storage for tests and early local demos.
- `sqlite` — local persistent storage through `database/sql` and the pure-Go `modernc.org/sqlite` driver, suitable for Linux ARM64 without CGO.
- `mysql` — reserved production/staging target; adapter and migrations are not implemented yet.

Run with the default memory repository:

```bash
DB_ENGINE=memory go run ./cmd/api
```

Run with SQLite using either `DATABASE_URL` or `SQLITE_PATH`:

```bash
DB_ENGINE=sqlite SQLITE_PATH=./warfarin.db go run ./cmd/api
# or
DB_ENGINE=sqlite DATABASE_URL=file:./warfarin.db go run ./cmd/api
```

SQLite schema is applied automatically at repository startup and is also stored in `migrations/sqlite_schema.sql` for review/deployment tooling. The adapter persists medication records, INR records, and settings while preserving existing abnormal INR tier logic in the service layer.
