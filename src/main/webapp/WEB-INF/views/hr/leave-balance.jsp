<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Quản lý Quỹ phép | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <style>
        .toolbar { display:flex; gap:10px; align-items:center; margin-bottom:16px; flex-wrap:wrap; }
        .toolbar-search { flex:1; min-width:200px; position:relative; }
        .toolbar-search input {
            width:100%; padding:8px 12px 8px 36px; border:1px solid var(--border);
            border-radius:8px; font-size:13px; font-family:inherit; color:var(--text);
            background:var(--white); box-sizing:border-box; transition:border-color .15s,box-shadow .15s;
        }
        .toolbar-search input:focus { outline:none; border-color:var(--brand); box-shadow:0 0 0 3px rgba(79,70,229,.12); }
        .toolbar-search .icon-search { position:absolute; left:10px; top:50%; transform:translateY(-50%); color:var(--muted); font-size:15px; pointer-events:none; }
        .card-top { display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; }
        .row-type-select {
            padding:5px 10px; border:1px solid var(--border); border-radius:6px;
            font-size:13px; font-family:inherit; color:var(--text); background:var(--white); cursor:pointer;
        }
        .progress-wrap { display:flex; align-items:center; gap:8px; min-width:130px; }
        .progress-bar { flex:1; height:6px; background:#e5e7eb; border-radius:99px; overflow:hidden; }
        .progress-fill { height:100%; border-radius:99px; background:var(--brand); transition:width .3s; }
        .progress-fill.warning { background:#f59e0b; }
        .progress-fill.danger  { background:#ef4444; }
        .progress-pct { font-size:11px; color:var(--muted); white-space:nowrap; }
        .empty-state { text-align:center; padding:40px 0; color:var(--muted); font-size:14px; }
        .pagination { display:flex; align-items:center; justify-content:space-between; margin-top:16px; flex-wrap:wrap; gap:10px; }
        .pagination-info { font-size:13px; color:var(--muted); }
        .pagination-buttons { display:flex; gap:4px; align-items:center; }
        .page-btn { min-width:32px; height:32px; padding:0 8px; border:1px solid var(--border); border-radius:6px; background:var(--white); color:var(--text); font-size:13px; cursor:pointer; transition:background .15s,border-color .15s; display:inline-flex; align-items:center; justify-content:center; }
        .page-btn:hover:not(:disabled) { background:var(--bg); border-color:var(--brand); }
        .page-btn.active { background:var(--brand); color:#fff; border-color:var(--brand); font-weight:600; }
        .page-btn:disabled { opacity:.4; cursor:not-allowed; }
        .modal-overlay { display:none; position:fixed; inset:0; background:rgba(0,0,0,.45); z-index:1000; align-items:center; justify-content:center; }
        .modal-overlay.open { display:flex; }
        .modal { background:var(--white); border-radius:12px; padding:28px 32px; width:100%; max-width:440px; box-shadow:0 20px 60px rgba(0,0,0,.2); animation:slideUp .2s ease; }
        @keyframes slideUp { from{transform:translateY(24px);opacity:0} to{transform:translateY(0);opacity:1} }
        .modal h3 { margin:0 0 20px; font-size:16px; color:var(--text); }
        .modal-field { margin-bottom:14px; }
        .modal-field label { display:block; font-size:13px; font-weight:500; color:var(--text); margin-bottom:6px; }
        .modal-field input, .modal-field select { width:100%; padding:8px 12px; border:1px solid var(--border); border-radius:8px; font-size:13px; font-family:inherit; color:var(--text); background:var(--white); box-sizing:border-box; transition:border-color .15s; }
        .modal-field input:focus, .modal-field select:focus { outline:none; border-color:var(--brand); box-shadow:0 0 0 3px rgba(79,70,229,.12); }
        .modal-field input[readonly] { background:#f9fafb; color:var(--muted); }
        .modal-actions { display:flex; gap:10px; justify-content:flex-end; margin-top:20px; }
        .toast { position:fixed; top:20px; right:20px; padding:12px 20px; border-radius:8px; font-size:13px; font-weight:500; color:#fff; z-index:2000; animation:fadeIn .3s ease; box-shadow:0 4px 16px rgba(0,0,0,.15); }
        .toast.success { background:#10b981; }
        .toast.error   { background:#ef4444; }
        .toast.info    { background:#3b82f6; }
        @keyframes fadeIn { from{opacity:0;transform:translateY(-8px)} to{opacity:1;transform:translateY(0)} }
        .field-hint { font-size:11px; color:var(--muted); margin-top:4px; display:block; }
    </style>
</head>
<body>
<div class="main-layout">
    <%@ include file="/WEB-INF/common/sidebar.jsp" %>
    <div class="content-area">

        <div class="page-header">
            <div>
                <h1>Quản lý Quỹ phép</h1>
                <div class="subtitle">Xem và điều chỉnh số ngày phép của nhân viên</div>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/admin/leave-types" class="btn btn-secondary btn-sm" style="display:inline-flex;align-items:center;gap:6px;height:36px;font-weight:500;">
                    ⚙️ Cấu hình loại phép
                </a>
            </div>
        </div>

        <%-- Toast --%>
        <c:if test="${not empty msg}">
            <c:choose>
                <c:when test="${msg eq 'update_ok'}">   <div class="toast success" id="toast">✓ Cập nhật quỹ phép thành công</div></c:when>
                <c:when test="${msg eq 'create_ok'}">   <div class="toast success" id="toast">✓ Thêm quỹ phép thành công</div></c:when>
                <c:when test="${msg eq 'reset_ok'}">    <div class="toast success" id="toast">✓ Reset toàn bộ quỹ phép thành công</div></c:when>
                <c:when test="${msg eq 'delete_ok'}">   <div class="toast success" id="toast">✓ Xóa quỹ phép thành công</div></c:when>
                <c:when test="${msg eq 'delete_fail'}"> <div class="toast error"   id="toast">✗ Không thể xóa quỹ phép này</div></c:when>
                <c:when test="${msg eq 'duplicate'}">   <div class="toast error"   id="toast">✗ Bản ghi đã tồn tại cho nhân viên này</div></c:when>
                <c:when test="${msg eq 'invalid_input'}"><div class="toast error"   id="toast">✗ Dữ liệu nhập không hợp lệ</div></c:when>
                <c:when test="${msg eq 'no_records_added'}"><div class="toast info"  id="toast">ℹ️ Không có bản ghi mới nào được tạo thêm</div></c:when>
                <c:otherwise>                           <div class="toast error"   id="toast">✗ Có lỗi xảy ra, vui lòng thử lại</div></c:otherwise>
            </c:choose>
        </c:if>

        <div class="card">
            <div class="card-top">
                <div class="toolbar" style="margin-bottom:0;flex:1;">
                    <div class="toolbar-search">
                        <span class="icon-search">&#9906;</span>
                        <input type="text" id="searchInput" placeholder="Tìm theo tên nhân viên..." oninput="applyFilters()">
                    </div>
                </div>
                <div style="display:flex;gap:8px;margin-left:12px;flex-shrink:0;">
                    <button class="btn btn-primary btn-sm" onclick="openCreateModal()">+ Thêm mới</button>
                    <button class="btn btn-danger  btn-sm" onclick="confirmReset()">↺ Reset đầu năm</button>
                </div>
            </div>

            <div class="table-wrap">
                <table id="balanceTable">
                    <thead>
                    <tr>
                        <th>#</th>
                        <th>Nhân viên</th>
                        <th>Loại phép</th>
                        <th>Tổng ngày</th>
                        <th>Đã dùng</th>
                        <th>Còn lại</th>
                        <th>Sử dụng</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody id="tableBody">
                    <c:forEach items="${balanceRows}" var="row" varStatus="st">
                        <tr data-employee="${row.employeeName}">
                            <td>${st.count}</td>
                            <td><strong>${row.employeeName}</strong></td>
                            <td>
                                <select class="row-type-select" onchange="updateRowUI(this.closest('tr'))">
                                    <c:forEach items="${row.balances}" var="b">
                                        <option value="${b.id}"
                                                data-id="${b.id}"
                                                data-empname="${row.employeeName}"
                                                data-typename="${b.leaveTypeName}"
                                                data-used="${b.usedDays}"
                                                data-remaining="${b.remainingDays}">
                                            ${b.leaveTypeName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </td>
                            <td class="val-total">–</td>
                            <td class="val-used">–</td>
                            <td class="val-remaining">–</td>
                            <td>
                                <div class="progress-wrap">
                                    <div class="progress-bar"><div class="progress-fill" style="width:0%"></div></div>
                                    <span class="progress-pct">0%</span>
                                </div>
                            </td>
                            <td>
                                <button class="btn btn-secondary btn-sm" onclick="openEditFromRow(this)">Sửa</button>
                                <button class="btn btn-danger btn-sm" onclick="deleteFromRow(this)" style="margin-left:4px;">Xóa</button>
                            </td>
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

<%-- MODAL: Sửa --%>
<div class="modal-overlay" id="editOverlay">
    <div class="modal">
        <h3>✏️ Chỉnh sửa Quỹ phép</h3>
        <form method="post" action="${pageContext.request.contextPath}/hr/leave-balance">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="editId">
            <div class="modal-field">
                <label>Nhân viên</label>
                <input type="text" id="editEmployeeName" readonly>
            </div>
            <div class="modal-field">
                <label>Loại phép</label>
                <input type="text" id="editLeaveTypeName" readonly>
            </div>
            <div class="modal-field">
                <label>Số ngày đã dùng</label>
                <input type="number" name="usedDays" id="editUsedDays" min="0" step="0.5" required>
            </div>
            <div class="modal-field">
                <label>Số ngày còn lại</label>
                <input type="number" name="remainingDays" id="editRemainingDays" min="0" step="0.5" required>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" onclick="closeModal('editOverlay')">Hủy</button>
                <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<%-- MODAL: Thêm mới --%>
<div class="modal-overlay" id="createOverlay">
    <div class="modal">
        <h3>➕ Thêm Quỹ phép</h3>
        <form method="post" action="${pageContext.request.contextPath}/hr/leave-balance">
            <input type="hidden" name="action" value="create">
            
            <div class="modal-field">
                <label>Phạm vi áp dụng</label>
                <select name="scope" id="createScope" onchange="toggleScopeFields()" required>
                    <option value="one">Một nhân viên cụ thể</option>
                    <option value="dept">Theo phòng ban</option>
                    <option value="all">Tất cả nhân viên hoạt động</option>
                </select>
            </div>

            <div class="modal-field" id="fieldEmployee">
                <label>Tìm nhân viên</label>
                <input type="text" id="createEmpSearch" list="empDatalist" placeholder="Gõ tên hoặc mã NV" autocomplete="off" oninput="syncEmpId()" required>
                <datalist id="empDatalist">
                    <c:forEach items="${employees}" var="emp">
                        <option data-id="${emp.employeeId}" value="${emp.employeeCode} – ${emp.fullName}"></option>
                    </c:forEach>
                </datalist>
                <input type="hidden" name="employeeId" id="createEmpId">
                <small id="empHint" class="field-hint"></small>
            </div>

            <div class="modal-field" id="fieldDepartment" style="display:none;">
                <label>Phòng ban</label>
                <select name="departmentId" id="createDeptId">
                    <option value="">-- Chọn phòng ban --</option>
                    <c:forEach items="${departments}" var="dept">
                        <option value="${dept.id}">${dept.name}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="modal-field">
                <label>Loại phép</label>
                <select name="leaveTypeId" id="createLeaveTypeSelect" onchange="onLeaveTypeChange()" required>
                    <option value="">-- Chọn loại phép --</option>
                    <c:forEach items="${leaveTypes}" var="ltype">
                        <option value="${ltype.id}" data-days="${ltype.daysPerYear != null ? ltype.daysPerYear : ''}">
                            ${ltype.name} (${ltype.daysPerYear != null ? ltype.daysPerYear : '∞'} ngày/năm)
                        </option>
                    </c:forEach>
                </select>
            </div>
            
            <div class="modal-field">
                <label>Số ngày được phép (tổng)</label>
                <input type="number" name="totalDays" id="createTotalDays" min="0" step="0.5" placeholder="Ví dụ: 12" required>
            </div>
            
            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" onclick="closeCreate()">Hủy</button>
                <button type="submit" class="btn btn-primary">Thêm mới</button>
            </div>
        </form>
    </div>
</div>

<%-- FORM ẨN: Reset --%>
<form id="resetForm" method="post" action="${pageContext.request.contextPath}/hr/leave-balance" style="display:none;">
    <input type="hidden" name="action" value="reset">
</form>

<script>
    /* ── Cập nhật UI một hàng khi đổi loại phép ── */
    function updateRowUI(tr) {
        const sel = tr.querySelector('.row-type-select');
        if (!sel) return;
        const opt = sel.options[sel.selectedIndex];
        if (!opt) return;
        const used      = parseFloat(opt.dataset.used)      || 0;
        const remaining = parseFloat(opt.dataset.remaining)  || 0;
        const total     = used + remaining;
        const pct       = total > 0 ? Math.round(used / total * 100) : 0;

        tr.querySelector('.val-total').textContent     = total.toFixed(1).replace('.0','');
        tr.querySelector('.val-used').textContent      = used.toFixed(1).replace('.0','');
        const remEl = tr.querySelector('.val-remaining');
        remEl.textContent  = remaining.toFixed(1).replace('.0','');
        remEl.style.color  = remaining <= 0 ? '#ef4444' : '';
        remEl.style.fontWeight = remaining <= 0 ? 'bold' : '';

        const fill = tr.querySelector('.progress-fill');
        fill.style.width = pct + '%';
        fill.className = 'progress-fill' + (pct >= 90 ? ' danger' : pct >= 60 ? ' warning' : '');
        tr.querySelector('.progress-pct').textContent = pct + '%';
    }

    /* ── Pagination ── */
    const PAGE_SIZE = 10;
    let currentPage = 1;
    let filtered = [];
    const allRows = Array.from(document.querySelectorAll('#tableBody tr'));

    function applyFilters() {
        const kw = document.getElementById('searchInput').value.trim().toLowerCase();
        filtered = allRows.filter(r => !kw || (r.dataset.employee||'').toLowerCase().includes(kw));
        currentPage = 1;
        renderPage();
    }

    function renderPage() {
        const total = filtered.length, totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
        if (currentPage > totalPages) currentPage = totalPages;
        const start = (currentPage-1)*PAGE_SIZE, end = Math.min(start+PAGE_SIZE, total);
        allRows.forEach(r => r.style.display = 'none');
        filtered.slice(start, end).forEach(r => r.style.display = '');
        document.getElementById('emptyState').style.display   = total === 0 ? 'block' : 'none';
        document.getElementById('balanceTable').style.display = total === 0 ? 'none'  : '';
        document.getElementById('paginationInfo').textContent =
            total === 0 ? 'Không có kết quả' : 'Hiển thị '+(start+1)+'–'+end+' / '+total+' nhân viên';
        buildPager(totalPages);
    }

    function buildPager(tp) {
        const c = document.getElementById('paginationButtons');
        c.innerHTML = '';
        c.appendChild(mkBtn('‹', currentPage===1, ()=>go(currentPage-1)));
        pageRange(currentPage, tp).forEach(p => {
            if (p==='...') { const s=document.createElement('span'); s.textContent='…'; s.style.cssText='padding:0 4px;color:var(--muted);font-size:13px;'; c.appendChild(s); }
            else { const b=mkBtn(p,false,()=>go(p)); if(p===currentPage) b.classList.add('active'); c.appendChild(b); }
        });
        c.appendChild(mkBtn('›', currentPage===tp, ()=>go(currentPage+1)));
    }
    function mkBtn(l,d,fn) { const b=document.createElement('button'); b.className='page-btn'; b.textContent=l; b.disabled=d; if(!d) b.addEventListener('click',fn); return b; }
    function go(p) { currentPage=p; renderPage(); }
    function pageRange(cur,tot) {
        if(tot<=7) return Array.from({length:tot},(_,i)=>i+1);
        if(cur<=4) return [...Array.from({length:5},(_,i)=>i+1),'...',tot];
        if(cur>=tot-3) return [1,'...',...Array.from({length:5},(_,i)=>tot-4+i)];
        return [1,'...',cur-1,cur,cur+1,'...',tot];
    }

    /* ── Modal Edit ── */
    function openEditFromRow(btn) {
        const tr  = btn.closest('tr');
        const sel = tr.querySelector('.row-type-select');
        const opt = sel.options[sel.selectedIndex];
        document.getElementById('editId').value            = opt.dataset.id;
        document.getElementById('editEmployeeName').value  = opt.dataset.empname;
        document.getElementById('editLeaveTypeName').value = opt.dataset.typename;
        document.getElementById('editUsedDays').value      = opt.dataset.used;
        document.getElementById('editRemainingDays').value = opt.dataset.remaining;
        document.getElementById('editOverlay').classList.add('open');
    }
    function closeModal(id) { document.getElementById(id).classList.remove('open'); }

    /* ── Modal Create ── */
    function openCreateModal() { document.getElementById('createOverlay').classList.add('open'); }
    function closeCreate() {
        document.getElementById('createOverlay').classList.remove('open');
        document.getElementById('createScope').value = 'one';
        toggleScopeFields();
        ['createEmpSearch','createEmpId','createTotalDays','createLeaveTypeSelect'].forEach(id => {
            const el = document.getElementById(id);
            if(el) el.value = '';
        });
        document.getElementById('empHint').textContent = '';
    }
    function syncEmpId() {
        const val = document.getElementById('createEmpSearch').value;
        const opts = document.getElementById('empDatalist').options;
        const hidden = document.getElementById('createEmpId');
        const hint   = document.getElementById('empHint');
        let found = false;
        for (let i=0;i<opts.length;i++) {
            if (opts[i].value===val) {
                hidden.value = opts[i].dataset.id;
                hint.textContent='✓ Đã chọn (ID: '+hidden.value+')';
                hint.style.color='#10b981'; found=true; break;
            }
        }
        if (!found) { hidden.value=''; hint.textContent=val.trim()?'⚠ Chọn từ danh sách gợi ý':''; hint.style.color='#ef4444'; }
    }

    function toggleScopeFields() {
        const scope = document.getElementById('createScope').value;
        const fEmp = document.getElementById('fieldEmployee');
        const fDept = document.getElementById('fieldDepartment');
        const empSearch = document.getElementById('createEmpSearch');
        const deptId = document.getElementById('createDeptId');

        if (scope === 'one') {
            fEmp.style.display = 'block';
            fDept.style.display = 'none';
            empSearch.required = true;
            deptId.required = false;
        } else if (scope === 'dept') {
            fEmp.style.display = 'none';
            fDept.style.display = 'block';
            empSearch.required = false;
            deptId.required = true;
        } else {
            fEmp.style.display = 'none';
            fDept.style.display = 'none';
            empSearch.required = false;
            deptId.required = false;
        }
    }

    function onLeaveTypeChange() {
        const select = document.getElementById('createLeaveTypeSelect');
        const opt = select.options[select.selectedIndex];
        if (opt) {
            const days = opt.dataset.days;
            if (days) {
                document.getElementById('createTotalDays').value = days;
            } else {
                document.getElementById('createTotalDays').value = '';
            }
        }
    }

    function deleteFromRow(btn) {
        const tr = btn.closest('tr');
        const sel = tr.querySelector('.row-type-select');
        const opt = sel.options[sel.selectedIndex];
        if (!opt) return;
        const id = opt.dataset.id;
        const empName = opt.dataset.empname;
        const typeName = opt.dataset.typename;
        
        if (confirm('Bạn có chắc chắn muốn xóa quỹ phép "' + typeName + '" của nhân viên "' + empName + '" không?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/hr/leave-balance';
            
            const actInput = document.createElement('input');
            actInput.type = 'hidden';
            actInput.name = 'action';
            actInput.value = 'delete';
            form.appendChild(actInput);
            
            const idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'id';
            idInput.value = id;
            form.appendChild(idInput);
            
            document.body.appendChild(form);
            form.submit();
        }
    }

    /* ── Reset ── */
    function confirmReset() {
        if (confirm('⚠️ Reset toàn bộ quỹ phép về đầu năm?\n\nHành động này không thể hoàn tác!'))
            document.getElementById('resetForm').submit();
    }

    /* ── Overlay click ── */
    ['editOverlay','createOverlay'].forEach(id => {
        document.getElementById(id).addEventListener('click', function(e) { if(e.target===this) this.classList.remove('open'); });
    });

    /* ── Toast ── */
    const toast = document.getElementById('toast');
    if (toast) setTimeout(()=>toast.remove(), 4000);

    /* ── Init ── */
    allRows.forEach(tr => updateRowUI(tr));
    filtered = allRows;
    renderPage();
</script>
</body>
</html>
