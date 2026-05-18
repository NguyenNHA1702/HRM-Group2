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
      <div class="page-header-right">
        <a href="${pageContext.request.contextPath}/employee/add" class="btn btn-primary btn-sm">+ Thêm nhân viên</a>
      </div>
    </div>

    <!-- ── Stat cards — dùng stats (HrStatsDto) ── -->
    <div class="stats-grid mb-24">

      <div class="stat-card">
        <div>
          <p class="stat-label">Tổng nhân viên</p>
          <p class="stat-value">${stats.totalEmployees}</p>
        </div>
        <div class="stat-icon icon-blue">
          <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        </div>
      </div>

      <div class="stat-card">
        <div>
          <p class="stat-label">Nhân viên mới tháng này</p>
          <p class="stat-value">${stats.newThisMonth}</p>
        </div>
        <div class="stat-icon icon-green">
          <svg viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
        </div>
      </div>

      <div class="stat-card">
        <div>
          <p class="stat-label">Đã nghỉ việc</p>
          <p class="stat-value">${stats.terminated}</p>
        </div>
        <div class="stat-icon icon-red">
          <svg viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
        </div>
      </div>

      <div class="stat-card">
        <div>
          <p class="stat-label">Quỹ lương tháng</p>
          <%-- Dùng method getPayrollFundFormatted() từ HrStatsDto --%>
          <p class="stat-value">${stats.payrollFundFormatted}</p>
        </div>
        <div class="stat-icon icon-purple">
          <svg viewBox="0 0 24 24"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
        </div>
      </div>

    </div>

    <!-- ── Charts row 1 — headcountByDept & recruitmentTrend ── -->
    <%-- Map keys: dept_name / count  |  month_label / new_count --%>
    <div class="grid-2 mb-24">
      <div class="card">
        <div class="card-header"><span class="card-title">Nhân viên theo Phòng ban</span></div>
        <div class="card-body"><canvas id="deptChart" height="150"></canvas></div>
      </div>
      <div class="card">
        <div class="card-header"><span class="card-title">Tuyển dụng 5 tháng gần đây</span></div>
        <div class="card-body"><canvas id="recruitChart" height="150"></canvas></div>
      </div>
    </div>

    <!-- ── Pending leave summary (tính từ headcountByDept hoặc query riêng) ── -->
    <div class="grid-2 mb-24">

      <!-- Biểu đồ tròn chấm công — nếu có attribute attendanceSummary từ Controller,
           hiện tại Controller HR chưa set nên hiển thị placeholder -->
      <div class="card">
        <div class="card-header"><span class="card-title">Tình trạng chấm công hôm nay</span></div>
        <div class="card-body" style="display:flex;justify-content:center;">
          <canvas id="attendPieChart" height="180" style="max-width:280px;"></canvas>
        </div>
      </div>

      <!-- Pending requests — headcountByDept dùng làm nguồn, hoặc Controller mở rộng sau -->
      <div class="card">
        <div class="card-header"><span class="card-title">Đơn từ cần xử lý</span></div>
        <div class="card-body">
          <%-- Nếu Controller bổ sung setAttribute("pendingByType", ...) thì dùng c:forEach --%>
          <c:choose>
            <c:when test="${not empty pendingByType}">
              <c:forEach var="item" items="${pendingByType}">
                <div class="pending-row">
                  <span class="pending-label">${item.leave_type}</span>
                  <span class="badge badge-blue">${item.cnt} đơn</span>
                </div>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <%-- Placeholder — thay bằng dữ liệu thật khi Controller bổ sung --%>
              <p class="text-muted text-sm" style="padding:8px 0;">
                Chưa có dữ liệu đơn từ. Thêm <code>pendingByType</code> vào Controller HR để hiển thị.
              </p>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

    </div>

  </main>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
<script>
  // ── Bar chart: headcountByDept — Map keys: dept_name, emp_count ──
  (function () {
    const raw = [
      <c:forEach var="d" items="${headcountByDept}" varStatus="s">
      { label: "${d.dept_name}", value: ${d.emp_count} }<c:if test="${!s.last}">,</c:if>
      </c:forEach>
    ];
    createBarChart('deptChart', raw.map(r => r.label), raw.map(r => r.value), '#4F46E5');
  })();

  // ── Bar chart: recruitmentTrend — Map keys: month_label, new_count ──
  (function () {
    const raw = [
      <c:forEach var="r" items="${recruitmentTrend}" varStatus="s">
      { label: "${r.month_label}", value: ${r.new_count} }<c:if test="${!s.last}">,</c:if>
      </c:forEach>
    ];
    createBarChart('recruitChart', raw.map(r => r.label), raw.map(r => r.value), '#10B981');
  })();

  // ── Pie chart placeholder (thay bằng dữ liệu thật nếu có) ──
  createDoughnutChart('attendPieChart',
          ['Đúng giờ', 'Đi muộn', 'Nghỉ phép'],
          [0, 0, 0],
          ['#10B981', '#F59E0B', '#EF4444']
  );
</script>
</body>
</html>
