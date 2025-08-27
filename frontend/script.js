// API配置 - 根据运行环境自动选择后端地址（支持 Docker/Nginx 代理 和 直接用 Python 启动）
// 规则：
// 1. 如果页面在本地用 python http.server (默认端口 3000) 启动，则后端通常在 http://localhost:8080 -> 使用完整 URL 避开 CORS。
// 2. 其它情况下（例如 Docker 下前端由 Nginx 代理），使用相对路径 '/api' 以便通过代理转发。
// 3. 支持通过 window.__API_BASE_URL 手动覆盖（用于调试或特殊部署）。
const API_BASE_URL = (function() {
    // 手动覆盖优先
    if (window.__API_BASE_URL) return window.__API_BASE_URL.replace(/\/$/, '');

    const loc = window.location;
    const host = loc.hostname;
    const port = loc.port;

    // 如果是在本地通过 python http.server（或其它本地静态服务器）运行，或访问地址为 0.0.0.0 / ::1，
    // 或者页面正在使用 3000 端口（常见于开发时用 python 或 npm 启动前端），则使用后端完整地址以避免被静态服务器拦截并返回 HTML。
    const localHosts = ['localhost', '127.0.0.1', '0.0.0.0', '::1'];
    if (port === '3000' || localHosts.includes(host)) {
        return 'http://localhost:8080/api';
    }

    // 默认使用相对路径，交给前端代理（Docker + Nginx）处理
    return '/api';
})();

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    loadStatistics();
    loadRuleSources();
    
    // 绑定表单提交事件
    document.getElementById('addRuleForm').addEventListener('submit', handleAddRule);
    
    // 绑定回车键查询
    document.getElementById('domainInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            queryDomain();
        }
    });

    // 绑定搜索回车事件
    const searchInput = document.getElementById('searchKeyword');
    if (searchInput) {
        searchInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                searchRules();
            }
        });
    }
});

// 查询单个域名
async function queryDomain() {
    const domainInput = document.getElementById('domainInput');
    const domain = domainInput.value.trim();
    
    if (!domain) {
        showMessage('请输入域名', 'error');
        return;
    }
    
    if (!isValidDomain(domain)) {
        showMessage('域名格式不正确', 'error');
        return;
    }
    
    const queryBtn = document.getElementById('queryBtn');
    const originalText = queryBtn.textContent;
    
    try {
        queryBtn.textContent = '查询中...';
        queryBtn.disabled = true;
        
        const response = await fetch(`${API_BASE_URL}/query/domain?domain=${encodeURIComponent(domain)}`);
        const result = await response.json();
        
        if (result.code === 200) {
            displayQueryResults([result.data]);
        } else {
            showMessage(result.message || '查询失败', 'error');
        }
    } catch (error) {
        console.error('查询失败:', error);
        showMessage('网络错误，请检查后端服务是否启动', 'error');
    } finally {
        queryBtn.textContent = originalText;
        queryBtn.disabled = false;
    }
}

// 搜索规则
async function searchRules() {
    const keywordEl = document.getElementById('searchKeyword');
    const limitEl = document.getElementById('searchLimit');
    const keyword = keywordEl ? keywordEl.value.trim() : '';
    const limit = limitEl && limitEl.value ? parseInt(limitEl.value, 10) : 100;

    if (!keyword) {
        showMessage('请输入搜索关键字', 'error');
        return;
    }

    const searchBtn = document.getElementById('searchBtn');
    const originalText = searchBtn ? searchBtn.textContent : '';

    try {
        if (searchBtn) {
            searchBtn.textContent = '搜索中...';
            searchBtn.disabled = true;
        }

        const resp = await fetch(`${API_BASE_URL}/rules/search?keyword=${encodeURIComponent(keyword)}&limit=${encodeURIComponent(limit)}`);
        const data = await resp.json();

        if (data.code === 200) {
            displaySearchResults(data.data);
        } else {
            showMessage(data.message || '搜索失败', 'error');
        }
    } catch (err) {
        console.error('搜索失败', err);
        showMessage('网络错误，请检查后端服务', 'error');
    } finally {
        if (searchBtn) {
            searchBtn.textContent = originalText;
            searchBtn.disabled = false;
        }
    }
}

