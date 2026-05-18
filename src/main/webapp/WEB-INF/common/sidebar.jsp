<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Import Google Font Inter -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<!-- Import FontAwesome -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<!-- Import Sidebar CSS -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">

<div class="sidebar">
    <div class="logo-section">
        <div class="logo-icon"><i class="fas fa-building-user"></i></div>
        <div class="logo-text">
            <h2>HRMS</h2>
            <p>Quản lý Nhân sự</p>
        </div>
    </div>

    <nav class="nav-menu">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item ${pageContext.request.requestURI.contains('dashboard') ? 'active' : ''}">
            <i class="fas fa-chart-pie"></i> Dashboard
        </a>

        <a href="${pageContext.request.contextPath}/employees" class="nav-item ${pageContext.request.requestURI.contains('employees') ? 'active' : ''}">
            <i class="fas fa-user-group"></i> Nhân viên
        </a>

        <a href="${pageContext.request.contextPath}/departments" class="nav-item ${pageContext.request.requestURI.contains('departments') ? 'active' : ''}">
            <i class="fas fa-sitemap"></i> Phòng ban
        </a>

        <a href="${pageContext.request.contextPath}/attendance" class="nav-item ${pageContext.request.requestURI.contains('attendance') ? 'active' : ''}">
            <i class="fas fa-user-clock"></i> Chấm công
        </a>

        <a href="${pageContext.request.contextPath}/leave" class="nav-item ${pageContext.request.requestURI.contains('leave') ? 'active' : ''}">
            <i class="fas fa-calendar-check"></i> Nghỉ phép
        </a>

        <a href="${pageContext.request.contextPath}/salary" class="nav-item ${pageContext.request.requestURI.contains('salary') ? 'active' : ''}">
            <i class="fas fa-money-check-dollar"></i> Lương
        </a>

        <div style="margin: 20px 16px 10px; font-size: 0.7rem; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px;">
            Hệ thống (Admin)
        </div>

        <a href="${pageContext.request.contextPath}/admin/users" class="nav-item ${pageContext.request.requestURI.contains('users') ? 'active' : ''}">
            <i class="fas fa-user-gear"></i> Quản lý Users
        </a>

        <a href="${pageContext.request.contextPath}/admin/permissions" class="nav-item ${pageContext.request.requestURI.contains('permissions') ? 'active' : ''}">
            <i class="fas fa-shield-halved"></i> Phân quyền
        </a>

        <a href="${pageContext.request.contextPath}/settings" class="nav-item ${pageContext.request.requestURI.contains('settings') ? 'active' : ''}">
            <i class="fas fa-sliders"></i> Cấu hình
        </a>
    </nav>

    <div style="padding: 20px; border-top: 1px solid #f1f5f9;">
        <a href="${pageContext.request.contextPath}/logout" class="nav-item" style="color: #ef4444;">
            <i class="fas fa-right-from-bracket" style="color: #ef4444;"></i> Đăng xuất
        </a>
    </div>
</div>