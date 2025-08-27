// Frontend script: loads rule sources and statistics, displays ruleCount, and supports single-source refresh.

// Determine API base URL. When the frontend is served on port 3000 (local static server),
// use full backend URL to avoid the static server intercepting /api requests.
let API_BASE_URL = (function() {
    if (window.__API_BASE_URL) return window.__API_BASE_URL.replace(/\/$/, '');
    const loc = window.location;
    const host = loc.hostname;
    const port = loc.port;
    const localHosts = ['localhost', '127.0.0.1', '0.0.0.0', '::1'];
    if (port === '3000' || localHosts.includes(host)) return 'http://localhost:8080/api';
    return '/api';
})();

if ((window.location && window.location.port === '3000') && API_BASE_URL.startsWith('/')) {
    API_BASE_URL = 'http://localhost:8080' + API_BASE_URL;
}

console.info('API_BASE_URL =', API_BASE_URL);

document.addEventListener('DOMContentLoaded', function() {
    loadStatistics();
    loadRuleSources();
    const addForm = document.getElementById('addRuleForm');
    if (addForm) addForm.addEventListener('submit', handleAddRule);
    // Bind domain query Enter key
    const domainInput = document.getElementById('domainInput');
    if (domainInput) {
        domainInput.addEventListener('keypress', function(e) { if (e.key === 'Enter') queryDomain(); });
    }
    // Bind search Enter key
    const searchInput = document.getElementById('searchKeyword');
    if (searchInput) {
        searchInput.addEventListener('keypress', function(e) { if (e.key === 'Enter') searchRules(); });
    }
});

async function loadRuleSources() {
    try {
        const resp = await fetch(`${API_BASE_URL}/rules/sources`);
        const j = await resp.json();
        if (j.code === 200) displayRuleSources(j.data);
    } catch (e) {
        console.error('loadRuleSources', e);
        showMessage('无法加载规则源，请检查后端是否可用', 'error');
    }
}

function displayRuleSources(sources) {
    const el = document.getElementById('ruleSources');
    if (!el) return;
    if (!sources || sources.length === 0) { el.innerHTML = '<p class="no-result">暂无规则源</p>'; return; }
    el.innerHTML = sources.map((s, idx) => {
        const last = s.lastUpdated ? new Date(s.lastUpdated).toLocaleString() : '未更新';
        const rc = (s.ruleCount || 0).toLocaleString();
        const statusClass = getStatusClass(s.status);
        return `
            <div class="rule-source">
                <div class="rule-header">
                    <div class="rule-name">${escapeHtml(s.name || '未命名')}</div>
                    <span class="rule-status ${statusClass}">${escapeHtml(s.status || '未知')}</span>
                </div>
                <div class="rule-url-summary" onclick="toggleRuleUrl(${idx})">
                    <span class="rule-url-text">${truncateUrl(s.url, 80)}</span>
                    <span class="rule-toggle">展开</span>
                </div>
                <div class="rule-url-details" id="rule-url-details-${idx}" style="display:none;">
                    <a href="${s.url}" target="_blank">${s.url}</a>
                </div>
                <div class="rule-details">
                    <div class="rule-meta">
                        <span>规则数量: ${rc}</span>
                        <span>最后更新: ${last}</span>
                        <span>状态: ${s.enabled ? '启用' : '禁用'}</span>
                    </div>
                    <div class="rule-actions">
                        <button class="small-btn" onclick="refreshOneRule('${encodeURIComponent(s.url)}')">刷新</button>
                        <button class="delete-btn" onclick="removeRuleSource('${s.url}')">删除</button>
                    </div>
                </div>
            </div>`;
    }).join('');
}

async function refreshOneRule(encodedUrl) {
    try {
        const resp = await fetch(`${API_BASE_URL}/rules/refresh_one?url=${encodedUrl}`, { method: 'POST' });
        const j = await resp.json();
        if (j.code === 200) {
            showMessage('单个规则刷新已开始，稍后自动更新列表', 'success');
            setTimeout(() => { loadRuleSources(); loadStatistics(); }, 3000);
        } else showMessage(j.message || '刷新失败', 'error');
    } catch (e) { console.error('refreshOneRule', e); showMessage('无法连接后端，刷新失败', 'error'); }
}

async function loadStatistics() {
    try {
        const resp = await fetch(`${API_BASE_URL}/rules/statistics`);
        const j = await resp.json();
        if (j.code === 200) displayStatistics(j.data);
    } catch (e) { console.error('loadStatistics', e); }
}

