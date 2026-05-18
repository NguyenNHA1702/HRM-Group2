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
                                                                                   <%-- Su dung cac thuoc tinh cua LocalDateTime va format so co 0 o dau --%>
                                                                                   <fmt:formatNumber value="${u.lastLoginAt.dayOfMonth}" pattern="00"/>/<fmt:formatNumber value="${u.lastLoginAt.monthValue}" pattern="00"/>/${u.lastLoginAt.year} <fmt:formatNumber value="${u.lastLoginAt.hour}" pattern="00"/>:<fmt:formatNumber value="${u.lastLoginAt.minute}" pattern="00"/>
                                                                               </c:when>

                                        <c:otherwise>-</c:otherwise>

                                    </c:choose>

                                </td>

                                <td>

                                    <div class="actions">

                                        <a href="${pageContext.request.contextPath}/admin/user/update?id=${u.employeeId}"
                                           class="action-btn edit"
                                           title="Chỉnh sửa">

                                            <i class="fa-solid fa-pen-to-square"></i>

                                        </a>

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

                <form action="${pageContext.request.contextPath}/admin/users/action"
                      method="post">

                    <input type="hidden" name="action" value="create">

                    <div class="form-row">

                        <label for="fullName">
                            Họ và tên
                            <span style="color:red">*</span>
                        </label>

                        <input type="text"
                               id="fullName"
                               name="fullName"
                               placeholder="Nguyễn Văn A"
                               required>

                    </div>

                    <div class="form-row">

                        <label for="email">
                            Email đăng nhập
                            <span style="color:red">*</span>
                        </label>

                        <input type="email"
                               id="email"
                               name="email"
                               placeholder="Nhập bất kỳ địa chỉ email nào"
                               required>



                    </div>

                    <div class="form-row">

                        <label for="roleId">
                            Role
                            <span style="color:red">*</span>
                        </label>

                        <select id="roleId"
                                name="roleId"
                                required>

                            <option value="">-- Chọn Role --</option>

                            <c:forEach var="rg" items="${roleGroups}">
                                <option value="${rg[0]}">
                                    ${rg[1]}
                                </option>
                            </c:forEach>

                        </select>

                    </div>

                    <div class="form-row">

                        <label for="password">
                            Mật khẩu tạm thời
                            <span style="color:red">*</span>
                        </label>

                        <input type="password"
                               id="password"
                               name="password"
                               required>

                    </div>

                    <div class="modal-actions">

                        <button type="button"
                                class="btn-cancel"
                                onclick="closeModal('createUserModal')">

                            Hủy

                        </button>

                        <button type="submit"
                                class="btn-primary">

                            <i class="fa-solid fa-check"></i>
                            Tạo tài khoản

                        </button>

                    </div>

                </form>

            </div>

        </div>

        <%-- Delete Form --%>
        <form id="deleteForm"
              method="post"
              action="${pageContext.request.contextPath}/admin/users/action"
              style="display:none">

            <input type="hidden" name="action" value="delete">

            <input type="hidden"
                   name="userId"
                   id="deleteUserId"
                   value="">

        </form>

    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/user-list.js"></script>

</body>
</html>