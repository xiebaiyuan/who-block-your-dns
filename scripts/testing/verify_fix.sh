#!/bin/bash

echo "🔍 验证前端修复结果"
echo "===================="

# 测试单个查询API
echo ""
echo "📍 测试 google-analytics.com 单个查询:"
result=$(curl -s "http://localhost:8080/api/query/domain?domain=google-analytics.com")
echo "API返回: $result"

# 提取blocked状态
blocked=$(echo "$result" | jq -r '.data[] | select(.[0]=="blocked") | .[1]')
echo "阻止状态: $blocked"

if [ "$blocked" = "true" ]; then
    echo "✅ google-analytics.com 确实被阻止了！"
    
    # 提取匹配规则
    rule=$(echo "$result" | jq -r '.data[] | select(.[0]=="matched_rule") | .[1]')
    source=$(echo "$result" | jq -r '.data[] | select(.[0]=="rule_source") | .[1]')
    echo "匹配规则: $rule"
    echo "规则源: $source"
else
    echo "❌ google-analytics.com 没有被阻止"
fi

echo ""
echo "📍 测试批量查询:"
batch_result=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"domains": ["google-analytics.com", "github.com"]}' \
    "http://localhost:8080/api/query/domains")

echo "批量API返回:"
echo "$batch_result" | jq '.'

echo ""
echo "🎯 前端修复要点:"
echo "1. 前端代码已添加parseResultData函数来处理二维数组格式"
echo "2. 单个查询返回二维数组格式: [[key, value], ...]"
echo "3. 批量查询返回对象数组格式: [{domain: '', blocked: true}, ...]"
echo "4. 现在前端应该能正确显示google-analytics.com被阻止的状态"

echo ""
echo "🌐 测试地址:"
echo "主前端: http://localhost:3000"
echo "测试页面: file:///$(pwd)/test_page.html"
