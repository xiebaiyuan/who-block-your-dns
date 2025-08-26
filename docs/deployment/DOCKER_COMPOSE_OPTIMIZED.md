# 🐳 Optimized Docker Compose Configurations

This directory contains optimized Docker Compose configurations for different deployment scenarios.

## 📁 Configuration Files

### `docker-compose.optimized.yml`
Production-optimized configuration using pre-built remote images with resource limits and performance tuning.

### `docker-compose.dev-optimized.yml`
Development-optimized configuration that can use either remote images (faster startup) or local builds (for development).

## 🚀 Usage

### Production Deployment (Fastest Startup)

```bash
# Use the optimized production configuration
docker-compose -f docker-compose.optimized.yml up -d
```

### Development with Remote Images (Faster Startup)

```bash
# Use remote images for faster development startup
docker-compose -f docker-compose.dev-optimized.yml up -d

# To switch to local builds for development, edit the file to comment out the image lines
# and uncomment the build lines
```

### Development with Local Builds

```bash
# Edit docker-compose.dev-optimized.yml to use local builds
# Comment out the image lines and uncomment the build lines

docker-compose -f docker-compose.dev-optimized.yml up -d
```

## ⚡ Performance Improvements

### Resource Limits
- Backend: 1GB memory limit, 0.5 CPU limit
- Frontend: 128MB memory limit, 0.25 CPU limit

### Volume Optimization
- Local volume driver with bind mounting for better performance

### Network Optimization
- Custom bridge network with named interface

## 🛠️ Configuration Options

### Environment Variables

```bash
# Backend port (default: 8080)
BACKEND_PORT=8080

# Frontend port (default: 3000)  
FRONTEND_PORT=3000

# Log level (default: INFO)
LOG_LEVEL=INFO
```

### Switching Between Remote and Local Images

In `docker-compose.dev-optimized.yml`:

```yaml
# For remote images (fast startup)
image: adguardquery/adguard-dns-query:backend-latest

# For local builds (development)
# image: adguardquery/adguard-dns-query:backend-latest
# build: 
#   context: ./backend-python
#   dockerfile: Dockerfile
```

## 📊 Monitoring

Check service status:
```bash
docker-compose -f docker-compose.optimized.yml ps
```

View logs:
```bash
docker-compose -f docker-compose.optimized.yml logs -f
```

## 🔄 Updates

Pull latest images:
```bash
docker-compose -f docker-compose.optimized.yml pull
docker-compose -f docker-compose.optimized.yml up -d
```