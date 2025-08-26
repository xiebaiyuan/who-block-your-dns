#!/bin/bash

# Combined Service Start Script
# Starts both backend and frontend services in a single container

# Set working directory
cd /app

# Create logs directory if it doesn't exist
mkdir -p logs

# Function to handle shutdown gracefully
cleanup() {
    echo "Shutting down services..."
    if [ -n "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
    fi
    exit 0
}

# Trap signals for graceful shutdown
trap cleanup SIGTERM SIGINT

# Start backend service
echo "🚀 Starting backend service..."
python /app/main.py &
BACKEND_PID=$!

# Wait a moment for backend to initialize
sleep 3

# Check if backend started successfully
if ps -p $BACKEND_PID > /dev/null; then
    echo "✅ Backend service started successfully (PID: $BACKEND_PID)"
else
    echo "❌ Backend service failed to start"
    exit 1
fi

# Start Nginx in foreground
echo "🌐 Starting Nginx frontend..."
nginx -g "daemon off;"