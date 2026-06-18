<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Cấu hình Loại nghỉ phép | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <style>
        /* ── Toolbar ── */
        .card-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
        .toolbar { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; flex: 1; }
        .toolbar-search { flex: 1; min-width: 200px; position: relative; }
        .toolbar-search input {
            width: 100%; padding: 8px 12px 8px 36px;
            border: 1px solid var(--border); border-radius: 8px;
            font-size: 13px; font-family: inherit; color: var(--text);
            background: var(--white); box-sizing: border-box;
            transition: border-color .15s, box-shadow .15s;
        }
        .toolbar-search input:focus { outline: none; border-color: var(--brand); box-shadow: 0 0 0 3px rgba(79,70,229,.12); }
        .toolbar-search .icon-search {
            position: absolute; left: 10px; top: 50%; transform: translateY(-50%);
            color: var(--muted); font-size: 15px; pointer-events: none;
        }

        /* ── Badges ── */
        .badge-active   { color: #166534; background: #dcfce7; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .badge-inactive { color: #6b7280; background: #f3f4f6; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .badge-paid   { color: #1e3a8a; background: #dbeafe; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .badge-unpaid { color: #92400e; background: #fef3c7; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }

        /* ── Empty state ── */
        .empty-state { text-align: center; padding: 40px 0; color: var(--muted); font-size: 14px; }

        /* ── Modal ── */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,.45); z-index: 1000;
            align-items: center; justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal {
            background: var(--white); border-radius: 14px;
            padding: 28px 32px; width: 100%; max-width: 480px;
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
        .modal-field input, .modal-field select, .modal-field textarea {
            width: 100%; padding: 8px 12px; border: 1px solid var(--border);
            border-radius: 8px; font-size: 13px; font-family: inherit;
            color: var(--text); background: var(--white);
            box-sizing: border-box; transition: border-color .15s;
        }
        .modal-field input:focus, .modal-field select:focus, .modal-field textarea:focus {
            outline: none; border-color: var(--brand); box-shadow: 0 0 0 3px rgba(79,70,229,.12);
        }
        .modal-field .field-hint { font-size: 11px; color: var(--muted); margin-top: 4px; display: block; }
        .modal-field .checkbox-row { display: flex; align-items: center; gap: 8px; }
        .modal-field .checkbox-row input[type=checkbox] { width: auto; }
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
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-8px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>

<div class="main-layout">
    <%@ include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">

        <div class="page-header">
            <div>
                <h1>Cấu hình Loại nghỉ phép</h1>
                <div class="subtitle">Quản lý các loại phép và hạn mức ngày phép trong năm</div>
            </div>
        </div>

        <%-- Toast notification --%>
        <c:if test="${not empty msg}">
            <c:choose>
                <c:when test="${msg eq 'create_ok'}">  <div class="toast success" id="toast">✓ Thêm loại phép mới thành công</div></c:when>
                <c:when test="${msg eq 'update_ok'}">  <div class="toast success" id="toast">✓ Cập nhật loại phép thành công</div></c:when>
                <c:when test="${msg eq 'toggle_ok'}">  <div class="toast success" id="toast">✓ Đã thay đổi trạng thái</div></c:when>
                <c:when test="${msg eq 'invalid_input'}"><div class="toast error"   id="toast">✗ Dữ liệu không hợp lệ</div></c:when>
                <c:otherwise>                          <div class="toast error"   id="toast">✗ Có lỗi xảy ra</div></c:otherwise>
            </c:choose>
        </c:if>

        <div class="card">
            <div class="card-top">
                <div class="toolbar">
                    <div class="toolbar-search">
                        <span class="icon-search">&#9906;</span>
                        <input type="text" id="searchInput" placeholder="Tìm theo tên hoặc mã loại phép..." oninput="applyFilter()">
                    </div>
                </div>
                <div style="margin-left: 12px; flex-shrink: 0;">
                    <button class="btn btn-primary btn-sm" onclick="openCreateModal()">+ Thêm loại phép</button>
                </div>
            </div>

            <div class="table-wrap">
                <table id="leaveTypeTable">
                    <thead>
                    <tr>
                        <th>#</th>
                        <th>Mã</th>
                        <th>Tên loại phép</th>
                        <th>Ngày phép / Năm</th>
                        <th>Có lương</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody id="tableBody">
                    <c:forEach items="${leaveTypes}" var="leaveType" varStatus="st">
                        <tr data-name="${leaveType.name}" data-code="${leaveType.code}">
                            <td>${st.count}</td>
                            <td><code>${leaveType.code}</code></td>
                            <td><strong>${leaveType.name}</strong></td>
                            <td>
                                <c:choose>
                                    <c:when test="${leaveType.daysPerYear != null}">
                                        ${leaveType.daysPerYear} ngày
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color:var(--muted);">Không giới hạn</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${leaveType.paid}"><span class="badge-paid">Có lương</span></c:when>
                                    <c:otherwise><span class="badge-unpaid">Không lương</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${leaveType.active}"><span class="badge-active">Đang dùng</span></c:when>
                                    <c:otherwise><span class="badge-inactive">Tạm dừng</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div style="display:flex;gap:6px;">
                                    <button class="btn btn-secondary btn-sm"
                                             onclick="openEditModal(${leaveType.id}, '${leaveType.code}', '${leaveType.name}', '${leaveType.daysPerYear != null ? leaveType.daysPerYear : ''}', ${leaveType.paid}, ${leaveType.active})">
                                        Sửa
                                    </button>
                                    <form method="post" action="${pageContext.request.contextPath}/admin/leave-types" style="display:inline;">
                                        <input type="hidden" name="action" value="toggle">
                                        <input type="hidden" name="id" value="${leaveType.id}">
                                        <button type="submit" class="btn btn-sm ${leaveType.active ? 'btn-danger' : 'btn-success'}"
                                                onclick="return confirm('${leaveType.active ? 'Tạm dừng' : 'Kích hoạt'} loại phép này?')">
                                            ${leaveType.active ? 'Tạm dừng' : 'Kích hoạt'}
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
                <div id="emptyState" class="empty-state" style="display:none;">Không tìm thấy loại phép nào.</div>
            </div>
        </div>
    </div>
</div>

<%-- ════ MODAL: Thêm mới ════ --%>
<div class="modal-overlay" id="createOverlay">
    <div class="modal">
        <h3>➕ Thêm loại nghỉ phép mới</h3>
        <form method="post" action="${pageContext.request.contextPath}/admin/leave-types">
            <input type="hidden" name="action" value="create">
            <div class="modal-field">
                <label>Mã loại phép <span style="color:#ef4444;">*</span></label>
                <input type="text" name="code" placeholder="Ví dụ: ANNUAL, SICK, UNPAID" required maxlength="30" style="text-transform:uppercase;">
                <span class="field-hint">Mã duy nhất, viết hoa, không dấu. Ví dụ: ANNUAL, SICK, MATERNITY</span>
            </div>
            <div class="modal-field">
                <label>Tên loại phép <span style="color:#ef4444;">*</span></label>
                <input type="text" name="name" placeholder="Ví dụ: Nghỉ phép năm" required maxlength="100">
            </div>
            <div class="modal-field">
                <label>Số ngày phép / Năm</label>
                <input type="number" name="daysPerYear" placeholder="Để trống = không giới hạn" min="0" step="0.5">
                <span class="field-hint">Để trống nếu là loại phép không giới hạn số ngày</span>
            </div>
            <div class="modal-field">
                <div class="checkbox-row">
                    <input type="checkbox" name="isPaid" id="createIsPaid" value="on">
                    <label for="createIsPaid" style="margin-bottom:0;">Có tính lương (Paid Leave)</label>
                </div>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" onclick="closeCreateModal()">Hủy</button>
                <button type="submit" class="btn btn-primary">Thêm mới</button>
            </div>
        </form>
    </div>
</div>

<%-- ════ MODAL: Chỉnh sửa ════ --%>
<div class="modal-overlay" id="editOverlay">
    <div class="modal">
        <h3>✏️ Chỉnh sửa Loại nghỉ phép</h3>
        <form method="post" action="${pageContext.request.contextPath}/admin/leave-types">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="editId">
            <div class="modal-field">
                <label>Mã loại phép <span style="color:#ef4444;">*</span></label>
                <input type="text" name="code" id="editCode" required maxlength="30" style="text-transform:uppercase;">
            </div>
            <div class="modal-field">
                <label>Tên loại phép <span style="color:#ef4444;">*</span></label>
                <input type="text" name="name" id="editName" required maxlength="100">
            </div>
            <div class="modal-field">
                <label>Số ngày phép / Năm</label>
                <input type="number" name="daysPerYear" id="editDaysPerYear" placeholder="Để trống = không giới hạn" min="0" step="0.5">
                <span class="field-hint">Thay đổi hạn mức này sẽ ảnh hưởng đến tính năng Reset phép đầu năm</span>
            </div>
            <div class="modal-field">
                <div class="checkbox-row">
                    <input type="checkbox" name="isPaid" id="editIsPaid" value="on">
                    <label for="editIsPaid" style="margin-bottom:0;">Có tính lương (Paid Leave)</label>
                </div>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" onclick="closeEditModal()">Hủy</button>
                <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<script>
    /* ─── Client-side filter ─── */
    const allRows = Array.from(document.querySelectorAll('#tableBody tr'));
    function applyFilter() {
        const q = document.getElementById('searchInput').value.trim().toLowerCase();
        let count = 0;
        allRows.forEach(row => {
            const name = (row.dataset.name || '').toLowerCase();
            const code = (row.dataset.code || '').toLowerCase();
            const match = !q || name.includes(q) || code.includes(q);
            row.style.display = match ? '' : 'none';
            if (match) count++;
        });
        document.getElementById('emptyState').style.display = count === 0 ? 'block' : 'none';
        document.getElementById('leaveTypeTable').style.display = count === 0 ? 'none' : '';
    }

    /* ─── Modal Create ─── */
    function openCreateModal() {
        document.getElementById('createOverlay').classList.add('open');
    }
    function closeCreateModal() {
        document.getElementById('createOverlay').classList.remove('open');
    }

    /* ─── Modal Edit ─── */
    function openEditModal(id, code, name, daysPerYear, isPaid, isActive) {
        document.getElementById('editId').value = id;
        document.getElementById('editCode').value = code;
        document.getElementById('editName').value = name;
        document.getElementById('editDaysPerYear').value = daysPerYear || '';
        document.getElementById('editIsPaid').checked = isPaid;
        document.getElementById('editOverlay').classList.add('open');
    }
    function closeEditModal() {
        document.getElementById('editOverlay').classList.remove('open');
    }

    /* ─── Close modals on overlay click ─── */
    document.getElementById('createOverlay').addEventListener('click', function(e) {
        if (e.target === this) closeCreateModal();
    });
    document.getElementById('editOverlay').addEventListener('click', function(e) {
        if (e.target === this) closeEditModal();
    });

    /* ─── Toast auto-hide ─── */
    const toast = document.getElementById('toast');
    if (toast) setTimeout(() => toast.remove(), 4000);
</script>

</body>
</html>