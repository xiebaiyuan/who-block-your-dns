#!/bin/bash

# AdGuard域名查询服务 - Docker停止脚本 (支持多种配置)

echo "🐳 停止AdGuard域名查询服务 (Docker版本)..."

# 检查配置选项
CONFIG="default"
if [ "$1" = "--combined" ]; then
    CONFIG="combined"
    echo "🔄 停止合并配置 (单容器)"
elif [ "$1" = "--optimized" ]; then
    CONFIG="optimized"
    echo "⚡ 停止优化配置"
elif [ "$1" = "--cached" ]; then
    CONFIG="cached"
    echo "💾 停止规则缓存配置"
fi

# 检查Docker Compose版本并停止服务
COMPOSE_CMD=""
case $CONFIG in
    "combined")
        if docker compose version &> /dev/null 2>&1; then
            echo "🛑 使用Docker Compose V2停止合并服务..."
            docker compose -f docker-compose.combined.yml down
            COMPOSE_CMD="docker compose -f docker-compose.combined.yml"
        else
            echo "🛑 使用Docker Compose V1停止合并服务..."
            docker-compose -f docker-compose.combined.yml down
            COMPOSE_CMD="docker-compose -f docker-compose.combined.yml"
        fi
        ;;
    "optimized")
        if docker compose version &> /dev/null 2>&1; then
            echo "🛑 使用Docker Compose V2停止优化服务..."
            docker compose -f docker-compose.optimized.yml down
            COMPOSE_CMD="docker compose -f docker-compose.optimized.yml"
        else
            echo "🛑 使用Docker Compose V1停止优化服务..."
            docker-compose -f docker-compose.optimized.yml down
            COMPOSE_CMD="docker-compose -f docker-compose.optimized.yml"
        fi
        ;;
    "cached")
        if docker compose version &> /dev/null 2>&1; then
            echo "🛑 使用Docker Compose V2停止缓存服务..."
            docker compose -f docker-compose.optimized-with-rules-cache.yml down
            COMPOSE_CMD="docker compose -f docker-compose.optimized-with-rules-cache.yml"
        else
            echo "🛑 使用Docker Compose V1停止缓存服务..."
            docker-compose -f docker-compose.optimized-with-rules-cache.yml down
            COMPOSE_CMD="docker-compose -f docker-compose.optimized-with-rules-cache.yml"
        fi
        ;;
    *)
        if docker compose version &> /dev/null 2>&1; then
            echo "🛑 使用Docker Compose V2停止服务..."
            docker compose down
            COMPOSE_CMD="docker compose"
        else
            echo "🛑 使用Docker Compose V1停止服务..."
            docker-compose down
            COMPOSE_CMD="docker-compose"
        fi
        ;;
esac

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