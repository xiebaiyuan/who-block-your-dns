# 🐍 Python Version with Rule Caching

This guide explains how to use the Python version of the AdGuard DNS Query Service with rule caching support.

## 🎯 Purpose

The Python version now includes rule caching functionality that significantly improves startup time after the first run by persisting downloaded rules to disk.

## 🚀 Quick Start

### Starting the Service
```bash
# Start the service with rule caching
./start-python.sh
```

### Stopping the Service
```bash
# Stop the service and preserve rule cache
./stop-python.sh
```

## 📁 Cache Location

Rules are cached in the `backend-python/rules-cache/` directory with the following files:

- `domain_rules.json` - Domain blocking rules
- `hosts_rules.json` - Hosts file format rules  
- `rule_sources.json` - Rule source metadata

## 🔄 How Rule Caching Works

### First Startup
1. Rules are downloaded from remote sources
2. Rules are parsed and stored in memory
3. Rules are automatically cached to disk
4. Startup time: Several minutes (depending on network and rule sources)

### Subsequent Startups
1. Rules are loaded from local cache files
2. Rules are parsed and stored in memory
3. Background update process starts
4. Startup time: Seconds (much faster than first run)

### Rule Refresh
- Manual refresh via API will update the cache
- Automatic refresh every 6 hours also updates the cache
- Cache is automatically invalidated when rule sources are added/removed

## 📊 Performance Benefits

### Startup Time
- **First Run**: Several minutes (network download)
- **Subsequent Runs**: Seconds (local cache)

### Bandwidth Usage
- **First Run**: Full rule downloads
- **Subsequent Runs**: Minimal (only updates)

### Reliability
- Service can start even with temporary network issues
- Previously downloaded rules are always available

## 🛠️ Implementation Details

### Environment Variables
The Python backend respects the following environment variables:

```bash
# Customize cache directory (default: /app/rules-cache)
RULES_CACHE_DIR=./backend-python/rules-cache

# Log level (default: INFO)
LOG_LEVEL=INFO
```

### Cache Management
- Automatic cache saving after rule updates
- Automatic cache loading on startup
- Manual cache refresh via API endpoints
- Cache directory creation if it doesn't exist

## 🧪 Testing Rule Caching

### Verify Cache Creation
```bash
# After first run, check cache files
ls -la backend-python/rules-cache/

# Check cache contents
cat backend-python/rules-cache/rule_sources.json | jq '.'
```

### Test Fast Startup
```bash
# Stop service
./stop-python.sh

# Start service again (should be much faster)
./start-python.sh

# Look for "已从缓存加载规则" message in logs
tail -f backend-python/logs/backend.log
```

### Manual Cache Operations
```bash
# Clear cache (force re-download on next startup)
rm -rf backend-python/rules-cache/

# Preserve cache but clear logs
rm -rf backend-python/logs/
```

## 🐛 Troubleshooting

### Cache Issues
If you encounter cache-related problems:

1. **Corrupted Cache**:
   ```bash
   # Clear cache and restart
   rm -rf backend-python/rules-cache/
   ./stop-python.sh
   ./start-python.sh
   ```

2. **Permission Issues**:
   ```bash
   # Fix cache directory permissions
   chmod -R 755 backend-python/rules-cache/
   ```

3. **Cache Not Loading**:
   ```bash
   # Check logs for cache loading messages
   grep "缓存" backend-python/logs/backend.log
   ```

### Performance Issues
If startup is still slow:

1. **Check Network**:
   ```bash
   # Test rule source connectivity
   curl -I https://easylist-downloads.adblockplus.org/easylist.txt
   ```

2. **Monitor Resource Usage**:
   ```bash
   # Monitor during startup
   top -p $(cat backend-python.pid)
   ```

## 📈 Monitoring

### Log Messages
Look for these messages in `backend-python/logs/backend.log`:

```
# Cache loading
INFO: 已从缓存加载域名规则: 5 个源
INFO: 已从缓存加载Hosts规则: 3 个源
INFO: 已从缓存加载规则源信息: 8 个源

# Cache saving
INFO: 规则已保存到缓存目录: /app/rules-cache

# Cache directory issues
ERROR: 保存规则到缓存失败: [Errno 13] Permission denied
```

### API Endpoints
The same API endpoints work with cached rules:

- `GET /api/rules/statistics` - View rule statistics
- `GET /api/rules/sources` - List rule sources
- `POST /api/rules/refresh` - Refresh rules (updates cache)
- `GET /api/query/domain?domain=example.com` - Query domains (uses cached rules)

## 🧹 Maintenance

### Regular Maintenance
```bash
# Clean logs while preserving cache
rm -rf backend-python/logs/*.log

# Update dependencies
cd backend-python
pip install -r requirements.txt --upgrade
```

### Cache Cleanup
```bash
# Remove old cache (forces fresh download)
rm -rf backend-python/rules-cache/

# Remove specific rule source from cache
# Edit the JSON files in rules-cache/ directory
```

## 📚 Related Documentation

- [Rule Caching Feature](RULE_CACHING.md)
- [API Documentation](api/README.md)
- [Development Guide](development/CONTRIBUTING.md)