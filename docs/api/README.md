# API Documentation

The AdGuard DNS Query Service provides a RESTful API for querying domain blocking status and managing rule sources.

## Base URL

```
http://localhost:8080/api
```

## Authentication

Currently, no authentication is required. The API is open for public use.

## Content Type

All API requests and responses use `application/json` content type unless otherwise specified.

## Response Format

All API responses follow this standard format:

```json
{
  "code": 200,
  "message": "Success message",
  "data": {}, 
  "timestamp": 1640995200000
}
```

## Domain Query Endpoints

### Single Domain Query

Query whether a single domain is blocked by AdGuard rules.

**Endpoint:** `GET /query/domain`

**Parameters:**
- `domain` (string, required): The domain to query

**Example Request:**
```bash
curl "http://localhost:8080/api/query/domain?domain=doubleclick.net"
```

**Example Response:**
```json
{
  "code": 200,
  "message": "查询成功",
  "data": [
    ["domain", "doubleclick.net"],
    ["blocked", true],
    ["matched_rule", "||doubleclick.net^"],
    ["rule_source", "AdGuard Base Filter"],
    ["rule_type", "domain"],
    ["query_time", 1640995200000],
    ["duration", 15]
  ],
  "timestamp": 1640995200000
}
```

### Batch Domain Query

Query multiple domains at once (up to 100 domains).

**Endpoint:** `POST /query/domains`

**Request Body:**
```json
{
  "domains": ["domain1.com", "domain2.com", "domain3.com"]
}
```

**Example Request:**
```bash
curl -X POST "http://localhost:8080/api/query/domains" \
     -H "Content-Type: application/json" \
     -d '{"domains": ["doubleclick.net", "github.com", "google-analytics.com"]}'
```

**Example Response:**
```json
{
  "code": 200,
  "message": "批量查询成功",
  "data": [
    {
      "domain": "doubleclick.net",
      "blocked": true,
      "matched_rules": [
        {
          "rule": "||doubleclick.net^",
          "rule_source": "AdGuard Base Filter",
          "rule_type": "domain"
        }
      ],
      "query_time": 1640995200000,
      "duration": 12
    },
    {
      "domain": "github.com", 
      "blocked": false,
      "matched_rules": [],
      "query_time": 1640995200001,
      "duration": 8
    }
  ],
  "timestamp": 1640995200000
}
```

## Rule Management Endpoints

### Get Statistics

Get current statistics about loaded rules and sources.

**Endpoint:** `GET /rules/statistics`

**Example Request:**
```bash
curl "http://localhost:8080/api/rules/statistics"
```

**Example Response:**
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "totalSources": 33,
    "enabledSources": 33,
    "domainRules": 693367,
    "regexRules": 133,
    "hostsRules": 20384,
    "lastUpdate": 1640995200000,
    "cacheSize": 1250
  },
  "timestamp": 1640995200000
}
```

### Get Rule Sources

Get a list of all configured rule sources.

**Endpoint:** `GET /rules/sources`

**Example Request:**
```bash
curl "http://localhost:8080/api/rules/sources"
```

**Example Response:**
```json
{
  "code": 200,
  "message": "获取成功",
  "data": [
    {
      "url": "https://example.com/rules.txt",
      "name": "Example Rules",
      "enabled": true,
      "last_updated": 1640995200000,
      "rule_count": 1500,
      "status": "已更新"
    }
  ],
  "timestamp": 1640995200000
}
```

### Add Rule Source

Add a new rule source to the system.

**Endpoint:** `POST /rules/sources`

**Request Body:**
```json
{
  "name": "Custom Rules",
  "url": "https://example.com/custom-rules.txt",
  "enabled": true
}
```

**Example Request:**
```bash
curl -X POST "http://localhost:8080/api/rules/sources" \
     -H "Content-Type: application/json" \
     -d '{"name": "Custom Rules", "url": "https://example.com/rules.txt", "enabled": true}'
```

**Example Response:**
```json
{
  "code": 200,
  "message": "规则源添加成功",
  "data": null,
  "timestamp": 1640995200000
}
```

### Delete Rule Source

Remove a rule source from the system.

**Endpoint:** `DELETE /rules/sources`

**Parameters:**
- `url` (string, required): The URL of the rule source to delete

**Example Request:**
```bash
curl -X DELETE "http://localhost:8080/api/rules/sources?url=https://example.com/rules.txt"
```

**Example Response:**
```json
{
  "code": 200,
  "message": "规则源删除成功",
  "data": null,
  "timestamp": 1640995200000
}
```

### Refresh Rules

Manually trigger a refresh of all rule sources.

**Endpoint:** `POST /rules/refresh`

**Example Request:**
```bash
curl -X POST "http://localhost:8080/api/rules/refresh"
```

**Example Response:**
```json
{
  "code": 200,
  "message": "规则刷新已开始",
  "data": null,
  "timestamp": 1640995200000
}
```

## Error Responses

### Error Format

All error responses follow this format:

```json
{
  "code": 400,
  "message": "Error description",
  "data": null,
  "timestamp": 1640995200000
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| 400  | Bad Request - Invalid parameters |
| 404  | Not Found - Endpoint not found |
| 500  | Internal Server Error - Server error |

### Error Examples

**Invalid Domain:**
```json
{
  "code": 400,
  "message": "无效的域名格式",
  "data": null,
  "timestamp": 1640995200000
}
```

**Too Many Domains:**
```json
{
  "code": 400,
  "message": "域名数量不能超过100个",
  "data": null,
  "timestamp": 1640995200000
}
```

## Rate Limiting

Currently, no rate limiting is implemented. However, it's recommended to:
- Limit batch queries to 100 domains maximum
- Avoid excessive concurrent requests
- Cache results when possible

## OpenAPI/Swagger Documentation

Interactive API documentation is available at:
```
http://localhost:8080/docs
```

This provides a complete interface for testing all API endpoints directly from your browser.

## SDK and Client Libraries

Currently, no official SDK is provided. However, the API is REST-compliant and can be easily integrated with any HTTP client library.

### Python Example
```python
import requests

# Single domain query
response = requests.get("http://localhost:8080/api/query/domain?domain=doubleclick.net")
result = response.json()

# Batch query
domains = ["doubleclick.net", "github.com"]
response = requests.post("http://localhost:8080/api/query/domains", 
                        json={"domains": domains})
results = response.json()
```

### JavaScript Example
```javascript
// Single domain query
const response = await fetch('http://localhost:8080/api/query/domain?domain=doubleclick.net');
const result = await response.json();

// Batch query  
const domains = ['doubleclick.net', 'github.com'];
const response = await fetch('http://localhost:8080/api/query/domains', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ domains })
});
const results = await response.json();
```