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

    <!-- Page header -->
    <div class="page-header">
      <div>
        <h1>Dashboard Admin</h1>
        <p class="subtitle">Tổng quan hệ thống &amp; người dùng</p>
      </div>
      <div class="page-header-right">
        <a href="#" class="notif-btn" title="Thông báo">
          <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
            <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
          </svg>
        </a>
      </div>
    </div>

    <!-- ── Stat cards — dùng stats (AdminStatsDto) ── -->
    <div class="stats-grid mb-24">

      <div class="stat-card">
        <div>
          <p class="stat-label">Tổng Users</p>
          <p class="stat-value">${stats.totalActiveUsers}</p>
        </div>
        <div class="stat-icon icon-blue">
          <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        </div>
      </div>

      <div class="stat-card">
        <div>
          <p class="stat-label">Hoạt động hôm nay</p>
          <p class="stat-value">${stats.activeToday}</p>
        </div>
        <div class="stat-icon icon-green">
          <svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
        </div>
      </div>

      <div class="stat-card">
        <div>
          <p class="stat-label">Roles</p>
          <p class="stat-value">${stats.totalRoles}</p>
        </div>
        <div class="stat-icon icon-purple">
          <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
        </div>
      </div>

      <div class="stat-card">
        <div>
          <p class="stat-label">Tăng trưởng</p>
          <p class="stat-value">
            <fmt:formatNumber value="${stats.growthPercent}" maxFractionDigits="1"/>%
          </p>
          <p class="stat-sub">↑ so với tháng trước</p>
        </div>
        <div class="stat-icon icon-orange">
          <svg viewBox="0 0 24 24"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
        </div>
      </div>

    </div><!-- /stats-grid -->

    <!-- ── Charts — dùng dailyLogins & usersByRole ── -->
    <div class="grid-2 mb-24">

      <div class="card">
        <div class="card-header"><span class="card-title">Đăng nhập theo ngày</span></div>
        <div class="card-body">
          <canvas id="loginChart" height="140"></canvas>
        </div>
      </div>

      <div class="card">
        <div class="card-header"><span class="card-title">Phân bổ Users theo Role</span></div>
        <div class="card-body">
          <canvas id="roleChart" height="140"></canvas>
        </div>
      </div>

    </div>

    <!-- ── Recent activity — dùng recentActivities (List<Map>) ── -->
    <%-- Map keys từ DB view vw_recent_activity: actor_name, action_desc, time_label --%>
    <div class="card mb-24">
      <div class="card-header"><span class="card-title">Hoạt động gần đây</span></div>
      <c:choose>
        <c:when test="${not empty recentActivities}">
          <c:forEach var="act" items="${recentActivities}">
            <div class="activity-row">
              <div>
                <span class="activity-name">${act.actor_name}</span>
                <span class="activity-desc"> ${act.action_desc}</span>
              </div>
              <span class="activity-time">${act.time_label}</span>
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
  // ── Line chart: dailyLogins — Map keys: login_date, login_count ──
  (function () {
    const raw = [
      <c:forEach var="d" items="${dailyLogins}" varStatus="s">
      { label: "${d.login_date}", value: ${d.login_count} }<c:if test="${!s.last}">,</c:if>
      </c:forEach>
    ];
    createLineChart('loginChart', raw.map(r => r.label), raw.map(r => r.value), '#4F46E5');
  })();

  // ── Bar chart: usersByRole — Map keys: role_group, user_count ──
  (function () {
    const raw = [
      <c:forEach var="r" items="${usersByRole}" varStatus="s">
      { label: "${r.role_group}", value: ${r.user_count} }<c:if test="${!s.last}">,</c:if>
      </c:forEach>
    ];
    createBarChart('roleChart', raw.map(r => r.label), raw.map(r => r.value), '#4F46E5');
  })();
</script>
</body>
</html>
