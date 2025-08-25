#!/bin/bash

echo "🚀 AdGuard API 最终测试脚本"
echo "========================"

# 设置API基础URL
BASE_URL="http://localhost:8080"

# 测试统计API
echo ""
echo "📊 测试统计API..."
curl -s "$BASE_URL/api/rules/statistics" | jq '.'

# 测试域名查询API
echo ""
echo "🔍 测试域名查询..."

# 解析返回数据的函数(返回格式是二维数组)
parse_blocked_status() {
    echo "$1" | jq -r '.data | if type == "array" then (.[1][1] // false) else .blocked end'
}

parse_rule() {
    echo "$1" | jq -r '.data | if type == "array" then (.[2][1] // "null") else .matched_rule end'
}

# 测试应该被阻止的域名
echo ""
echo "🚫 测试广告域名 (应该被阻止):"
domains_to_block=("doubleclick.net" "googleadservices.com" "google-analytics.com" "googlesyndication.com")

blocked_count=0
total_block_tests=${#domains_to_block[@]}

for domain in "${domains_to_block[@]}"; do
    echo "   查询: $domain"
    result=$(curl -s "$BASE_URL/api/query/domain?domain=$domain")
    blocked=$(parse_blocked_status "$result")
    rule=$(parse_rule "$result")
    
    if [ "$blocked" = "true" ]; then
        echo "   ✅ 正确阻止 - 匹配规则: $rule"
        ((blocked_count++))
    else
        echo "   ❌ 未被阻止"
    fi
done

# 测试应该被允许的域名
echo ""
echo "✅ 测试正常域名 (应该被允许):"
domains_to_allow=("github.com" "stackoverflow.com" "developer.mozilla.org" "docs.python.org")

allowed_count=0
total_allow_tests=${#domains_to_allow[@]}

for domain in "${domains_to_allow[@]}"; do
    echo "   查询: $domain"
    result=$(curl -s "$BASE_URL/api/query/domain?domain=$domain")
    blocked=$(parse_blocked_status "$result")
    
    if [ "$blocked" = "false" ]; then
        echo "   ✅ 正确允许"
        ((allowed_count++))
    else
        rule=$(parse_rule "$result")
        echo "   ❌ 被误阻止 - 匹配规则: $rule"
    fi
done

# 测试子域名匹配
echo ""
echo "🌐 测试子域名匹配:"
subdomains=("www.doubleclick.net" "stats.doubleclick.net" "ssl.google-analytics.com")

subdomain_count=0
total_subdomain_tests=${#subdomains[@]}

for domain in "${subdomains[@]}"; do
    echo "   查询: $domain"
    result=$(curl -s "$BASE_URL/api/query/domain?domain=$domain")
    blocked=$(parse_blocked_status "$result")
    
    if [ "$blocked" = "true" ]; then
        rule=$(parse_rule "$result")
        echo "   ✅ 子域名正确匹配 - 规则: $rule"
        ((subdomain_count++))
    else
        echo "   ❌ 子域名未匹配"
    fi
done

# 测试特殊情况
echo ""
echo "🧪 测试特殊情况:"
special_cases=("facebook.com" "twitter.com" "instagram.com")

for domain in "${special_cases[@]}"; do
    echo "   查询: $domain"
    result=$(curl -s "$BASE_URL/api/query/domain?domain=$domain")
    blocked=$(parse_blocked_status "$result")
    
    if [ "$blocked" = "true" ]; then
        rule=$(parse_rule "$result")
        echo "   🚫 被阻止 - 规则: $rule"
    else
        echo "   ✅ 被允许"
    fi
done

# 测试批量查询
echo ""
echo "📦 测试批量查询..."
batch_data='{"domains": ["doubleclick.net", "github.com", "google-analytics.com", "stackoverflow.com"]}'
echo "   发送批量查询..."
batch_result=$(curl -s -X POST -H "Content-Type: application/json" -d "$batch_data" "$BASE_URL/api/query/domains")
echo "$batch_result" | jq '.data[] | "   " + (.domain) + ": " + (if .blocked then "🚫 阻止" else "✅ 允许" end)'

# 性能测试
echo ""
echo "⚡ 性能测试..."
echo "   执行10次查询测量平均响应时间..."

total_time=0
query_count=10

for i in $(seq 1 $query_count); do
    start_time=$(date +%s%N)
    curl -s "$BASE_URL/api/query/domain?domain=doubleclick.net" > /dev/null
    end_time=$(date +%s%N)
    duration=$(((end_time - start_time) / 1000000))  # 转换为毫秒
    total_time=$((total_time + duration))
done

avg_time=$((total_time / query_count))
echo "   平均响应时间: ${avg_time}ms"

# 最终统计
echo ""
echo "📊 测试统计结果:"
echo "   阻止域名测试: $blocked_count/$total_block_tests 通过"
echo "   允许域名测试: $allowed_count/$total_allow_tests 通过" 
echo "   子域名测试: $subdomain_count/$total_subdomain_tests 通过"

total_tests=$((total_block_tests + total_allow_tests + total_subdomain_tests))
passed_tests=$((blocked_count + allowed_count + subdomain_count))
success_rate=$(( (passed_tests * 100) / total_tests ))

echo "   总体通过率: $passed_tests/$total_tests ($success_rate%)"

if [ $success_rate -ge 80 ]; then
    echo "🎉 测试成功！AdGuard域名查询服务工作正常"
else
    echo "⚠️  部分测试失败，请检查规则配置"
fi

echo ""
echo "🎯 服务地址:"
echo "   后端API: http://localhost:8080"
echo "   前端界面: http://localhost:3000"
echo "   API文档: http://localhost:8080/docs"
