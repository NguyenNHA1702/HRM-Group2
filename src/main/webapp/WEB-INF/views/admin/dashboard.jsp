<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Dashboard – Admin | HRMS</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
<div class="main-layout">

  <%@ include file="../../common/sidebar.jsp" %>

  <main class="content-area">

    <div class="page-header">
      <div>
        <h1>Dashboard Admin</h1>
        <p class="subtitle">Tổng quan hệ thống &amp; người dùng</p>
      </div>
    </div>

    <div class="stats-grid mb-24">
      <div class="stat-card">
        <div>
          <p class="stat-label">Tổng Users</p>
          <p class="stat-value">${stats.totalActiveUsers}</p>
        </div>
        <div class="stat-icon icon-blue">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
        </div>
      </div>

      <div class="stat-card">
        <div>
          <p class="stat-label">Hoạt động hôm nay</p>
          <p class="stat-value">${stats.activeToday}</p>
        </div>
        <div class="stat-icon icon-green">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        </div>
      </div>

      <div class="stat-card">
        <div>
          <p class="stat-label">Roles</p>
          <p class="stat-value">${stats.totalRoles}</p>
        </div>
        <div class="stat-icon icon-purple">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="20" height="8" rx="2" ry="2"/><rect x="2" y="14" width="20" height="8" rx="2" ry="2"/></svg>
        </div>
      </div>

      <div class="stat-card">
        <div>
          <p class="stat-label">Tổng nhân viên</p>
          <p class="stat-value">${stats.totalEmployees}</p>
        </div>
        <div class="stat-icon icon-orange">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><path d="M20 8v6M23 11h-6"/></svg>
        </div>
      </div>
    </div>

    <!-- Quick Shortcuts Panel -->
    <div class="card mb-24">
      <div class="card-header"><span class="card-title">Truy cập nhanh phím chức năng</span></div>
      <div class="card-body" style="display:grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap:12px;">
        <a href="${pageContext.request.contextPath}/admin/users" style="display:flex; align-items:center; gap:10px; padding:12px 16px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; text-decoration:none; color:#1e293b; font-weight:500;">
          <span style="background:#e0e7ff; color:#4f46e5; width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:18px;">👤</span>
          <span>Quản lý người dùng</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/roles" style="display:flex; align-items:center; gap:10px; padding:12px 16px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; text-decoration:none; color:#1e293b; font-weight:500;">
          <span style="background:#f3e8ff; color:#9333ea; width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:18px;">🔑</span>
          <span>Phân quyền Vai trò</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/work-shifts" style="display:flex; align-items:center; gap:10px; padding:12px 16px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; text-decoration:none; color:#1e293b; font-weight:500;">
          <span style="background:#dcfce7; color:#16a34a; width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:18px;">⏰</span>
          <span>Quản lý Ca làm việc</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/holidays" style="display:flex; align-items:center; gap:10px; padding:12px 16px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; text-decoration:none; color:#1e293b; font-weight:500;">
          <span style="background:#fef3c7; color:#d97706; width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:18px;">📅</span>
          <span>Cấu hình Ngày lễ</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/salary-scales" style="display:flex; align-items:center; gap:10px; padding:12px 16px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; text-decoration:none; color:#1e293b; font-weight:500;">
          <span style="background:#e0f2fe; color:#0284c7; width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:18px;">💰</span>
          <span>Thang bảng lương</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/insurance" style="display:flex; align-items:center; gap:10px; padding:12px 16px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; text-decoration:none; color:#1e293b; font-weight:500;">
          <span style="background:#ffe4e6; color:#e11d48; width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:18px;">🛡️</span>
          <span>Cấu hình Bảo hiểm</span>
        </a>
      </div>
    </div>

    <div class="grid-2 mb-24">
      <div class="card">
        <div class="card-header"><span class="card-title">Đăng nhập theo ngày</span></div>
        <div class="card-body"><canvas id="loginChart" height="140"></canvas></div>
      </div>
      <div class="card">
        <div class="card-header"><span class="card-title">Phân bổ Users theo Role</span></div>
        <div class="card-body"><canvas id="roleChart" height="140"></canvas></div>
      </div>
    </div>

    <div class="card mb-24">
      <div class="card-header"><span class="card-title">Hoạt động gần đây</span></div>
      <c:choose>
        <c:when test="${not empty recentActivities}">
          <c:forEach var="act" items="${recentActivities}">
            <%-- Tự động lấy Key bất kể Controller trả về chữ Hoa hay chữ Thường --%>
            <c:set var="fName" value="${act['full_name'] != null ? act['full_name'] : act['FULL_NAME']}" />
            <c:set var="fAction" value="${act['action'] != null ? act['action'] : act['ACTION']}" />
            <c:set var="fModule" value="${act['module_code'] != null ? act['module_code'] : act['MODULE_CODE']}" />
            <c:set var="fIp" value="${act['ip_address'] != null ? act['ip_address'] : act['IP_ADDRESS']}" />

            <div class="activity-row" style="display:flex; justify-content:space-between; padding:12px; border-bottom:1px solid #f1f5f9;">
              <div>
                <span class="activity-name" style="font-weight:600; color:#1e293b;">${fName}</span>
                <span class="activity-desc" style="color:#64748b;"> thực hiện hành động
                  <span class="badge" style="background:#e2e8f0; color:#475569; padding:2px 6px; border-radius:4px;">${fAction}</span>
                  trên phân hệ ${fModule}
                </span>
              </div>
              <span class="activity-time" style="color:#94a3b8; font-family:monospace;">${fIp}</span>
            </div>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <div class="card-body text-muted">Chưa có hoạt động nào.</div>
        </c:otherwise>
      </c:choose>
    </div>

  </main>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
<script>
  window.addEventListener("DOMContentLoaded", function () {
    // 1. Line chart: dailyLogins
    const loginLabels = [];
    const loginValues = [];
    <c:forEach var="d" items="${dailyLogins}">
    if ("${d['login_date']}" !== "") {
      loginLabels.push("${d['login_date']}");
      loginValues.push(Number("${d['total_logins'] != null ? d['total_logins'] : (d['login_count'] != null ? d['login_count'] : 0)}"));
    }
    </c:forEach>
    if (loginLabels.length > 0) {
      createLineChart('loginChart', loginLabels, loginValues, '#4F46E5');
    } else {
      createLineChart('loginChart', ['Chưa có dữ liệu'], [0], '#4F46E5');
    }

    // 2. Bar chart: usersByRole
    const roleLabels = [];
    const roleValues = [];
    <c:forEach var="r" items="${usersByRole}">
    if ("${r['group_name']}" !== "" || "${r['role_group']}" !== "") {
      <c:set var="roleLbl" value="${r['group_name'] != null ? r['group_name'] : r['role_group']}" />
      roleLabels.push("${roleLbl}");
      roleValues.push(Number("${r['user_count'] != null ? r['user_count'] : 0}"));
    }
    </c:forEach>
    if (roleLabels.length > 0) {
      createBarChart('roleChart', roleLabels, roleValues, '#6366F1');
    } else {
      createBarChart('roleChart', ['ADMIN', 'HR', 'MANAGER', 'EMPLOYEE'], [0, 0, 0, 0], '#6366F1');
    }
  });
</script>
</body>
</html>