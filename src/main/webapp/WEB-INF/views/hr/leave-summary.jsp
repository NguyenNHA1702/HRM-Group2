<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Báo cáo nghỉ phép | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <style>
        /* ── Filter panel ── */
        .filter-panel { background:var(--white); border:1px solid var(--border); border-radius:12px; padding:20px; margin-bottom:24px; }
        .filter-form  { display:flex; gap:16px; align-items:flex-end; flex-wrap:wrap; }
        .filter-field { display:flex; flex-direction:column; gap:6px; flex:1; min-width:160px; }
        .filter-field label { font-size:13px; font-weight:500; color:var(--text); }
        .filter-field input, .filter-field select { padding:8px 12px; border:1px solid var(--border); border-radius:8px; font-size:13px; font-family:inherit; color:var(--text); background:var(--white); box-sizing:border-box; }
        .filter-field input:focus, .filter-field select:focus { outline:none; border-color:var(--brand); box-shadow:0 0 0 3px rgba(79,70,229,.12); }
        /* ── Stat cards ── */
        .stats-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(200px,1fr)); gap:16px; margin-bottom:24px; }
        .stat-card { background:var(--white); border:1px solid var(--border); border-radius:12px; padding:18px 20px; display:flex; align-items:center; gap:14px; transition:transform .2s,box-shadow .2s; }
        .stat-card:hover { transform:translateY(-2px); box-shadow:0 4px 12px rgba(0,0,0,.06); }
        .stat-icon { width:44px; height:44px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:18px; flex-shrink:0; }
        .stat-icon.green  { background:#dcfce7; } .stat-icon.amber { background:#fef3c7; } .stat-icon.blue { background:#e0e7ff; }
        .stat-num   { font-size:22px; font-weight:700; color:var(--text); line-height:1.2; }
        .stat-label { font-size:12px; color:var(--muted); margin-top:3px; }
        /* ── Table helpers ── */
        .card-top { display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; }
        .toolbar-search { position:relative; flex:1; min-width:200px; max-width:300px; }
        .toolbar-search input { width:100%; padding:8px 12px 8px 36px; border:1px solid var(--border); border-radius:8px; font-size:13px; font-family:inherit; color:var(--text); background:var(--white); box-sizing:border-box; }
        .toolbar-search input:focus { outline:none; border-color:var(--brand); box-shadow:0 0 0 3px rgba(79,70,229,.12); }
        .toolbar-search .icon { position:absolute; left:10px; top:50%; transform:translateY(-50%); color:var(--muted); font-size:15px; pointer-events:none; }
        .row-type-select { padding:5px 10px; border:1px solid var(--border); border-radius:6px; font-size:13px; font-family:inherit; color:var(--text); background:var(--white); cursor:pointer; }
        .badge-g { color:#166534; background:#dcfce7; padding:2px 8px; border-radius:99px; font-size:12px; font-weight:500; }
        .badge-y { color:#92400e; background:#fef3c7; padding:2px 8px; border-radius:99px; font-size:12px; font-weight:500; }
        .badge-b { color:#1e3a8a; background:#dbeafe; padding:2px 8px; border-radius:99px; font-size:12px; font-weight:500; }
        .empty-state { text-align:center; padding:40px 0; color:var(--muted); font-size:14px; }
        .pagination { display:flex; align-items:center; justify-content:space-between; margin-top:16px; flex-wrap:wrap; gap:10px; }
        .pagination-info { font-size:13px; color:var(--muted); }
        .pagination-buttons { display:flex; gap:4px; }
        .page-btn { min-width:32px; height:32px; padding:0 8px; border:1px solid var(--border); border-radius:6px; background:var(--white); color:var(--text); font-size:13px; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; transition:background .15s,border-color .15s; }
        .page-btn:hover:not(:disabled) { background:var(--bg); border-color:var(--brand); }
        .page-btn.active { background:var(--brand); color:#fff; border-color:var(--brand); font-weight:600; }
        .page-btn:disabled { opacity:.4; cursor:not-allowed; }
        /* ── Print ── */
        .print-title { display:none; }
        @media print {
            .sidebar,.filter-panel,.card-top,.pagination,.btn { display:none!important; }
            .content-area { padding:0; width:100%; }
            .print-title { display:block; text-align:center; margin-bottom:16px; }
            .table-wrap th,.table-wrap td { border:1px solid #ddd; padding:6px; font-size:11px; }
        }
    </style>
</head>
<body>
<div class="main-layout">
    <%@ include file="/WEB-INF/common/sidebar.jsp" %>
    <div class="content-area">

        <div class="print-title">
            <h2>BÁO CÁO TỔNG HỢP NGHỈ PHÉP</h2>
            <p>Thời gian: Từ ${fromDate} đến ${toDate}</p>
        </div>

        <div class="page-header">
            <div>
                <h1>Báo cáo nghỉ phép</h1>
                <div class="subtitle">Thống kê tình hình nghỉ phép theo từng nhân viên</div>
            </div>
            <button class="btn btn-secondary" onclick="window.print()">🖨️ In báo cáo</button>
        </div>

        <%-- Filter --%>
        <div class="filter-panel">
            <form method="get" action="${pageContext.request.contextPath}/hr/leave-summary" class="filter-form">
                <div class="filter-field">
                    <label for="fromDate">Từ ngày</label>
                    <input type="date" name="fromDate" id="fromDate" value="${fromDate}">
                </div>
                <div class="filter-field">
                    <label for="toDate">Đến ngày</label>
                    <input type="date" name="toDate" id="toDate" value="${toDate}">
                </div>
                <div class="filter-field">
                    <label for="deptId">Phòng ban</label>
                    <select name="deptId" id="deptId">
                        <option value="">-- Tất cả --</option>
                        <c:forEach items="${departments}" var="d">
                            <option value="${d.id}" ${d.id == selectedDeptId ? 'selected' : ''}>${d.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div style="display:flex;gap:8px;">
                    <button type="submit" class="btn btn-primary" style="height:38px;">🔍 Lọc</button>
                    <a href="${pageContext.request.contextPath}/hr/leave-summary" class="btn btn-secondary" style="height:38px;display:flex;align-items:center;text-decoration:none;">↺ Làm mới</a>
                </div>
            </form>
        </div>

        <%-- Tính tổng để hiện stat cards --%>
        <c:set var="totalApproved" value="0"/>
        <c:set var="totalPending"  value="0"/>
        <c:forEach items="${summaryRows}" var="empRow">
            <c:forEach items="${empRow.leaveData}" var="ld">
                <c:set var="totalApproved" value="${totalApproved + ld.totalApprovedDays}"/>
                <c:set var="totalPending"  value="${totalPending  + ld.totalPendingDays}"/>
            </c:forEach>
        </c:forEach>

        <%-- Stat cards --%>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon green">✔️</div>
                <div><div class="stat-num"><fmt:formatNumber value="${totalApproved}" maxFractionDigits="1"/> ngày</div><div class="stat-label">Tổng phép đã duyệt</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon amber">⏳</div>
                <div><div class="stat-num"><fmt:formatNumber value="${totalPending}" maxFractionDigits="1"/> ngày</div><div class="stat-label">Tổng phép chờ duyệt</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon blue">👥</div>
                <div><div class="stat-num">${summaryRows.size()}</div><div class="stat-label">Nhân viên có trong báo cáo</div></div>
            </div>
        </div>

        <%-- Table --%>
        <div class="card">
            <div class="card-top">
                <h3 style="margin:0;font-size:15px;">Chi tiết báo cáo</h3>
                <div class="toolbar-search">
                    <span class="icon">&#9906;</span>
                    <input type="text" id="searchInput" placeholder="Tìm tên, mã NV, phòng ban..." oninput="applyFilter()">
                </div>
            </div>

            <div class="table-wrap">
                <table id="summaryTable">
                    <thead>
                    <tr>
                        <th>#</th>
                        <th>Mã NV</th>
                        <th>Nhân viên</th>
                        <th>Phòng ban</th>
                        <th>Loại phép</th>
                        <th>Đã nghỉ (Duyệt)</th>
                        <th>Đang xin (Chờ)</th>
                        <th>Còn lại</th>
                    </tr>
                    </thead>
                    <tbody id="tableBody">
                    <c:forEach items="${summaryRows}" var="empRow" varStatus="st">
                        <tr data-name="${empRow.fullName}" data-code="${empRow.employeeCode}" data-dept="${empRow.departmentName}">
                            <td>${st.count}</td>
                            <td><code>${empRow.employeeCode}</code></td>
                            <td><strong>${empRow.fullName}</strong></td>
                            <td>${empRow.departmentName}</td>
                            <td>
                                <select class="row-type-select" onchange="updateSummaryRow(this.closest('tr'))">
                                    <c:forEach items="${empRow.leaveData}" var="ld">
                                        <option value="${ld.leaveTypeName}"
                                                data-approved="${ld.totalApprovedDays}"
                                                data-pending="${ld.totalPendingDays}"
                                                data-remaining="${ld.remainingDays}">
                                            ${ld.leaveTypeName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </td>
                            <td class="val-approved">–</td>
                            <td class="val-pending">–</td>
                            <td class="val-remaining">–</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
                <div id="emptyState" class="empty-state" style="display:none;">Không tìm thấy nhân viên nào.</div>
            </div>

            <div class="pagination">
                <div class="pagination-info" id="paginationInfo"></div>
                <div class="pagination-buttons" id="paginationButtons"></div>
            </div>
        </div>
    </div>
</div>

<script>
    /* ── Update 1 hàng khi đổi dropdown loại phép ── */
    function updateSummaryRow(tr) {
        const sel = tr.querySelector('.row-type-select');
        const opt = sel.options[sel.selectedIndex];
        if (!opt) return;
        const approved  = parseFloat(opt.dataset.approved)  || 0;
        const pending   = parseFloat(opt.dataset.pending)   || 0;
        const remaining = parseFloat(opt.dataset.remaining) || 0;

        const fmtDay = v => v === 0 ? '0' : v.toFixed(1).replace('.0','') + ' ngày';

        const aprEl = tr.querySelector('.val-approved');
        aprEl.innerHTML = approved > 0
            ? '<span class="badge-g">' + fmtDay(approved) + '</span>' : '0';

        const penEl = tr.querySelector('.val-pending');
        penEl.innerHTML = pending > 0
            ? '<span class="badge-y">' + fmtDay(pending) + '</span>' : '0';

        const remEl = tr.querySelector('.val-remaining');
        remEl.innerHTML = '<span class="badge-b">' + fmtDay(remaining) + '</span>';
        if (remaining <= 0) remEl.querySelector('span').style.cssText='color:#991b1b;background:#fee2e2;';
    }

    /* ── Pagination ── */
    const PAGE_SIZE = 10;
    let currentPage = 1, filtered = [];
    const allRows = Array.from(document.querySelectorAll('#tableBody tr'));

    function applyFilter() {
        const kw = document.getElementById('searchInput').value.trim().toLowerCase();
        filtered = allRows.filter(r =>
            !kw ||
            (r.dataset.name||'').toLowerCase().includes(kw) ||
            (r.dataset.code||'').toLowerCase().includes(kw) ||
            (r.dataset.dept||'').toLowerCase().includes(kw)
        );
        currentPage = 1;
        renderPage();
    }

    function renderPage() {
        const total = filtered.length, tp = Math.max(1, Math.ceil(total/PAGE_SIZE));
        if (currentPage > tp) currentPage = tp;
        const s = (currentPage-1)*PAGE_SIZE, e = Math.min(s+PAGE_SIZE, total);
        allRows.forEach(r => r.style.display='none');
        filtered.slice(s,e).forEach(r => r.style.display='');
        document.getElementById('emptyState').style.display   = total===0?'block':'none';
        document.getElementById('summaryTable').style.display = total===0?'none':'';
        document.getElementById('paginationInfo').textContent =
            total===0 ? 'Không có kết quả' : 'Hiển thị '+(s+1)+'–'+e+' / '+total+' nhân viên';
        buildPager(tp);
    }

    function buildPager(tp) {
        const c = document.getElementById('paginationButtons');
        c.innerHTML = '';
        c.appendChild(mkBtn('‹', currentPage===1, ()=>go(currentPage-1)));
        pageRange(currentPage,tp).forEach(p => {
            if (p==='...') { const s=document.createElement('span'); s.textContent='…'; s.style.cssText='padding:0 4px;color:var(--muted);font-size:13px;'; c.appendChild(s); }
            else { const b=mkBtn(p,false,()=>go(p)); if(p===currentPage) b.classList.add('active'); c.appendChild(b); }
        });
        c.appendChild(mkBtn('›', currentPage===tp, ()=>go(currentPage+1)));
    }
    function mkBtn(l,d,fn) { const b=document.createElement('button'); b.className='page-btn'; b.textContent=l; b.disabled=d; if(!d) b.addEventListener('click',fn); return b; }
    function go(p) { currentPage=p; renderPage(); }
    function pageRange(c,t) {
        if(t<=7) return Array.from({length:t},(_,i)=>i+1);
        if(c<=4) return [...Array.from({length:5},(_,i)=>i+1),'...',t];
        if(c>=t-3) return [1,'...',...Array.from({length:5},(_,i)=>t-4+i)];
        return [1,'...',c-1,c,c+1,'...',t];
    }

    /* ── Init ── */
    allRows.forEach(tr => updateSummaryRow(tr));
    filtered = allRows;
    renderPage();
</script>
</body>
</html>
