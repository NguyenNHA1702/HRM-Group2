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
        /* ── Toolbar ── */
        .toolbar {
            display: flex; gap: 10px; align-items: center;
            margin-bottom: 16px; flex-wrap: wrap;
        }
        .toolbar-search { flex: 1; min-width: 200px; position: relative; }
        .toolbar-search input {
            width: 100%; padding: 8px 12px 8px 36px;
            border: 1px solid var(--border); border-radius: 8px;
            font-size: 13px; font-family: inherit; color: var(--text);
            background: var(--white); box-sizing: border-box;
            transition: border-color .15s, box-shadow .15s;
        }
        .toolbar-search input:focus {
            outline: none; border-color: var(--brand);
            box-shadow: 0 0 0 3px rgba(79,70,229,.12);
        }
        .toolbar-search .icon-search {
            position: absolute; left: 10px; top: 50%;
            transform: translateY(-50%);
            color: var(--muted); font-size: 15px; pointer-events: none;
        }
        .toolbar select {
            padding: 8px 12px; border: 1px solid var(--border);
            border-radius: 8px; font-size: 13px; font-family: inherit;
            color: var(--text); background: var(--white); cursor: pointer;
            transition: border-color .15s;
        }
        .toolbar select:focus {
            outline: none; border-color: var(--brand);
            box-shadow: 0 0 0 3px rgba(79,70,229,.12);
        }

        /* ── Progress bar ── */
        .progress-wrap { display: flex; align-items: center; gap: 8px; min-width: 140px; }
        .progress-bar {
            flex: 1; height: 6px; background: #e5e7eb;
            border-radius: 99px; overflow: hidden;
        }
        .progress-fill {
            height: 100%; border-radius: 99px;
            background: var(--brand); transition: width .3s;
        }
        .progress-fill.warning { background: #f59e0b; }
        .progress-fill.danger  { background: #ef4444; }
        .progress-pct { font-size: 11px; color: var(--muted); white-space: nowrap; }

        /* ── Badges ── */
        .badge-paid    { color: #166534; background: #dcfce7; padding: 2px 8px; border-radius: 99px; font-size: 11px; }
        .badge-unpaid  { color: #92400e; background: #fef3c7; padding: 2px 8px; border-radius: 99px; font-size: 11px; }

        /* ── Empty state ── */
        .empty-state { text-align: center; padding: 40px 0; color: var(--muted); font-size: 14px; }

        /* ── Pagination ── */
        .pagination {
            display: flex; align-items: center; justify-content: space-between;
            margin-top: 16px; flex-wrap: wrap; gap: 10px;
        }
        .pagination-info { font-size: 13px; color: var(--muted); }
        .pagination-buttons { display: flex; gap: 4px; align-items: center; }
        .page-btn {
            min-width: 32px; height: 32px; padding: 0 8px;
            border: 1px solid var(--border); border-radius: 6px;
            background: var(--white); color: var(--text);
            font-size: 13px; cursor: pointer;
            transition: background .15s, border-color .15s;
            display: inline-flex; align-items: center; justify-content: center;
        }
        .page-btn:hover:not(:disabled) { background: var(--bg); border-color: var(--brand); }
        .page-btn.active { background: var(--brand); color: #fff; border-color: var(--brand); font-weight: 600; }
        .page-btn:disabled { opacity: 0.4; cursor: not-allowed; }

        /* ── Card header with button ── */
        .card-top {
            display: flex; align-items: center;
            justify-content: space-between; margin-bottom: 14px;
        }

        /* ── Modal ── */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,.45); z-index: 1000;
            align-items: center; justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal {
            background: var(--white); border-radius: 12px;
            padding: 28px 32px; width: 100%; max-width: 440px;
            box-shadow: 0 20px 60px rgba(0,0,0,.2);
            animation: slideUp .2s ease;
        }
        @keyframes slideUp {
            from { transform: translateY(24px); opacity: 0; }
            to   { transform: translateY(0);    opacity: 1; }
        }
        .modal h3 { margin: 0 0 20px; font-size: 16px; color: var(--text); }
        .modal-field { margin-bottom: 14px; }
        .modal-field label { display: block; font-size: 13px; font-weight: 500; color: var(--text); margin-bottom: 6px; }
        .modal-field input, .modal-field select {
            width: 100%; padding: 8px 12px; border: 1px solid var(--border);
            border-radius: 8px; font-size: 13px; font-family: inherit;
            color: var(--text); background: var(--white);
            box-sizing: border-box; transition: border-color .15s;
        }
        .modal-field input:focus, .modal-field select:focus {
            outline: none; border-color: var(--brand);
            box-shadow: 0 0 0 3px rgba(79,70,229,.12);
        }
        .modal-field input[readonly] { background: #f9fafb; color: var(--muted); }
        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; }

        /* ── Toast ── */
        .toast {
            position: fixed; top: 20px; right: 20px;
            padding: 12px 20px; border-radius: 8px;
            font-size: 13px; font-weight: 500; color: #fff;
            z-index: 2000; animation: fadeIn .3s ease;
            box-shadow: 0 4px 16px rgba(0,0,0,.15);
        }
        .toast.success { background: #10b981; }
        .toast.error   { background: #ef4444; }
        .toast.info    { background: #6366f1; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-8px); } to { opacity: 1; transform: translateY(0); } }
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
        </div>

        <%-- Toast notification --%>
        <c:if test="${not empty msg}">
            <c:choose>
                <c:when test="${msg eq 'update_ok'}">   <div class="toast success" id="toast">✓ Cập nhật quỹ phép thành công</div></c:when>
                <c:when test="${msg eq 'create_ok'}">   <div class="toast success" id="toast">✓ Thêm quỹ phép mới thành công</div></c:when>
                <c:when test="${msg eq 'reset_ok'}">    <div class="toast success" id="toast">✓ Reset toàn bộ quỹ phép thành công</div></c:when>
                <c:when test="${msg eq 'duplicate'}">   <div class="toast error"   id="toast">✗ Bản ghi đã tồn tại cho nhân viên này</div></c:when>
                <c:when test="${msg eq 'invalid_input'}"><div class="toast error"   id="toast">✗ Dữ liệu nhập không hợp lệ</div></c:when>
                <c:otherwise>                           <div class="toast error"   id="toast">✗ Có lỗi xảy ra, vui lòng thử lại</div></c:otherwise>
            </c:choose>
        </c:if>

        <div class="card">

            <%-- Card top: toolbar + buttons --%>
            <div class="card-top">
                <div class="toolbar" style="margin-bottom:0; flex: 1;">
                    <div class="toolbar-search">
                        <span class="icon-search">&#9906;</span>
                        <input type="text" id="searchInput"
                               placeholder="Tìm theo tên nhân viên..."
                               oninput="applyFilters()">
                    </div>
                    <select id="typeFilter" onchange="applyFilters()">
                        <option value="">Tất cả loại phép</option>
                        <c:forEach items="${leaveTypes}" var="ltype">
                            <option value="${ltype.name}">${ltype.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div style="display:flex; gap:8px; margin-left:12px; flex-shrink:0;">
                    <button class="btn btn-primary btn-sm" onclick="openCreateModal()">+ Thêm mới</button>
                    <button class="btn btn-danger  btn-sm" onclick="confirmReset()">↺ Reset đầu năm</button>
                </div>
            </div>

            <%-- Table --%>
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
                        <tr data-employee="${row.employeeName}" data-type="">
                            <td>${st.count}</td>
                            <td><strong>${row.employeeName}</strong></td>
                            <td>
                                <select class="row-type-select" onchange="onRowTypeChange(this)" style="padding: 6px 10px; border: 1px solid var(--border); border-radius: 6px; font-size: 13px; font-family: inherit; color: var(--text); background: var(--white); cursor: pointer;">
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
                            <td><span class="total-days-val">0</span></td>
                            <td><span class="used-days-val">0</span></td>
                            <td>
                                <span class="remaining-days-val">0</span>
                            </td>
                            <td>
                                <div class="progress-wrap">
                                    <div class="progress-bar">
                                        <div class="progress-fill" style="width:0%"></div>
                                    </div>
                                    <span class="progress-pct">0%</span>
                                </div>
                            </td>
                            <td>
                                <button class="btn btn-secondary btn-sm edit-btn"
                                        onclick="openEditModalFromRow(this)">
                                    Sửa
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>

                <div id="emptyState" class="empty-state" style="display:none;">
                    Không tìm thấy bản ghi nào phù hợp.
                </div>
            </div>

            <%-- Pagination --%>
            <div class="pagination">
                <div class="pagination-info" id="paginationInfo"></div>
                <div class="pagination-buttons" id="paginationButtons"></div>
            </div>

        </div><%-- /card --%>
    </div><%-- /content-area --%>
</div><%-- /main-layout --%>

<%-- ═══════════════════ MODAL: Chỉnh sửa ═══════════════════ --%>
<div class="modal-overlay" id="editOverlay">
    <div class="modal">
        <h3>✏️ Chỉnh sửa Quỹ phép</h3>
        <form method="post" action="${pageContext.request.contextPath}/hr/leave-balance">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id"     id="editId">

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
                <input type="number" name="usedDays" id="editUsedDays"
                       min="0" step="0.5" required>
            </div>
            <div class="modal-field">
                <label>Số ngày còn lại</label>
                <input type="number" name="remainingDays" id="editRemainingDays"
                       min="0" step="0.5" required>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" onclick="closeEditModal()">Hủy</button>
                <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<%-- ═══════════════════ MODAL: Thêm mới ═══════════════════ --%>
<div class="modal-overlay" id="createOverlay">
    <div class="modal">
        <h3>➕ Thêm Quỹ phép mới</h3>
        <form method="post" action="${pageContext.request.contextPath}/hr/leave-balance">
            <input type="hidden" name="action" value="create">

            <div class="modal-field">
                <label>Tìm nhân viên (gõ tên hoặc mã NV)</label>
                <input type="text"
                       id="createEmployeeSearch"
                       list="employeeDatalist"
                       placeholder="Ví dụ: Nguyễn Văn A hoặc EMP001"
                       autocomplete="off"
                       oninput="syncEmployeeId()"
                       required>
                <datalist id="employeeDatalist">
                    <c:forEach items="${employees}" var="emp">
                        <option data-id="${emp.employeeId}"
                                value="${emp.employeeCode} – ${emp.fullName}">
                        </option>
                    </c:forEach>
                </datalist>
                <%-- Hidden field gửi ID thực lên server --%>
                <input type="hidden" name="employeeId" id="createEmployeeId">
                <small id="empLookupHint" style="color:var(--muted);font-size:11px;margin-top:4px;display:block;"></small>
            </div>
            <div class="modal-field">
                <label>Loại phép</label>
                <select name="leaveTypeId" id="createLeaveTypeId" required>
                    <option value="">-- Chọn loại phép --</option>
                    <c:forEach items="${leaveTypes}" var="ltype">
                        <option value="${ltype.id}">${ltype.name} (${ltype.daysPerYear != null ? ltype.daysPerYear : '∞'} ngày/năm)</option>
                    </c:forEach>
                </select>
            </div>
            <div class="modal-field">
                <label>Số ngày được phép (tổng)</label>
                <input type="number" name="totalDays" id="createTotalDays"
                       min="0" step="0.5" placeholder="Ví dụ: 12" required>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" onclick="closeCreateModal()">Hủy</button>
                <button type="submit" class="btn btn-primary">Thêm mới</button>
            </div>
        </form>
    </div>
</div>

<%-- ═══════════════════ FORM ẨN: Reset ═══════════════════ --%>
<form id="resetForm" method="post" action="${pageContext.request.contextPath}/hr/leave-balance" style="display:none;">
    <input type="hidden" name="action" value="reset">
</form>

<script>
    /* ─── Row UI Update Helper ─── */
    function updateRowUI(rowEl) {
        const select = rowEl.querySelector('.row-type-select');
        if (!select) return;
        const opt = select.options[select.selectedIndex];
        if (!opt) return;

        const used = parseFloat(opt.getAttribute('data-used')) || 0;
        const remaining = parseFloat(opt.getAttribute('data-remaining')) || 0;
        const total = used + remaining;
        const pct = total > 0 ? Math.round((used / total) * 100) : 0;

        // Update total
        rowEl.querySelector('.total-days-val').textContent = total.toFixed(1).replace('.0', '');
        // Update used
        rowEl.querySelector('.used-days-val').textContent = used.toFixed(1).replace('.0', '');
        // Update remaining
        const remainingValEl = rowEl.querySelector('.remaining-days-val');
        remainingValEl.textContent = remaining.toFixed(1).replace('.0', '');
        if (remaining <= 0) {
            remainingValEl.style.color = '#ef4444';
            remainingValEl.style.fontWeight = 'bold';
        } else {
            remainingValEl.style.color = 'inherit';
            remainingValEl.style.fontWeight = 'normal';
        }

        // Update progress bar
        const fill = rowEl.querySelector('.progress-fill');
        fill.style.width = pct + '%';
        fill.className = 'progress-fill'; // reset
        if (pct >= 90) fill.classList.add('danger');
        else if (pct >= 60) fill.classList.add('warning');

        rowEl.querySelector('.progress-pct').textContent = pct + '%';

        // Update row dataset type for filtering
        rowEl.dataset.type = opt.getAttribute('data-typename');
    }

    function onRowTypeChange(selectEl) {
        const rowEl = selectEl.closest('tr');
        updateRowUI(rowEl);
    }

    function openEditModalFromRow(buttonEl) {
        const rowEl = buttonEl.closest('tr');
        const select = rowEl.querySelector('.row-type-select');
        const opt = select.options[select.selectedIndex];
        
        const id = opt.getAttribute('data-id');
        const empName = opt.getAttribute('data-empname');
        const leaveType = opt.getAttribute('data-typename');
        const usedDays = opt.getAttribute('data-used');
        const remainingDays = opt.getAttribute('data-remaining');

        openEditModal(id, empName, leaveType, usedDays, remainingDays);
    }

    /* ─── Pagination ─── */
    const PAGE_SIZE = 10;
    let currentPage = 1;
    let filteredRows = [];
    const allRows = Array.from(document.querySelectorAll('#tableBody tr'));

    function applyFilters() {
        const keyword  = document.getElementById('searchInput').value.trim().toLowerCase();
        const typeVal  = document.getElementById('typeFilter').value;

        // If a specific type is filtered, pre-select it in all row dropdowns
        if (typeVal) {
            allRows.forEach(row => {
                const select = row.querySelector('.row-type-select');
                if (select) {
                    for (let i = 0; i < select.options.length; i++) {
                        if (select.options[i].getAttribute('data-typename') === typeVal) {
                            select.selectedIndex = i;
                            updateRowUI(row);
                            break;
                        }
                    }
                }
            });
        }

        filteredRows = allRows.filter(row => {
            const emp  = (row.dataset.employee || '').toLowerCase();
            const type = (row.dataset.type || '');
            return (!keyword || emp.includes(keyword)) &&
                   (!typeVal  || type === typeVal);
        });

        currentPage = 1;
        renderPage();
    }

    function renderPage() {
        const total      = filteredRows.length;
        const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
        if (currentPage > totalPages) currentPage = totalPages;

        const start = (currentPage - 1) * PAGE_SIZE;
        const end   = Math.min(start + PAGE_SIZE, total);

        allRows.forEach(r => r.style.display = 'none');
        filteredRows.forEach((r, i) => {
            r.style.display = (i >= start && i < end) ? '' : 'none';
        });

        document.getElementById('emptyState').style.display     = total === 0 ? 'block' : 'none';
        document.getElementById('balanceTable').style.display   = total === 0 ? 'none'  : '';
        document.getElementById('paginationInfo').textContent   =
            total === 0 ? 'Không có kết quả'
                        : 'Hiển thị ' + (start+1) + '–' + end + ' / ' + total + ' bản ghi';

        renderPaginationButtons(totalPages);
    }

    function renderPaginationButtons(totalPages) {
        const c = document.getElementById('paginationButtons');
        c.innerHTML = '';
        c.appendChild(makeBtn('‹', currentPage === 1, () => goToPage(currentPage - 1)));
        getPageRange(currentPage, totalPages).forEach(p => {
            if (p === '...') {
                const s = document.createElement('span');
                s.textContent = '…'; s.style.cssText = 'padding:0 4px;color:var(--muted);font-size:13px;';
                c.appendChild(s);
            } else {
                const b = makeBtn(p, false, () => goToPage(p));
                if (p === currentPage) b.classList.add('active');
                c.appendChild(b);
            }
        });
        c.appendChild(makeBtn('›', currentPage === totalPages, () => goToPage(currentPage + 1)));
    }

    function makeBtn(label, disabled, onClick) {
        const b = document.createElement('button');
        b.className = 'page-btn'; b.textContent = label; b.disabled = disabled;
        if (!disabled) b.addEventListener('click', onClick);
        return b;
    }

    function goToPage(p) { currentPage = p; renderPage(); }

    function getPageRange(cur, tot) {
        if (tot <= 7) return Array.from({length: tot}, (_, i) => i + 1);
        if (cur <= 4) return [...Array.from({length: 5}, (_, i) => i + 1), '...', tot];
        if (cur >= tot - 3) return [1, '...', ...Array.from({length: 5}, (_, i) => tot - 4 + i)];
        return [1, '...', cur-1, cur, cur+1, '...', tot];
    }

    /* ─── Modal Edit ─── */
    function openEditModal(id, empName, leaveType, usedDays, remainingDays) {
        document.getElementById('editId').value             = id;
        document.getElementById('editEmployeeName').value  = empName;
        document.getElementById('editLeaveTypeName').value = leaveType;
        document.getElementById('editUsedDays').value      = usedDays;
        document.getElementById('editRemainingDays').value = remainingDays;
        document.getElementById('editOverlay').classList.add('open');
    }

    function closeEditModal() {
        document.getElementById('editOverlay').classList.remove('open');
    }

    /* ─── Modal Create ─── */
    function openCreateModal() {
        document.getElementById('createOverlay').classList.add('open');
    }

    function syncEmployeeId() {
        const searchInput = document.getElementById('createEmployeeSearch');
        const searchVal = searchInput.value;
        const datalist = document.getElementById('employeeDatalist');
        const options = datalist.options;
        const hiddenInput = document.getElementById('createEmployeeId');
        const hint = document.getElementById('empLookupHint');
        
        let found = false;
        for (let i = 0; i < options.length; i++) {
            if (options[i].value === searchVal) {
                const empId = options[i].getAttribute('data-id');
                hiddenInput.value = empId;
                hint.textContent = "✓ Đã chọn nhân viên (ID: " + empId + ")";
                hint.style.color = "#10b981";
                found = true;
                break;
            }
        }
        
        if (!found) {
            hiddenInput.value = "";
            if (searchVal.trim() === "") {
                hint.textContent = "";
            } else {
                hint.textContent = "⚠ Vui lòng chọn nhân viên từ danh sách gợi ý.";
                hint.style.color = "#ef4444";
            }
        }
    }

    function closeCreateModal() {
        document.getElementById('createOverlay').classList.remove('open');
        document.getElementById('createEmployeeSearch').value = '';
        document.getElementById('createEmployeeId').value = '';
        document.getElementById('createLeaveTypeId').value = '';
        document.getElementById('createTotalDays').value = '';
        document.getElementById('empLookupHint').textContent = '';
    }

    /* ─── Reset confirm ─── */
    function confirmReset() {
        if (confirm('⚠️ Bạn có chắc muốn RESET toàn bộ quỹ phép về giá trị đầu năm?\n\nHành động này sẽ đặt lại used_days = 0 và remaining_days = tổng ngày phép theo loại cho TẤT CẢ nhân viên.')) {
            document.getElementById('resetForm').submit();
        }
    }

    /* ─── Close modal on overlay click ─── */
    document.getElementById('editOverlay').addEventListener('click', function(e) {
        if (e.target === this) closeEditModal();
    });
    document.getElementById('createOverlay').addEventListener('click', function(e) {
        if (e.target === this) closeCreateModal();
    });

    /* ─── Toast auto-hide ─── */
    const toast = document.getElementById('toast');
    if (toast) setTimeout(() => toast.remove(), 4000);

    /* ─── Init ─── */
    allRows.forEach(row => updateRowUI(row));
    applyFilters();
</script>

</body>
</html>
