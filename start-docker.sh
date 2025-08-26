#!/bin/bash

# AdGuard域名查询服务 - Docker启动脚本 (支持多种配置)

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

# 检查配置选项
CONFIG="default"
if [ "$1" = "--combined" ]; then
    CONFIG="combined"
    echo "🔄 使用合并配置 (单容器)"
elif [ "$1" = "--optimized" ]; then
    CONFIG="optimized"
    echo "⚡ 使用优化配置"
elif [ "$1" = "--cached" ]; then
    CONFIG="cached"
    echo "💾 使用规则缓存配置"
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
case $CONFIG in
    "combined")
        docker-compose -f docker-compose.combined.yml down 2>/dev/null || docker compose -f docker-compose.combined.yml down 2>/dev/null || true
        ;;
    "optimized")
        docker-compose -f docker-compose.optimized.yml down 2>/dev/null || docker compose -f docker-compose.optimized.yml down 2>/dev/null || true
        ;;
    "cached")
        docker-compose -f docker-compose.optimized-with-rules-cache.yml down 2>/dev/null || docker compose -f docker-compose.optimized-with-rules-cache.yml down 2>/dev/null || true
        ;;
    *)
        docker-compose down 2>/dev/null || docker compose down 2>/dev/null || true
        ;;
esac

# 构建并启动服务
echo "🏗️  构建镜像..."
case $CONFIG in
    "combined")
        if docker compose version &> /dev/null 2>&1; then
            docker compose -f docker-compose.combined.yml build
        else
            docker-compose -f docker-compose.combined.yml build
        fi
        ;;
    "optimized"|"cached"|"default")
        if docker compose version &> /dev/null 2>&1; then
            docker compose build
        else
            docker-compose build
        fi
        ;;
esac

if [ $? -ne 0 ]; then
    echo "❌ 镜像构建失败"
    exit 1
fi

echo "🚀 启动服务..."
case $CONFIG in
    "combined")
        if docker compose version &> /dev/null 2>&1; then
            docker compose -f docker-compose.combined.yml up -d
        else
            docker-compose -f docker-compose.combined.yml up -d
        fi
        ;;
    "optimized")
        if docker compose version &> /dev/null 2>&1; then
            docker compose -f docker-compose.optimized.yml up -d
        else
            docker-compose -f docker-compose.optimized.yml up -d
        fi
        ;;
    "cached")
        if docker compose version &> /dev/null 2>&1; then
            docker compose -f docker-compose.optimized-with-rules-cache.yml up -d
        else
            docker-compose -f docker-compose.optimized-with-rules-cache.yml up -d
        fi
        ;;
    *)
        if docker compose version &> /dev/null 2>&1; then
            docker compose up -d
        else
            docker-compose up -d
        fi
        ;;
esac

if [ $? -ne 0 ]; then
    echo "❌ 服务启动失败"
    exit 1
fi

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo "🔍 检查服务状态..."
case $CONFIG in
    "combined")
        if docker compose version &> /dev/null 2>&1; then
            docker compose -f docker-compose.combined.yml ps
        else
            docker-compose -f docker-compose.combined.yml ps
        fi
        ;;
    "optimized")
        if docker compose version &> /dev/null 2>&1; then
            docker compose -f docker-compose.optimized.yml ps
        else
            docker-compose -f docker-compose.optimized.yml ps
        fi
        ;;
    "cached")
        if docker compose version &> /dev/null 2>&1; then
            docker compose -f docker-compose.optimized-with-rules-cache.yml ps
        else
            docker-compose -f docker-compose.optimized-with-rules-cache.yml ps
        fi
        ;;
    *)
        if docker compose version &> /dev/null 2>&1; then
            docker compose ps
        else
            docker-compose ps
        fi
        ;;
esac

