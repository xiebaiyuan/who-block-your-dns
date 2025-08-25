#!/bin/bash

echo "🚀 测试多规则匹配功能"
echo "========================"

BASE_URL="http://localhost:8080"

# 测试一些可能有多个匹配规则的域名
echo ""
echo "🔍 测试多规则匹配的域名:"

test_domains=("google-analytics.com" "doubleclick.net" "googleadservices.com" "googlesyndication.com")

for domain in "${test_domains[@]}"; do
    echo ""
    echo "📋 测试域名: $domain"
    echo "----------------------------------------"
    
    result=$(curl -s "$BASE_URL/api/query/domain?domain=$domain")
    
    # 解析并显示匹配的规则数量
    matched_rules_count=$(echo "$result" | jq -r '.data | map(select(.[0] == "matched_rules")) | .[0][1] | length')
    blocked=$(echo "$result" | jq -r '.data | map(select(.[0] == "blocked")) | .[0][1]')
    
    if [ "$blocked" = "true" ]; then
        echo "✅ 域名被阻止"
        echo "📊 匹配的规则数量: $matched_rules_count"
        echo ""
        echo "🗂️  匹配的规则详情:"
        echo "$result" | jq -r '.data | map(select(.[0] == "matched_rules")) | .[0][1][] | "   • \(.rule) (\(.rule_type)) - \(.rule_source)"'
    else
        echo "❌ 域名未被阻止"
    fi
    
    echo "----------------------------------------"
done

# 测试一个正常域名
echo ""
echo "✅ 测试正常域名 (应该没有匹配规则):"
normal_domain="github.com"
echo "📋 测试域名: $normal_domain"

result=$(curl -s "$BASE_URL/api/query/domain?domain=$normal_domain")
blocked=$(echo "$result" | jq -r '.data | map(select(.[0] == "blocked")) | .[0][1]')

if [ "$blocked" = "false" ]; then
    echo "✅ 域名正确被允许"
else
    echo "❌ 域名被错误阻止"
fi

echo ""
echo "🎉 多规则测试完成!"
echo ""
echo "💡 提示: 在网页界面 http://localhost:3000 中查询这些域名，"
echo "   应该能看到所有匹配的规则以不同颜色的标签显示。"
