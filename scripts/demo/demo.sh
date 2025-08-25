#!/bin/bash

# AdGuard域名查询服务演示脚本

echo "🚀 AdGuard域名查询服务演示"
echo "================================"

# 检查项目结构
echo "📁 项目结构:"
find /Users/xiebaiyuan/workspace/github/adrule/adguard-query-service -type f -name "*.java" -o -name "*.html" -o -name "*.css" -o -name "*.js" -o -name "*.yml" -o -name "*.xml" | head -20

echo ""
echo "✨ 功能特性:"
echo "  🔍 单个域名查询 - 快速查询单个域名是否被阻止"
echo "  📋 批量域名查询 - 支持一次查询多个域名（最多100个）"
echo "  🛡️ 多种规则支持 - 支持域名规则、正则规则、Hosts规则"
echo "  ⚡ 缓存机制 - 使用Caffeine缓存提高查询速度"
echo "  🔄 自动更新 - 定时自动更新规则列表"
echo "  ➕ 规则源管理 - 支持添加/删除自定义规则源"
echo "  📊 统计信息 - 实时显示规则数量和更新状态"
echo "  🎨 现代化UI - 响应式设计，支持移动端"

echo ""
echo "🔧 技术栈:"
echo "  后端: Spring Boot 3.3.2 + Caffeine Cache + Hutool"
echo "  前端: HTML5 + CSS3 + Vanilla JavaScript"

echo ""
echo "🚀 启动服务:"
echo "  1. cd /Users/xiebaiyuan/workspace/github/adrule/adguard-query-service"
echo "  2. ./start.sh"
echo ""
echo "  或者分别启动:"
echo "  后端: cd backend && mvn spring-boot:run"
echo "  前端: cd frontend && python3 -m http.server 3000"

echo ""
echo "🌐 访问地址:"
echo "  前端页面: http://localhost:3000"
echo "  后端API: http://localhost:8080/api"

echo ""
echo "📚 主要API端点:"
echo "  GET  /api/query/domain?domain=example.com     - 查询单个域名"
echo "  POST /api/query/domains                       - 批量查询域名"
echo "  GET  /api/rules/sources                       - 获取规则源列表"
echo "  POST /api/rules/sources                       - 添加规则源"
echo "  POST /api/rules/refresh                       - 刷新规则"
echo "  GET  /api/rules/statistics                    - 获取统计信息"

echo ""
echo "📝 默认规则源包括:"
echo "  • Scam Blocklist"
echo "  • Dan Pollock's List"
echo "  • Peter Lowe's List"
echo "  • WindowsSpyBlocker"
echo "  • AdGuard Base Filter"
echo "  • 乘风广告过滤规则"
echo "  • Anti-AD"
echo "  • uBlock Origin Filters"
echo "  • 等等..."

echo ""
echo "💡 使用说明:"
echo "  1. 启动服务后，系统会自动下载和缓存所有规则源"
echo "  2. 首次启动可能需要几分钟时间来初始化"
echo "  3. 可以通过前端界面查询域名和管理规则源"
echo "  4. 支持单个查询和批量查询"
echo "  5. 查询结果会显示是否被阻止、匹配规则等详细信息"

echo ""
echo "================================"
echo "🎉 AdGuard域名查询服务已就绪！"
