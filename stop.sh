#!/bin/bash

# AdGuard域名查询服务停止脚本

echo "🛑 停止AdGuard域名查询服务..."

# 停止后端服务
if [ -f "backend.pid" ]; then
    BACKEND_PID=$(cat backend.pid)
    if ps -p $BACKEND_PID > /dev/null 2>&1; then
        echo "🎯 停止后端服务 (PID: $BACKEND_PID)..."
        kill $BACKEND_PID
        
        # 等待进程停止
        sleep 3
        
        # 如果进程仍在运行，强制杀死
        if ps -p $BACKEND_PID > /dev/null 2>&1; then
            echo "⚠️  强制停止后端服务..."
            kill -9 $BACKEND_PID
        fi
        
        echo "✅ 后端服务已停止"
    else
        echo "⚠️  后端服务进程不存在 (PID: $BACKEND_PID)"
    fi
    rm -f backend.pid
else
    echo "⚠️  未找到后端服务PID文件"
fi

# 停止前端服务
if [ -f "frontend.pid" ]; then
    FRONTEND_PID=$(cat frontend.pid)
    if ps -p $FRONTEND_PID > /dev/null 2>&1; then
        echo "🌐 停止前端服务 (PID: $FRONTEND_PID)..."
        kill $FRONTEND_PID
        
        # 等待进程停止
        sleep 2
        
        # 如果进程仍在运行，强制杀死
        if ps -p $FRONTEND_PID > /dev/null 2>&1; then
            echo "⚠️  强制停止前端服务..."
            kill -9 $FRONTEND_PID
        fi
        
        echo "✅ 前端服务已停止"
    else
        echo "⚠️  前端服务进程不存在 (PID: $FRONTEND_PID)"
    fi
    rm -f frontend.pid
else
    echo "⚠️  未找到前端服务PID文件"
fi

# 额外检查并停止可能遗留的Java进程
echo "🔍 检查遗留的Java进程..."
JAVA_PIDS=$(ps aux | grep "adguard-query-service" | grep -v grep | awk '{print $2}')
if [ ! -z "$JAVA_PIDS" ]; then
    echo "🎯 发现遗留的Java进程，正在停止..."
    echo $JAVA_PIDS | xargs kill
    sleep 2
    
    # 强制杀死仍在运行的进程
    JAVA_PIDS=$(ps aux | grep "adguard-query-service" | grep -v grep | awk '{print $2}')
    if [ ! -z "$JAVA_PIDS" ]; then
        echo "⚠️  强制停止遗留进程..."
        echo $JAVA_PIDS | xargs kill -9
    fi
fi

# 检查并停止可能遗留的Python HTTP服务器
echo "🔍 检查遗留的Python HTTP服务器进程..."
PYTHON_PIDS=$(ps aux | grep "python.*http.server.*3000" | grep -v grep | awk '{print $2}')
if [ ! -z "$PYTHON_PIDS" ]; then
    echo "🐍 发现遗留的Python HTTP服务器进程，正在停止..."
    echo $PYTHON_PIDS | xargs kill
fi

echo ""
echo "🎉 AdGuard域名查询服务已完全停止!"
echo "📝 日志文件保留在 logs/ 目录中"
