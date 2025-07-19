# Discuss - Phoenix Docker Development Setup

This Phoenix application is configured to run in Docker containers for development, providing isolation and consistency across different development environments.

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. **Initial Setup** (run once):
   ```bash
   ./dev.sh setup
   ```

2. **Start the development environment**:
   ```bash
   ./dev.sh start
   ```

3. **Visit your application**:
   Open http://localhost:4000

## Development Commands

The `dev.sh` script provides convenient commands for common development tasks:

- `./dev.sh setup` - Initial setup (build, create database, run migrations)
- `./dev.sh start` - Start the development environment
- `./dev.sh stop` - Stop the development environment
- `./dev.sh restart` - Restart the development environment
- `./dev.sh logs` - Show application logs
- `./dev.sh db-logs` - Show database logs
- `./dev.sh shell` - Open IEx shell in the container
- `./dev.sh bash` - Open bash shell in the container
- `./dev.sh migrate` - Run database migrations
- `./dev.sh rollback` - Rollback last migration
- `./dev.sh reset` - Reset the database
- `./dev.sh test` - Run tests with test database
- `./dev.sh clean` - Clean up Docker resources

## Manual Docker Commands

If you prefer to use Docker Compose directly:

```bash
# Start the development environment
docker-compose up

# Start in detached mode
docker-compose up -d

# View logs
docker-compose logs -f web

# Run commands in the container
docker-compose exec web mix ecto.migrate
docker-compose exec web iex -S mix

# Run tests
docker-compose --profile test up -d test_db
docker-compose run --rm -e MIX_ENV=test web mix test

# Stop everything
docker-compose down
```

## Local Development (without Docker)

If you prefer to run locally, you can still use the containerized PostgreSQL:

1. Start only the database:
   ```bash
   docker-compose up -d db
   ```

2. Run Phoenix locally:
   ```bash
   mix phx.server
   ```

The database will be available at `localhost:5432`.

## Environment Variables

The application uses these environment variables (defined in `.env`):

- `DATABASE_URL` - PostgreSQL connection string
- `TEST_DATABASE_URL` - Test database connection string
- `SECRET_KEY_BASE` - Phoenix secret key
- `PHX_HOST` - Phoenix host
- `PHX_PORT` - Phoenix port

## Ports

- **4000** - Phoenix web server
- **5432** - PostgreSQL development database
- **5433** - PostgreSQL test database

## Data Persistence

Database data is persisted in Docker volumes:
- `discuss_postgres_data` - Development database
- `discuss_test_postgres_data` - Test database

To completely reset everything:
```bash
./dev.sh clean
```
