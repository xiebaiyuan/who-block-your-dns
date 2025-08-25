#!/bin/bash

# AdGuard域名查询服务启动脚本

echo "🚀 启动AdGuard域名查询服务..."

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "❌ 错误: 未找到Java运行环境，请安装Java 17或更高版本"
    exit 1
fi

# 检查Maven环境
if ! command -v mvn &> /dev/null; then
    echo "❌ 错误: 未找到Maven，请安装Maven"
    exit 1
fi

# 启动后端服务
echo "📦 编译并启动后端服务..."
cd backend

# 清理并编译项目
mvn clean compile

if [ $? -ne 0 ]; then
    echo "❌ 后端编译失败"
    exit 1
fi

# 后台启动Spring Boot应用
nohup mvn spring-boot:run > ../logs/backend.log 2>&1 &
BACKEND_PID=$!

echo "🎯 后端服务已启动 (PID: $BACKEND_PID)"
echo "📝 后端日志: logs/backend.log"

# 等待后端服务启动
echo "⏳ 等待后端服务启动..."
sleep 10

# 检查后端服务是否启动成功
if curl -s http://localhost:8080/api/rules/statistics > /dev/null; then
    echo "✅ 后端服务启动成功: http://localhost:8080/api"
else
    echo "❌ 后端服务启动失败，请查看日志文件"
    exit 1
fi

# 回到项目根目录
cd ..

# 启动前端服务
echo "🌐 启动前端服务..."
cd frontend

# 检查Python3是否可用
if command -v python3 &> /dev/null; then
    echo "🐍 使用Python3启动前端服务..."
    nohup python3 -m http.server 3000 > ../logs/frontend.log 2>&1 &
    FRONTEND_PID=$!
    echo "🎯 前端服务已启动 (PID: $FRONTEND_PID)"
elif command -v python &> /dev/null; then
    echo "🐍 使用Python启动前端服务..."
    nohup python -m http.server 3000 > ../logs/frontend.log 2>&1 &
    FRONTEND_PID=$!
    echo "🎯 前端服务已启动 (PID: $FRONTEND_PID)"
else
    echo "⚠️  未找到Python，请手动启动前端服务"
    echo "   方式1: cd frontend && python3 -m http.server 3000"
    echo "   方式2: cd frontend && npx http-server -p 3000"
    echo "   方式3: 使用任何Web服务器托管frontend目录"
fi

echo ""
echo "🎉 AdGuard域名查询服务启动完成!"
echo ""
echo "📍 服务地址:"
echo "   后端API: http://localhost:8080/api"
echo "   前端页面: http://localhost:3000"
echo ""
echo "📋 进程信息:"
echo "   后端PID: $BACKEND_PID"
if [ ! -z "$FRONTEND_PID" ]; then
    echo "   前端PID: $FRONTEND_PID"
fi
echo ""
echo "📝 日志文件:"
echo "   后端日志: logs/backend.log"
echo "   前端日志: logs/frontend.log"
echo ""
echo "🛑 停止服务:"
echo "   kill $BACKEND_PID"
if [ ! -z "$FRONTEND_PID" ]; then
    echo "   kill $FRONTEND_PID"
fi
echo ""
echo "💡 提示: 首次启动可能需要几分钟来下载和缓存规则..."

# 保存PID到文件，方便后续停止
echo $BACKEND_PID > backend.pid
if [ ! -z "$FRONTEND_PID" ]; then
    echo $FRONTEND_PID > frontend.pid
fi