// 显示搜索结果
function displaySearchResults(results) {
    const container = document.getElementById('searchResult');

    if (!results || results.length === 0) {
        container.innerHTML = '<p class="no-result">未找到匹配规则</p>';
        return;
    }

    const html = results.map((r, idx) => `
        <div class="search-item">
            <div class="search-index">${idx + 1}.</div>
            <div class="search-body">
                <div class="search-rule">${escapeHtml(r.rule)}</div>
                <div class="search-meta">
                    <span class="search-source">${escapeHtml(r.rule_source)}</span>
                    <span class="search-type">${r.rule_type}</span>
                </div>
                <div class="search-details" id="search-details-${idx}">
                    <div class="search-detail-row">
                        <span class="search-detail-label">链接:</span>
                        <span class="search-detail-value">${escapeHtml(r.rule_source_url || '')}</span>
                    </div>
                </div>
                <div class="search-toggle" onclick="toggleSearchDetails(${idx})">展开详情</div>
            </div>
        </div>
    `).join('');

    container.innerHTML = html;
}

// 切换搜索详情显示
function toggleSearchDetails(index) {
    const detailsElement = document.getElementById(`search-details-${index}`);
    const toggleElement = detailsElement.parentElement.querySelector('.search-toggle');
    
    if (detailsElement.classList.contains('expanded')) {
        detailsElement.classList.remove('expanded');
        toggleElement.textContent = '展开详情';
    } else {
        detailsElement.classList.add('expanded');
        toggleElement.textContent = '收起详情';
    }
}

// 简单转义HTML
function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/[&<>\"']/g, function(tag) {
        const charsToReplace = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#39;'
        };
        return charsToReplace[tag] || tag;
    });
}

// 批量查询域名
async function bulkQuery() {
    const bulkInput = document.getElementById('bulkInput');
    const domains = bulkInput.value
        .split('\n')
        .map(d => d.trim())
        .filter(d => d && isValidDomain(d));
    
    if (domains.length === 0) {
        showMessage('请输入有效的域名列表', 'error');
        return;
    }
    
    if (domains.length > 100) {
        showMessage('单次查询域名数量不能超过100个', 'error');
        return;
    }
    
    const bulkQueryBtn = document.getElementById('bulkQueryBtn');
    const originalText = bulkQueryBtn.textContent;
    
    try {
        bulkQueryBtn.textContent = '查询中...';
        bulkQueryBtn.disabled = true;
        
        const response = await fetch(`${API_BASE_URL}/query/domains`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({domains: domains})
        });
        
        const result = await response.json();
        
        if (result.code === 200) {
            // 批量查询返回的数据格式已经是对象格式，直接使用
            displayQueryResults(result.data);
        } else {
            showMessage(result.message || '批量查询失败', 'error');
        }
    } catch (error) {
        console.error('批量查询失败:', error);
        showMessage('网络错误，请检查后端服务是否启动', 'error');
    } finally {
        bulkQueryBtn.textContent = originalText;
        bulkQueryBtn.disabled = false;
    }
}

// 解析后端返回的结果数据
function parseResultData(data) {
    const result = {};
    
    if (Array.isArray(data)) {
        // 二维数组格式 [["domain", "example.com"], ["blocked", true], ...]
        data.forEach(([key, value]) => {
            switch (key) {
                case 'domain':
                    result.domain = value;
                    break;
                case 'blocked':
                    result.blocked = value;
                    break;
                case 'matched_rule':
                    result.matchedRule = value;
                    break;
                case 'matched_rules':
                    result.matchedRules = value || [];
                    break;
                case 'rule_source':
                    result.ruleSource = value;
                    break;
                case 'rule_type':
                    result.ruleType = value;
                    break;
                case 'duration':
                    result.duration = value;
                    break;
                case 'query_time':
                    result.queryTime = value;
                    break;
            }
        });
    } else {
        // 如果已经是对象格式
        result.domain = data.domain;
        result.blocked = data.blocked;
        result.matchedRule = data.matched_rule || data.matchedRule;
        result.matchedRules = data.matched_rules || data.matchedRules || [];
        result.ruleSource = data.rule_source || data.ruleSource;
        result.ruleType = data.rule_type || data.ruleType;
        result.duration = data.duration;
        result.queryTime = data.query_time || data.queryTime;
    }
    return result;
}

