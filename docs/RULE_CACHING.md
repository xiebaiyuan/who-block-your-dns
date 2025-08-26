# 📦 Rule Caching Feature

This feature adds persistent rule caching to the AdGuard DNS Query Service, which significantly reduces startup time after the first run.

## 🎯 Purpose

- **Reduce startup time**: Avoid re-downloading all rules on container restart
- **Save bandwidth**: No need to fetch rules from remote sources every time
- **Improve reliability**: Service can start even if remote rule sources are temporarily unavailable

## 📁 Cache Location

Rules are cached in the `/app/rules-cache` directory by default. This can be customized using the `RULES_CACHE_DIR` environment variable.

## 🗃️ Cached Data

The following data is persisted to disk:

1. **Domain Rules** - Parsed domain blocking rules
2. **Hosts Rules** - Hosts file format rules
3. **Rule Source Metadata** - Information about each rule source (name, status, last update time, etc.)

Note: Regex rules are not currently cached due to serialization complexity.

## 🐳 Docker Integration

### Volume Mounting

To persist rules across container restarts, mount a volume to the rules-cache directory:

```yaml
volumes:
  - /host/path/rules-cache:/app/rules-cache
```

### Environment Variables

Customize the cache directory with:
```bash
RULES_CACHE_DIR=/custom/cache/path
```

## 🚀 How It Works

1. **First Startup**: Rules are downloaded from remote sources and cached to disk
2. **Subsequent Startups**: Rules are loaded from cache, skipping remote downloads
3. **Rule Refresh**: When rules are manually refreshed, the cache is updated
4. **Cache Invalidation**: Cache is automatically invalidated when rule sources are added/removed

## 📊 Performance Benefits

- **Startup Time**: Reduced from several minutes to seconds
- **Bandwidth**: Eliminates repeated rule downloads
- **Reliability**: Service starts even with network issues

## 🛠️ Implementation Details

### Cache Files

- `domain_rules.json` - Domain blocking rules
- `hosts_rules.json` - Hosts format rules
- `rule_sources.json` - Rule source metadata

### Cache Management

- Automatic cache saving after rule updates
- Automatic cache loading on startup
- Manual cache refresh via API
- Cache directory creation if it doesn't exist

## 🧪 Testing

To test the caching feature:

1. Start the service (first run will download and cache rules)
2. Restart the service (should load from cache quickly)
3. Check logs for "已从缓存加载规则" message
4. Verify API responses are consistent

## 🔄 API Endpoints

The existing API endpoints continue to work as before:
- `POST /api/rules/refresh` - Refresh rules and update cache
- `GET /api/rules/statistics` - View rule statistics
- Rule query endpoints - Use cached rules for lookups

## 🧹 Cache Maintenance

To clear the cache:
1. Stop the container
2. Remove the cache directory contents
3. Restart the container

The service will automatically re-download rules on the next startup.