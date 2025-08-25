# Documentation

Welcome to the AdGuard DNS Query Service documentation. This directory contains comprehensive guides for setup, deployment, development, and API usage.

## 📚 Documentation Structure

```
docs/
├── README.md                    # This index file
├── PROJECT_SUMMARY.md          # Complete project overview  
├── PROJECT_STRUCTURE.md        # Detailed project structure
├── api/                        # API documentation
│   └── README.md               # Complete API reference
├── setup/                      # Setup and installation guides
│   └── QUICK_SETUP.md         # Quick start guide
├── deployment/                 # Deployment documentation
│   └── README.md              # Comprehensive deployment guide
└── development/               # Development documentation
    └── CONTRIBUTING.md        # Contributing guidelines
```

## 🚀 Quick Start

New to the project? Start here:

1. **[Quick Setup Guide](setup/QUICK_SETUP.md)** - Get up and running in minutes
2. **[API Documentation](api/README.md)** - Learn how to use the API
3. **[Deployment Guide](deployment/README.md)** - Deploy to production

## 📖 Documentation Categories

### 🛠️ Setup and Installation
- **[Quick Setup Guide](setup/QUICK_SETUP.md)**: Fast setup for both development and production
  - One-click deployment options
  - GitHub Actions CI/CD setup
  - Docker Hub integration
  - Multi-platform support

### 🌐 API Reference
- **[API Documentation](api/README.md)**: Complete API reference
  - Domain query endpoints
  - Rule management endpoints
  - Request/response formats
  - Error handling
  - Code examples in multiple languages

### 🚀 Deployment
- **[Deployment Guide](deployment/README.md)**: Production deployment strategies
  - Docker deployment (recommended)
  - Cloud platform deployments (AWS, GCP, Azure)
  - Kubernetes deployment
  - Environment configuration
  - Monitoring and scaling

### 👨‍💻 Development
- **[Contributing Guide](development/CONTRIBUTING.md)**: How to contribute to the project
  - Development setup
  - Code style guidelines
  - Testing requirements
  - Pull request process

### 📋 Project Overview
- **[Project Summary](PROJECT_SUMMARY.md)**: Complete project overview
  - Architecture and structure
  - Technology stack
  - Feature overview
  - File organization
- **[Project Structure](PROJECT_STRUCTURE.md)**: Detailed file and directory structure
  - Directory purposes and organization
  - File lifecycle and usage patterns
  - Navigation and relationship guide

## 🎯 Common Use Cases

### For Developers

**Setting up development environment:**
```bash
git clone https://github.com/your-username/who-block-your-dns.git
cd who-block-your-dns
./start-docker.sh
```

**Running tests:**
```bash
./scripts/testing/final_test.sh
```

**Contributing to the project:**
- Read [Contributing Guide](development/CONTRIBUTING.md)
- Check [API Documentation](api/README.md) for endpoints

### For DevOps/Deployment

**Production deployment:**
```bash
export DOCKER_USERNAME=your-dockerhub-username
./deploy-production.sh
```

**Kubernetes deployment:**
- See [Deployment Guide](deployment/README.md#kubernetes-deployment)

**Cloud platform deployment:**
- See platform-specific sections in [Deployment Guide](deployment/README.md)

### For API Users

**Single domain query:**
```bash
curl "http://localhost:8080/api/query/domain?domain=doubleclick.net"
```

**Batch query:**
```bash
curl -X POST "http://localhost:8080/api/query/domains" \
     -H "Content-Type: application/json" \
     -d '["doubleclick.net", "github.com"]'
```

**Complete API reference:**
- See [API Documentation](api/README.md)

## 🔗 External Resources

### GitHub Repository
- **Main Repository**: [https://github.com/your-username/who-block-your-dns](https://github.com/your-username/who-block-your-dns)
- **Issues**: Report bugs and request features
- **Discussions**: Community discussions and Q&A

### Docker Hub
- **Backend Image**: `your-username/adguard-dns-query:backend-latest`
- **Frontend Image**: `your-username/adguard-dns-query:frontend-latest`
- **Multi-platform**: Supports AMD64 and ARM64

### Live Documentation
- **API Documentation**: http://localhost:8080/docs (when running locally)
- **Interactive API Testing**: Built-in Swagger UI

## 📞 Getting Help

### Documentation Issues
If you find issues with the documentation:
1. Check if the issue is already reported
2. Open an issue on GitHub
3. Suggest improvements via pull request

### Technical Support
For technical issues:
1. Check the [Troubleshooting sections](deployment/README.md#troubleshooting) in deployment docs
2. Review [Common Issues](../scripts/README.md#troubleshooting) in scripts documentation
3. Search existing GitHub issues
4. Open a new issue with detailed information

### Community
- **GitHub Discussions**: For general questions and ideas
- **Issues**: For bug reports and feature requests
- **Pull Requests**: For code contributions

## 🔄 Documentation Updates

This documentation is actively maintained and updated with each release. The documentation follows the same versioning as the project.

### Contributing to Documentation
Documentation contributions are welcome! Please:
1. Follow the existing style and structure
2. Update the relevant index files
3. Test all code examples
4. Submit a pull request

### Documentation Standards
- **Markdown Format**: All documentation in Markdown
- **Clear Structure**: Hierarchical organization
- **Code Examples**: Working, tested examples
- **Cross-References**: Internal links between documents
- **Up-to-Date**: Regular updates with code changes

---

**Need something specific?** Use the search function in your browser (Ctrl/Cmd + F) or check the [project's GitHub repository](https://github.com/your-username/who-block-your-dns) for the most current information.