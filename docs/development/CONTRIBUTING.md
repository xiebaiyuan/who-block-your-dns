# Contributing to AdGuard DNS Query Service

Thank you for your interest in contributing to the AdGuard DNS Query Service! This document provides guidelines and information for contributors.

## 🚀 Quick Start for Contributors

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/who-block-your-dns.git`
3. Create a feature branch: `git checkout -b feature/amazing-feature`
4. Make your changes
5. Test your changes locally
6. Commit and push: `git commit -m 'Add amazing feature'`
7. Open a Pull Request

## 🛠️ Development Setup

### Prerequisites

- Docker and Docker Compose
- Python 3.11+ (for local development)
- Git

### Local Development

```bash
# Clone the repository
git clone https://github.com/your-username/who-block-your-dns.git
cd who-block-your-dns

# Start development environment
./start-docker.sh

# Or start locally
cd backend-python
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python3 main.py
```

### Testing

```bash
# Run API tests
./scripts/final_test.sh

# Run basic tests
./scripts/test_api.sh

# Test multi-rule functionality
./scripts/test_multiple_rules.sh
```

## 📝 Code Style and Standards

### Python (Backend)
- Follow PEP 8 style guidelines
- Use type hints where appropriate
- Add docstrings for functions and classes
- Keep functions focused and small

### JavaScript (Frontend)
- Use modern ES6+ syntax
- Follow consistent naming conventions
- Add comments for complex logic
- Maintain responsive design principles

### Docker
- Use multi-stage builds when appropriate
- Minimize image size
- Include health checks
- Follow security best practices

## 🔧 Making Changes

### Backend Changes
1. Modify files in `backend-python/`
2. Update `requirements.txt` if adding dependencies
3. Test API endpoints
4. Update documentation if needed

### Frontend Changes
1. Modify files in `frontend/`
2. Test responsive design
3. Ensure cross-browser compatibility
4. Update UI documentation

### Docker Changes
1. Test locally with `docker-compose up`
2. Verify multi-platform support
3. Test health checks
4. Update deployment documentation

## 🧪 Testing Guidelines

### Before Submitting
- [ ] All existing tests pass
- [ ] New functionality has appropriate tests
- [ ] API endpoints work correctly
- [ ] Frontend displays correctly
- [ ] Docker containers build and run
- [ ] Documentation is updated

### Test Coverage
- Add tests for new API endpoints
- Test error handling
- Verify edge cases
- Test with different rule sources

## 📚 Documentation

### Code Documentation
- Add inline comments for complex logic
- Document API endpoints with proper examples
- Include type hints and docstrings
- Update README.md if needed

### User Documentation
- Update API documentation
- Add usage examples
- Document configuration options
- Include troubleshooting guides

## 🚢 Deployment and CI/CD

### GitHub Actions
- All PRs trigger automated tests
- Main branch pushes trigger Docker builds
- Multi-platform images are automatically built
- Security scanning is performed

### Docker Images
- Images are built for `linux/amd64` and `linux/arm64`
- Semantic versioning is used for tags
- Latest tags are updated on main branch

## 🐛 Bug Reports

### Before Reporting
1. Check existing issues
2. Test with latest version
3. Gather relevant information

### Information to Include
- Operating system and version
- Docker version (if using containers)
- Steps to reproduce
- Expected vs actual behavior
- Error messages or logs
- Browser information (for frontend issues)

## ✨ Feature Requests

### Before Requesting
1. Check existing issues and discussions
2. Consider if it fits the project scope
3. Think about implementation complexity

### Request Format
- Clear description of the feature
- Use case and benefits
- Possible implementation approach
- Any alternative solutions considered

## 🤝 Pull Request Process

### PR Requirements
- [ ] Descriptive title and description
- [ ] Related issue linked (if applicable)
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Code follows style guidelines
- [ ] No merge conflicts

### Review Process
1. Automated tests run
2. Code review by maintainers
3. Testing by reviewers
4. Merge after approval

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## 📞 Getting Help

- Open an issue for bugs or questions
- Start a discussion for ideas or general questions
- Check existing documentation
- Review code examples in the repository

## 🎯 Project Goals

### Core Values
- **Simplicity**: Keep the interface clean and intuitive
- **Performance**: Fast queries and efficient caching
- **Reliability**: Robust error handling and monitoring
- **Security**: Safe defaults and secure configurations
- **Accessibility**: Works on all platforms and devices

### Technical Goals
- Multi-platform Docker support
- Comprehensive API coverage
- Modern web technologies
- Automated CI/CD pipeline
- Comprehensive documentation

Thank you for contributing to making the web a safer place! 🛡️