# 检查服务是否可访问
echo "🔍 检查服务..."
max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
    case $CONFIG in
        "combined")
            if curl -s -f http://localhost:3000/api/rules/statistics > /dev/null 2>&1; then
                echo "✅ 服务启动成功"
                break
            fi
            ;;
        *)
            if curl -s -f http://localhost:8080/api/rules/statistics > /dev/null 2>&1; then
                echo "✅ 后端API启动成功"
                break
            fi
            ;;
    esac
    
    if [ $attempt -eq $max_attempts ]; then
        echo "❌ 服务启动超时，请检查日志"
        case $CONFIG in
            "combined")
                echo "查看日志: docker-compose -f docker-compose.combined.yml logs"
                ;;
            "optimized")
                echo "查看日志: docker-compose -f docker-compose.optimized.yml logs"
                ;;
            "cached")
                echo "查看日志: docker-compose -f docker-compose.optimized-with-rules-cache.yml logs"
                ;;
            *)
                echo "查看日志: docker-compose logs backend"
                ;;
        esac
        exit 1
    fi
    
    echo "   等待服务启动... ($attempt/$max_attempts)"
    sleep 2
    ((attempt++))
done

# 检查前端是否可访问
echo "🔍 检查前端服务..."
case $CONFIG in
    "combined")
        if curl -s -f http://localhost:3000 > /dev/null 2>&1; then
            echo "✅ 前端服务启动成功"
        else
            echo "⚠️  前端服务可能还在启动中，请稍后访问"
        fi
        ;;
    *)
        if curl -s -f http://localhost:3000 > /dev/null 2>&1; then
            echo "✅ 前端服务启动成功"
        else
            echo "⚠️  前端服务可能还在启动中，请稍后访问"
        fi
        ;;
esac

echo ""
echo "🎉 AdGuard域名查询服务启动完成! (Docker版本)"
echo ""
echo "📍 服务地址:"
case $CONFIG in
    "combined")
        echo "   统一访问: http://localhost:3000"
        echo "   API接口: http://localhost:3000/api"
        echo "   API文档: http://localhost:3000/docs"
        ;;
    *)
        echo "   前端页面: http://localhost:3000"
        echo "   后端API: http://localhost:8080/api"
        echo "   API文档: http://localhost:8080/docs"
        ;;
esac
echo ""
echo "🐳 Docker Management Commands:"
case $CONFIG in
    "combined")
        echo "   View status:  docker compose -f docker-compose.combined.yml ps"
        echo "   View logs:    docker compose -f docker-compose.combined.yml logs -f"
        echo "   Stop service: docker compose -f docker-compose.combined.yml down"
        echo "   Restart:      docker compose -f docker-compose.combined.yml restart"
        ;;
    "optimized")
        echo "   View status:  docker compose -f docker-compose.optimized.yml ps"
        echo "   View logs:    docker compose -f docker-compose.optimized.yml logs -f"
        echo "   Stop service: docker compose -f docker-compose.optimized.yml down"
        echo "   Restart:      docker compose -f docker-compose.optimized.yml restart"
        ;;
    "cached")
        echo "   View status:  docker compose -f docker-compose.optimized-with-rules-cache.yml ps"
        echo "   View logs:    docker compose -f docker-compose.optimized-with-rules-cache.yml logs -f"
        echo "   Stop service: docker compose -f docker-compose.optimized-with-rules-cache.yml down"
        echo "   Restart:      docker compose -f docker-compose.optimized-with-rules-cache.yml restart"
        ;;
    *)
        echo "   View status:  docker compose ps"
        echo "   View logs:    docker compose logs -f"
        echo "   Stop service: docker compose down"
        echo "   Restart:      docker compose restart"
        ;;
esac
echo ""
echo "🧪 Testing Commands:"
echo "   Full test:    ./scripts/testing/final_test.sh"
echo "   Basic test:   ./scripts/testing/test_api.sh"
echo "   Quick test:   python3 scripts/testing/quick_test.py"
echo ""
echo "💡 Tips:"
echo "   - First startup may take a few minutes to download rules"
echo "   - Data is persisted in Docker volumes"
echo "   - Customize configuration by editing .env file"
echo "   - Use --combined flag for single container mode"
echo "   - Use --optimized flag for optimized configuration"
echo "   - Use --cached flag for rule caching configuration"
echo ""
echo "📚 Documentation: See docs/README.md for complete guides"