<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Dashboard – HR | HRMS</title>
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
        <h1>Dashboard HR</h1>
        <p class="subtitle">Quản lý nhân sự &amp; tuyển dụng</p>
      </div>
    </div>

    <div class="stats-grid mb-24">
      <div class="stat-card">
        <div>
          <p class="stat-label">Tổng nhân viên</p>
          <p class="stat-value">${stats.totalEmployees}</p>
        </div>
        <div class="stat-icon icon-blue">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
        </div>
      </div>

      <div class="stat-card">
        <div>
          <p class="stat-label">Nhân viên mới tháng này</p>
          <p class="stat-value">${stats.newThisMonth}</p>
        </div>
        <div class="stat-icon icon-green">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/></svg>
        </div>
      </div>

      <div class="stat-card">
        <div>
          <p class="stat-label">Đã nghỉ việc</p>
          <p class="stat-value">${stats.terminated}</p>
        </div>
        <div class="stat-icon icon-red">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
        </div>
      </div>

      <div class="stat-card">
        <div>
          <p class="stat-label">Quỹ lương tháng</p>
          <p class="stat-value">${stats.payrollFundFormatted}</p>
        </div>
        <div class="stat-icon icon-purple">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
        </div>
      </div>
    </div>

    <!-- Quick Shortcuts Panel -->
    <div class="card mb-24">
      <div class="card-header"><span class="card-title">Truy cập nhanh phân hệ HR</span></div>
      <div class="card-body" style="display:grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap:12px;">
        <a href="${pageContext.request.contextPath}/hr/contracts" style="display:flex; align-items:center; gap:10px; padding:12px 16px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; text-decoration:none; color:#1e293b; font-weight:500;">
          <span style="background:#e0e7ff; color:#4f46e5; width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:18px;">📄</span>
          <span>Hợp đồng lao động</span>
        </a>
        <a href="${pageContext.request.contextPath}/hr/departments" style="display:flex; align-items:center; gap:10px; padding:12px 16px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; text-decoration:none; color:#1e293b; font-weight:500;">
          <span style="background:#f3e8ff; color:#9333ea; width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:18px;">🏢</span>
          <span>Quản lý Phòng ban</span>
        </a>
        <a href="${pageContext.request.contextPath}/payroll/list" style="display:flex; align-items:center; gap:10px; padding:12px 16px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; text-decoration:none; color:#1e293b; font-weight:500;">
          <span style="background:#dcfce7; color:#16a34a; width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:18px;">💸</span>
          <span>Danh sách Bảng lương</span>
        </a>
        <a href="${pageContext.request.contextPath}/hr/candidates" style="display:flex; align-items:center; gap:10px; padding:12px 16px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; text-decoration:none; color:#1e293b; font-weight:500;">
          <span style="background:#fef3c7; color:#d97706; width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:18px;">👨‍💼</span>
          <span>Quản lý Ứng viên</span>
        </a>
        <a href="${pageContext.request.contextPath}/hr/leave-summary" style="display:flex; align-items:center; gap:10px; padding:12px 16px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; text-decoration:none; color:#1e293b; font-weight:500;">
          <span style="background:#e0f2fe; color:#0284c7; width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:18px;">📊</span>
          <span>Báo cáo Nghỉ phép</span>
        </a>
        <a href="${pageContext.request.contextPath}/hr/attendance-statistics" style="display:flex; align-items:center; gap:10px; padding:12px 16px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; text-decoration:none; color:#1e293b; font-weight:500;">
          <span style="background:#ffe4e6; color:#e11d48; width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:18px;">⏱️</span>
          <span>Thống kê Chấm công</span>
        </a>
      </div>
    </div>

    <div class="grid-2 mb-24">
      <div class="card" style="border-left: 4px solid #4F46E5;">
        <div class="card-header"><span class="card-title">Công việc Cần xử lý</span></div>
        <div class="card-body" style="display:flex; flex-direction:column; gap:16px;">
          <a href="${pageContext.request.contextPath}/hr/leave-requests" style="display:flex; justify-content:space-between; align-items:center; text-decoration:none; color:inherit; padding:12px; background:#f8fafc; border-radius:8px;">
            <div>
              <p style="margin:0; font-weight:600; color:#1e293b;">Đơn nghỉ phép chờ duyệt</p>
              <p style="margin:4px 0 0; font-size:13px; color:#64748b;">Xem danh sách đơn cần phê duyệt</p>
            </div>
            <span style="font-size:24px; font-weight:700; color:#4F46E5;">${stats.pendingLeaves}</span>
          </a>
          <a href="${pageContext.request.contextPath}/hr/attendance-explanations" style="display:flex; justify-content:space-between; align-items:center; text-decoration:none; color:inherit; padding:12px; background:#f8fafc; border-radius:8px;">
            <div>
              <p style="margin:0; font-weight:600; color:#1e293b;">Giải trình chấm công chờ duyệt</p>
              <p style="margin:4px 0 0; font-size:13px; color:#64748b;">Xem danh sách giải trình cần xét duyệt</p>
            </div>
            <span style="font-size:24px; font-weight:700; color:#F59E0B;">${stats.pendingExplanations}</span>
          </a>
          <a href="${pageContext.request.contextPath}/hr/vacancies" style="display:flex; justify-content:space-between; align-items:center; text-decoration:none; color:inherit; padding:12px; background:#f8fafc; border-radius:8px;">
            <div>
              <p style="margin:0; font-weight:600; color:#1e293b;">Vị trí tuyển dụng đang mở</p>
              <p style="margin:4px 0 0; font-size:13px; color:#64748b;">Xem danh sách vị trí đang tuyển</p>
            </div>
            <span style="font-size:24px; font-weight:700; color:#10B981;">${stats.openVacancies}</span>
          </a>
        </div>
      </div>

      <div class="card">
        <div class="card-header"><span class="card-title">Top 5 Phòng ban đông nhân sự nhất</span></div>
        <div class="card-body"><canvas id="deptChart" height="150"></canvas></div>
      </div>
    </div>

  </main>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
<script>
  window.addEventListener("DOMContentLoaded", function () {
    // 1. Headcount By Department
    const deptLabels = [];
    const deptValues = [];
    <c:forEach var="d" items="${headcountByDept}">
    if ("${d['dept_name']}" !== "" || "${d['department_name']}" !== "") {
      <c:set var="deptLbl" value="${d['dept_name'] != null ? d['dept_name'] : d['department_name']}" />
      deptLabels.push("${deptLbl}");
      deptValues.push(Number("${d['emp_count'] != null ? d['emp_count'] : (d['total_employees'] != null ? d['total_employees'] : 0)}"));
    }
    </c:forEach>
    if (deptLabels.length > 0) {
      createBarChart('deptChart', deptLabels, deptValues, '#4F46E5');
    } else {
      createBarChart('deptChart', ['Chưa có dữ liệu'], [0], '#4F46E5');
    }

    // 2. Recruitment Trend
    const recruitLabels = [];
    const recruitValues = [];
    <c:forEach var="r" items="${recruitmentTrend}">
    if ("${r['month_label']}" !== "") {
      recruitLabels.push("${r['month_label']}");
      recruitValues.push(Number("${r['new_count'] != null ? r['new_count'] : 0}"));
    }
    </c:forEach>
    if (recruitLabels.length > 0) {
      createBarChart('recruitChart', recruitLabels, recruitValues, '#10B981');
    } else {
      createBarChart('recruitChart', ['Tháng 3', 'Tháng 4', 'Tháng 5'], [0, 0, 0], '#10B981');
    }
  });
</script>
</body>
</html>