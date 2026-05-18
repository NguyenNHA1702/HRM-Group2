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

        <div class="stats-grid mb-24">
            <div class="stat-card">
                <div>
                    <p class="stat-label">Nhân viên trong team</p>
                    <p class="stat-value">${stats.teamSize}</p>
                </div>
                <div class="stat-icon icon-blue">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                </div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-label">Có mặt hôm nay</p>
                    <p class="stat-value">${stats.presentToday}</p>
                </div>
                <div class="stat-icon icon-green">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                </div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-label">Nghỉ phép</p>
                    <p class="stat-value">${stats.onLeave}</p>
                </div>
                <div class="stat-icon icon-red">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/></svg>
                </div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-label">Đơn chờ duyệt</p>
                    <p class="stat-value">${stats.pendingApprovals}</p>
                </div>
                <div class="stat-icon icon-orange">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                </div>
            </div>
        </div>

        <div class="grid-2 mb-24">
            <div class="card">
                <div class="card-header"><span class="card-title">KPI Team</span></div>
                <div class="card-body"><canvas id="kpiChart" height="150"></canvas></div>
            </div>
            <div class="card">
                <div class="card-header"><span class="card-title">Trạng thái làm việc hôm nay</span></div>
                <div class="card-body"><canvas id="attendChart" height="150"></canvas></div>
            </div>
        </div>

        <div class="card mb-24">
            <div class="card-header"><span class="card-title">Tình trạng team hôm nay</span></div>
            <div class="table-wrap">
                <table style="width:100%; border-collapse:collapse; text-align:left;">
                    <thead>
                    <tr style="background:#f8fafc; border-bottom:1px solid #e2e8f0;">
                        <th style="padding:12px;">Nhân viên</th>
                        <th style="padding:12px;">Check-in</th>
                        <th style="padding:12px;">Check-out</th>
                        <th style="padding:12px;">Trạng thái</th>
                        <th style="padding:12px;">KPI</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty teamStatus}">
                            <c:forEach var="emp" items="${teamStatus}">
                                <tr style="border-bottom:1px solid #f1f5f9;">
                                    <td style="padding:12px; font-weight:600;">${emp['employee_name'] != null ? emp['employee_name'] : emp['full_name']}</td>
                                    <td style="padding:12px;">${empty emp['check_in'] ? '—' : emp['check_in']}</td>
                                    <td style="padding:12px;">${empty emp['check_out'] ? '—' : emp['check_out']}</td>
                                    <td style="padding:12px;">
                                        <c:set var="statusLabel" value="${emp['attendance_status'] != null ? emp['attendance_status'] : emp['status']}" />
                                        <c:choose>
                                            <c:when test="${statusLabel == 'PRESENT'}">
                                                <span class="badge badge-green" style="background:#dcfce7; color:#15803d; padding:4px 8px; border-radius:4px; font-size:12px;">Có mặt</span>
                                            </c:when>
                                            <c:when test="${statusLabel == 'LATE'}">
                                                <span class="badge badge-orange" style="background:#fef3c7; color:#b45309; padding:4px 8px; border-radius:4px; font-size:12px;">Đi muộn</span>
                                            </c:when>
                                            <c:when test="${statusLabel == 'EARLY_LEAVE'}">
                                                <span class="badge badge-blue" style="background:#dbeafe; color:#1d4ed8; padding:4px 8px; border-radius:4px; font-size:12px;">Về sớm</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-red" style="background:#fee2e2; color:#b91c1c; padding:4px 8px; border-radius:4px; font-size:12px;">Vắng / Nghỉ</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding:12px;">
                                        <span class="fw-600">${emp['kpi_score'] != null ? emp['kpi_score'] : 0}%</span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr><td colspan="5" class="text-muted" style="text-align:center; padding:20px;">Không có dữ liệu team.</td></tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card">
            <div class="card-header"><span class="card-title">Đơn từ cần duyệt</span></div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty pendingLeaves}">
                        <c:forEach var="req" items="${pendingLeaves}">
                            <div class="leave-row" style="display:flex; justify-content:space-between; align-items:center; padding:12px 0; border-bottom:1px solid #f1f5f9;">
                                <div class="leave-info">
                                    <h4 style="margin:0 0 4px 0;">
                                            ${req['employee_name']}
                                        <span class="badge badge-blue" style="background:#e0f2fe; color:#0369a1; margin-left:6px; padding:2px 6px; border-radius:4px; font-size:11px;">${req['leave_type']}</span>
                                    </h4>
                                    <p style="margin:0; color:#64748b; font-size:13px;">
                                        Ngày: ${req['start_date']} đến ${req['end_date']} · Lý do: ${req['reason']}
                                    </p>
                                </div>
                                <div class="leave-actions" style="display:flex; gap:8px;">
                                    <a href="${pageContext.request.contextPath}/leave/approve?id=${req['leave_request_id']}" style="background:#10b981; color:#fff; padding:6px 12px; border-radius:6px; text-decoration:none; font-size:13px;">Duyệt</a>
                                    <a href="${pageContext.request.contextPath}/leave/reject?id=${req['leave_request_id']}" style="background:#ef4444; color:#fff; padding:6px 12px; border-radius:6px; text-decoration:none; font-size:13px;">Từ chối</a>
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
    window.addEventListener("DOMContentLoaded", function () {
        // 1. KPI Chart
        const kpiLabels = [];
        const kpiValues = [];
        <c:forEach var="k" items="${teamKpi}">
        if ("${k['employee_name']}" !== "" || "${k['full_name']}" !== "") {
            <c:set var="kpiName" value="${k['employee_name'] != null ? k['employee_name'] : k['full_name']}" />
            kpiLabels.push("${kpiName}");
            kpiValues.push(Number("${k['kpi_score'] != null ? k['kpi_score'] : 0}"));
        }
        </c:forEach>
        if (kpiLabels.length > 0) {
            createBarChart('kpiChart', kpiLabels, kpiValues, '#4F46E5');
        } else {
            createBarChart('kpiChart', ['Chưa có dữ liệu'], [0], '#4F46E5');
        }

        // 2. Attendance Status Doughnut
        let presentCount = 0;
        let absentCount = 0;
        <c:forEach var="emp" items="${teamStatus}">
        var st = "${emp['attendance_status'] != null ? emp['attendance_status'] : emp['status']}";
        if (st === 'PRESENT' || st === 'LATE' || st === 'EARLY_LEAVE') {
            presentCount++;
        } else if (st !== "") {
            absentCount++;
        }
        </c:forEach>

        // Nếu cả 2 bằng 0 tức là mảng rỗng, cho số liệu mặc định 0 để không lỗi canvas
        createDoughnutChart('attendChart',
            ['Có mặt / Muộn', 'Vắng / Nghỉ'],
            [presentCount, absentCount],
            ['#10B981', '#EF4444']
        );
    });
</script>
</body>
</html>