// 显示查询结果
function displayQueryResults(results) {
    const resultContainer = document.getElementById('queryResult');
    
    if (!results || results.length === 0) {
        resultContainer.innerHTML = '<p class="no-result">没有查询结果</p>';
        return;
    }
    
    const html = results.map(rawResult => {
        const result = parseResultData(rawResult);
        const statusClass = result.blocked ? 'result-blocked' : 'result-allowed';
        const statusLabel = result.blocked ? 'status-blocked' : 'status-allowed';
        const statusText = result.blocked ? '已阻止' : '允许';
        
        // 构建匹配规则的HTML
        let matchedRulesHtml = '';
        if (result.blocked) {
            if (result.matchedRules && result.matchedRules.length > 0) {
                // 显示多个匹配的规则
                matchedRulesHtml = `
                    <div class="matched-rules-section">
                        <strong>匹配的规则 (${result.matchedRules.length}个):</strong>
                        <div class="matched-rules-list">
                            ${result.matchedRules.map((matchedRule, index) => `
                                <div class="matched-rule-item">
                                    <span class="rule-number">${index + 1}.</span>
                                    <div class="rule-details">
                                        <div class="rule-text">${matchedRule.rule}</div>
                                        <div class="rule-meta">
                                            <span class="rule-source">
                                                ${matchedRule.rule_source}
                                                ${matchedRule.rule_source_url ? `<a href="${matchedRule.rule_source_url}" target="_blank" class="rule-url-link" title="查看规则源">🔗</a>` : ''}
                                            </span>
                                            <span class="rule-type-badge rule-type-${matchedRule.rule_type}">${matchedRule.rule_type}</span>
                                        </div>
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                `;
            } else {
                // 降级显示单个规则（向后兼容）
                matchedRulesHtml = `
                    <span><strong>匹配规则:</strong> ${result.matchedRule || '未知'}</span>
                    <span><strong>规则源:</strong> ${result.ruleSource || '未知'}</span>
                    <span><strong>规则类型:</strong> ${result.ruleType || '未知'}</span>
                `;
            }
        }
        
        return `
            <div class="result-item ${statusClass}">
                <div class="result-domain">${result.domain}</div>
                <span class="result-status ${statusLabel}">${statusText}</span>
                <div class="result-details">
                    ${matchedRulesHtml}
                    <span><strong>查询耗时:</strong> ${result.duration || 0}ms</span>
                </div>
            </div>
        `;
    }).join('');
    
    resultContainer.innerHTML = html;
}

// 加载统计信息
async function loadStatistics() {
    try {
        const response = await fetch(`${API_BASE_URL}/rules/statistics`);
        const result = await response.json();
        
        if (result.code === 200) {
            displayStatistics(result.data);
        }
    } catch (error) {
        console.error('加载统计信息失败:', error);
    }
}

// 显示统计信息
function displayStatistics(stats) {
    const statisticsContainer = document.getElementById('statistics');
    
    const lastUpdate = stats.lastUpdate ? new Date(stats.lastUpdate).toLocaleString() : '未更新';
    
    statisticsContainer.innerHTML = `
        <div class="stat-item">
            <span class="stat-number">${stats.totalSources || 0}</span>
            <span class="stat-label">规则源总数</span>
        </div>
        <div class="stat-item">
            <span class="stat-number">${stats.enabledSources || 0}</span>
            <span class="stat-label">已启用源</span>
        </div>
        <div class="stat-item">
            <span class="stat-number">${(stats.domainRules || 0).toLocaleString()}</span>
            <span class="stat-label">域名规则</span>
        </div>
        <div class="stat-item">
            <span class="stat-number">${(stats.regexRules || 0).toLocaleString()}</span>
            <span class="stat-label">正则规则</span>
        </div>
        <div class="stat-item">
            <span class="stat-number">${(stats.hostsRules || 0).toLocaleString()}</span>
            <span class="stat-label">Hosts规则</span>
        </div>
        <div class="stat-item">
            <span class="stat-number">${lastUpdate}</span>
            <span class="stat-label">最后更新</span>
        </div>
    `;
}

// 加载规则源列表
async function loadRuleSources() {
    try {
        const response = await fetch(`${API_BASE_URL}/rules/sources`);
        const result = await response.json();
        
        if (result.code === 200) {
            displayRuleSources(result.data);
        }
    } catch (error) {
        console.error('加载规则源失败:', error);
    }
}

// 显示规则源列表
function displayRuleSources(sources) {
    const ruleSourcesContainer = document.getElementById('ruleSources');
    
    if (!sources || sources.length === 0) {
        ruleSourcesContainer.innerHTML = '<p class="no-result">暂无规则源</p>';
        return;
    }
    
    const html = sources.map((source, index) => {
        const statusClass = getStatusClass(source.status);
        const lastUpdated = source.lastUpdated ? 
            new Date(source.lastUpdated).toLocaleString() : '未更新';
        
        return `
            <div class="rule-source">
                <div class="rule-header">
                    <div class="rule-name-section">
                        <div class="rule-name">${source.name || '未命名'}</div>
                    </div>
                    <span class="rule-status ${statusClass}">${source.status || '未知'}</span>
                </div>
                <div class="rule-url-summary" onclick="toggleRuleUrl(${index})">
                    <span class="rule-url-text">${truncateUrl(source.url, 50)}</span>
                    <span class="rule-toggle">展开</span>
                </div>
                <div class="rule-url-details" id="rule-url-details-${index}" style="display: none;">
                    <a href="${source.url}" target="_blank" title="打开原始链接" class="rule-full-url">
                        ${source.url}
                    </a>
                </div>
                <div class="rule-details">
                    <div class="rule-meta">
                        <span>规则数量: ${(source.ruleCount || 0).toLocaleString()}</span>
                        <span>最后更新: ${lastUpdated}</span>
                        <span>状态: ${source.enabled ? '启用' : '禁用'}</span>
                    </div>
                    <button class="delete-btn" onclick="removeRuleSource('${source.url}')">
                        删除
                    </button>
                </div>
            </div>
        `;
    }).join('');
    
    ruleSourcesContainer.innerHTML = html;
}

// 获取状态样式类
function getStatusClass(status) {
    if (!status) return 'status-warning';
    
    if (status.includes('成功')) return 'status-success';
    if (status.includes('失败') || status.includes('错误')) return 'status-error';
    return 'status-warning';
}

// 截断URL显示
function truncateUrl(url, maxLength) {
    if (!url) return '';
    if (url.length <= maxLength) return url;
    return url.substring(0, maxLength) + '...';
}

// 切换规则URL显示
function toggleRuleUrl(index) {
    const detailsElement = document.getElementById(`rule-url-details-${index}`);
    const summaryElement = detailsElement.previousElementSibling;
    const toggleElement = summaryElement.querySelector('.rule-toggle');
    
    if (detailsElement.style.display === 'block' || detailsElement.style.display === '') {
        detailsElement.style.display = 'none';
        toggleElement.textContent = '展开';
    } else {
        detailsElement.style.display = 'block';
        toggleElement.textContent = '收起';
    }
}

// 刷新规则
async function refreshRules() {
    try {
        const response = await fetch(`${API_BASE_URL}/rules/refresh`, {
            method: 'POST'
        });
        
        const result = await response.json();
        
        if (result.code === 200) {
            showMessage('规则刷新已开始，请稍后查看更新状态', 'success');
            // 3秒后重新加载统计和规则源
            setTimeout(() => {
                loadStatistics();
                loadRuleSources();
            }, 3000);
        } else {
            showMessage(result.message || '刷新失败', 'error');
        }
    } catch (error) {
        console.error('刷新规则失败:', error);
        showMessage('网络错误，请检查后端服务是否启动', 'error');
    }
}

// 显示添加规则表单
function showAddRuleForm() {
    document.getElementById('addRuleModal').style.display = 'block';
}

// 关闭添加规则表单
function closeAddRuleForm() {
    document.getElementById('addRuleModal').style.display = 'none';
    document.getElementById('addRuleForm').reset();
}

// 处理添加规则
async function handleAddRule(event) {
    event.preventDefault();
    
    const formData = new FormData(event.target);
    const ruleSource = {
        name: document.getElementById('ruleName').value.trim(),
        url: document.getElementById('ruleUrl').value.trim(),
        enabled: document.getElementById('ruleEnabled').checked
    };
    
    if (!ruleSource.name || !ruleSource.url) {
        showMessage('请填写完整信息', 'error');
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/rules/sources`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(ruleSource)
        });
        
        const result = await response.json();
        
        if (result.code === 200) {
            showMessage('规则源添加成功', 'success');
            closeAddRuleForm();
            loadRuleSources();
            loadStatistics();
        } else {
            showMessage(result.message || '添加失败', 'error');
        }
    } catch (error) {
        console.error('添加规则源失败:', error);
        showMessage('网络错误，请检查后端服务是否启动', 'error');
    }
}

// 删除规则源
async function removeRuleSource(url) {
    if (!confirm('确定要删除这个规则源吗？')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/rules/sources?url=${encodeURIComponent(url)}`, {
            method: 'DELETE'
        });
        
        const result = await response.json();
        
        if (result.code === 200) {
            showMessage('规则源删除成功', 'success');
            loadRuleSources();
            loadStatistics();
        } else {
            showMessage(result.message || '删除失败', 'error');
        }
    } catch (error) {
        console.error('删除规则源失败:', error);
        showMessage('网络错误，请检查后端服务是否启动', 'error');
    }
}

// 验证域名格式
function isValidDomain(domain) {
    const domainRegex = /^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return domainRegex.test(domain) && 
           !domain.startsWith('.') && 
           !domain.endsWith('.') && 
           !domain.includes('..');
}

// 显示消息提示
function showMessage(message, type = 'info') {
    // 创建消息元素
    const messageDiv = document.createElement('div');
    messageDiv.className = `message message-${type}`;
    messageDiv.textContent = message;
    
    // 添加样式
    messageDiv.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        border-radius: 8px;
        color: white;
        font-weight: 600;
        z-index: 10000;
        max-width: 300px;
        word-wrap: break-word;
        animation: slideIn 0.3s ease;
    `;
    
    // 根据类型设置颜色
    switch (type) {
        case 'success':
            messageDiv.style.background = '#27ae60';
            break;
        case 'error':
            messageDiv.style.background = '#e74c3c';
            break;
        case 'warning':
            messageDiv.style.background = '#f39c12';
            break;
        default:
            messageDiv.style.background = '#3498db';
    }
    
    // 添加动画样式
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideIn {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        @keyframes slideOut {
            from { transform: translateX(0); opacity: 1; }
            to { transform: translateX(100%); opacity: 0; }
        }
    `;
    document.head.appendChild(style);
    
    // 添加到页面
    document.body.appendChild(messageDiv);
    
    // 3秒后自动消失
    setTimeout(() => {
        messageDiv.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
            if (messageDiv.parentNode) {
                messageDiv.parentNode.removeChild(messageDiv);
            }
        }, 300);
    }, 3000);
}

// 点击模态框外部关闭
window.onclick = function(event) {
    const modal = document.getElementById('addRuleModal');
    if (event.target === modal) {
        closeAddRuleForm();
    }
}
