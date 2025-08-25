#!/usr/bin/env python3
"""
AdGuard域名查询API测试脚本
测试各种域名匹配和正则匹配功能
"""

import requests
import json
import time
from typing import List, Dict, Any

# API 基础URL
BASE_URL = "http://localhost:8080"

class APITester:
    def __init__(self, base_url: str = BASE_URL):
        self.base_url = base_url
        self.session = requests.Session()
        self.test_results = []
        
    def print_header(self, title: str):
        """打印测试标题"""
        print(f"\n{'='*60}")
        print(f" {title}")
        print('='*60)
    
    def print_result(self, test_name: str, success: bool, details: str = ""):
        """打印测试结果"""
        status = "✅ PASS" if success else "❌ FAIL" 
        print(f"{status} {test_name}")
        if details:
            print(f"      {details}")
            
    def test_statistics_api(self):
        """测试统计API"""
        self.print_header("测试统计API")
        
        try:
            response = self.session.get(f"{self.base_url}/api/rules/statistics")
            if response.status_code == 200:
                stats = response.json()
                print(f"📊 统计信息:")
                print(f"   域名规则: {stats['domain_rules']:,} 条")
                print(f"   正则规则: {stats['regex_rules']:,} 条") 
                print(f"   Hosts规则: {stats['hosts_rules']:,} 条")
                print(f"   总规则源: {stats['total_sources']} 个")
                self.print_result("统计API", True)
                return True
            else:
                self.print_result("统计API", False, f"HTTP {response.status_code}")
                return False
        except Exception as e:
            self.print_result("统计API", False, str(e))
            return False
    
    def test_rule_sources_api(self):
        """测试规则源列表API"""
        self.print_header("测试规则源列表API")
        
        try:
            response = self.session.get(f"{self.base_url}/api/rules/sources")
            if response.status_code == 200:
                sources = response.json()
                print(f"📋 规则源列表 (前5个):")
                for i, source in enumerate(sources[:5]):
                    print(f"   {i+1}. {source['name']} - {source['url']}")
                    print(f"      规则数: {source['rule_count']}, 状态: {source['status']}")
                self.print_result("规则源列表API", True, f"共{len(sources)}个规则源")
                return True
            else:
                self.print_result("规则源列表API", False, f"HTTP {response.status_code}")
                return False
        except Exception as e:
            self.print_result("规则源列表API", False, str(e))
            return False
    
    def test_domain_queries(self):
        """测试域名查询功能"""
        self.print_header("测试域名查询功能")
        
        # 测试用例：应该被阻止的域名
        blocked_domains = [
            "doubleclick.net",           # 广告域名
            "googleadservices.com",      # Google广告服务
            "googlesyndication.com",     # Google广告联盟
            "facebook.com",              # 可能被某些规则阻止
            "ads.yahoo.com",             # Yahoo广告
            "googletagmanager.com",      # Google标签管理器
            "google-analytics.com",      # Google分析
            "scorecardresearch.com",     # 分析跟踪
        ]
        
        # 测试用例：应该被允许的域名
        allowed_domains = [
            "github.com",
            "stackoverflow.com", 
            "developer.mozilla.org",
            "docs.python.org",
            "www.wikipedia.org",
            "news.ycombinator.com",
        ]
        
        print("🚫 测试被阻止的域名:")
        blocked_count = 0
        for domain in blocked_domains:
            try:
                response = self.session.get(f"{self.base_url}/api/rules/query", 
                                          params={"domain": domain})
                if response.status_code == 200:
                    result = response.json()
                    matched = result.get('matched', False)
                    matched_rule = result.get('matched_rule', '')
                    rule_type = result.get('rule_type', '')
                    
                    if matched:
                        blocked_count += 1
                        self.print_result(f"域名 {domain}", True, 
                                        f"匹配规则: {matched_rule[:50]}... (类型: {rule_type})")
                    else:
                        self.print_result(f"域名 {domain}", False, "未被阻止")
                else:
                    self.print_result(f"域名 {domain}", False, f"HTTP {response.status_code}")
            except Exception as e:
                self.print_result(f"域名 {domain}", False, str(e))
        
        print(f"\n✅ 允许的域名:")
        allowed_count = 0
        for domain in allowed_domains:
            try:
                response = self.session.get(f"{self.base_url}/api/rules/query", 
                                          params={"domain": domain})
                if response.status_code == 200:
                    result = response.json()
                    matched = result.get('matched', False)
                    
                    if not matched:
                        allowed_count += 1
                        self.print_result(f"域名 {domain}", True, "正确允许")
                    else:
                        matched_rule = result.get('matched_rule', '')
                        self.print_result(f"域名 {domain}", False, f"被阻止: {matched_rule[:50]}...")
                else:
                    self.print_result(f"域名 {domain}", False, f"HTTP {response.status_code}")
            except Exception as e:
                self.print_result(f"域名 {domain}", False, str(e))
        
        print(f"\n📈 域名查询统计:")
        print(f"   阻止域名: {blocked_count}/{len(blocked_domains)}")
        print(f"   允许域名: {allowed_count}/{len(allowed_domains)}")
        
        return True
    
    def test_subdomain_matching(self):
        """测试子域名匹配"""
        self.print_header("测试子域名匹配功能")
        
        # 测试子域名匹配
        test_cases = [
            # 主域名及其子域名
            ("doubleclick.net", "主域名"),
            ("www.doubleclick.net", "www子域名"),
            ("stats.doubleclick.net", "stats子域名"),
            ("ad.doubleclick.net", "ad子域名"),
            
            # Google Analytics相关
            ("google-analytics.com", "GA主域名"),
            ("ssl.google-analytics.com", "SSL子域名"),
            ("www.google-analytics.com", "www子域名"),
            
            # 更深层的子域名
            ("tracking.ads.doubleclick.net", "多级子域名"),
        ]
        
        for domain, description in test_cases:
            try:
                response = self.session.get(f"{self.base_url}/api/rules/query", 
                                          params={"domain": domain})
                if response.status_code == 200:
                    result = response.json()
                    matched = result.get('matched', False)
                    matched_rule = result.get('matched_rule', '')
                    rule_type = result.get('rule_type', '')
                    
                    if matched:
                        self.print_result(f"{description} ({domain})", True, 
                                        f"匹配: {matched_rule[:40]}... (类型: {rule_type})")
                    else:
                        self.print_result(f"{description} ({domain})", False, "未匹配")
                else:
                    self.print_result(f"{description} ({domain})", False, f"HTTP {response.status_code}")
            except Exception as e:
                self.print_result(f"{description} ({domain})", False, str(e))
        
        return True
    
    def test_batch_query(self):
        """测试批量查询功能"""
        self.print_header("测试批量查询功能")
        
        domains = [
            "doubleclick.net",
            "github.com", 
            "googleadservices.com",
            "stackoverflow.com",
            "google-analytics.com"
        ]
        
        try:
            response = self.session.post(f"{self.base_url}/api/rules/batch-query", 
                                       json={"domains": domains})
            if response.status_code == 200:
                results = response.json()
                print(f"📦 批量查询结果:")
                
                for result in results['results']:
                    domain = result['domain']
                    matched = result['matched']
                    status = "🚫 阻止" if matched else "✅ 允许"
                    matched_rule = result.get('matched_rule', '')
                    rule_preview = matched_rule[:30] + "..." if len(matched_rule) > 30 else matched_rule
                    
                    print(f"   {status} {domain}")
                    if matched and matched_rule:
                        print(f"        规则: {rule_preview}")
                
                self.print_result("批量查询", True, f"查询了{len(domains)}个域名")
                return True
            else:
                self.print_result("批量查询", False, f"HTTP {response.status_code}")
                return False
        except Exception as e:
            self.print_result("批量查询", False, str(e))
            return False
    
    def test_edge_cases(self):
        """测试边界情况"""
        self.print_header("测试边界情况")
        
        edge_cases = [
            # 空域名
            ("", "空域名"),
            # 无效域名格式
            ("invalid..domain", "无效域名格式"),
            # 很长的域名
            ("a" * 100 + ".example.com", "超长域名"),
            # 特殊字符
            ("test-domain.com", "包含连字符的域名"),
            ("test_domain.com", "包含下划线的域名"),
            # IP地址
            ("192.168.1.1", "IP地址"),
            ("::1", "IPv6地址"),
            # 国际化域名
            ("例子.测试", "中文域名"),
        ]
        
        for domain, description in edge_cases:
            try:
                response = self.session.get(f"{self.base_url}/api/rules/query", 
                                          params={"domain": domain})
                
                if response.status_code == 200:
                    result = response.json()
                    self.print_result(f"{description}", True, f"返回正常结果")
                elif response.status_code == 422:
                    self.print_result(f"{description}", True, "正确返回验证错误")
                else:
                    self.print_result(f"{description}", False, f"HTTP {response.status_code}")
                    
            except Exception as e:
                self.print_result(f"{description}", False, str(e))
        
        return True
    
    def test_performance(self):
        """测试性能"""
        self.print_header("测试查询性能")
        
        test_domains = [
            "doubleclick.net",
            "github.com",
            "google.com", 
            "facebook.com",
            "amazon.com"
        ]
        
        total_time = 0
        successful_queries = 0
        
        print("🏃 执行性能测试...")
        
        for i in range(10):  # 执行10次查询
            for domain in test_domains:
                try:
                    start_time = time.time()
                    response = self.session.get(f"{self.base_url}/api/rules/query", 
                                              params={"domain": domain})
                    end_time = time.time()
                    
                    if response.status_code == 200:
                        query_time = end_time - start_time
                        total_time += query_time
                        successful_queries += 1
                        
                except Exception:
                    pass
        
        if successful_queries > 0:
            avg_time = (total_time / successful_queries) * 1000  # 转换为毫秒
            self.print_result("性能测试", True, 
                            f"平均查询时间: {avg_time:.2f}ms (共{successful_queries}次查询)")
        else:
            self.print_result("性能测试", False, "无法完成查询")
        
        return True
    
    def test_rule_update_api(self):
        """测试规则更新API"""
        self.print_header("测试规则更新功能")
        
        try:
            print("🔄 触发规则更新...")
            response = self.session.post(f"{self.base_url}/api/rules/update")
            
            if response.status_code == 200:
                result = response.json()
                self.print_result("规则更新触发", True, result.get('message', ''))
                return True
            else:
                self.print_result("规则更新触发", False, f"HTTP {response.status_code}")
                return False
                
        except Exception as e:
            self.print_result("规则更新触发", False, str(e))
            return False
    
    def run_all_tests(self):
        """运行所有测试"""
        print("🚀 开始AdGuard域名查询API测试")
        print(f"🎯 目标服务器: {self.base_url}")
        
        # 运行各项测试
        tests = [
            self.test_statistics_api,
            self.test_rule_sources_api, 
            self.test_domain_queries,
            self.test_subdomain_matching,
            self.test_batch_query,
            self.test_edge_cases,
            self.test_performance,
            # self.test_rule_update_api,  # 注释掉，避免频繁更新
        ]
        
        passed = 0
        total = len(tests)
        
        for test in tests:
            try:
                if test():
                    passed += 1
            except Exception as e:
                print(f"❌ 测试执行失败: {e}")
        
        # 最终报告
        self.print_header("测试报告")
        print(f"📊 测试完成: {passed}/{total} 通过")
        
        if passed == total:
            print("🎉 所有测试通过！")
        else:
            print(f"⚠️  有 {total - passed} 个测试失败")
        
        return passed == total

def main():
    """主函数"""
    print("AdGuard域名查询API测试工具")
    print("=" * 60)
    
    # 检查服务是否可用
    try:
        response = requests.get(f"{BASE_URL}/api/rules/statistics", timeout=5)
        if response.status_code != 200:
            print(f"❌ 服务不可用: HTTP {response.status_code}")
            print(f"请确保后端服务运行在 {BASE_URL}")
            return
    except Exception as e:
        print(f"❌ 无法连接到服务: {e}")
        print(f"请确保后端服务运行在 {BASE_URL}")
        return
    
    # 运行测试
    tester = APITester()
    success = tester.run_all_tests()
    
    if success:
        exit(0)
    else:
        exit(1)

if __name__ == "__main__":
    main()
