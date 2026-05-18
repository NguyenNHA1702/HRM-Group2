<%@ page pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="brand-icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width: 20px; height: 20px;">
                <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
                <circle cx="9" cy="7" r="4"></circle>
                <path d="M22 21v-2a4 4 0 0 0-3-3.87"></path>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
            </svg>
        </div>
        <div class="brand-text">
            <span class="brand-name">HRMS</span>
            <span class="brand-sub">Quản lý Nhân sự</span>
        </div>
    </div>

    <nav class="sidebar-nav">
        <ul>
            <li class="nav-item ${pageContext.request.requestURI.contains('/dashboard') ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/dashboard">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="9"></rect><rect x="14" y="3" width="7" height="5"></rect><rect x="14" y="12" width="7" height="9"></rect><rect x="3" y="16" width="7" height="5"></rect></svg>
                    Dashboard
                </a>
            </li>

            <c:if test="${sessionScope.roleGroup eq 'EMPLOYEE'}">
                <li class="nav-item ${pageContext.request.requestURI.contains('/cham-cong') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/cham-cong">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        Chấm công
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/nghi-phep') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/nghi-phep">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Nghỉ phép
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/luong') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/luong">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                        Lương
                    </a>
                </li>
            </c:if>

            <c:if test="${sessionScope.roleGroup eq 'MANAGER'}">
                <li class="nav-item ${pageContext.request.requestURI.contains('/nhan-vien') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/nhan-vien">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        Nhân viên
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/cham-cong') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/cham-cong">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        Chấm công
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/nghi-phep') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/nghi-phep">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Nghỉ phép
                    </a>
                </li>
            </c:if>

            <c:if test="${sessionScope.roleGroup eq 'HR'}">
                <li class="nav-item ${pageContext.request.requestURI.contains('/nhan-vien') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/nhan-vien">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        Nhân viên
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/phong-ban') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/phong-ban">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                        Phòng ban
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/cham-cong') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/cham-cong">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        Chấm công
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/nghi-phep') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/nghi-phep">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Nghỉ phép
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/luong') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/luong">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                        Lương
                    </a>
                </li>
            </c:if>

            <c:if test="${sessionScope.roleGroup eq 'ADMIN'}">
                <li class="nav-item ${pageContext.request.requestURI.contains('/nhan-vien') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/nhan-vien">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        Nhân viên
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/phong-ban') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/phong-ban">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                        Phòng ban
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/cham-cong') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/cham-cong">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        Chấm công
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/nghi-phep') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/nghi-phep">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Nghỉ phép
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/luong') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/luong">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                        Lương
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/quan-ly-users') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/quan-ly-users">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                        Quản lý Users
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/phan-quyen') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/phan-quyen">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                        Phân quyền
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/cau-hinh') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/cau-hinh">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
                        Cấu hình
                    </a>
                </li>
            </c:if>
        </ul>
    </nav>

    <div class="sidebar-footer">
        <div class="sidebar-user">
            <div class="user-avatar">
                <c:choose>
                    <c:when test="${not empty sessionScope.avatarUrl}">
                        <img src="${pageContext.request.contextPath}${sessionScope.avatarUrl}" alt="Avatar">
                    </c:when>
                    <c:when test="${not empty sessionScope.fullName}">
                        <c:out value="${sessionScope.fullName.substring(0, 1).toUpperCase()}" />
                    </c:when>
                    <c:otherwise>U</c:otherwise>
                </c:choose>
            </div>
            <div class="user-info">
                <span class="user-name">
                    <c:out value="${not empty sessionScope.fullName ? sessionScope.fullName : 'Hệ thống'}" />
                </span>
                <span class="user-role">
                    <c:choose>
                        <c:when test="${sessionScope.roleGroup eq 'ADMIN'}">Admin</c:when>
                        <c:when test="${sessionScope.roleGroup eq 'HR'}">Quản lý Nhân sự</c:when>
                        <c:when test="${sessionScope.roleGroup eq 'MANAGER'}">Quản lý Bộ phận</c:when>
                        <c:otherwise>Nhân viên</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="logout-icon" title="Đăng xuất">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                    <polyline points="16 17 21 12 16 7"></polyline>
                    <line x1="21" y1="12" x2="9" y2="12"></line>
                </svg>
            </a>
        </div>
    </div>
</aside>