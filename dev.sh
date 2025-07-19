#!/bin/bash

# Development helper script for Discuss Phoenix app

set -e

case "$1" in
  "setup")
    echo "🚀 Setting up development environment..."
    docker-compose build
    docker-compose up -d db
    echo "⏳ Waiting for database to be ready..."
    sleep 10
    docker-compose run --rm web mix ecto.create
    docker-compose run --rm web mix ecto.migrate
    echo "✅ Setup complete!"
    ;;
  
  "start")
    echo "🚀 Starting development environment..."
    docker-compose up
    ;;
  
  "stop")
    echo "🛑 Stopping development environment..."
    docker-compose down
    ;;
  
  "restart")
    echo "🔄 Restarting development environment..."
    docker-compose restart
    ;;
  
  "logs")
    docker-compose logs -f web
    ;;
  
  "db-logs")
    docker-compose logs -f db
    ;;
  
  "shell")
    docker-compose exec web iex -S mix
    ;;
  
  "bash")
    docker-compose exec web sh
    ;;
  
  "migrate")
    docker-compose run --rm web mix ecto.migrate
    ;;
  
  "rollback")
    docker-compose run --rm web mix ecto.rollback
    ;;
  
  "reset")
    echo "🗑️  Resetting database..."
    docker-compose run --rm web mix ecto.reset
    ;;
  
  "test")
    echo "🧪 Running tests..."
    docker-compose --profile test up -d test_db
    sleep 5
    TEST_DATABASE_URL=ecto://postgres:postgres@localhost:5433/discuss_test docker-compose run --rm -e MIX_ENV=test web mix test
    ;;
  
  "clean")
    echo "🧹 Cleaning up Docker resources..."
    docker-compose down -v
    docker system prune -f
    ;;
  
  *)
    echo "Usage: $0 {setup|start|stop|restart|logs|db-logs|shell|bash|migrate|rollback|reset|test|clean}"
    echo ""
    echo "Commands:"
    echo "  setup     - Initial setup of the development environment"
    echo "  start     - Start the development environment"
    echo "  stop      - Stop the development environment"
    echo "  restart   - Restart the development environment"
    echo "  logs      - Show logs from the web container"
    echo "  db-logs   - Show logs from the database container"
    echo "  shell     - Open IEx shell in the web container"
    echo "  bash      - Open bash shell in the web container"
    echo "  migrate   - Run database migrations"
    echo "  rollback  - Rollback last migration"
    echo "  reset     - Reset the database"
    echo "  test      - Run tests with test database"
    echo "  clean     - Clean up Docker resources"
    exit 1
    ;;
esac
