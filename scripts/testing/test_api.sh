#!/bin/bash

echo "🚀 AdGuard API 测试脚本"
echo "========================"

# 设置API基础URL
BASE_URL="http://localhost:8080"

# 测试统计API
echo ""
echo "📊 测试统计API..."
curl -s "$BASE_URL/api/rules/statistics" | jq '.' 2>/dev/null || curl -s "$BASE_URL/api/rules/statistics"

# 测试域名查询API
echo ""
echo "🔍 测试域名查询..."

# 测试应该被阻止的域名
echo ""
echo "🚫 测试广告域名 (应该被阻止):"
domains_to_block=("doubleclick.net" "googleadservices.com" "google-analytics.com" "googlesyndication.com" "facebook.com")

for domain in "${domains_to_block[@]}"; do
    echo "   查询: $domain"
    result=$(curl -s "$BASE_URL/api/query/domain?domain=$domain")
    echo "   原始响应: $result"
    if echo "$result" | jq -e '.data.matched == true' >/dev/null 2>&1; then
        echo "   ✅ 正确阻止"
        echo "$result" | jq -r '.data.matched_rule' 2>/dev/null | head -c 50
        echo "..."
    else
        echo "   ❌ 未被阻止"
    fi
    echo ""
done

# 测试应该被允许的域名
echo ""
echo "✅ 测试正常域名 (应该被允许):"
domains_to_allow=("github.com" "stackoverflow.com" "developer.mozilla.org" "docs.python.org")

for domain in "${domains_to_allow[@]}"; do
    echo "   查询: $domain"
    result=$(curl -s "$BASE_URL/api/query/domain?domain=$domain")
    echo "   原始响应: $result"
    if echo "$result" | jq -e '.data.matched == false' >/dev/null 2>&1; then
        echo "   ✅ 正确允许"
    else
        echo "   ❌ 被误阻止"
        echo "$result" | jq -r '.data.matched_rule' 2>/dev/null | head -c 50
        echo "..."
    fi
    echo ""
done

# 测试子域名匹配
echo ""
echo "🌐 测试子域名匹配:"
subdomains=("www.doubleclick.net" "stats.doubleclick.net" "ssl.google-analytics.com")

for domain in "${subdomains[@]}"; do
    echo "   查询: $domain"
    result=$(curl -s "$BASE_URL/api/query/domain?domain=$domain")
    if echo "$result" | jq -e '.data.matched == true' >/dev/null 2>&1; then
        echo "   ✅ 子域名正确匹配"
    else
        echo "   ❌ 子域名未匹配"
    fi
    echo ""
done

# 测试批量查询
echo ""
echo "📦 测试批量查询..."
batch_data='{"domains": ["doubleclick.net", "github.com", "google-analytics.com", "stackoverflow.com"]}'
echo "   发送批量查询..."
curl -s -X POST -H "Content-Type: application/json" -d "$batch_data" "$BASE_URL/api/query/domains" | jq '.' 2>/dev/null || curl -s -X POST -H "Content-Type: application/json" -d "$batch_data" "$BASE_URL/api/query/domains"

# 测试规则源列表
echo ""
echo "📋 测试规则源列表 (前3个)..."
curl -s "$BASE_URL/api/rules/sources" | jq '.[:3]' 2>/dev/null || curl -s "$BASE_URL/api/rules/sources" | head -c 500

echo ""
echo "🎉 API测试完成!"
