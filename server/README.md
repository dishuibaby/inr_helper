# Server

Go/Gin API server for the warfarin INR MVP.

## Local Development

```bash
cd server
go test ./...
go run ./cmd/api
```

The server listens on `:8080` by default and exposes `GET /healthz` plus the `/api/v1/*` MVP endpoints.

## Database Engine Strategy

The MVP currently runs on an in-memory repository so frontend and API work can continue without installing MySQL. Keep repository callers behind `server/internal/repository.Repository` and select concrete adapters through `DB_ENGINE` so the backend can switch storage engines with one config value later.

Supported engine values by design:

- `memory` — current default; volatile process-local storage for tests and early local demos.
- `sqlite` — planned local development engine to avoid requiring MySQL installation.
- `mysql` — planned production/staging engine when migrations and deployment are ready.

Current status:

```bash
DB_ENGINE=memory go run ./cmd/api
```

`DB_ENGINE=sqlite` and `DB_ENGINE=mysql` are reserved and intentionally fail until their adapters, migrations, and connection settings are implemented. Do not wire handlers or services directly to a concrete database package; add a repository adapter that satisfies `repository.Repository` and update the engine factory instead.
