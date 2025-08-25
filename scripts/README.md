# Scripts Directory

This directory contains various utility scripts for testing, deployment, and demonstration of the AdGuard DNS Query Service.

## 📁 Directory Structure

```
scripts/
├── testing/          # Test scripts and utilities
├── demo/            # Demo and example scripts  
├── deployment/      # Deployment utilities (if any)
└── README.md        # This file
```

## 🧪 Testing Scripts

Located in `scripts/testing/`

### final_test.sh
**Purpose:** Comprehensive API functionality test  
**Usage:** `./scripts/testing/final_test.sh`  
**Description:** Runs a complete test suite including:
- Statistics API testing
- Single domain queries (blocked and allowed)
- Batch domain queries
- Subdomain matching tests
- Performance benchmarks
- Success rate calculation

**Prerequisites:** 
- Backend service running on localhost:8080
- `curl` and `jq` installed

### test_api.sh
**Purpose:** Basic API endpoint testing  
**Usage:** `./scripts/testing/test_api.sh`  
**Description:** Simple tests for core API functionality:
- Statistics endpoint
- Domain query endpoints
- Rule source management
- Basic error handling

### test_multiple_rules.sh
**Purpose:** Multi-rule matching functionality test  
**Usage:** `./scripts/testing/test_multiple_rules.sh`  
**Description:** Tests domains that match multiple blocking rules:
- Multiple rule source matching
- Rule priority testing
- Detailed rule information display

### verify_fix.sh
**Purpose:** Frontend-backend integration verification  
**Usage:** `./scripts/testing/verify_fix.sh`  
**Description:** Verifies that frontend can properly parse backend responses:
- Tests API response format
- Validates frontend compatibility
- Checks data parsing functions

### test_api.py
**Purpose:** Python-based API testing utility  
**Usage:** `python3 scripts/testing/test_api.py`  
**Description:** Python script for programmatic API testing:
- Object-oriented test structure
- Detailed error reporting
- Extensible test framework

### quick_test.py
**Purpose:** Quick verification of service status  
**Usage:** `python3 scripts/testing/quick_test.py`  
**Description:** Fast health check for the service:
- Service availability check
- Basic functionality verification
- Quick response time measurement

## 🎭 Demo Scripts

Located in `scripts/demo/`

### demo.sh
**Purpose:** Interactive service demonstration  
**Usage:** `./scripts/demo/demo.sh`  
**Description:** Provides an overview of the service:
- Feature showcase
- Technical stack information
- Usage instructions
- API endpoint examples

### test_page.html
**Purpose:** Standalone HTML test page  
**Usage:** Open in browser or serve with web server  
**Description:** Independent frontend for testing:
- Direct API interaction
- Browser-based testing
- UI component testing

## 📋 Usage Examples

### Running All Tests
```bash
# Run comprehensive test suite
./scripts/testing/final_test.sh

# Run basic API tests
./scripts/testing/test_api.sh

# Run Python tests
python3 scripts/testing/test_api.py
```

### Demo and Exploration
```bash
# Show service demo
./scripts/demo/demo.sh

# Open test page in browser
open scripts/demo/test_page.html
```

### Service Verification
```bash
# Quick health check
python3 scripts/testing/quick_test.py

# Verify frontend-backend integration
./scripts/testing/verify_fix.sh
```

## 🔧 Script Requirements

### System Requirements
- **Bash**: Version 4.0+ (for shell scripts)
- **Python**: Version 3.7+ (for Python scripts)
- **curl**: For HTTP requests
- **jq**: For JSON parsing (optional but recommended)

### Service Requirements
- Backend service running on `localhost:8080`
- Frontend service running on `localhost:3000` (for integration tests)

## 🎯 Testing Best Practices

### Before Running Tests
1. **Start Services:**
   ```bash
   ./start-docker.sh
   # or
   ./deploy-production.sh
   ```

2. **Wait for Initialization:**
   - Backend needs time to load rules (1-2 minutes)
   - Frontend needs backend to be healthy

3. **Check Service Status:**
   ```bash
   curl http://localhost:8080/api/rules/statistics
   curl http://localhost:3000
   ```

### Test Execution Order
1. Start with `quick_test.py` for basic verification
2. Run `test_api.sh` for API functionality
3. Execute `final_test.sh` for comprehensive testing
4. Use specific tests (`test_multiple_rules.sh`, etc.) as needed

### Interpreting Results
- **Green ✅**: Test passed successfully
- **Red ❌**: Test failed, check logs
- **Yellow ⚠️**: Warning or partial failure
- **Success Rate**: Should be >80% for healthy service

## 🐛 Troubleshooting

### Common Issues

**Service Not Running:**
```bash
# Check if services are up
docker ps
# or
curl http://localhost:8080/api/rules/statistics
```

**Permission Denied:**
```bash
# Make scripts executable
chmod +x scripts/testing/*.sh
chmod +x scripts/demo/*.sh
```

**Missing Dependencies:**
```bash
# Install jq (macOS)
brew install jq

# Install jq (Ubuntu/Debian)
sudo apt-get install jq

# Install curl (usually pre-installed)
sudo apt-get install curl
```

**Test Failures:**
- Check backend logs: `docker-compose logs backend`
- Verify API endpoints manually
- Ensure rules have finished loading
- Check network connectivity

### Debugging Tips
1. **Enable Verbose Output:** Most scripts support debug mode
2. **Check Logs:** Review container logs for errors
3. **Manual Testing:** Use curl to test API endpoints directly
4. **Network Issues:** Verify port accessibility

## 📈 Extending Tests

### Adding New Tests
1. **Shell Scripts:** Follow existing naming convention
2. **Python Scripts:** Use the test framework pattern
3. **Documentation:** Update this README with new scripts

### Test Categories
- **Unit Tests:** Individual API endpoint testing
- **Integration Tests:** Full workflow testing
- **Performance Tests:** Load and response time testing
- **Compatibility Tests:** Frontend-backend integration

## 🔗 Related Documentation

- [API Documentation](../docs/api/README.md)
- [Deployment Guide](../docs/deployment/README.md)
- [Contributing Guide](../docs/development/CONTRIBUTING.md)
- [Quick Setup](../docs/setup/QUICK_SETUP.md)