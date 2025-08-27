#!/usr/bin/env python3
"""
快速API测试脚本
"""

import requests
import json

BASE_URL = "http://localhost:8080"

def test_basic_functionality():
    print("🚀 AdGuard API 快速测试")
    print("=" * 50)
    
    # 1. 测试统计API
    print("\n📊 测试统计API...")
    try:
        resp = requests.get(f"{BASE_URL}/api/rules/statistics")
        if resp.status_code == 200:
            result = resp.json()
            stats = result.get('data', {})
            print(f"✅ 统计API正常")
            print(f"   域名规则: {stats.get('domainRules', 0):,}")
            print(f"   正则规则: {stats.get('regexRules', 0):,}")
            print(f"   Hosts规则: {stats.get('hostsRules', 0):,}")
        else:
            print(f"❌ 统计API失败: {resp.status_code}")
    except Exception as e:
        print(f"❌ 统计API错误: {e}")
    
    # 2. 测试域名查询
    print("\n🔍 测试域名查询...")
    test_domains = [
        ("doubleclick.net", "应该被阻止"),
        ("github.com", "应该被允许"),
        ("googleadservices.com", "应该被阻止"),
        ("stackoverflow.com", "应该被允许"),
    ]
    
    for domain, expected in test_domains:
        try:
            resp = requests.get(f"{BASE_URL}/api/query/domain", params={"domain": domain})
            if resp.status_code == 200:
                result = resp.json()
                # 数据格式是数组 [ [key, value], [key, value], ... ]
                data = dict(result.get('data', []))
                matched = data.get('blocked', False)
                status = "🚫 阻止" if matched else "✅ 允许"
                print(f"   {status} {domain} ({expected})")
                if matched:
                    rule = data.get('matched_rule', '')[:50]
                    print(f"      匹配规则: {rule}...")
            else:
                print(f"   ❌ {domain} 查询失败: {resp.status_code}")
        except Exception as e:
            print(f"   ❌ {domain} 查询错误: {e}")
    
    # 3. 测试批量查询
    print("\n📦 测试批量查询...")
    try:
        domains = ["doubleclick.net", "github.com", "google-analytics.com"]
        resp = requests.post(f"{BASE_URL}/api/query/domains", json={"domains": domains})
        if resp.status_code == 200:
            result = resp.json()
            results = result.get('data', [])
            print("✅ 批量查询正常")
            for item in results:
                domain = item['domain']
                matched = item['blocked']
                status = "🚫" if matched else "✅"
                print(f"   {status} {domain}")
        else:
            print(f"❌ 批量查询失败: {resp.status_code}")
    except Exception as e:
        print(f"❌ 批量查询错误: {e}")
    
    print("\n🎉 测试完成!")

if __name__ == "__main__":
    test_basic_functionality()
