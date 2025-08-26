# Deployment Guide

This guide covers various deployment options for the AdGuard DNS Query Service.

## Quick Deployment Options

### 🐳 Docker (Recommended)

**Production Deployment with Pre-built Images:**
```bash
# Set your Docker Hub username
export DOCKER_USERNAME=your-dockerhub-username

# Deploy using production script
./deploy-production.sh
```

**Development Deployment with Local Build:**
```bash
# Start development environment
./start-docker.sh
```

**Optimized Deployment (Fastest Startup):**
```bash
# Use optimized configurations for better performance
docker-compose -f docker-compose.optimized.yml up -d

# For development with remote images (faster startup)
docker-compose -f docker-compose.dev-optimized.yml up -d
```

See [Optimized Docker Compose Configurations](DOCKER_COMPOSE_OPTIMIZED.md) for detailed usage instructions.

## Deployment Environments

### Development Environment

Uses `docker-compose.yml` for local development with source code mounting.

**Features:**
- Local image builds
- Source code mounting for live reloading
- Development-friendly configuration
- Verbose logging

**Commands:**
```bash
# Start development environment
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Production Environment

Uses `docker-compose.prod.yml` for production deployment with optimized images.

**Features:**
- Pre-built multi-platform images
- Production-optimized configuration
- Health checks and monitoring
- Automatic restart policies

**Commands:**
```bash
# Deploy production environment
DOCKER_USERNAME=your-username docker-compose -f docker-compose.prod.yml up -d

# Or use the deployment script
./deploy-production.sh
```

### Optimized Environments

Uses `docker-compose.optimized.yml` or `docker-compose.dev-optimized.yml` for performance-optimized deployments.

**Features:**
- Resource limits for better performance
- Pre-built images for faster startup
- Volume and network optimizations
- Custom health check configurations

**Commands:**
```bash
# Production-optimized deployment
docker-compose -f docker-compose.optimized.yml up -d

# Development-optimized deployment (remote images)
docker-compose -f docker-compose.dev-optimized.yml up -d

# View logs
docker-compose -f docker-compose.optimized.yml logs -f
```

See [Optimized Docker Compose Configurations](DOCKER_COMPOSE_OPTIMIZED.md) for detailed usage instructions.

## Platform-Specific Deployments

### Linux (AMD64/x86_64)

```bash
# Pull AMD64 images explicitly
docker pull --platform linux/amd64 your-username/adguard-dns-query:backend-latest
docker pull --platform linux/amd64 your-username/adguard-dns-query:frontend-latest

# Run with specific platform
docker run -d --platform linux/amd64 -p 8080:8080 your-username/adguard-dns-query:backend-latest
docker run -d --platform linux/amd64 -p 3000:80 your-username/adguard-dns-query:frontend-latest
```

### Linux (ARM64)

```bash
# Pull ARM64 images explicitly (for ARM servers or Apple Silicon)
docker pull --platform linux/arm64 your-username/adguard-dns-query:backend-latest
docker pull --platform linux/arm64 your-username/adguard-dns-query:frontend-latest

# Run with specific platform
docker run -d --platform linux/arm64 -p 8080:8080 your-username/adguard-dns-query:backend-latest
docker run -d --platform linux/arm64 -p 3000:80 your-username/adguard-dns-query:frontend-latest
```

### Apple Silicon (M1/M2/M3)

Docker automatically selects ARM64 images for Apple Silicon:

```bash
# Standard commands work automatically
./deploy-production.sh

# Or manual deployment
docker-compose -f docker-compose.prod.yml up -d
```

## Cloud Platform Deployments

### AWS ECS

Create task definition (`ecs-task-definition.json`):

```json
{
  "family": "adguard-dns-query",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::your-account:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "your-username/adguard-dns-query:backend-latest",
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/adguard-dns-query",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "backend"
        }
      }
    },
    {
      "name": "frontend",
      "image": "your-username/adguard-dns-query:frontend-latest",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "dependsOn": [
        {
          "containerName": "backend",
          "condition": "HEALTHY"
        }
      ]
    }
  ]
}
```

Deploy:
```bash
aws ecs register-task-definition --cli-input-json file://ecs-task-definition.json
aws ecs create-service --cluster your-cluster --service-name adguard-dns-query --task-definition adguard-dns-query
```

### Google Cloud Run

Deploy backend:
```bash
gcloud run deploy adguard-backend \
  --image your-username/adguard-dns-query:backend-latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080
```

Deploy frontend:
```bash
gcloud run deploy adguard-frontend \
  --image your-username/adguard-dns-query:frontend-latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 80
