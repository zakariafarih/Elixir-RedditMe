#!/bin/bash

# Production deployment script for Discuss Phoenix app

set -e

case "$1" in
  "build")
    echo "🔨 Building production Docker image..."
    docker build -f Dockerfile.prod -t discuss:latest .
    echo "✅ Build complete!"
    ;;
  
  "deploy")
    echo "🚀 Deploying to production..."
    
    # Check if .env.prod exists
    if [ ! -f .env.prod ]; then
      echo "❌ .env.prod file not found!"
      echo "📝 Copy .env.prod.template to .env.prod and fill in your values"
      exit 1
    fi
    
    # Load environment variables
    export $(cat .env.prod | xargs)
    
    # Stop existing containers
    docker-compose -f docker-compose.prod.yml down
    
    # Build and start new containers
    docker-compose -f docker-compose.prod.yml up --build -d
    
    # Wait for database to be ready
    echo "⏳ Waiting for database to be ready..."
    sleep 15
    
    # Run database migrations
    echo "🗄️  Running database migrations..."
    docker-compose -f docker-compose.prod.yml exec web ./bin/discuss eval "Discuss.Release.migrate"
    
    echo "✅ Deployment complete!"
    echo "🌐 Your app should be available at http://${PHX_HOST}:${PORT}"
    ;;
  
  "migrate")
    echo "🗄️  Running database migrations..."
    docker-compose -f docker-compose.prod.yml exec web ./bin/discuss eval "Discuss.Release.migrate"
    ;;
  
  "logs")
    docker-compose -f docker-compose.prod.yml logs -f
    ;;
  
  "shell")
    docker-compose -f docker-compose.prod.yml exec web ./bin/discuss remote
    ;;
  
  "stop")
    echo "🛑 Stopping production environment..."
    docker-compose -f docker-compose.prod.yml down
    ;;
  
  "restart")
    echo "🔄 Restarting production environment..."
    docker-compose -f docker-compose.prod.yml restart
    ;;
  
  "status")
    docker-compose -f docker-compose.prod.yml ps
    ;;
  
  "clean")
    echo "🧹 Cleaning up Docker resources..."
    docker-compose -f docker-compose.prod.yml down -v
    docker system prune -f
    ;;
  
  "backup-db")
    echo "💾 Creating database backup..."
    timestamp=$(date +%Y%m%d_%H%M%S)
    docker-compose -f docker-compose.prod.yml exec db pg_dump -U postgres discuss_prod > "backup_${timestamp}.sql"
    echo "✅ Backup created: backup_${timestamp}.sql"
    ;;
  
  "restore-db")
    if [ -z "$2" ]; then
      echo "❌ Please provide backup file: ./deploy.sh restore-db backup_file.sql"
      exit 1
    fi
    echo "📥 Restoring database from $2..."
    docker-compose -f docker-compose.prod.yml exec -T db psql -U postgres -d discuss_prod < "$2"
    echo "✅ Database restored!"
    ;;
  
  *)
    echo "Usage: $0 {build|deploy|migrate|logs|shell|stop|restart|status|clean|backup-db|restore-db}"
    echo ""
    echo "Commands:"
    echo "  build      - Build production Docker image"
    echo "  deploy     - Deploy to production (build, migrate, start)"
    echo "  migrate    - Run database migrations"
    echo "  logs       - Show application logs"
    echo "  shell      - Open remote shell in production container"
    echo "  stop       - Stop production environment"
    echo "  restart    - Restart production environment"
    echo "  status     - Show container status"
    echo "  clean      - Clean up Docker resources"
    echo "  backup-db  - Create database backup"
    echo "  restore-db - Restore database from backup file"
    exit 1
    ;;
esac
