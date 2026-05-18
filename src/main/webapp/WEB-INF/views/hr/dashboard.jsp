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

    <div class="grid-2 mb-24">
      <div class="card">
        <div class="card-header"><span class="card-title">Nhân viên theo Phòng ban</span></div>
        <div class="card-body"><canvas id="deptChart" height="150"></canvas></div>
      </div>
      <div class="card">
        <div class="card-header"><span class="card-title">Tuyển dụng gần đây</span></div>
        <div class="card-body"><canvas id="recruitChart" height="150"></canvas></div>
      </div>
    </div>

    <div class="grid-2 mb-24">
      <div class="card">
        <div class="card-header"><span class="card-title">Tình trạng chấm công hôm nay</span></div>
        <div class="card-body" style="display:flex; justify-content:center;">
          <canvas id="attendPieChart" height="180" style="max-width:280px;"></canvas>
        </div>
      </div>

      <div class="card">
        <div class="card-header"><span class="card-title">Đơn từ cần xử lý</span></div>
        <div class="card-body">
          <p class="text-muted text-sm" style="padding:8px 0;">Hệ thống ghi nhận có đơn nghỉ phép đang chờ xem xét duyệt trên toàn công ty.</p>
        </div>
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

    // 3. Attendance Doughnut
    createDoughnutChart('attendPieChart',
            ['Đúng giờ', 'Đi muộn', 'Nghỉ phép'],
            [6, 2, 2],
            ['#10B981', '#F59E0B', '#EF4444']
    );
  });
</script>
</body>
</html>