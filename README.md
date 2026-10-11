# E-Reserved

An educational Go project with microservice boundaries, intended to build backend engineering skills.

The repository currently contains skeletons for four services, PostgreSQL, and versioned migrations. Service containers build correctly and handle `SIGTERM`; HTTP and gRPC transports will be added in the next stage.

## Services and data ownership

| Service | Responsibility | Database | PostgreSQL role |
| --- | --- | --- | --- |
| `api` | Future external HTTP API entry point | — | — |
| `user` | Users and authentication | `user_db` | `user_app` |
| `order` | Products, inventory, reservations, and orders | `order_db` | `order_app` |
| `payment` | Payment accounts and operations | `payment_db` | `payment_app` |

Docker Compose uses one PostgreSQL instance, while each internal service has its own database and credentials. Cross-service references are stored as identifiers: for example, Order Service does not create a foreign key to Payment Service data.

## Structure

```text
.
├── Dockerfile
├── docker-compose.yml
├── deploy/postgres/init/
│   └── 01-create-service-databases.sh
└── services/
    ├── api/
    ├── user/
    │   └── migrations/
    ├── order/
    │   └── migrations/
    └── payment/
        └── migrations/
```

`Dockerfile` is shared by all services. Compose passes the `SERVICE` build argument, such as `api` or `payment`; the build stage produces a Linux binary from `./services/<service>`, while the runtime image does not contain the Go toolchain.

## Requirements

- Docker Desktop with Docker Compose v2;
- Go `1.25.11` to run checks outside containers.

## Quick start

Create a local environment file from the template:

```bash
cp .env.template .env
```

`DATABASE_URL` is currently assembled from passwords directly in Compose. URL-encode passwords containing special characters; for local development, using URL-safe values is simpler.

Build images and start PostgreSQL, migration jobs, and services:

```bash
docker compose up -d --build
```

Check container status:

```bash
docker compose ps
```

Expected result:

- `postgres` has the `healthy` status;
- `user-migrate`, `order-migrate`, and `payment-migrate` exit with code `0`;
- `api`, `user`, `order`, and `payment` have the `Up` status.

View service logs:

```bash
docker compose logs -f api user order payment
```

Inspect tables created by migrations:

```bash
docker compose exec postgres psql -U postgres -d user_db -c '\dt'
docker compose exec postgres psql -U postgres -d order_db -c '\dt'
docker compose exec postgres psql -U postgres -d payment_db -c '\dt'
```

## Migrations

The project uses `golang-migrate`. Each service owns only the migration files in `services/<service>/migrations`.

Migration file naming:

```text
000001_description.up.sql
000001_description.down.sql
```

When running `docker compose up`, Compose starts a dedicated one-shot migration job before its corresponding service. Re-running it is safe: `golang-migrate` reports `no change` when the schema is already current.

Run a specific migrator manually:

```bash
docker compose run --rm user-migrate
docker compose run --rm order-migrate
docker compose run --rm payment-migrate
```

Do not edit a migration that has already been applied in a shared environment. Create a new migration version instead.

## Checks and shutdown

```bash
go test ./...
docker compose config
```

Stop containers while preserving local PostgreSQL data:

```bash
docker compose down
```

Reset the local database and run the initialization script again:

```bash
docker compose down -v
docker compose up -d --build
```

`down -v` removes the named volume containing local PostgreSQL data. Use it only when those data can be discarded.
