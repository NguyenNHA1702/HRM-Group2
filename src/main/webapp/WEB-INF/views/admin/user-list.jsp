<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Quản lý Users</title>

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>

    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"/>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/user-list.css"/>
</head>

<body>

<jsp:include page="/WEB-INF/common/sidebar.jsp" />

<div class="main-wrapper">
    <div class="page-content">

        <script>
            window.contextPath = '${pageContext.request.contextPath}';
            window.actionUrl =
                '${pageContext.request.contextPath}/admin/users/action';
        </script>

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
                <p class="page-sub">
                    Xin chào, ${sessionScope.fullName}
                </p>
            </div>
        </div>

        <%-- Stats Cards --%>
        <div class="stats-grid">

            <div class="stat-card">
                <div class="stat-label">Tổng Users</div>
                <div class="stat-value total">
                    ${stats.totalUsers}
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-label">Active</div>
                <div class="stat-value active">
                    ${stats.activeUsers}
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-label">Inactive</div>
                <div class="stat-value inactive">
                    ${stats.inactiveUsers}
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-label">Admins</div>
                <div class="stat-value admin">
                    ${stats.adminUsers}
                </div>
            </div>

        </div>

        <%-- Toolbar --%>
        <div class="toolbar">

            <form method="get"
                  action="${pageContext.request.contextPath}/admin/users"
                  id="filterForm">

                <div class="toolbar-top">

                    <div class="search-box">
                        <i class="fa-solid fa-magnifying-glass"></i>

                        <input type="text"
                               id="searchInput"
                               name="keyword"
                               placeholder="Tìm kiếm theo tên, email..."
                               value="${filterKeyword}">
                    </div>

                    <button type="button"
                            class="btn-primary"
                            onclick="openModal('createUserModal')">

                        <i class="fa-solid fa-plus"></i>
                        Tạo tài khoản
                    </button>

                </div>

                <div class="filters">

                    <select name="roleGroup"
                            class="filter-select filter-auto">

                        <option value="">Tất cả Roles</option>

                        <option value="ADMIN"
                                ${filterRoleGroup == 'ADMIN' ? 'selected' : ''}>
                            Admin
                        </option>

                        <option value="HR"
                                ${filterRoleGroup == 'HR' ? 'selected' : ''}>
                            HR
                        </option>

                        <option value="MANAGER"
                                ${filterRoleGroup == 'MANAGER' ? 'selected' : ''}>
                            Manager
                        </option>

                        <option value="EMPLOYEE"
                                ${filterRoleGroup == 'EMPLOYEE' ? 'selected' : ''}>
                            Employee
                        </option>

                    </select>

                    <select name="status"
                            class="filter-select filter-auto">

                        <option value="">Tất cả trạng thái</option>

                        <option value="1"
                                ${filterStatus == '1' ? 'selected' : ''}>
                            Active
                        </option>

                        <option value="0"
                                ${filterStatus == '0' ? 'selected' : ''}>
                            Inactive
                        </option>

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

                                <td class="td-email">
                                    ${u.username}
                                </td>

                                <td class="td-name">
                                    ${u.fullName}
                                </td>

                                <td>
                                    <span class="badge ${u.roleBadgeClass}">
                                        ${u.roleDisplayName}
                                    </span>
                                </td>

                                <td class="td-code">

                                    <c:choose>

                                        <c:when test="${not empty u.employeeCode}">
                                            ${u.employeeCode}
                                        </c:when>

                                        <c:otherwise>
                                            <span style="color:var(--text-muted)">-</span>
                                        </c:otherwise>

                                    </c:choose>

                                </td>

                                <td>
                                    <span class="${u.statusClass}">
                                        ${u.statusLabel}
                                    </span>
                                </td>

                                <td class="td-date">

                                    <c:choose>

                                       <c:when test="${u.lastLoginAt != null}">
                                           <fmt:formatNumber value="${u.lastLoginAt.dayOfMonth}" pattern="00"/>/<fmt:formatNumber value="${u.lastLoginAt.monthValue}" pattern="00"/>/${u.lastLoginAt.year}
                                           <fmt:formatNumber value="${u.lastLoginAt.hour}" pattern="00"/>:<fmt:formatNumber value="${u.lastLoginAt.minute}" pattern="00"/>
                                       </c:when>

                                        <c:otherwise>-</c:otherwise>

                                    </c:choose>

                                </td>

                                <td>

                                    <div class="actions">

                                        <button class="action-btn view"
                                                title="Xem chi tiết"
                                                onclick="viewUser(${u.employeeId})">

                                            <svg viewBox="0 0 24 24">
                                                <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/>
                                                <circle cx="12" cy="12" r="3"/>
                                            </svg>

                                        </button>

                                        <a href="${pageContext.request.contextPath}/admin/user/update?id=${u.employeeId}"
                                           class="action-btn edit"
                                           title="Chỉnh sửa">

                                            <svg viewBox="0 0 24 24">
                                                <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                                                <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                                            </svg>

                                        </a>

                                        <c:choose>

                                            <c:when test="${u.active}">

                                                <button class="action-btn lock"
                                                        title="Khóa tài khoản"
                                                        onclick="lockUser(${u.id})">

                                                    <svg viewBox="0 0 24 24">
                                                        <rect x="5" y="11" width="14" height="10" rx="2"/>
                                                        <path d="M8 11V7a4 4 0 0 1 8 0v4"/>
                                                    </svg>

                                                </button>

                                            </c:when>

                                            <c:otherwise>

                                                <button class="action-btn unlock"
                                                        title="Mở khóa"
                                                        onclick="unlockUser(${u.id})">

                                                    <svg viewBox="0 0 24 24">
                                                        <rect x="5" y="11" width="14" height="10" rx="2"/>
                                                        <path d="M8 11V7a4 4 0 0 1 7.5-2"/>
                                                    </svg>

                                                </button>

                                            </c:otherwise>

                                        </c:choose>

                                        <button class="action-btn reset"
                                                title="Yêu cầu đổi mật khẩu"
                                                onclick="resetPassword(${u.id})">

                                            <svg viewBox="0 0 24 24">
                                                <circle cx="8" cy="15" r="4"/>
                                                <path d="M11 12l9-9"/>
                                                <path d="M17 6l3 3"/>
                                                <path d="M14 9l3 3"/>
                                            </svg>

                                        </button>

                                        <button class="action-btn delete"
                                                title="Xóa tài khoản"
                                                onclick="confirmDelete(${u.id}, '${u.fullName}')">

                                            <svg viewBox="0 0 24 24">
                                                <polyline points="3 6 5 6 21 6"/>
                                                <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/>
                                                <path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                                                <line x1="10" y1="11" x2="10" y2="17"/>
                                                <line x1="14" y1="11" x2="14" y2="17"/>
                                            </svg>

                                        </button>

                                    </div>

                                </td>

                            </tr>

                        </c:forEach>

                    </c:otherwise>

                </c:choose>

                </tbody>

            </table>

            <%-- Pagination controls --%>
            <div class="pagination-container">
                <div>
                    Hiển thị từ
                    <c:choose>
                        <c:when test="${totalRecords == 0}">0</c:when>
                        <c:otherwise>${(page - 1) * pageSize + 1}</c:otherwise>
                    </c:choose>
                    đến
                    <c:choose>
                        <c:when test="${page * pageSize > totalRecords}">${totalRecords}</c:when>
                        <c:otherwise>${page * pageSize}</c:otherwise>
                    </c:choose>
                    trên tổng số <strong>${totalRecords}</strong> users
                </div>

                <c:if test="${totalPages > 1}">
                    <ul class="pagination">
                        <li class="page-item ${page == 1 ? 'disabled' : ''}">
                            <c:url var="previousPageUrl" value="/admin/users">
                                <c:param name="page" value="${page - 1}"/>
                                <c:param name="keyword" value="${filterKeyword}"/>
                                <c:param name="roleGroup" value="${filterRoleGroup}"/>
                                <c:param name="status" value="${filterStatus}"/>
                            </c:url>
                            <a href="${previousPageUrl}" title="Trang trước">&laquo;</a>
                        </li>

                        <c:forEach var="i" begin="1" end="${totalPages}">
                            <c:url var="pageUrl" value="/admin/users">
                                <c:param name="page" value="${i}"/>
                                <c:param name="keyword" value="${filterKeyword}"/>
                                <c:param name="roleGroup" value="${filterRoleGroup}"/>
                                <c:param name="status" value="${filterStatus}"/>
                            </c:url>
                            <li class="page-item ${page == i ? 'active' : ''}">
                                <a href="${pageUrl}">${i}</a>
                            </li>
                        </c:forEach>

                        <li class="page-item ${page == totalPages ? 'disabled' : ''}">
                            <c:url var="nextPageUrl" value="/admin/users">
                                <c:param name="page" value="${page + 1}"/>
                                <c:param name="keyword" value="${filterKeyword}"/>
                                <c:param name="roleGroup" value="${filterRoleGroup}"/>
                                <c:param name="status" value="${filterStatus}"/>
                            </c:url>
                            <a href="${nextPageUrl}" title="Trang sau">&raquo;</a>
                        </li>
                    </ul>
                </c:if>
            </div>

        </div>

        <%-- =============== Create User Modal =============== --%>
        <div class="modal-overlay" id="createUserModal">

            <div class="modal modal-wide">

                <div class="modal-title">
                    <i class="fa-solid fa-user-plus"></i>
                    Tạo tài khoản mới
                </div>

                <form action="${pageContext.request.contextPath}/admin/users/action"
                      method="post">

                    <input type="hidden" name="action" value="create">

                    <%-- Section: Thong tin ca nhan --%>
                    <div class="modal-section-label">
                        <i class="fa-solid fa-id-card"></i> Thông tin cá nhân
                    </div>

                    <div class="form-grid-2">

                        <div class="form-row">
                            <label for="fullName">
                                Họ và tên <span style="color:red">*</span>
                            </label>
                            <input type="text"
                                   id="fullName"
                                   name="fullName"
                                   placeholder="Nguyễn Văn A"
                                   required>
                        </div>

                        <div class="form-row">
                            <label for="phone">Số điện thoại</label>
                            <input type="text"
                                   id="phone"
                                   name="phone"
                                   placeholder="0901234567">
                        </div>

                        <div class="form-row">
                            <label for="dateOfBirth">Ngày sinh</label>
                            <input type="date"
                                   id="dateOfBirth"
                                   name="dateOfBirth">
                        </div>

                        <div class="form-row">
                            <label for="gender">Giới tính</label>
                            <select id="gender" name="gender">
                                <option value="">-- Chọn giới tính --</option>
                                <option value="Male">Nam</option>
                                <option value="Female">Nữ</option>
                                <option value="Other">Khác</option>
                            </select>
                        </div>

                        <div class="form-row">
                            <label for="email">
                                Email đăng nhập <span style="color:red">*</span>
                            </label>
                            <input type="email"
                                   id="email"
                                   name="email"
                                   placeholder="Nhập địa chỉ email đăng nhập"
                                   required>
                        </div>

                        <div class="form-row">
                            <label for="personalEmail">Email cá nhân</label>
                            <input type="email"
                                   id="personalEmail"
                                   name="personalEmail"
                                   placeholder="Email liên lạc cá nhân">
                        </div>

                    </div>

                    <%-- Section: Cong viec & Phan quyen --%>
                    <div class="modal-section-label" style="margin-top:6px;">
                        <i class="fa-solid fa-briefcase"></i> Công việc &amp; Phân quyền
                    </div>

                    <div class="form-grid-2">

                        <div class="form-row">
                            <label for="departmentId">Phòng ban</label>
                            <select id="departmentId" name="departmentId">
                                <option value="">-- Chọn phòng ban --</option>
                                <c:forEach var="dept" items="${departments}">
                                    <option value="${dept.id}">${dept.name}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="form-row">
                            <label for="positionId">Chức vụ / Vị trí</label>
                            <select id="positionId" name="positionId">
                                <option value="">-- Chọn chức vụ --</option>
                                <c:forEach var="pos" items="${positions}">
                                    <option value="${pos.id}">${pos.name}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="form-row">
                            <label for="roleId">
                                Quyền hệ thống (Role) <span style="color:red">*</span>
                            </label>
                            <select id="roleId" name="roleId" required>
                                <option value="">-- Chọn Role --</option>
                                <c:forEach var="rg" items="${roleGroups}">
                                    <option value="${rg[0]}">${rg[1]}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="form-row">
                            <label for="isActive">Trạng thái hoạt động</label>
                            <select id="isActive" name="isActive">
                                <option value="1">Đang hoạt động (ACTIVE)</option>
                                <option value="0">Đã khóa (INACTIVE)</option>
                            </select>
                        </div>

                    </div>

                    <%-- Mat khau --%>
                    <div class="form-row" style="margin-top:4px;">
                        <label for="password">
                            Mật khẩu tạm thời <span style="color:red">*</span>
                        </label>
                        <input type="password"
                               id="password"
                               name="password"
                               required>
                        <span class="form-hint">Người dùng nên đổi mật khẩu sau lần đăng nhập đầu tiên.</span>
                    </div>

                    <div class="modal-actions">

                        <button type="button"
                                class="btn-cancel"
                                onclick="closeModal('createUserModal')">
                            Hủy
                        </button>

                        <button type="submit" class="btn-primary">
                            <i class="fa-solid fa-check"></i>
                            Tạo tài khoản
                        </button>

                    </div>

                </form>

            </div>

        </div>
        <%-- =============== End Create User Modal =============== --%>

        <%-- =============== View User Modal =============== --%>
        <div class="modal-overlay" id="viewUserModal">

            <div class="modal modal-wide">

                <div class="modal-title">
                    <i class="fa-solid fa-id-card"></i>
                    Chi tiết thông tin tài khoản
                </div>

                <div class="profile-card-layout" style="display: flex; gap: 24px; margin-bottom: 20px;">
                    
                    <%-- Left side: Avatar & Code --%>
                    <div style="flex: 0 0 160px; text-align: center; border-right: 1px solid #f1f5f9; padding-right: 24px; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                        <div style="width: 100px; height: 100px; border-radius: 50%; background: #f1f5f9; display: flex; align-items: center; justify-content: center; overflow: hidden; margin-bottom: 12px; border: 1px solid var(--border);">
                            <img id="view_avatar" src="" style="width: 100%; height: 100%; object-fit: cover; display: none;">
                            <div id="view_avatar_placeholder" style="display: flex; align-items: center; justify-content: center; width: 100%; height: 100%;">
                                <i class="fas fa-user" style="font-size: 3rem; color: #94a3b8;"></i>
                            </div>
                        </div>
                        <div id="view_employeeCode" style="font-weight: 700; color: var(--indigo-text); font-size: 14px; margin-bottom: 6px;"></div>
                        <div><span id="view_status"></span></div>
                    </div>

                    <%-- Right side: Profile Details --%>
                    <div style="flex: 1;">
                        
                        <div class="modal-section-label">
                            <i class="fa-solid fa-user-tag"></i> Thông tin cá nhân
                        </div>
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px 20px; margin-bottom: 20px;">
                            <div>
                                <label style="font-size: 12px; color: var(--text-sub); display: block; margin-bottom: 2px;">Họ và tên</label>
                                <div id="view_fullName" style="font-weight: 600; font-size: 14px; color: var(--text);"></div>
                            </div>
                            <div>
                                <label style="font-size: 12px; color: var(--text-sub); display: block; margin-bottom: 2px;">Số điện thoại</label>
                                <div id="view_phone" style="font-weight: 600; font-size: 14px; color: var(--text);"></div>
                            </div>
                            <div>
                                <label style="font-size: 12px; color: var(--text-sub); display: block; margin-bottom: 2px;">Ngày sinh</label>
                                <div id="view_dateOfBirth" style="font-weight: 600; font-size: 14px; color: var(--text);"></div>
                            </div>
                            <div>
                                <label style="font-size: 12px; color: var(--text-sub); display: block; margin-bottom: 2px;">Giới tính</label>
                                <div id="view_gender" style="font-weight: 600; font-size: 14px; color: var(--text);"></div>
                            </div>
                        </div>

                        <div class="modal-section-label">
                            <i class="fa-solid fa-briefcase"></i> Công việc &amp; Vai trò
                        </div>
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px 20px;">
                            <div>
                                <label style="font-size: 12px; color: var(--text-sub); display: block; margin-bottom: 2px;">Phòng ban</label>
                                <div id="view_department" style="font-weight: 600; font-size: 14px; color: var(--text);"></div>
                            </div>
                            <div>
                                <label style="font-size: 12px; color: var(--text-sub); display: block; margin-bottom: 2px;">Chức vụ / Vị trí</label>
                                <div id="view_position" style="font-weight: 600; font-size: 14px; color: var(--text);"></div>
                            </div>
                            <div>
                                <label style="font-size: 12px; color: var(--text-sub); display: block; margin-bottom: 2px;">Email công việc</label>
                                <div id="view_workEmail" style="font-weight: 600; font-size: 14px; color: var(--text);"></div>
                            </div>
                            <div>
                                <label style="font-size: 12px; color: var(--text-sub); display: block; margin-bottom: 2px;">Email cá nhân</label>
                                <div id="view_personalEmail" style="font-weight: 600; font-size: 14px; color: var(--text);"></div>
                            </div>
                            <div style="grid-column: span 2;">
                                <label style="font-size: 12px; color: var(--text-sub); display: block; margin-bottom: 2px;">Quyền hệ thống (Role)</label>
                                <div id="view_role" style="font-weight: 600; font-size: 14px; color: var(--indigo-text);"></div>
                            </div>
                        </div>

                    </div>

                </div>

                <div class="modal-actions" style="margin-top: 16px;">
                    <button type="button"
                            class="btn-cancel"
                            onclick="closeModal('viewUserModal')">
                        Đóng
                    </button>
                </div>

            </div>

        </div>
        <%-- =============== End View User Modal =============== --%>

        <%-- Delete Form --%>
        <form id="deleteForm"
              method="post"
              action="${pageContext.request.contextPath}/admin/users/action"
              style="display:none">

            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="userId" id="deleteUserId" value="">

        </form>

    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/user-list.js"></script>

</body>
</html>
