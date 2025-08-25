#!/bin/bash

# AdGuard域名查询服务 - Docker停止脚本

echo "🐳 停止AdGuard域名查询服务 (Docker版本)..."

# 检查Docker Compose版本并停止服务
if docker compose version &> /dev/null 2>&1; then
    echo "🛑 使用Docker Compose V2停止服务..."
    docker compose down
    COMPOSE_CMD="docker compose"
else
    echo "🛑 使用Docker Compose V1停止服务..."
    docker-compose down
    COMPOSE_CMD="docker-compose"
fi

if [ $? -eq 0 ]; then
    echo "✅ 服务已成功停止"
else
    echo "⚠️  停止服务时出现问题"
fi

# 清理无用的镜像和容器（可选）
read -p "是否清理无用的Docker镜像和容器？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 清理无用的Docker资源..."
    docker system prune -f
    echo "✅ 清理完成"
fi

echo ""
echo "🎉 AdGuard域名查询服务已完全停止!"
echo ""
echo "💡 重启服务: ./start-docker.sh"
echo "💡 查看停止的容器: docker ps -a"