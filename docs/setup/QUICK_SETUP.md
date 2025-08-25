# Quick Setup Guide

This guide helps you quickly set up the AdGuard DNS Query Service for development or production.

## 🚀 One-Click Setup Options

### Option 1: Production Deployment (Recommended)
Use pre-built Docker images from Docker Hub:

```bash
# Clone the repository
git clone https://github.com/your-username/who-block-your-dns.git
cd who-block-your-dns

# Set your Docker Hub username
export DOCKER_USERNAME=your-dockerhub-username

# Deploy production version
./deploy-production.sh
```

### Option 2: Development Setup
Build and run locally:

```bash
# Clone the repository
git clone https://github.com/your-username/who-block-your-dns.git
cd who-block-your-dns

# Start development environment
./start-docker.sh
```

### Option 3: Manual Docker Commands
```bash
# Pull and run pre-built images
docker run -d --name adguard-backend -p 8080:8080 your-username/adguard-dns-query:backend-latest
docker run -d --name adguard-frontend -p 3000:80 your-username/adguard-dns-query:frontend-latest
```

## 🔧 GitHub Actions Setup

To enable automatic Docker builds and pushes:

1. **Fork this repository** to your GitHub account

2. **Set up Docker Hub secrets** in your repository:
   - Go to: Settings → Secrets and variables → Actions
   - Add these secrets:
     - `DOCKER_USERNAME`: Your Docker Hub username
     - `DOCKER_PASSWORD`: Your Docker Hub access token

3. **Create Docker Hub access token**:
   - Go to Docker Hub → Account Settings → Security → Access Tokens
   - Create new token with Read/Write/Delete permissions

4. **Push to trigger build**:
   ```bash
   git push origin main
   ```

5. **Check the build**:
   - Go to Actions tab in your GitHub repository
   - Watch the "Docker Build and Push" workflow

## 📦 Docker Images

After successful CI/CD setup, your images will be available at:
- Backend: `your-username/adguard-dns-query:backend-latest`
- Frontend: `your-username/adguard-dns-query:frontend-latest`

## 🌍 Multi-Platform Support

The GitHub Actions workflow automatically builds for:
- `linux/amd64` (Intel/AMD 64-bit)
- `linux/arm64` (ARM 64-bit/Apple Silicon)

## 🔍 Verification

Test your setup:

```bash
# Check if services are running
curl http://localhost:8080/api/rules/statistics
curl http://localhost:3000

# Run comprehensive tests
./scripts/final_test.sh
```

## 📱 Access Points

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080/api  
- **API Documentation**: http://localhost:8080/docs

## 🆘 Troubleshooting

### Docker Issues
```bash
# Check container status
docker ps

# View logs
docker compose logs -f

# Restart services
docker compose restart
```

### Build Issues
```bash
# Clean rebuild
docker compose down
docker compose build --no-cache
docker compose up -d
```

### GitHub Actions Issues
- Check secrets are set correctly
- Verify Docker Hub credentials
- Check workflow logs in Actions tab

## 📚 Next Steps

- ⭐ Star the repository
- 🍴 Fork for your modifications  
- 📖 Read the full [README.md](README.md)
- 🤝 Check [Contributing Guidelines](CONTRIBUTING.md)
- 🐛 Report issues or request features

---

**Need help?** Open an issue in the repository!