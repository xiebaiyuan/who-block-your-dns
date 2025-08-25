import asyncio
import re
import time
import threading
from datetime import datetime
from typing import List, Dict, Optional, Set, Union, Any
from urllib.parse import urlparse
import logging

import requests
from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from cachetools import TTLCache
import schedule

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/backend.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# 创建FastAPI应用
app = FastAPI(
    title="AdGuard域名查询服务",
    description="查询域名是否被AdGuard规则阻止",
    version="1.0.0"
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 数据模型
class RuleSource(BaseModel):
    url: str
    name: str
    enabled: bool = True
    last_updated: Optional[int] = None
    rule_count: int = 0
    status: str = "未更新"

class MatchedRule(BaseModel):
    rule: str
    rule_source: str
    rule_source_url: str
    rule_type: str

class DomainQueryResult(BaseModel):
    domain: str
    blocked: bool
    matched_rules: List[MatchedRule] = []
    # 保留向后兼容性
    matched_rule: Optional[str] = None
    rule_source: Optional[str] = None
    rule_type: Optional[str] = None
    query_time: int
    duration: int

class ApiResponse(BaseModel):
    code: int
    message: str
    data: Optional[Union[Dict, List, str, int]] = None
    timestamp: int

class BulkQueryRequest(BaseModel):
    domains: List[str]

# 全局变量
domain_rules: Dict[str, Set[str]] = {}  # URL -> Set[domain]
regex_rules: Dict[str, Set[re.Pattern]] = {}  # URL -> Set[Pattern]
hosts_rules: Dict[str, Set[str]] = {}  # URL -> Set[domain]
rule_sources: Dict[str, RuleSource] = {}  # URL -> RuleSource
query_cache = TTLCache(maxsize=10000, ttl=3600)  # 1小时缓存

# 默认规则源配置
DEFAULT_RULE_SOURCES = [
    {
        "url": "https://raw.githubusercontent.com/durablenapkin/scamblocklist/refs/heads/master/adguard.txt",
        "name": "Scam Blocklist",
        "enabled": True
    },
    {
        "url": "https://someonewhocares.org/hosts/zero/hosts",
        "name": "Dan Pollock's List",
        "enabled": True
    },
    {
        "url": "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=adblockplus&showintro=1&mimetype=plaintext",
        "name": "Peter Lowe's List",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/refs/heads/master/data/hosts/spy.txt",
        "name": "WindowsSpyBlocker",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts",
        "name": "DaSheng Ad Clean",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt",
        "name": "AdGuard Base",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/AdguardTeam/cname-trackers/master/data/combined_disguised_trackers.txt",
        "name": "AdGuard CNAME disguised tracker list",
        "enabled": True
    },
    {
        "url": "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt",
        "name": "AdGuard DNS filter",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/Crystal-RainSlide/AdditionalFiltersCN/master/CN.txt",
        "name": "AdditionalFiltersCN",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/banbendalao/ADgk/master/ADgk.txt",
        "name": "ADgk mobile ad rules",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/rule.txt",
        "name": "ChengFeng ad filter rules",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/mv.txt",
        "name": "ChengFeng video filter rules",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/o0HalfLife0o/list/master/ad.txt",
        "name": "HalfLife merged rules",
        "enabled": True
    },
    {
        "url": "https://adaway.org/hosts.txt",
        "name": "AdAway official ad-blocking Host rules",
        "enabled": True
    },
    {
        "url": "https://easylist-downloads.adblockplus.org/antiadblockfilters.txt",
        "name": "Remove anti-adblock warning rules",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/Cats-Team/AdRules/main/dns.txt",
        "name": "XingShao AdRules DNS List",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/AdGuard/Advertising/Advertising.txt",
        "name": "AdGuard blackmatrix7 merged",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/zsakvo/AdGuard-Custom-Rule/master/rule/zhihu.txt",
        "name": "Zhihu standard version",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/timlu85/AdGuard-Home_Youtube-Adfilter/master/Youtube-Adfilter-Web.txt",
        "name": "Youtube-Adfilter-Web",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/AWAvenue-Ads-Rule.txt",
        "name": "Autumn Wind ad rules",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/ilxp/koolproxy/refs/heads/main/rules/adg.txt",
        "name": "koolproxy adg rules",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/ilxp/koolproxy/refs/heads/main/rules/antiad.txt",
        "name": "koolproxy antiad rules",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/uBlockOrigin/uAssets/refs/heads/master/filters/filters.txt",
        "name": "uBlock filters",
        "enabled": True
    },
    {
        "url": "https://ublockorigin.pages.dev/filters/badware.txt",
        "name": "uBlock filters – Badware risks",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/uBlockOrigin/uAssetsCDN/refs/heads/main/filters/privacy.min.txt",
        "name": "uBlock filters – Privacy",
        "enabled": True
    },
    {
        "url": "https://ublockorigin.github.io/uAssets/filters/quick-fixes.txt",
        "name": "uBlock filters – Quick fixes",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/uBlockOrigin/uAssets/refs/heads/master/filters/resource-abuse.txt",
        "name": "uBlock filters – Resource abuse",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/uBlockOrigin/uAssetsCDN/refs/heads/main/filters/unbreak.txt",
        "name": "uBlock filters – Unbreak",
        "enabled": True
    },
    {
        "url": "https://filters.adtidy.org/extension/ublock/filters/11.txt",
        "name": "AdGuard Mobile Ads",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/thhbdd/Block-pcdn-domains/refs/heads/main/ban.txt",
        "name": "Block PCDN domains",
        "enabled": True
    },
    {
        "url": "https://anti-ad.net/easylist.txt",
        "name": "anti-AD",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/refs/heads/master/discretion/pcdn.txt",
        "name": "anti-AD PCDN rules",
        "enabled": True
    },
    {
        "url": "https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/refs/heads/master/discretion/dns.txt",
        "name": "anti-AD httpdns",
        "enabled": True
    }
]

def is_valid_domain(domain: str) -> bool:
    """验证域名格式"""
    if not domain or not isinstance(domain, str):
        return False
    
    domain = domain.strip().lower()
    if not domain:
        return False
    
    # 基本的域名格式验证
    pattern = r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return (re.match(pattern, domain) and 
            not domain.startswith('.') and 
            not domain.endswith('.') and 
            '..' not in domain)

def parse_rules(source: RuleSource, content: str) -> tuple:
    """解析规则内容"""
    lines = content.split('\n')
    domains = set()
    regexes = set()
    hosts = set()
    rule_count = 0
    
    for line in lines:
        line = line.strip()
        
        # 跳过空行和注释
        if not line or line.startswith('#') or line.startswith('!'):
            continue
        
        try:
            # 处理AdGuard格式规则
            if line.startswith('||') and line.endswith('^'):
                # 域名规则: ||example.com^
                domain = line[2:-1].lower()
                if is_valid_domain(domain):
                    domains.add(domain)
                    rule_count += 1
            elif line.startswith('/') and line.endswith('/'):
                # 正则规则: /regex/
                regex_str = line[1:-1]
                try:
                    regex_pattern = re.compile(regex_str, re.IGNORECASE)
                    regexes.add(regex_pattern)
                    rule_count += 1
                except re.error:
                    logger.debug(f"无效正则表达式: {regex_str}")
            elif ' ' in line:
                # Hosts格式: 0.0.0.0 example.com
                parts = line.split()
                if len(parts) >= 2:
                    domain = parts[1].lower()
                    if is_valid_domain(domain):
                        hosts.add(domain)
                        rule_count += 1
            elif line.startswith('@@'):
                # 白名单规则，暂时跳过
                continue
            elif is_valid_domain(line):
                # 纯域名
                domains.add(line.lower())
                rule_count += 1
        except Exception as e:
            logger.debug(f"解析规则失败: {line} - {e}")
    
    return domains, regexes, hosts, rule_count

def update_rule_from_source(source: RuleSource):
    """从单个规则源更新规则"""
    try:
        logger.info(f"正在更新规则源: {source.name} - {source.url}")
        
        response = requests.get(source.url, timeout=60)
        response.raise_for_status()
        
        content = response.text
        if not content.strip():
            logger.warning(f"规则源内容为空: {source.url}")
            source.status = "内容为空"
            rule_sources[source.url] = source
            return
        
        domains, regexes, hosts, rule_count = parse_rules(source, content)
        
        # 存储规则
        if domains:
            domain_rules[source.url] = domains
        if regexes:
            regex_rules[source.url] = regexes
        if hosts:
            hosts_rules[source.url] = hosts
        
        source.rule_count = rule_count
        source.last_updated = int(time.time() * 1000)
        source.status = "更新成功"
        rule_sources[source.url] = source
        
        logger.info(f"规则源更新完成: {source.name} - 规则数: {rule_count}")
        
    except Exception as e:
        logger.error(f"更新规则源失败: {source.url} - {e}")
        source.status = f"更新失败: {str(e)}"
        rule_sources[source.url] = source

def update_all_rules():
    """更新所有规则"""
    logger.info("开始更新所有AdGuard规则...")
    
    for source_data in DEFAULT_RULE_SOURCES:
        if source_data["enabled"]:
            source = RuleSource(**source_data)
            update_rule_from_source(source)
    
    # 更新自定义规则源
    for source in list(rule_sources.values()):
        if source.enabled and source.url not in [s["url"] for s in DEFAULT_RULE_SOURCES]:
            update_rule_from_source(source)
    
    logger.info("规则更新完成")
    logger.info(f"域名规则源: {len(domain_rules)}, 总规则数: {sum(len(rules) for rules in domain_rules.values())}")
    logger.info(f"正则规则源: {len(regex_rules)}, 总规则数: {sum(len(rules) for rules in regex_rules.values())}")
    logger.info(f"Hosts规则源: {len(hosts_rules)}, 总规则数: {sum(len(rules) for rules in hosts_rules.values())}")

def query_domain_internal(domain: str) -> DomainQueryResult:
    """内部域名查询函数，支持返回多个匹配规则"""
    start_time = time.time()
    
    # 检查缓存
    cache_key = f"query:{domain.lower()}"
    cached_result = query_cache.get(cache_key)
    if cached_result:
        return cached_result
    
    result = DomainQueryResult(
        domain=domain,
        blocked=False,
        matched_rules=[],
        query_time=int(time.time() * 1000),
        duration=0
    )
    
    lower_domain = domain.lower()
    matched_rules = []
    
    # 1. 检查域名规则
    for source_url, domains in domain_rules.items():
        # 精确匹配
        if lower_domain in domains:
            matched_rules.append(MatchedRule(
                rule=lower_domain,
                rule_source=get_rule_source_name(source_url),
                rule_source_url=source_url,
                rule_type="domain"
            ))
        else:
            # 子域名匹配
            for rule_domain in domains:
                if lower_domain.endswith('.' + rule_domain):
                    matched_rules.append(MatchedRule(
                        rule=rule_domain,
                        rule_source=get_rule_source_name(source_url),
                        rule_source_url=source_url,
                        rule_type="domain"
                    ))
                    break  # 同一个源只匹配一个规则
    
    # 2. 检查Hosts规则
    for source_url, hosts in hosts_rules.items():
        if lower_domain in hosts:
            matched_rules.append(MatchedRule(
                rule=lower_domain,
                rule_source=get_rule_source_name(source_url),
                rule_source_url=source_url,
                rule_type="hosts"
            ))
        else:
            # 子域名匹配
            for host_domain in hosts:
                if lower_domain.endswith('.' + host_domain):
                    matched_rules.append(MatchedRule(
                        rule=host_domain,
                        rule_source=get_rule_source_name(source_url),
                        rule_source_url=source_url,
                        rule_type="hosts"
                    ))
                    break  # 同一个源只匹配一个规则
    
    # 3. 检查正则规则
    for source_url, patterns in regex_rules.items():
        for pattern in patterns:
            try:
                if pattern.search(lower_domain):
                    matched_rules.append(MatchedRule(
                        rule=pattern.pattern,
                        rule_source=get_rule_source_name(source_url),
                        rule_source_url=source_url,
                        rule_type="regex"
                    ))
                    break  # 同一个源只匹配一个正则规则
            except Exception as e:
                logger.debug(f"正则匹配错误: {pattern.pattern} - {e}")
    
    # 设置结果
    result.matched_rules = matched_rules
    result.blocked = len(matched_rules) > 0
    
    # 为了向后兼容，设置第一个匹配的规则
    if matched_rules:
        first_match = matched_rules[0]
        result.matched_rule = first_match.rule
        result.rule_source = first_match.rule_source
        result.rule_type = first_match.rule_type
    
    result.duration = int((time.time() - start_time) * 1000)
    
    # 缓存结果
    query_cache[cache_key] = result
    
    return result

def get_rule_source_name(url: str) -> str:
    """获取规则源名称"""
    source = rule_sources.get(url)
    return source.name if source else url

# 定时任务
def schedule_checker():
    """定时任务检查器"""
    while True:
        schedule.run_pending()
        time.sleep(60)

# 设置定时更新规则（每6小时）
schedule.every(6).hours.do(update_all_rules)

# API端点
@app.on_event("startup")
async def startup_event():
    """应用启动时初始化"""
    logger.info("启动AdGuard域名查询服务...")
    
    # 启动定时任务线程
    threading.Thread(target=schedule_checker, daemon=True).start()
    
    # 初始化规则源
    for source_data in DEFAULT_RULE_SOURCES:
        source = RuleSource(**source_data)
        rule_sources[source.url] = source
    
    # 后台更新规则
    threading.Thread(target=update_all_rules, daemon=True).start()

@app.get("/")
async def root():
    """根路径"""
    return {"message": "AdGuard域名查询服务正在运行", "version": "1.0.0"}

@app.get("/api/query/domain")
async def query_domain(domain: str):
    """查询单个域名"""
    try:
        if not domain or not domain.strip():
            raise HTTPException(status_code=400, detail="域名不能为空")
        
        clean_domain = domain.strip().lower()
        
        if not is_valid_domain(clean_domain):
            raise HTTPException(status_code=400, detail="域名格式不正确")
        
        result = query_domain_internal(clean_domain)
        
        return ApiResponse(
            code=200,
            message="查询成功",
            data=result,
            timestamp=int(time.time() * 1000)
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"查询域名失败: {domain} - {e}")
        raise HTTPException(status_code=500, detail=f"查询失败: {str(e)}")

@app.post("/api/query/domains")
async def query_domains(request: BulkQueryRequest):
    """批量查询域名"""
    try:
        domains = request.domains
        
        if not domains:
            raise HTTPException(status_code=400, detail="域名列表不能为空")
        
        if len(domains) > 100:
            raise HTTPException(status_code=400, detail="单次查询域名数量不能超过100个")
        
        results = []
        for domain in domains:
            if domain and domain.strip():
                clean_domain = domain.strip().lower()
                if is_valid_domain(clean_domain):
                    result = query_domain_internal(clean_domain)
                    results.append(result)
        
        return ApiResponse(
            code=200,
            message="批量查询成功",
            data=results,
            timestamp=int(time.time() * 1000)
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"批量查询域名失败: {e}")
        raise HTTPException(status_code=500, detail=f"批量查询失败: {str(e)}")

@app.get("/api/rules/sources")
async def get_rule_sources():
    """获取所有规则源"""
    try:
        sources = list(rule_sources.values())
        return ApiResponse(
            code=200,
            message="获取成功",
            data=sources,
            timestamp=int(time.time() * 1000)
        )
    except Exception as e:
        logger.error(f"获取规则源列表失败: {e}")
        raise HTTPException(status_code=500, detail=f"获取规则源列表失败: {str(e)}")

@app.post("/api/rules/sources")
async def add_rule_source(source: RuleSource, background_tasks: BackgroundTasks):
    """添加规则源"""
    try:
        if not source.url or not source.url.strip():
            raise HTTPException(status_code=400, detail="规则源URL不能为空")
        
        if not source.name or not source.name.strip():
            raise HTTPException(status_code=400, detail="规则源名称不能为空")
        
        # 添加到规则源列表
        rule_sources[source.url] = source
        
        # 如果启用，后台更新规则
        if source.enabled:
            background_tasks.add_task(update_rule_from_source, source)
        
        return ApiResponse(
            code=200,
            message="规则源添加成功",
            timestamp=int(time.time() * 1000)
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"添加规则源失败: {source.name if source else 'Unknown'} - {e}")
        raise HTTPException(status_code=500, detail=f"添加规则源失败: {str(e)}")

@app.delete("/api/rules/sources")
async def remove_rule_source(url: str):
    """删除规则源"""
    try:
        if not url or not url.strip():
            raise HTTPException(status_code=400, detail="规则源URL不能为空")
        
        # 从所有存储中删除
        domain_rules.pop(url, None)
        regex_rules.pop(url, None)
        hosts_rules.pop(url, None)
        rule_sources.pop(url, None)
        
        # 清理查询缓存
        query_cache.clear()
        
        return ApiResponse(
            code=200,
            message="规则源删除成功",
            timestamp=int(time.time() * 1000)
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"删除规则源失败: {url} - {e}")
        raise HTTPException(status_code=500, detail=f"删除规则源失败: {str(e)}")

@app.post("/api/rules/refresh")
async def refresh_rules(background_tasks: BackgroundTasks):
    """刷新所有规则"""
    try:
        # 清理缓存
        query_cache.clear()
        
        # 后台更新规则
        background_tasks.add_task(update_all_rules)
        
        return ApiResponse(
            code=200,
            message="规则刷新已开始，请稍后查看更新状态",
            timestamp=int(time.time() * 1000)
        )
    except Exception as e:
        logger.error(f"刷新规则失败: {e}")
        raise HTTPException(status_code=500, detail=f"刷新规则失败: {str(e)}")

@app.get("/api/rules/statistics")
async def get_statistics():
    """获取统计信息"""
    try:
        total_sources = len(rule_sources)
        enabled_sources = sum(1 for s in rule_sources.values() if s.enabled)
        domain_rule_count = sum(len(rules) for rules in domain_rules.values())
        regex_rule_count = sum(len(rules) for rules in regex_rules.values())
        hosts_rule_count = sum(len(rules) for rules in hosts_rules.values())
        
        last_update = 0
        if rule_sources:
            last_update = max(
                (s.last_updated or 0) for s in rule_sources.values()
            )
        
        stats = {
            "totalSources": total_sources,
            "enabledSources": enabled_sources,
            "domainRules": domain_rule_count,
            "regexRules": regex_rule_count,
            "hostsRules": hosts_rule_count,
            "lastUpdate": last_update,
            "cacheSize": len(query_cache)
        }
        
        return ApiResponse(
            code=200,
            message="获取成功",
            data=stats,
            timestamp=int(time.time() * 1000)
        )
    except Exception as e:
        logger.error(f"获取统计信息失败: {e}")
        raise HTTPException(status_code=500, detail=f"获取统计信息失败: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    
    # 确保日志目录存在
    import os
    os.makedirs("logs", exist_ok=True)
    
    # 启动服务
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8080,
        reload=True,
        log_level="info"
    )
