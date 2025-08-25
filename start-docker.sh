#!/bin/bash

# AdGuard域名查询服务 - Docker启动脚本

echo "🐳 启动AdGuard域名查询服务 (Docker版本)..."

# 检查Docker环境
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: 未找到Docker，请安装Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    echo "❌ 错误: 未找到docker-compose，请安装docker-compose"
    exit 1
fi

# 检查是否存在.env文件
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        echo "📋 复制环境配置文件..."
        cp .env.example .env
        echo "✅ 已创建 .env 文件，您可以根据需要修改配置"
    fi
fi

# 停止并清理已存在的容器
echo "🧹 清理已存在的容器..."
docker-compose down 2>/dev/null || docker compose down 2>/dev/null || true

# 构建并启动服务
echo "🏗️  构建镜像..."
if docker compose version &> /dev/null 2>&1; then
    docker compose build
else
    docker-compose build
fi

if [ $? -ne 0 ]; then
    echo "❌ 镜像构建失败"
    exit 1
fi

echo "🚀 启动服务..."
if docker compose version &> /dev/null 2>&1; then
    docker compose up -d
else
    docker-compose up -d
fi

if [ $? -ne 0 ]; then
    echo "❌ 服务启动失败"
    exit 1
fi

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo "🔍 检查服务状态..."
if docker compose version &> /dev/null 2>&1; then
    docker compose ps
else
    docker-compose ps
fi

# 检查后端API是否可访问
echo "🔍 检查后端API..."
max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
    if curl -s -f http://localhost:8080/api/rules/statistics > /dev/null 2>&1; then
        echo "✅ 后端API启动成功"
        break
    fi
    if [ $attempt -eq $max_attempts ]; then
        echo "❌ 后端API启动超时，请检查日志"
        echo "查看日志: docker-compose logs backend"
        exit 1
    fi
    echo "   等待后端API启动... ($attempt/$max_attempts)"
    sleep 2
    ((attempt++))
done

# 检查前端是否可访问
echo "🔍 检查前端服务..."
if curl -s -f http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ 前端服务启动成功"
else
    echo "⚠️  前端服务可能还在启动中，请稍后访问"
fi

echo ""
echo "🎉 AdGuard域名查询服务启动完成! (Docker版本)"
echo ""
echo "📍 服务地址:"
echo "   前端页面: http://localhost:3000"
echo "   后端API: http://localhost:8080/api"
echo "   API文档: http://localhost:8080/docs"
echo ""
echo "🐳 Docker管理命令:"
echo "   查看状态: docker-compose ps"
echo "   查看日志: docker-compose logs -f"
echo "   停止服务: docker-compose down"
echo "   重启服务: docker-compose restart"
echo ""
echo "💡 提示:"
echo "   - 首次启动可能需要几分钟来下载和缓存规则"
echo "   - 所有数据将持久化保存在Docker卷中"
echo "   - 可以通过修改 .env 文件自定义配置"