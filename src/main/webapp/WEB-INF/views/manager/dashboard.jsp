<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Dashboard – Manager | HRMS</title>
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
                <h1>Dashboard Manager</h1>
                <p class="subtitle">Quản lý team &amp; phê duyệt đơn từ</p>
            </div>
        </div>

        <!-- ── Stat cards — dùng stats (ManagerStatsDto) ── -->
        <div class="stats-grid mb-24">

            <div class="stat-card">
                <div>
                    <p class="stat-label">Nhân viên trong team</p>
                    <p class="stat-value">${stats.teamSize}</p>
                </div>
                <div class="stat-icon icon-blue">
                    <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                </div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-label">Có mặt hôm nay</p>
                    <p class="stat-value">${stats.presentToday}</p>
                </div>
                <div class="stat-icon icon-green">
                    <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                </div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-label">Nghỉ phép</p>
                    <p class="stat-value">${stats.onLeave}</p>
                </div>
                <div class="stat-icon icon-red">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                </div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-label">Đơn chờ duyệt</p>
                    <p class="stat-value">${stats.pendingApprovals}</p>
                </div>
                <div class="stat-icon icon-orange">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                </div>
            </div>

        </div>

        <!-- ── Charts — teamKpi & (không có attendanceTrend trong Controller, dùng teamStatus) ── -->
        <%-- teamKpi Map keys: employee_name, kpi_score --%>
        <div class="grid-2 mb-24">
            <div class="card">
                <div class="card-header"><span class="card-title">KPI Team (tháng này)</span></div>
                <div class="card-body"><canvas id="kpiChart" height="150"></canvas></div>
            </div>
            <div class="card">
                <div class="card-header"><span class="card-title">Xu hướng chấm công tuần này</span></div>
                <div class="card-body"><canvas id="attendChart" height="150"></canvas></div>
            </div>
        </div>

        <!-- ── Team status table — dùng teamStatus (List<Map>) ── -->
        <%-- Map keys: employee_name, check_in, check_out, attendance_status, kpi_score --%>
        <div class="card mb-24">
            <div class="card-header"><span class="card-title">Tình trạng team hôm nay</span></div>
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Nhân viên</th>
                        <th>Check-in</th>
                        <th>Check-out</th>
                        <th>Trạng thái</th>
                        <th>KPI</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty teamStatus}">
                            <c:forEach var="emp" items="${teamStatus}">
                                <tr>
                                    <td class="fw-600">${emp.employee_name}</td>
                                    <td>${empty emp.check_in ? '—' : emp.check_in}</td>
                                    <td>${empty emp.check_out ? '—' : emp.check_out}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${emp.attendance_status == 'present'}">
                                                <span class="badge badge-green">Có mặt</span>
                                            </c:when>
                                            <c:when test="${emp.attendance_status == 'late'}">
                                                <span class="badge badge-orange">Đi muộn</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-red">Nghỉ phép</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="fw-600">${emp.kpi_score}%</span>
                                        <span class="progress-bar">
                        <span class="progress-fill" style="width:${emp.kpi_score}%"></span>
                      </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr><td colspan="5" class="text-muted" style="text-align:center;padding:20px;">Không có dữ liệu.</td></tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- ── Pending leave approvals — dùng pendingLeaves (List<Map>) ── -->
        <%-- Map keys: employee_name, leave_type, start_date, end_date, reason, leave_request_id --%>
        <div class="card">
            <div class="card-header"><span class="card-title">Đơn từ cần duyệt</span></div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty pendingLeaves}">
                        <c:forEach var="req" items="${pendingLeaves}">
                            <div class="leave-row">
                                <div class="leave-info">
                                    <h4>
                                            ${req.employee_name}
                                        <span class="badge badge-blue" style="margin-left:6px;">${req.leave_type}</span>
                                    </h4>
                                    <p>
                                        Ngày: ${req.start_date}
                                        <c:if test="${req.start_date != req.end_date}"> – ${req.end_date}</c:if>
                                        · Lý do: ${req.reason}
                                    </p>
                                </div>
                                <div class="leave-actions">
                                    <a href="${pageContext.request.contextPath}/leave/approve?id=${req.leave_request_id}"
                                       class="btn btn-success btn-sm">Duyệt</a>
                                    <a href="${pageContext.request.contextPath}/leave/reject?id=${req.leave_request_id}"
                                       class="btn btn-danger btn-sm">Từ chối</a>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted text-sm">Không có đơn nào cần duyệt.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

    </main>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
<script>
    // ── KPI chart — teamKpi: employee_name, kpi_score ──
    (function () {
        const raw = [
            <c:forEach var="k" items="${teamKpi}" varStatus="s">
            { label: "${k.employee_name}", value: ${k.kpi_score} }<c:if test="${!s.last}">,</c:if>
            </c:forEach>
        ];
        if (raw.length) {
            createBarChart('kpiChart', raw.map(r => r.label), raw.map(r => r.value), '#4F46E5');
        }
    })();

    // ── Attendance trend — teamStatus: attendance_status gom nhóm ──
    (function () {
        const rows = [
            <c:forEach var="emp" items="${teamStatus}" varStatus="s">
            { status: "${emp.attendance_status}" }<c:if test="${!s.last}">,</c:if>
            </c:forEach>
        ];
        const present = rows.filter(r => r.status === 'present' || r.status === 'late').length;
        const absent  = rows.filter(r => r.status === 'leave' || r.status === 'absent').length;
        createDoughnutChart('attendChart',
            ['Có mặt / Muộn', 'Vắng mặt'],
            [present, absent],
            ['#10B981', '#EF4444']
        );
    })();
</script>
</body>
</html>