function displayStatistics(stats) {
    const el = document.getElementById('statistics'); if (!el) return;
    const last = stats.lastUpdate ? new Date(stats.lastUpdate).toLocaleString() : '未更新';
    el.innerHTML = `
        <div class="stat-item"><span class="stat-number">${stats.totalSources || 0}</span><span class="stat-label">规则源总数</span></div>
        <div class="stat-item"><span class="stat-number">${stats.enabledSources || 0}</span><span class="stat-label">已启用源</span></div>
        <div class="stat-item"><span class="stat-number">${(stats.domainRules || 0).toLocaleString()}</span><span class="stat-label">域名规则</span></div>
        <div class="stat-item"><span class="stat-number">${(stats.regexRules || 0).toLocaleString()}</span><span class="stat-label">正则规则</span></div>
        <div class="stat-item"><span class="stat-number">${(stats.hostsRules || 0).toLocaleString()}</span><span class="stat-label">Hosts规则</span></div>
        <div class="stat-item"><span class="stat-number">${last}</span><span class="stat-label">最后更新</span></div>`;
}

function removeRuleSource(url) {
    if (!confirm('确定要删除这个规则源吗？')) return;
    fetch(`${API_BASE_URL}/rules/sources?url=${encodeURIComponent(url)}`, { method: 'DELETE' })
        .then(r => r.json())
        .then(j => { if (j.code === 200) { showMessage('规则源删除成功', 'success'); loadRuleSources(); loadStatistics(); } else showMessage(j.message || '删除失败', 'error'); })
        .catch(e => { console.error('removeRuleSource', e); showMessage('网络错误', 'error'); });
}

// ------------------ Query / Search related functions ------------------
async function queryDomain() {
    const domainEl = document.getElementById('domainInput');
    if (!domainEl) return;
    const domain = domainEl.value.trim();
    if (!domain) { showMessage('请输入域名', 'error'); return; }
    if (!isValidDomain(domain)) { showMessage('域名格式不正确', 'error'); return; }
    const btn = document.getElementById('queryBtn'); const orig = btn ? btn.textContent : null;
    try {
        if (btn) { btn.textContent = '查询中...'; btn.disabled = true; }
        const resp = await fetch(`${API_BASE_URL}/query/domain?domain=${encodeURIComponent(domain)}`);
        const j = await resp.json();
        if (j.code === 200) {
            displayQueryResults([j.data]);
        } else {
            showMessage(j.message || '查询失败', 'error');
        }
    } catch (e) {
        console.error('queryDomain', e);
        showMessage('网络错误，无法查询', 'error');
    } finally {
        if (btn) { btn.textContent = orig; btn.disabled = false; }
    }
}

async function searchRules() {
    const kwEl = document.getElementById('searchKeyword');
    const limitEl = document.getElementById('searchLimit');
    if (!kwEl) return;
    const keyword = (kwEl.value || '').trim();
    const limit = limitEl && limitEl.value ? parseInt(limitEl.value, 10) : 100;
    if (!keyword) { showMessage('请输入搜索关键字', 'error'); return; }
    const btn = document.getElementById('searchBtn'); const orig = btn ? btn.textContent : null;
    try {
        if (btn) { btn.textContent = '搜索中...'; btn.disabled = true; }
        const resp = await fetch(`${API_BASE_URL}/rules/search?keyword=${encodeURIComponent(keyword)}&limit=${encodeURIComponent(limit)}`);
        const j = await resp.json();
        if (j.code === 200) {
            displaySearchResults(j.data || []);
        } else {
            showMessage(j.message || '搜索失败', 'error');
        }
    } catch (e) {
        console.error('searchRules', e);
        showMessage('网络错误，无法搜索', 'error');
    } finally {
        if (btn) { btn.textContent = orig; btn.disabled = false; }
    }
}

function parseResultData(data) {
    const r = {};
    if (Array.isArray(data)) {
        data.forEach(([k, v]) => {
            if (k === 'domain') r.domain = v;
            if (k === 'blocked') r.blocked = v;
            if (k === 'matched_rule') r.matchedRule = v;
            if (k === 'matched_rules') r.matchedRules = v || [];
            if (k === 'rule_source') r.ruleSource = v;
            if (k === 'rule_type') r.ruleType = v;
            if (k === 'duration') r.duration = v;
            if (k === 'query_time') r.queryTime = v;
        });
    } else if (data && typeof data === 'object') {
        r.domain = data.domain;
        r.blocked = data.blocked;
        r.matchedRule = data.matched_rule || data.matchedRule;
        r.matchedRules = data.matched_rules || data.matchedRules || [];
        r.ruleSource = data.rule_source || data.ruleSource;
        r.ruleType = data.rule_type || data.ruleType;
        r.duration = data.duration;
        r.queryTime = data.query_time || data.queryTime;
    }
    return r;
}

