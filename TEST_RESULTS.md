# AdGuard域名查询服务 - 测试用例文档

## 概述
这是一个前后端分离的AdGuard域名查询服务，支持查询域名是否被AdGuard规则阻止，包括域名规则、正则规则和Hosts规则匹配。

## 服务信息
- **后端API**: http://localhost:8080
- **前端界面**: http://localhost:3000  
- **API文档**: http://localhost:8080/docs
- **规则统计**: 695,888条域名规则 + 133条正则规则 + 20,384条Hosts规则
- **规则源**: 33个活跃的规则源

## 测试用例

### 1. 基础API测试

#### 1.1 统计API测试
- **端点**: `GET /api/rules/statistics`
- **预期**: 返回规则统计信息
- **结果**: ✅ 通过
- **响应示例**:
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "totalSources": 33,
    "enabledSources": 33,
    "domainRules": 695888,
    "regexRules": 133,
    "hostsRules": 20384,
    "lastUpdate": 1756121321426,
    "cacheSize": 12
  }
}
```

#### 1.2 规则源列表API测试
- **端点**: `GET /api/rules/sources`
- **预期**: 返回33个规则源列表
- **结果**: ✅ 通过
- **包含规则源**: Scam Blocklist, Dan Pollock's List, Peter Lowe's List, AdGuard Base等

### 2. 域名查询测试

#### 2.1 广告域名阻止测试
测试已知的广告域名是否被正确阻止：

| 域名 | 预期结果 | 实际结果 | 匹配规则 | 状态 |
|------|----------|----------|----------|------|
| doubleclick.net | 阻止 | ✅ 阻止 | doubleclick.net | ✅ 通过 |
| googleadservices.com | 阻止 | ✅ 阻止 | googleadservices.com | ✅ 通过 |
| google-analytics.com | 阻止 | ✅ 阻止 | google-analytics.com | ✅ 通过 |
| googlesyndication.com | 阻止 | ✅ 阻止 | googlesyndication.com | ✅ 通过 |

#### 2.2 正常域名允许测试
测试正常域名是否被正确允许：

| 域名 | 预期结果 | 实际结果 | 状态 |
|------|----------|----------|------|
| github.com | 允许 | ✅ 允许 | ✅ 通过 |
| stackoverflow.com | 允许 | ✅ 允许 | ✅ 通过 |
| developer.mozilla.org | 允许 | ✅ 允许 | ✅ 通过 |
| docs.python.org | 允许 | ✅ 允许 | ✅ 通过 |

#### 2.3 子域名匹配测试
测试子域名是否能正确继承主域名的阻止规则：

| 域名 | 预期结果 | 实际结果 | 匹配规则 | 状态 |
|------|----------|----------|----------|------|
| www.doubleclick.net | 阻止 | ✅ 阻止 | doubleclick.net | ✅ 通过 |
| stats.doubleclick.net | 阻止 | ✅ 阻止 | doubleclick.net | ✅ 通过 |
| ssl.google-analytics.com | 阻止 | ✅ 阻止 | google-analytics.com | ✅ 通过 |

#### 2.4 特殊域名测试
测试社交媒体等域名的处理：

| 域名 | 实际结果 | 说明 |
|------|----------|------|
| facebook.com | ✅ 允许 | 未被当前规则集阻止 |
| twitter.com | ✅ 允许 | 未被当前规则集阻止 |
| instagram.com | ✅ 允许 | 未被当前规则集阻止 |

### 3. 批量查询测试

#### 3.1 批量查询API测试
- **端点**: `POST /api/query/domains`
- **请求体**: 
```json
{
  "domains": ["doubleclick.net", "github.com", "google-analytics.com", "stackoverflow.com"]
}
```
- **结果**: ✅ 通过
- **响应**: 正确返回每个域名的查询结果

### 4. 性能测试

#### 4.1 查询响应时间测试
- **测试方法**: 执行10次查询测量平均响应时间
- **测试域名**: doubleclick.net
- **平均响应时间**: 10ms
- **结果**: ✅ 通过 - 响应速度优秀

#### 4.2 缓存效果测试
- **缓存命中**: 在测试过程中缓存大小从0增长到12
- **结果**: ✅ 通过 - 缓存正常工作

### 5. API端点汇总

| 端点 | 方法 | 功能 | 状态 |
|------|------|------|------|
| `/api/rules/statistics` | GET | 获取规则统计 | ✅ 可用 |
| `/api/rules/sources` | GET | 获取规则源列表 | ✅ 可用 |
| `/api/query/domain` | GET | 单域名查询 | ✅ 可用 |
| `/api/query/domains` | POST | 批量域名查询 | ✅ 可用 |
| `/api/rules/refresh` | POST | 刷新规则 | ✅ 可用 |

### 6. 前端功能验证

前端界面提供以下功能：
- ✅ 单域名查询表单
- ✅ 批量域名查询
- ✅ 规则源管理
- ✅ 统计信息展示
- ✅ 响应式设计

## 测试总结

### 成功指标
- **总体通过率**: 11/11 (100%)
- **阻止域名测试**: 4/4 通过  
- **允许域名测试**: 4/4 通过
- **子域名测试**: 3/3 通过
- **平均响应时间**: 10ms
- **规则加载**: 695,888 + 133 + 20,384 = 716,405条规则

### 功能验证
✅ **域名匹配**: 精确匹配广告域名  
✅ **子域名继承**: 子域名正确继承主域名规则  
✅ **正常域名放行**: 正常网站不被误阻  
✅ **批量查询**: 支持一次查询多个域名  
✅ **缓存机制**: 查询结果缓存提升性能  
✅ **规则统计**: 实时统计规则数量和状态  
✅ **多规则源**: 支持33个不同的规则源  

### 规则覆盖范围
- **广告过滤**: ✅ Google广告、DoubleClick等
- **分析跟踪**: ✅ Google Analytics等
- **恶意软件**: ✅ 通过多个安全规则源
- **社交媒体**: ⚠️ 主流社交平台未被阻止（符合预期）

## 使用示例

### 通过API查询
```bash
# 单域名查询
curl "http://localhost:8080/api/query/domain?domain=doubleclick.net"

# 批量查询
curl -X POST -H "Content-Type: application/json" \
  -d '{"domains": ["doubleclick.net", "github.com"]}' \
  "http://localhost:8080/api/query/domains"
```

### 通过前端界面
访问 http://localhost:3000 使用Web界面进行查询。

## 结论

🎉 **AdGuard域名查询服务测试全部通过！**

服务已成功实现：
- 前后端分离架构
- 高性能域名查询（10ms平均响应）
- 支持70万+规则的实时匹配
- 完整的API和Web界面
- 缓存机制优化性能
- 支持单查询和批量查询
- 支持自定义规则源管理

该服务可以有效识别广告域名、跟踪域名等，为用户提供准确的域名安全检查功能。
