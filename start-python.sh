#!/bin/bash

# AdGuard域名查询服务 - Python版本启动脚本

echo "🐍 启动AdGuard域名查询服务 (Python版本)..."

# 检查Python环境
if ! command -v python3 &> /dev/null; then
    echo "❌ 错误: 未找到Python3，请安装Python 3.8或更高版本"
    exit 1
fi

echo "🔍 检测到Python版本:"
python3 --version

# 进入Python后端目录
cd "$(dirname "$0")/backend-python"

# 检查并创建虚拟环境
if [ ! -d "venv" ]; then
    echo "📦 创建Python虚拟环境..."
    python3 -m venv venv
fi

# 激活虚拟环境
echo "🔄 激活虚拟环境..."
source venv/bin/activate

# 升级pip
pip install --upgrade pip

# 安装依赖包
echo "📥 安装依赖包..."
pip install -r requirements.txt

# 创建日志目录
mkdir -p logs

# 启动后端服务
echo "🚀 启动Python后端服务..."
python3 main.py &
BACKEND_PID=$!

echo "🎯 Python后端服务已启动 (PID: $BACKEND_PID)"
echo "📝 后端日志: backend-python/logs/backend.log"

# 等待后端服务启动
echo "⏳ 等待后端服务启动..."
sleep 5

# 检查后端服务是否启动成功
if curl -s http://localhost:8080/api/rules/statistics > /dev/null; then
    echo "✅ 后端服务启动成功: http://localhost:8080/api"
else
    echo "❌ 后端服务启动失败，正在重试..."
    sleep 5
    if curl -s http://localhost:8080/api/rules/statistics > /dev/null; then
        echo "✅ 后端服务启动成功: http://localhost:8080/api"
    else
        echo "❌ 后端服务启动失败，请查看日志文件"
        kill $BACKEND_PID 2>/dev/null
        exit 1
    fi
fi

# 回到项目根目录
cd ..

# 启动前端服务
echo "🌐 启动前端服务..."
cd frontend

# 检查Python3是否可用启动HTTP服务器
if command -v python3 &> /dev/null; then
    echo "🐍 使用Python3启动前端服务..."
        # 显式绑定到 0.0.0.0，避免只绑定到 IPv6 本地回环 (::1)
        python3 -m http.server 3000 --bind 0.0.0.0 > ../logs/frontend.log 2>&1 &
    FRONTEND_PID=$!
    echo "🎯 前端服务已启动 (PID: $FRONTEND_PID)"
elif command -v python &> /dev/null; then
    echo "🐍 使用Python启动前端服务..."
        python -m http.server 3000 --bind 0.0.0.0 > ../logs/frontend.log 2>&1 &
    FRONTEND_PID=$!
    echo "🎯 前端服务已启动 (PID: $FRONTEND_PID)"
else
    echo "⚠️  未找到Python，请手动启动前端服务"
    echo "   方式1: cd frontend && python3 -m http.server 3000"
    echo "   方式2: cd frontend && npx http-server -p 3000"
    echo "   方式3: 使用任何Web服务器托管frontend目录"
fi

echo ""
echo "🎉 AdGuard域名查询服务启动完成! (Python版本)"
echo ""
echo "📍 服务地址:"
echo "   后端API: http://localhost:8080/api"
echo "   前端页面: http://localhost:3000"
echo "   API文档: http://localhost:8080/docs"
echo ""
echo "📋 进程信息:"
echo "   后端PID: $BACKEND_PID"
if [ ! -z "$FRONTEND_PID" ]; then
    echo "   前端PID: $FRONTEND_PID"
fi
echo ""
echo "📝 日志文件:"
echo "   后端日志: backend-python/logs/backend.log"
echo "   前端日志: logs/frontend.log"
echo ""
echo "🛑 停止服务:"
echo "   kill $BACKEND_PID"
if [ ! -z "$FRONTEND_PID" ]; then
    echo "   kill $FRONTEND_PID"
fi
echo ""
echo "🧪 Testing Commands:"
echo "   Full test:    ./scripts/testing/final_test.sh"
echo "   Basic test:   ./scripts/testing/test_api.sh"
echo "   Quick test:   python3 scripts/testing/quick_test.py"
echo ""
echo "💡 Tips:"
echo "   - First startup may take a few minutes to download and cache rules"
echo "   - Visit http://localhost:8080/docs for interactive API documentation"
echo "   - Python version starts faster with fewer dependencies"
echo ""
echo "📚 Documentation: See docs/README.md for complete guides"

# 保存PID到文件
echo $BACKEND_PID > backend-python.pid
if [ ! -z "$FRONTEND_PID" ]; then
    echo $FRONTEND_PID > frontend.pid
fi
