<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Quản lý Users</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"/>

    <style>
        :root {
            --sidebar-w:    240px;
            --topbar-h:     64px;

            --green:        #22c55e;
            --green-bg:     #dcfce7;
            --green-text:   #166534;
            --red:          #ef4444;
            --red-bg:       #fee2e2;
            --red-text:     #b91c1c;
            --blue:         #3b82f6;
            --blue-bg:      #dbeafe;
            --blue-text:    #1e40af;
            --indigo:       #6366f1;
            --indigo-bg:    #e0e7ff;
            --indigo-text:  #4338ca;
            --purple:       #8b5cf6;
            --purple-bg:    #f3e8ff;
            --purple-text:  #6b21a8;

            --btn:          #6c63ff;
            --btn-hv:       #5a52e0;

            --bg:           #f8fafc;
            --card:         #ffffff;
            --border:       #e5e7eb;
            --text:         #111827;
            --text-sub:     #6b7280;
            --text-muted:   #9ca3af;
            --radius:       12px;
            --shadow-sm:    0 1px 3px rgba(0,0,0,.06);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg);
            color: var(--text);
            display: flex;
            min-height: 100vh;
        }

        /* ====================== SIDEBAR ====================== */
        .sidebar {
            width: var(--sidebar-w);
            background: #1e2433;
            position: fixed;
            top: 0; left: 0; bottom: 0;
            z-index: 200;
            color: #94a3b8;
        }
        /* (Bạn có thể bổ sung nội dung sidebar nếu cần) */

        /* ====================== MAIN CONTENT ====================== */
        .main-wrapper {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .page-content {
            width: 100%;
            max-width: 1280px;
            padding: 40px 36px;
            flex: 1;
        }

        /* ====================== PAGE HEADER ====================== */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 28px;
        }
        .page-title {
            font-size: 24px;
            font-weight: 700;
            line-height: 1.2;
        }
        .page-sub {
            font-size: 13.5px;
            color: var(--text-sub);
            margin-top: 4px;
        }
        .bell-btn {
            position: relative;
            width: 42px; height: 42px;
            border-radius: 50%;
            background: white;
            border: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            color: #64748b;
        }
        .bell-badge {
            position: absolute;
            top: -4px; right: -4px;
            background: #ef4444;
            color: white;
            font-size: 10px;
            font-weight: 700;
            min-width: 18px;
            height: 18px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid white;
        }

        /* ====================== STATS GRID ====================== */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        .stat-card {
            background: white;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 24px 26px;
            box-shadow: var(--shadow-sm);
        }
        .stat-label {
            font-size: 13px;
            color: var(--text-sub);
            margin-bottom: 8px;
        }
        .stat-value {
            font-size: 36px;
            font-weight: 700;
            line-height: 1;
        }
        .stat-value.total    { color: #3b82f6; }
        .stat-value.active   { color: #22c55e; }
        .stat-value.inactive { color: #ef4444; }
        .stat-value.admin    { color: #6366f1; }

        /* ====================== TOOLBAR ====================== */
        .toolbar {
            background: white;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: var(--shadow-sm);
        }
        .toolbar-top {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 16px;
        }
        .search-box {
            flex: 1;
            position: relative;
            max-width: 460px;
        }
        .search-box i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
        }
        .search-box input {
            width: 100%;
            height: 48px;
            padding: 0 14px 0 42px;
            border: 1px solid var(--border);
            border-radius: 10px;
            font-size: 15px;
            background: #f8fafc;
        }
        .search-box input:focus {
            border-color: var(--btn);
            background: white;
            outline: none;
            box-shadow: 0 0 0 3px rgba(108,99,255,0.1);
        }

        .btn-primary {
            height: 48px;
            padding: 0 24px;
            background: var(--btn);
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 15px;
            box-shadow: 0 2px 8px rgba(108,99,255,0.3);
            transition: all 0.2s;
        }
        .btn-primary:hover {
            background: var(--btn-hv);
            transform: translateY(-1px);
        }

        /* Filters */
        .filters {
            display: flex;
            gap: 10px;
        }
        .filter-select {
            padding: 11px 34px 11px 14px;
            border: 1px solid var(--border);
            border-radius: 10px;
            background: #f8fafc url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='%239ca3af' viewBox='0 0 16 16'%3E%3Cpath d='M7.247 11.14L2.451 5.658C1.885 5.025 2.345 4 3.204 4h9.592c.86 0 1.32 1.025.753 1.658l-4.796 5.482a.5.5 0 0 1-.753 0z'/%3E%3C/svg%3E") no-repeat right 12px center;
            font-size: 14px;
            cursor: pointer;
        }

        /* ====================== TABLE ====================== */
        .table-wrapper {
            background: white;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: var(--shadow-sm);
        }
        table { width: 100%; border-collapse: collapse; }
        thead th {
            padding: 14px 20px;
            text-align: left;
            font-size: 11.5px;
            font-weight: 700;
            text-transform: uppercase;
            color: #64748b;
            border-bottom: 1px solid #e2e8f0;
        }
        tbody td {
            padding: 16px 20px;
            border-bottom: 1px solid #f1f5f9;
        }
        tbody tr:hover {
            background: #f8fafc;
        }

        .td-email { color: #64748b; font-size: 14px; }
        .td-name  { font-weight: 600; }
        .td-code  { color: #64748b; font-size: 14px; }
        .td-date  { color: #64748b; font-size: 14px; }

        /* Badges */
        .badge {
            padding: 5px 12px;
            border-radius: 9999px;
            font-size: 13px;
            font-weight: 500;
        }
        .badge-admin    { background: #f3e8ff; color: #7c3aed; }
        .badge-hr       { background: #dbeafe; color: #1e40af; }
        .badge-manager  { background: #d1fae5; color: #166534; }
        .badge-employee { background: #f1f5f9; color: #374151; }

        /* Status */
        .status-active {
            background: #dcfce7;
            color: #166534;
            padding: 5px 12px;
            border-radius: 9999px;
            font-size: 13px;
            font-weight: 500;
        }
        .status-inactive {
            background: #fce7f3;
            color: #9f1239;
            padding: 5px 12px;
            border-radius: 9999px;
            font-size: 13px;
            font-weight: 500;
        }

        /* Action Buttons */
        .actions {
            display: flex;
            gap: 6px;
        }
        .action-btn {
            width: 32px;
            height: 32px;
            border: none;
            background: none;
            color: #64748b;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }
        .action-btn:hover { background: #f1f5f9; transform: scale(1.1); }
        .action-btn.edit   { color: #3b82f6; }
        .action-btn.lock, .action-btn.unlock { color: #f59e0b; }
        .action-btn.reset  { color: #8b5cf6; }
        .action-btn.delete { color: #ef4444; }

        /* Modal */
        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(15,23,42,0.6);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 1000;
        }
        .modal-overlay.open { display: flex; }
        .modal {
            background: white;
            padding: 30px;
            border-radius: 16px;
            width: 480px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.2);
        }
        .modal-title {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .form-row {
            margin-bottom: 18px;
        }
        .form-row label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            font-size: 13.5px;
        }
        .form-row input, .form-row select {
            width: 100%;
            padding: 11px 14px;
            border: 1px solid var(--border);
            border-radius: 9px;
            font-size: 15px;
        }
        .form-hint {
            font-size: 12px;
            color: var(--text-muted);
            margin-top: 5px;
        }
        .modal-actions {
            margin-top: 30px;
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }
        .btn-cancel {
            padding: 10px 20px;
            background: #f3f4f6;
            border: 1px solid #e5e7eb;
            border-radius: 10px;
        }

        /* ====================== FLASH MESSAGES ====================== */
        .flash {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 14px 20px;
            border-radius: var(--radius);
            margin-bottom: 20px;
            font-size: 14px;
            font-weight: 500;
        }
        .flash.success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }
        .flash.error {
            background: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fecaca;
        }

        /* ====================== EMPTY STATE ====================== */
        .empty-state {
            text-align: center;
            padding: 48px 0;
            color: var(--text-muted);
        }
        .empty-state i { font-size: 36px; margin-bottom: 12px; display: block; }
    </style>
</head>
<body>

<%-- sidebar.jsp — nếu project không dùng sidebar, có thể để trống file này --%>

<div class="main-wrapper">
    <div class="page-content">

<script>window.actionUrl = '${pageContext.request.contextPath}/admin/users/action';</script>

<%-- Flash Messages --%>
<c:if test="${not empty sessionScope.flash_success}">
    <div class="flash success">
        <i class="fa-solid fa-circle-check"></i>
        ${sessionScope.flash_success}
    </div>
    <c:remove var="flash_success" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.flash_error}">
    <div class="flash error">
        <i class="fa-solid fa-circle-exclamation"></i>
        ${sessionScope.flash_error}
    </div>
    <c:remove var="flash_error" scope="session"/>
</c:if>

<%-- Page Header --%>
<div class="page-header">
    <div>
        <h1 class="page-title">Quản lý Users</h1>
        <p class="page-sub">Xin chào, ${sessionScope.fullName}</p>
    </div>
    <div class="header-actions">
        <a href="#" class="bell-btn">
            <i class="fa-solid fa-bell"></i>
            <span class="bell-badge">2</span>
        </a>
    </div>
</div>

<%-- Stats Cards --%>
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-label">Tổng Users</div>
        <div class="stat-value total">${stats.totalUsers}</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Active</div>
        <div class="stat-value active">${stats.activeUsers}</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Inactive</div>
        <div class="stat-value inactive">${stats.inactiveUsers}</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Admins</div>
        <div class="stat-value admin">${stats.adminUsers}</div>
    </div>
</div>

<%-- Toolbar --%>
<div class="toolbar">
    <form method="get" action="${pageContext.request.contextPath}/admin/users" id="filterForm">
        <div class="toolbar-top">
            <div class="search-box">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input type="text" id="searchInput" name="keyword"
                       placeholder="Tìm kiếm theo tên, email..."
                       value="${filterKeyword}">
            </div>
            <button type="button" class="btn-primary" onclick="openModal('createUserModal')">
                <i class="fa-solid fa-plus"></i> Tạo tài khoản
            </button>
        </div>

        <div class="filters">
            <select name="roleGroup" class="filter-select filter-auto">
                <option value="">Tất cả Roles</option>
                <option value="ADMIN"    ${filterRoleGroup == 'ADMIN' ? 'selected' : ''}>Admin</option>
                <option value="HR"       ${filterRoleGroup == 'HR' ? 'selected' : ''}>HR</option>
                <option value="MANAGER"  ${filterRoleGroup == 'MANAGER' ? 'selected' : ''}>Manager</option>
                <option value="EMPLOYEE" ${filterRoleGroup == 'EMPLOYEE' ? 'selected' : ''}>Employee</option>
            </select>
            <select name="status" class="filter-select filter-auto">
                <option value="">Tất cả trạng thái</option>
                <option value="1" ${filterStatus == '1' ? 'selected' : ''}>Active</option>
                <option value="0" ${filterStatus == '0' ? 'selected' : ''}>Inactive</option>
            </select>
        </div>
    </form>
</div>

<%-- User Table --%>
<div class="table-wrapper">
    <table>
        <thead>
            <tr>
                <th>EMAIL ĐĂNG NHẬP</th>
                <th>HỌ TÊN</th>
                <th>ROLE</th>
                <th>MÃ NV</th>
                <th>TRẠNG THÁI</th>
                <th>ĐĂNG NHẬP CUỐI</th>
                <th>THAO TÁC</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${empty users}">
                    <tr>
                        <td colspan="7">
                            <div class="empty-state">
                                <i class="fa-solid fa-users-slash"></i>
                                <p>Không tìm thấy người dùng nào.</p>
                            </div>
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="u" items="${users}">
                        <tr>
                            <td class="td-email">${u.username}</td>
                            <td class="td-name">${u.fullName}</td>
                            <td>
                                <span class="badge ${u.roleBadgeClass}">
                                    ${u.roleDisplayName}
                                </span>
                            </td>
                            <td class="td-code">
                                <c:choose>
                                    <c:when test="${not empty u.employeeCode}">${u.employeeCode}</c:when>
                                    <c:otherwise><span style="color:var(--text-muted)">-</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <span class="${u.statusClass}">${u.statusLabel}</span>
                            </td>
                            <td class="td-date">
                                <c:choose>
                                    <c:when test="${u.lastLoginAt != null}">
                                        <fmt:formatDate value="${u.lastLoginAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="actions">
                                    <button class="action-btn edit"
                                            title="Chỉnh sửa"
                                            onclick="openModal('editModal_${u.id}')">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </button>

                                    <c:choose>
                                        <c:when test="${u.active}">
                                            <button class="action-btn lock"
                                                    title="Khóa tài khoản"
                                                    onclick="lockUser(${u.id})">
                                                <i class="fa-solid fa-lock"></i>
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="action-btn unlock"
                                                    title="Mở khóa"
                                                    onclick="unlockUser(${u.id})">
                                                <i class="fa-solid fa-lock-open"></i>
                                            </button>
                                        </c:otherwise>
                                    </c:choose>

                                    <button class="action-btn reset"
                                            title="Yêu cầu đổi mật khẩu"
                                            onclick="resetPassword(${u.id})">
                                        <i class="fa-solid fa-key"></i>
                                    </button>

                                    <button class="action-btn delete"
                                            title="Xóa tài khoản"
                                            onclick="confirmDelete(${u.id}, '${u.fullName}')">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>
</div>

<%-- Create User Modal --%>
<div class="modal-overlay" id="createUserModal">
    <div class="modal">
        <div class="modal-title">
            <i class="fa-solid fa-user-plus"></i>
            Tạo tài khoản mới
        </div>
        <form action="${pageContext.request.contextPath}/admin/users/action" method="post">
            <input type="hidden" name="action" value="create">

            <div class="form-row">
                <label for="fullName">Họ và tên <span style="color:red">*</span></label>
                <input type="text" id="fullName" name="fullName" placeholder="Nguyễn Văn A" required>
            </div>

            <%-- Chấp nhận bất kỳ email nào, không cần có trong hồ sơ nhân viên --%>
            <div class="form-row">
                <label for="email">Email đăng nhập <span style="color:red">*</span></label>
                <input type="email" id="email" name="email"
                       placeholder="Nhập bất kỳ địa chỉ email nào" required>
                <p class="form-hint">
                    <i class="fa-solid fa-circle-info"></i>
                    Có thể dùng email công ty hoặc email cá nhân.
                    Nếu email trùng với hồ sơ nhân viên, tài khoản sẽ tự động được liên kết.
                </p>
            </div>

            <div class="form-row">
                <label for="roleId">Role <span style="color:red">*</span></label>
                <select id="roleId" name="roleId" required>
                    <option value="">-- Chọn Role --</option>
                    <c:forEach var="rg" items="${roleGroups}">
                        <option value="${rg[0]}">${rg[1]}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-row">
                <label for="password">Mật khẩu tạm thời <span style="color:red">*</span></label>
                <input type="password" id="password" name="password"
                       placeholder="Tối thiểu 8 ký tự" minlength="8" required>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="closeModal('createUserModal')">
                    Hủy
                </button>
                <button type="submit" class="btn-primary">
                    <i class="fa-solid fa-check"></i> Tạo tài khoản
                </button>
            </div>
        </form>
    </div>
</div>

<%-- Delete Form --%>
<form id="deleteForm" method="post" action="${pageContext.request.contextPath}/admin/users/action" style="display:none">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="userId" id="deleteUserId" value="">
</form>

</div><%-- /page-content --%>

<script>
function openModal(id) {
    const el = document.getElementById(id);
    if (el) { el.classList.add('open'); }
}
function closeModal(id) {
    const el = document.getElementById(id);
    if (el) { el.classList.remove('open'); }
}


document.querySelectorAll('.modal-overlay').forEach(ov => {
    ov.addEventListener('click', e => { if (e.target === ov) closeModal(ov.id); });
});


document.addEventListener('keydown', e => {
    if (e.key === 'Escape')
        document.querySelectorAll('.modal-overlay.open').forEach(m => closeModal(m.id));
});


document.querySelectorAll('.filter-auto').forEach(sel => {
    sel.addEventListener('change', () => {
        const f = document.getElementById('filterForm');
        if (f) f.submit();
    });
});

/* Debounce search 600ms */
(function () {
    const inp = document.getElementById('searchInput');
    if (!inp) return;
    let t;
    inp.addEventListener('input', () => {
        clearTimeout(t);
        t = setTimeout(() => {
            const f = document.getElementById('filterForm');
            if (f) f.submit();
        }, 600);
    });
})();

/* User actions */
const ACTION_URL = window.actionUrl || '';

function _post(params) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = ACTION_URL;
    Object.entries(params).forEach(([k, v]) => {
        const i = document.createElement('input');
        i.type = 'hidden'; i.name = k; i.value = v;
        form.appendChild(i);
    });
    document.body.appendChild(form);
    form.submit();
}

function lockUser(id)     { if (confirm('Khóa tài khoản này?'))                         _post({ action: 'lock',          userId: id }); }
function unlockUser(id)   { if (confirm('Mở khóa tài khoản này?'))                      _post({ action: 'unlock',        userId: id }); }
function resetPassword(id){ if (confirm('Yêu cầu đổi mật khẩu lần đăng nhập tiếp?'))   _post({ action: 'resetPassword', userId: id }); }

function confirmDelete(id, name) {
    if (confirm('Xóa tài khoản "' + name + '"?\nHành động không thể hoàn tác!')) {
        document.getElementById('deleteUserId').value = id;
        document.getElementById('deleteForm').submit();
    }
}

/* Flash tự ẩn sau 4s */
setTimeout(() => {
    document.querySelectorAll('.flash').forEach(el => {
        el.style.transition = 'opacity .5s';
        el.style.opacity = '0';
        setTimeout(() => el.remove(), 500);
    });
}, 4000);
</script>
</body>
</html>
