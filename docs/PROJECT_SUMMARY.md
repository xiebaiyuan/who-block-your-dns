# AdGuard 域名查询服务

这是一个前后端分离的AdGuard域名查询服务，用于查询域名是否被AdGuard规则阻止。

## 📂 项目结构

```
who-block-your-dns/
├── backend-python/          # Python FastAPI 后端
│   ├── main.py             # 主应用文件
│   ├── requirements.txt    # Python依赖
│   ├── Dockerfile          # 后端Docker配置
│   ├── .dockerignore       # Docker忽略文件
│   └── logs/               # 日志目录
├── frontend/               # 前端静态文件
│   ├── index.html          # 主页面
│   ├── script.js           # JavaScript逻辑
│   ├── styles.css          # 样式文件
│   └── Dockerfile          # 前端Docker配置
├── scripts/                # 工具脚本目录
│   ├── demo.sh             # 演示脚本
│   ├── final_test.sh       # 完整测试脚本
│   ├── test_api.py         # Python API测试
│   ├── test_api.sh         # Shell API测试
│   ├── test_multiple_rules.sh  # 多规则测试
│   ├── verify_fix.sh       # 修复验证脚本
│   ├── test_page.html      # 测试页面
│   └── quick_test.py       # 快速测试
├── docker-compose.yml      # Docker Compose 配置
├── .env.example           # 环境变量示例
├── start-python.sh        # Python版本启动脚本
├── start.sh               # Java版本启动脚本 (如果存在)
├── start-docker.sh        # Docker启动脚本
├── stop-python.sh         # Python版本停止脚本
├── stop.sh                # Java版本停止脚本 (如果存在)
├── stop-docker.sh         # Docker停止脚本
└── README.md              # 项目说明
```

## 🚀 快速启动

### 方式1: Docker部署 (推荐)

使用Docker是最简单、最可靠的部署方式：

```bash
# 启动所有服务
./start-docker.sh

# 停止所有服务
./stop-docker.sh
```

### 方式2: 传统部署

#### Python后端 + 前端
```bash
# 启动Python版本 (推荐)
./start-python.sh

# 停止服务
./stop-python.sh
```

## 🌐 访问地址

- **前端页面**: http://localhost:3000
- **后端API**: http://localhost:8080/api
- **API文档**: http://localhost:8080/docs

## ✨ 功能特性

- 🔍 **单个域名查询**: 快速查询单个域名是否被阻止
- 📋 **批量域名查询**: 支持一次查询多个域名（最多100个）
- 🛡️ **多种规则支持**: 支持域名规则、正则规则、Hosts规则
- ⚡ **缓存机制**: 使用本地缓存提高查询速度
- 🔄 **自动更新**: 定时自动更新规则列表
- ➕ **规则源管理**: 支持添加/删除自定义规则源
- 📊 **统计信息**: 实时显示规则数量和更新状态
- 🎨 **现代化UI**: 响应式设计，支持移动端

## 🛠️ 技术栈

### 后端 (Python版本)
- **FastAPI**: 现代化Web框架
- **Uvicorn**: ASGI服务器
- **Requests**: HTTP客户端
- **CacheTools**: 本地缓存
- **Schedule**: 定时任务

### 前端
- **HTML5 + CSS3**: 页面结构和样式
- **Vanilla JavaScript**: 交互逻辑
- **响应式设计**: 适配各种设备

### Docker化
- **Docker**: 容器化部署
- **Docker Compose**: 多容器编排
- **Nginx**: 前端静态文件服务器

## 📚 API文档

### 域名查询

#### 单个域名查询
```
GET /api/query/domain?domain=example.com
```

#### 批量域名查询
```
POST /api/query/domains
Content-Type: application/json

["domain1.com", "domain2.com", "domain3.com"]
```

### 规则管理

#### 获取所有规则源
```
GET /api/rules/sources
```

#### 添加规则源
```
POST /api/rules/sources
Content-Type: application/json

{
  "name": "自定义规则源",
  "url": "https://example.com/rules.txt",
  "enabled": true
}
```

#### 删除规则源
```
DELETE /api/rules/sources?url=https://example.com/rules.txt
```

#### 刷新规则
```
POST /api/rules/refresh
```

#### 获取统计信息
```
GET /api/rules/statistics
```

## 🧪 测试工具

项目提供了多种测试脚本，位于 `scripts/` 目录：

- `demo.sh`: 项目演示和功能介绍
- `final_test.sh`: 完整的API功能测试
- `test_api.sh`: 基本API测试
- `test_multiple_rules.sh`: 多规则匹配测试
- `verify_fix.sh`: 验证修复结果

## 🐳 Docker管理

### 常用命令
```bash
# 查看容器状态
docker compose ps

# 查看日志
docker compose logs -f

# 重启服务
docker compose restart

# 更新并重启
docker compose up -d --build
```

### 环境配置

复制 `.env.example` 为 `.env` 并根据需要修改配置：

```bash
cp .env.example .env
```

## 🔧 开发指南

### 项目整理

项目已经进行了如下整理：

1. **脚本分类**: 将测试和演示脚本移到 `scripts/` 目录
2. **Docker化**: 完整的Docker和Docker Compose配置
3. **启动脚本**: 提供多种启动方式的便捷脚本
4. **目录结构**: 清晰的项目结构和文件组织

### 添加新功能

1. **后端**: 在 `backend-python/main.py` 中添加新的API端点
2. **前端**: 在 `frontend/script.js` 中添加对应的JavaScript函数
3. **UI**: 在 `frontend/index.html` 和 `frontend/styles.css` 中添加界面元素

## 📝 版本更新

### v1.0.0
- ✅ 项目结构整理
- ✅ Docker化部署
- ✅ 脚本分类整理
- ✅ 完整的启动/停止脚本
- ✅ 健康检查和监控
- ✅ 响应式前端界面

## 💡 常见问题

### Q: Docker启动失败？
A: 确保Docker和Docker Compose已正确安装，检查端口3000和8080是否被占用。

### Q: 后端API无法访问？
A: 检查后端容器是否正常运行，查看日志：`docker compose logs backend`

### Q: 前端页面加载但无法查询？
A: 检查前端是否能正常访问后端API，确认网络配置正确。

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交Issue和Pull Request！