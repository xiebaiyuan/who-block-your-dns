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

function isValidDomain(d) { const re = /^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/; return re.test(d) && !d.startsWith('.') && !d.endsWith('.') && !d.includes('..'); }

function escapeHtml(s) { if (!s) return ''; return s.replace(/[&<>"']/g, t => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[t] || t); }

function truncateUrl(url, max) { if (!url) return ''; if (url.length <= max) return url; return url.substring(0, max) + '...'; }

function getStatusClass(status) { if (!status) return 'status-warning'; if ((status||'').indexOf('成功') !== -1) return 'status-success'; if ((status||'').indexOf('失败') !== -1 || (status||'').indexOf('错误') !== -1) return 'status-error'; return 'status-warning'; }

function toggleRuleUrl(i) { const d = document.getElementById(`rule-url-details-${i}`); if (!d) return; const t = d.previousElementSibling.querySelector('.rule-toggle'); if (d.style.display === 'block') { d.style.display = 'none'; t.textContent = '展开'; } else { d.style.display = 'block'; t.textContent = '收起'; } }

async function handleAddRule(e) { if (e && e.preventDefault) e.preventDefault(); const name = (document.getElementById('ruleName') || {}).value || ''; const url = (document.getElementById('ruleUrl') || {}).value || ''; const enabled = !!(document.getElementById('ruleEnabled') || {}).checked; if (!name || !url) { showMessage('请填写完整信息', 'error'); return; } try { const resp = await fetch(`${API_BASE_URL}/rules/sources`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ name, url, enabled }) }); const j = await resp.json(); if (j.code === 200) { showMessage('规则源添加成功', 'success'); loadRuleSources(); loadStatistics(); } else showMessage(j.message || '添加失败', 'error'); } catch (e) { console.error('handleAddRule', e); showMessage('网络错误', 'error'); } }

function showMessage(msg, type = 'info') { const div = document.createElement('div'); div.className = `message message-${type}`; div.textContent = msg; div.style.cssText = 'position:fixed;top:20px;right:20px;padding:10px 14px;border-radius:8px;color:#fff;font-weight:600;z-index:10000;max-width:320px;'; switch (type) { case 'success': div.style.background = '#27ae60'; break; case 'error': div.style.background = '#e74c3c'; break; case 'warning': div.style.background = '#f39c12'; break; default: div.style.background = '#3498db'; } document.body.appendChild(div); setTimeout(() => { div.style.transition = 'opacity 0.3s'; div.style.opacity = 0; setTimeout(() => { if (div.parentNode) div.parentNode.removeChild(div); }, 300); }, 3000); }