```

### Azure Container Instances

```bash
# Create resource group
az group create --name adguard-rg --location eastus

# Deploy backend
az container create \
  --resource-group adguard-rg \
  --name adguard-backend \
  --image your-username/adguard-dns-query:backend-latest \
  --ports 8080 \
  --dns-name-label adguard-backend-unique

# Deploy frontend
az container create \
  --resource-group adguard-rg \
  --name adguard-frontend \
  --image your-username/adguard-dns-query:frontend-latest \
  --ports 80 \
  --dns-name-label adguard-frontend-unique
```

## Kubernetes Deployment

### Basic Deployment

Create `k8s-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: adguard-backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: adguard-backend
  template:
    metadata:
      labels:
        app: adguard-backend
    spec:
      containers:
      - name: backend
        image: your-username/adguard-dns-query:backend-latest
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /api/rules/statistics
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: adguard-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: adguard-frontend
  template:
    metadata:
      labels:
        app: adguard-frontend
    spec:
      containers:
      - name: frontend
        image: your-username/adguard-dns-query:frontend-latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: adguard-backend-service
spec:
  selector:
    app: adguard-backend
  ports:
  - port: 8080
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: adguard-frontend-service
spec:
  selector:
    app: adguard-frontend
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

Deploy:
```bash
kubectl apply -f k8s-deployment.yaml
```

### Helm Chart

Create basic Helm chart structure:
```bash
helm create adguard-dns-query
```

## Environment Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `BACKEND_PORT` | Backend service port | `8080` |
| `FRONTEND_PORT` | Frontend service port | `3000` |
| `LOG_LEVEL` | Logging level (DEBUG, INFO, WARNING, ERROR) | `INFO` |
| `DOCKER_USERNAME` | Docker Hub username for images | `your-dockerhub-username` |

### Configuration Files

#### Development (.env)
```bash
BACKEND_PORT=8080
FRONTEND_PORT=3000
LOG_LEVEL=DEBUG
COMPOSE_PROJECT_NAME=adguard-dns-query-dev
```

#### Production (.env.prod)
```bash
BACKEND_PORT=8080
FRONTEND_PORT=80
LOG_LEVEL=INFO
COMPOSE_PROJECT_NAME=adguard-dns-query
DOCKER_USERNAME=your-dockerhub-username
```

## Monitoring and Health Checks

### Health Check Endpoints

**Backend Health Check:**
```bash
curl http://localhost:8080/api/rules/statistics
```

**Frontend Health Check:**
```bash
curl http://localhost:3000/
```

### Docker Health Checks

Health checks are built into the Docker containers:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/api/rules/statistics"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Monitoring with Prometheus

Add monitoring labels to your deployment:

```yaml
labels:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  prometheus.io/path: "/metrics"
```

## Scaling and Performance

### Horizontal Scaling

**Docker Compose:**
```bash
docker-compose up -d --scale backend=3 --scale frontend=2
```

**Kubernetes:**
```bash
kubectl scale deployment adguard-backend --replicas=3
kubectl scale deployment adguard-frontend --replicas=2
```

### Performance Tuning

**Backend Optimization:**
- Adjust cache size in application configuration
- Tune worker processes for Uvicorn
- Configure proper resource limits

**Frontend Optimization:**
- Use CDN for static assets
- Enable gzip compression in Nginx
- Configure browser caching headers

## Security Considerations

### Network Security
- Use HTTPS in production
- Configure proper firewall rules
- Use private networks for internal communication

### Container Security
- Use non-root users in containers
- Scan images for vulnerabilities
- Keep base images updated

### Data Security
- No persistent data storage required
- All rule data is cached in memory
- Regular rule updates from trusted sources

## Troubleshooting

### Common Issues

**Images not found:**
```bash
# Check image exists
docker pull your-username/adguard-dns-query:backend-latest

# Verify platform compatibility
docker image inspect your-username/adguard-dns-query:backend-latest
```

**Health check failures:**
```bash
# Check container logs
docker logs container-name

# Test health endpoints manually
curl -f http://localhost:8080/api/rules/statistics
```

**Port conflicts:**
```bash
# Check port usage
netstat -tulpn | grep :8080

# Use different ports
BACKEND_PORT=8081 FRONTEND_PORT=3001 docker-compose up -d
```

### Log Analysis

**View container logs:**
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend

# Last N lines
docker-compose logs --tail=50 backend
```

**Export logs:**
```bash
# Export to file
docker-compose logs > deployment.log

# With timestamps
docker-compose logs -t > deployment-with-timestamps.log
```