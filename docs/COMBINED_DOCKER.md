# 🔄 Combined Docker Configuration

This configuration combines both the frontend and backend services into a single Docker container, simplifying deployment and eliminating cross-container communication issues.

## 🎯 Purpose

- **Simplified Deployment**: Single container instead of separate frontend and backend containers
- **Eliminated Port Issues**: No need to configure cross-container communication
- **Reduced Resource Usage**: Single container uses fewer system resources
- **Easier Management**: Single service to start, stop, and monitor

## 📁 Structure

### Dockerfile.combined
A multi-stage Dockerfile that:
1. Builds Python dependencies in a builder stage
2. Combines Nginx (frontend) and Python FastAPI (backend) in a single runtime image
3. Configures Nginx to proxy API requests to the backend service

### start.sh
A startup script that:
1. Starts the backend Python service
2. Starts Nginx in the foreground
3. Handles graceful shutdown of both services

### docker-compose.combined.yml
Docker Compose configuration that uses the combined image.

## 🚀 How It Works

### Architecture
```
Internet → Port 3000 → Nginx (Port 80) → 
    Static Files (/) → /var/www/html/
    API Requests (/api) → Python Backend (Port 8080)
```

### Request Flow
1. **Frontend Requests** (`/`): Served directly by Nginx from `/var/www/html/`
2. **API Requests** (`/api/*`): Proxied by Nginx to the Python backend running on localhost:8080

## 🐳 Usage

### Build and Run
```bash
# Build the combined image
docker build -f Dockerfile.combined -t xiebaiyuan/who-block-your-dns:latest .

# Run with Docker
docker run -d -p 3000:80 \
  -v /host/logs:/app/logs \
  -v /host/rules-cache:/app/rules-cache \
  --name who-block-your-dns \
  xiebaiyuan/who-block-your-dns:latest

# Or use Docker Compose
docker-compose -f docker-compose.combined.yml up -d
```

### Environment Variables
```bash
LOG_LEVEL=INFO  # Backend logging level
```

## 🛠️ Implementation Details

### Frontend Changes
- Modified `script.js` to use relative paths (`/api`) instead of hardcoded URLs
- No other frontend changes required

### Backend Changes
- No backend code changes required
- Backend still listens on port 8080 (localhost only)
- Rules caching feature still works as before

### Nginx Configuration
- Static files served from `/var/www/html/`
- API requests proxied to `http://127.0.0.1:8080`
- Health checks configured for the combined service

## 🧪 Testing

To test the combined configuration:

1. Build the image:
   ```bash
   docker build -f Dockerfile.combined -t xiebaiyuan/who-block-your-dns:latest .
   ```

2. Run the container:
   ```bash
   docker run -d -p 3000:80 xiebaiyuan/who-block-your-dns:latest
   ```

3. Access the service:
   - Frontend: http://localhost:3000
   - API: http://localhost:3000/api/rules/statistics

4. Check logs:
   ```bash
   docker logs who-block-your-dns
   ```

## 📊 Benefits

### Deployment Simplicity
- Single container to manage
- No network configuration between containers
- Single port mapping (3000:80)

### Performance
- Eliminates container-to-container network latency
- Reduced memory footprint
- Faster startup times

### Maintenance
- Single image to update
- Simplified health checking
- Easier backup and restore

## ⚠️ Considerations

### Pros
✅ Simplified deployment
✅ Reduced resource usage
✅ Eliminated port configuration issues
✅ Single point of monitoring

### Cons
❌ Less microservice-oriented architecture
❌ Backend and frontend scale together
❌ Updates require rebuilding entire container

## 🔄 Migration from Separate Containers

To migrate from separate frontend/backend containers:

1. Stop existing containers:
   ```bash
   docker-compose down
   ```

2. Start combined container:
   ```bash
   docker-compose -f docker-compose.combined.yml up -d
   ```

3. Update any external references from port 8080/3000 to port 3000 only

## 🧹 Cleanup

To clean up old separate container configurations:
```bash
# Remove old containers
docker rm adguard-backend-dev adguard-frontend-dev

# Remove old networks
docker network rm adguard-query-service_adguard-network

# Remove old images (optional)
docker rmi adguard-query-service-backend adguard-query-service-frontend
```