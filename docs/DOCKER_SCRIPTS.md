# 🐳 Docker Scripts Usage Guide

This guide explains how to use the enhanced Docker management scripts with multiple configuration options.

## 🚀 Start Script (`start-docker.sh`)

### Basic Usage
```bash
# Start with default configuration (separate containers)
./start-docker.sh

# Start with combined configuration (single container)
./start-docker.sh --combined

# Start with optimized configuration
./start-docker.sh --optimized

# Start with rule caching configuration
./start-docker.sh --cached
```

### Features by Configuration

#### Default Configuration
- Separate frontend and backend containers
- Standard port mapping (3000 for frontend, 8080 for backend)
- Basic Docker Compose setup

#### Combined Configuration (`--combined`)
- Single container with both frontend and backend
- Simplified deployment with single port (3000)
- No cross-container communication issues
- Uses `docker-compose.combined.yml`

#### Optimized Configuration (`--optimized`)
- Performance-optimized setup
- Resource limits for better performance
- Uses `docker-compose.optimized.yml`

#### Rule Caching Configuration (`--cached`)
- Includes rule caching for faster startup
- Persistent rule storage
- Uses `docker-compose.optimized-with-rules-cache.yml`

## 🛑 Stop Script (`stop-docker.sh`)

### Basic Usage
```bash
# Stop default configuration
./stop-docker.sh

# Stop combined configuration
./stop-docker.sh --combined

# Stop optimized configuration
./stop-docker.sh --optimized

# Stop rule caching configuration
./stop-docker.sh --cached
```

## 📊 Configuration Comparison

| Configuration | Containers | Ports | Startup Time | Resource Usage | Complexity |
|---------------|------------|-------|--------------|----------------|------------|
| Default       | 2 (separate) | 3000, 8080 | Medium | Medium | Medium |
| Combined      | 1 (unified) | 3000 | Fast | Low | Low |
| Optimized     | 2 (separate) | 3000, 8080 | Medium-Fast | Low | Medium |
| Cached        | 2 (separate) | 3000, 8080 | Fast (after 1st run) | Medium | Medium |

## 🎯 When to Use Each Configuration

### Use Combined (`--combined`) When:
- You want the simplest deployment
- You prefer single container management
- You don't need separate scaling of frontend/backend
- You want to eliminate cross-container communication

### Use Optimized (`--optimized`) When:
- You want better resource management
- You need performance tuning
- You want to keep separate containers for scaling
- You don't mind slightly more complex setup

### Use Cached (`--cached`) When:
- You want faster startup times after first run
- You have limited bandwidth for rule downloads
- You want persistent rule storage
- You're running in environments with network restrictions

### Use Default When:
- You want standard setup without special requirements
- You're testing or developing
- You want maximum flexibility

## 🛠️ Advanced Usage

### Environment Variables
All configurations respect the `.env` file for customization:
```bash
# Create .env file from example
cp .env.example .env
# Edit .env to customize ports, log levels, etc.
```

### Manual Docker Compose Commands
You can also use Docker Compose directly:

```bash
# Combined configuration
docker-compose -f docker-compose.combined.yml up -d

# Optimized configuration
docker-compose -f docker-compose.optimized.yml up -d

# Rule caching configuration
docker-compose -f docker-compose.optimized-with-rules-cache.yml up -d
```

## 🧪 Testing Your Setup

After starting with any configuration, test the services:

```bash
# Test API endpoint
curl http://localhost:3000/api/rules/statistics

# Test frontend (for combined, this is the only endpoint)
curl http://localhost:3000

# For non-combined configurations, also test backend directly
curl http://localhost:8080/api/rules/statistics
```

## 📈 Performance Benefits

### Combined Configuration Benefits:
- **Startup Time**: Reduced by eliminating container-to-container network
- **Resource Usage**: Lower memory footprint
- **Management**: Single container to monitor and maintain

### Optimized Configuration Benefits:
- **Resource Limits**: Prevents resource exhaustion
- **Performance**: Better response times with resource reservations
- **Stability**: More predictable performance under load

### Rule Caching Benefits:
- **Startup Time**: Dramatically reduced after first run
- **Bandwidth**: Eliminates repeated rule downloads
- **Reliability**: Works even with temporary network issues

## 🚨 Troubleshooting

### Common Issues and Solutions

1. **Port Conflicts**:
   ```bash
   # Stop existing services
   ./stop-docker.sh
   
   # Check for remaining containers
   docker ps
   
   # Force remove if needed
   docker rm -f <container-name>
   ```

2. **Build Failures**:
   ```bash
   # Clean Docker cache
   docker system prune -a
   
   # Rebuild with no cache
   docker-compose build --no-cache
   ```

3. **Permission Issues**:
   ```bash
   # Ensure scripts are executable
   chmod +x start-docker.sh stop-docker.sh
   
   # Run with sudo if needed
   sudo ./start-docker.sh --combined
   ```

4. **Health Check Failures**:
   ```bash
   # Check logs for specific configuration
   docker-compose -f docker-compose.combined.yml logs -f
   ```

## 📚 Documentation References

- [Combined Docker Configuration](COMBINED_DOCKER.md)
- [Optimized Docker Compose Configurations](deployment/DOCKER_COMPOSE_OPTIMIZED.md)
- [Rule Caching Feature](RULE_CACHING.md)
- [Deployment Guide](deployment/README.md)