function displayQueryResults(results) {
    const container = document.getElementById('queryResult');
    if (!container) return;
    if (!results || results.length === 0) { container.innerHTML = '<p class="no-result">没有查询结果</p>'; return; }
    const html = results.map(raw => {
        const res = parseResultData(raw);
        const status = res.blocked ? '已阻止' : '允许';

        // 匹配规则展示：列出所有 matchedRules，如果没有则显示 matchedRule
        let matchedHtml = '';
        if (res.blocked) {
            const mr = res.matchedRules || [];
            if (mr && mr.length > 0) {
                matchedHtml = '<div class="matched-rules">';
                matchedHtml += mr.map(m => {
                    // m 可能是对象或字符串或数组
                    let ruleText = '';
                    let sourceName = '';
                    let sourceUrl = '';
                    if (typeof m === 'string') {
                        ruleText = m;
                    } else if (Array.isArray(m) && m.length >= 2) {
                        // 可能是 [k,v] 形式
                        ruleText = m[1];
                    } else if (m && typeof m === 'object') {
                        ruleText = m.rule || m.matched_rule || '';
                        sourceName = m.rule_source || m.ruleSource || '';
                        sourceUrl = m.rule_source_url || m.ruleSourceUrl || '';
                    }
                    return `
                        <div class="matched-rule-item">
                            <div class="matched-rule-text">${escapeHtml(ruleText)}</div>
                            <div class="matched-rule-meta">
                                ${ sourceName ? `<span class="matched-rule-source">来源：${escapeHtml(sourceName)}</span>` : '' }
                                ${ sourceUrl ? `<a class="source-link" href="${escapeHtml(sourceUrl)}" target="_blank">原始列表</a>` : '' }
                                ${ sourceUrl ? `<button class="copy-btn" data-copy="${encodeURIComponent(sourceUrl)}">复制列表链接</button>` : '' }
                                ${ ruleText ? `<button class="copy-btn" data-copy="${encodeURIComponent(ruleText)}">复制规则</button>` : '' }
                            </div>
                        </div>`;
                }).join('');
                matchedHtml += '</div>';
            } else {
                const ruleText = res.matchedRule || '';
                const sourceUrl = res.ruleSourceUrl || res.rule_source_url || '';
                const sourceName = res.ruleSource || res.rule_source || '';
                matchedHtml = `
                    <div class="matched-rule-item">
                        <div class="matched-rule-text">${escapeHtml(ruleText)}</div>
                        <div class="matched-rule-meta">
                            ${ sourceName ? `<span class="matched-rule-source">来源：${escapeHtml(sourceName)}</span>` : '' }
                            ${ sourceUrl ? `<a class="source-link" href="${escapeHtml(sourceUrl)}" target="_blank">原始列表</a>` : '' }
                            ${ sourceUrl ? `<button class="copy-btn" data-copy="${encodeURIComponent(sourceUrl)}">复制列表链接</button>` : '' }
                            ${ ruleText ? `<button class="copy-btn" data-copy="${encodeURIComponent(ruleText)}">复制规则</button>` : '' }
                        </div>
                    </div>`;
            }
        }

        return `<div class="query-item">
            <div class="query-domain">${escapeHtml(res.domain || '')}</div>
            <div class="query-status">${status}</div>
            <div class="query-details">${matchedHtml}<div>耗时: ${res.duration || 0} ms</div></div>
        </div>`;
    }).join('');
    container.innerHTML = html;
}

function displaySearchResults(results) {
    const container = document.getElementById('searchResult');
    if (!container) return;
    if (!results || results.length === 0) { container.innerHTML = '<p class="no-result">未找到匹配规则</p>'; return; }
    container.innerHTML = results.map((r, idx) => {
        const ruleText = r.rule || '';
        const sourceName = r.rule_source || r.ruleSource || '';
        const sourceUrl = r.rule_source_url || r.ruleSourceUrl || '';
        const ruleType = r.rule_type || r.ruleType || '';
        return `
        <div class="search-item">
            <div class="search-index">${idx + 1}.</div>
            <div class="search-body">
                <div class="search-rule">${escapeHtml(ruleText)}</div>
                <div class="search-meta">
                    <span class="search-source">${escapeHtml(sourceName)}</span>
                    <span class="search-type">${escapeHtml(ruleType)}</span>
                    ${ sourceUrl ? `<a class="source-link" href="${escapeHtml(sourceUrl)}" target="_blank">原始列表</a>` : '' }
                    ${ sourceUrl ? `<button class="copy-btn" data-copy="${encodeURIComponent(sourceUrl)}">复制列表链接</button>` : '' }
                    ${ ruleText ? `<button class="copy-btn" data-copy="${encodeURIComponent(ruleText)}">复制规则</button>` : '' }
                </div>
            </div>
        </div>`;
    }).join('');
}


