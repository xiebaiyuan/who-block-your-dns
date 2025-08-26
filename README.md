# AdGuard DNS Query Service

[![Docker Build](https://github.com/xiebaiyuan/who-block-your-dns/actions/workflows/docker-build.yml/badge.svg)](https://github.com/xiebaiyuan/who-block-your-dns/actions/workflows/docker-build.yml)
[![Docker Hub](https://img.shields.io/docker/pulls/xiebaiyuan/adguard-dns-query)](https://hub.docker.com/r/xiebaiyuan/adguard-dns-query)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A modern web-based AdGuard DNS query service that helps you check if domains are blocked by AdGuard rules. Built with FastAPI backend and vanilla JavaScript frontend.

## ✨ Features

- 🔍 **Single Domain Query**: Quick lookup for individual domains
- 📋 **Batch Domain Query**: Query up to 100 domains at once
- 🛡️ **Multiple Rule Types**: Support for domain rules, regex rules, and hosts rules
- ⚡ **Caching System**: Fast queries with built-in caching
- 🔄 **Auto Updates**: Automatic rule list updates
- ➕ **Rule Source Management**: Add/remove custom rule sources
- 📊 **Real-time Statistics**: Live rule count and update status
- 🎨 **Modern UI**: Responsive design for all devices
- 🐳 **Multi-platform Docker**: Support for ARM64 and AMD64

## 🚀 Quick Start

### Option 1: Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/xiebaiyuan/who-block-your-dns.git
cd who-block-your-dns

# Start with Docker Compose
./start-docker.sh

# Or manually
docker-compose up -d
```

### Option 2: Local Development

```bash
# Backend (Python)
cd backend-python
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python3 main.py

# Frontend (in another terminal)
cd frontend
python3 -m http.server 3000
```

### Option 3: Docker Hub Images

```bash
# Pull and run pre-built images
docker run -d -p 8080:8080 xiebaiyuan/adguard-dns-query:backend-latest
docker run -d -p 3000:80 xiebaiyuan/adguard-dns-query:frontend-latest
```

### Option 4: Optimized Docker Compose (Recommended for Production)

```bash
# Use optimized configurations for better performance
docker-compose -f docker-compose.optimized.yml up -d

# For development with remote images (faster startup)
docker-compose -f docker-compose.dev-optimized.yml up -d
```

### Option 5: Optimized Dependencies (Smaller Images)

This project includes optimized dependencies that reduce image size by 33%:

```bash
# Use optimized dependencies
cp backend-python/requirements.optimized.txt backend-python/requirements.txt

# Rebuild with smaller footprint
docker-compose build backend
```

See [Dependency Optimization Analysis](docs/DEPENDECY_OPTIMIZATION.md) for detailed benefits.

### Option 6: Rule Caching (Faster Startup)

This project includes rule caching to dramatically reduce startup time:

```bash
# Use the optimized configuration with rule caching
docker-compose -f docker-compose.optimized-with-rules-cache.yml up -d
```

See [Rule Caching Feature](docs/RULE_CACHING.md) for detailed information.

### Option 7: Combined Docker (Single Container)

This project includes a combined Docker configuration that runs both frontend and backend in a single container:

```bash
# Build and run the combined container
docker-compose -f docker-compose.combined.yml up -d

# Or build manually
docker build -f Dockerfile.combined -t xiebaiyuan/who-block-your-dns:latest .
docker run -d -p 3000:80 \
  -v /host/logs:/app/logs \
  -v /host/rules-cache:/app/rules-cache \
  --name who-block-your-dns \
  xiebaiyuan/who-block-your-dns:latest
```

### Enhanced Docker Scripts

The project includes enhanced Docker management scripts that support multiple configurations:

```bash
# Start with combined configuration (single container)
./start-docker.sh --combined

# Start with optimized configuration
./start-docker.sh --optimized

# Start with rule caching configuration
./start-docker.sh --cached

# Stop any configuration
./stop-docker.sh --combined
```

### Python Version with Rule Caching

The Python version also includes rule caching functionality for faster startup times:

```bash
# Start Python version with rule caching
./start-python.sh

# Stop Python version
./stop-python.sh
```

Rules are automatically cached in `backend-python/rules-cache/` after the first run, dramatically reducing startup time for subsequent runs.

See [Combined Docker Configuration](docs/COMBINED_DOCKER.md), [Docker Scripts Usage Guide](docs/DOCKER_SCRIPTS.md), and [Python Rule Caching](docs/PYTHON_RULE_CACHING.md) for detailed information.

## 📱 Access

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080/api
- **API Documentation**: http://localhost:8080/docs

## 🛠️ Tech Stack

### Backend
- **FastAPI**: Modern Python web framework
- **Uvicorn**: ASGI server
- **Requests**: HTTP client library
- **CacheTools**: In-memory caching
- **Schedule**: Task scheduling

### Frontend
- **HTML5/CSS3**: Modern web standards
- **Vanilla JavaScript**: No framework dependencies
- **Responsive Design**: Mobile-friendly interface

### DevOps
- **Docker**: Multi-platform containerization
- **GitHub Actions**: CI/CD pipeline
- **Nginx**: Production web server

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[📖 Complete Documentation Index](docs/README.md)** - Start here for all documentation
- **[🚀 Quick Setup Guide](docs/setup/QUICK_SETUP.md)** - Get started in minutes  
- **[🌐 API Reference](docs/api/README.md)** - Complete API documentation
- **[🚢 Deployment Guide](docs/deployment/README.md)** - Production deployment strategies
- **[👨‍💻 Contributing Guide](docs/development/CONTRIBUTING.md)** - How to contribute
- **[📋 Project Overview](docs/PROJECT_SUMMARY.md)** - Detailed project information
- **[🧪 Scripts Documentation](scripts/README.md)** - Testing and utility scripts

### Quick Links
- **Live API Docs**: http://localhost:8080/docs (when running locally)
- **GitHub Repository**: [Source Code and Issues](https://github.com/xiebaiyuan/who-block-your-dns)
- **Docker Hub**: [Pre-built Images](https://hub.docker.com/r/your-username/adguard-dns-query)

## 🧪 Testing

Run the included test scripts:

```bash
# Comprehensive API functionality test
./scripts/testing/final_test.sh

# Basic API test
./scripts/testing/test_api.sh

# Multi-rule matching test
./scripts/testing/test_multiple_rules.sh

# Python-based testing
python3 scripts/testing/test_api.py
```

See the [Scripts Documentation](scripts/README.md) for detailed information about all available testing utilities.

## 🐳 Docker Support

### Multi-platform Images

This project automatically builds Docker images for multiple architectures:
- `linux/amd64` (x86_64)
- `linux/arm64` (ARM64/Apple Silicon)

### GitHub Actions

The project includes automated CI/CD with GitHub Actions:
- Builds on every push to main branch  
- Creates and pushes multi-platform Docker images
- Supports semantic versioning with tags

See the [Deployment Guide](docs/deployment/README.md) for detailed CI/CD setup instructions.

### Environment Variables

Configure the application using environment variables:

```bash
# Backend configuration
BACKEND_PORT=8080
LOG_LEVEL=INFO

# Frontend configuration  
FRONTEND_PORT=3000
```

## 📦 Deployment

### Production Docker Compose

```yaml
services:
  backend:
    image: your-dockerhub-username/adguard-dns-query:backend-latest
    restart: unless-stopped
    environment:
      - LOG_LEVEL=INFO
    ports:
      - "8080:8080"

  frontend:
    image: your-dockerhub-username/adguard-dns-query:frontend-latest
    restart: unless-stopped
    ports:
      - "3000:80"
    depends_on:
      - backend
```

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: adguard-dns-query
spec:
  replicas: 2
  selector:
    matchLabels:
      app: adguard-dns-query
  template:
    metadata:
      labels:
        app: adguard-dns-query
    spec:
      containers:
      - name: backend
        image: your-dockerhub-username/adguard-dns-query:backend-latest
        ports:
        - containerPort: 8080
      - name: frontend  
        image: your-dockerhub-username/adguard-dns-query:frontend-latest
        ports:
        - containerPort: 80
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [AdGuard](https://adguard.com/) for the rule format specification
- All the maintainers of the public blocklist sources
- The open-source community for the tools and libraries used

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=your-username/who-block-your-dns&type=Date)](https://star-history.com/#your-username/who-block-your-dns&Date)

---

**Made with ❤️ by the community**
