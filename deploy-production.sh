#!/bin/bash

# Production deployment script using Docker Hub images
# This script pulls and runs pre-built multi-platform images

echo "🚀 Starting AdGuard DNS Query Service (Production)"
echo "=================================================="

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed or not in PATH"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null 2>&1 && ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: Docker Compose is not installed"
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

# Set Docker username (you can override this via environment variable)
DOCKER_USERNAME=${DOCKER_USERNAME:-"your-dockerhub-username"}

if [ "$DOCKER_USERNAME" = "your-dockerhub-username" ]; then
    echo "⚠️  Warning: Please set your Docker Hub username"
    echo "   export DOCKER_USERNAME=your-actual-username"
    echo "   or edit this script to set the correct username"
    read -p "Enter your Docker Hub username: " input_username
    if [ -n "$input_username" ]; then
        export DOCKER_USERNAME="$input_username"
    else
        echo "❌ Docker username is required"
        exit 1
    fi
fi

echo "🐳 Using Docker images from: $DOCKER_USERNAME/adguard-dns-query"

# Check if .env file exists, create from example if not
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        echo "📋 Creating .env file from template..."
        cp .env.example .env
        echo "✅ Created .env file. You can modify it if needed."
    fi
fi

# Pull the latest images
echo "📥 Pulling latest Docker images..."
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

# Stop any running containers
echo "🛑 Stopping any existing containers..."
$COMPOSE_CMD -f docker-compose.prod.yml down 2>/dev/null || true

# Pull images
echo "🔄 Pulling images for your platform..."
docker pull $DOCKER_USERNAME/adguard-dns-query:backend-latest
docker pull $DOCKER_USERNAME/adguard-dns-query:frontend-latest

if [ $? -ne 0 ]; then
    echo "❌ Failed to pull images. Please check:"
    echo "   1. Your Docker Hub username is correct"
    echo "   2. The images exist on Docker Hub"
    echo "   3. Your internet connection"
    exit 1
fi

# Start services
echo "🚀 Starting production services..."
$COMPOSE_CMD -f docker-compose.prod.yml up -d

if [ $? -ne 0 ]; then
    echo "❌ Failed to start services"
    exit 1
fi

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
max_attempts=60
attempt=1

while [ $attempt -le $max_attempts ]; do
    if $COMPOSE_CMD -f docker-compose.prod.yml ps | grep -q "healthy"; then
        backend_health=$($COMPOSE_CMD -f docker-compose.prod.yml ps | grep backend | grep healthy)
        frontend_health=$($COMPOSE_CMD -f docker-compose.prod.yml ps | grep frontend | grep healthy)
        
        if [ -n "$backend_health" ] && [ -n "$frontend_health" ]; then
            echo "✅ All services are healthy!"
            break
        fi
    fi
    
    if [ $attempt -eq $max_attempts ]; then
        echo "⚠️  Services are taking longer than expected to start"
        echo "   Check logs: $COMPOSE_CMD -f docker-compose.prod.yml logs"
        break
    fi
    
    echo "   Attempt $attempt/$max_attempts - waiting for health checks..."
    sleep 2
    ((attempt++))
done

# Display service status
echo ""
echo "📊 Service Status:"
$COMPOSE_CMD -f docker-compose.prod.yml ps

# Test connectivity
echo ""
echo "🔍 Testing connectivity..."
if curl -s -f http://localhost:8080/api/rules/statistics > /dev/null 2>&1; then
    echo "✅ Backend API is responding"
else
    echo "⚠️  Backend API is not responding yet"
fi

if curl -s -f http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Frontend is responding"
else
    echo "⚠️  Frontend is not responding yet"
fi

echo ""
echo "🎉 AdGuard DNS Query Service is running in production mode!"
echo ""
echo "📍 Access URLs:"
echo "   Frontend:    http://localhost:3000"
echo "   Backend API: http://localhost:8080/api"
echo "   API Docs:    http://localhost:8080/docs"
echo ""
echo "🐳 Docker Management:"
echo "   View logs:    $COMPOSE_CMD -f docker-compose.prod.yml logs -f"
echo "   Stop services: $COMPOSE_CMD -f docker-compose.prod.yml down"
echo "   Restart:      $COMPOSE_CMD -f docker-compose.prod.yml restart"
echo "   Update:       ./deploy-production.sh"
echo ""
echo "💡 Note: Images are built for multiple architectures (AMD64/ARM64)"
echo "   and automatically selected based on your system."