function isValidDomain(d) { const re = /^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/; return re.test(d) && !d.startsWith('.') && !d.endsWith('.') && !d.includes('..'); }

function escapeHtml(s) { if (!s) return ''; return s.replace(/[&<>"']/g, t => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[t] || t); }

function truncateUrl(url, max) { if (!url) return ''; if (url.length <= max) return url; return url.substring(0, max) + '...'; }

// 复制到剪贴板（带回退）
function copyToClipboard(text, btnEl) {
    if (!text) { showMessage('无内容可复制', 'error'); return; }
    const setBtnCopied = () => {
        try {
            if (btnEl) {
                const orig = btnEl.textContent;
                btnEl.textContent = '已复制';
                setTimeout(() => { btnEl.textContent = orig; }, 2000);
            }
        } catch (e) { /* ignore */ }
    };

    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(() => {
            showMessage('已复制到剪贴板', 'success');
            setBtnCopied();
        }).catch(err => {
            console.error('copy failed', err);
            fallbackCopy(text, btnEl);
        });
    } else {
        fallbackCopy(text, btnEl);
    }
}

function fallbackCopy(text, btnEl) {
    try {
        const ta = document.createElement('textarea');
        ta.value = text;
        ta.style.position = 'fixed';
        ta.style.left = '-9999px';
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
    showMessage('已复制到剪贴板', 'success');
    try { if (btnEl) { const orig = btnEl.textContent; btnEl.textContent = '已复制'; setTimeout(() => { btnEl.textContent = orig; }, 2000); } } catch(e){}
    } catch (e) {
        console.error('fallback copy failed', e);
        showMessage('复制失败，请手动复制', 'error');
    }
}

function getStatusClass(status) { if (!status) return 'status-warning'; if ((status||'').indexOf('成功') !== -1) return 'status-success'; if ((status||'').indexOf('失败') !== -1 || (status||'').indexOf('错误') !== -1) return 'status-error'; return 'status-warning'; }

function toggleRuleUrl(i) { const d = document.getElementById(`rule-url-details-${i}`); if (!d) return; const t = d.previousElementSibling.querySelector('.rule-toggle'); if (d.style.display === 'block') { d.style.display = 'none'; t.textContent = '展开'; } else { d.style.display = 'block'; t.textContent = '收起'; } }

async function handleAddRule(e) { if (e && e.preventDefault) e.preventDefault(); const name = (document.getElementById('ruleName') || {}).value || ''; const url = (document.getElementById('ruleUrl') || {}).value || ''; const enabled = !!(document.getElementById('ruleEnabled') || {}).checked; if (!name || !url) { showMessage('请填写完整信息', 'error'); return; } try { const resp = await fetch(`${API_BASE_URL}/rules/sources`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ name, url, enabled }) }); const j = await resp.json(); if (j.code === 200) { showMessage('规则源添加成功', 'success'); loadRuleSources(); loadStatistics(); } else showMessage(j.message || '添加失败', 'error'); } catch (e) { console.error('handleAddRule', e); showMessage('网络错误', 'error'); } }

function showMessage(msg, type = 'info') { const div = document.createElement('div'); div.className = `message message-${type}`; div.textContent = msg; div.style.cssText = 'position:fixed;top:20px;right:20px;padding:10px 14px;border-radius:8px;color:#fff;font-weight:600;z-index:10000;max-width:320px;'; switch (type) { case 'success': div.style.background = '#27ae60'; break; case 'error': div.style.background = '#e74c3c'; break; case 'warning': div.style.background = '#f39c12'; break; default: div.style.background = '#3498db'; } document.body.appendChild(div); setTimeout(() => { div.style.transition = 'opacity 0.3s'; div.style.opacity = 0; setTimeout(() => { if (div.parentNode) div.parentNode.removeChild(div); }, 300); }, 3000); }

// 事件委托：处理复制按钮点击
document.addEventListener('click', function(e) {
    const btn = e.target.closest && e.target.closest('.copy-btn');
    if (!btn) return;
    const raw = btn.getAttribute('data-copy');
    if (!raw) { showMessage('无可复制内容', 'error'); return; }
    try {
        const toCopy = decodeURIComponent(raw);
        copyToClipboard(toCopy, btn);
    } catch (e) {
        // 如果不是编码字符串，直接复制原始
        copyToClipboard(raw, btn);
    }
});

