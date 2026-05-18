<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Dashboard – Nhân viên | HRMS</title>
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
                <h1>Dashboard</h1>
                <p class="subtitle">Xin chào, <strong>${sessionScope.fullName}</strong>!</p>
            </div>
        </div>

        <!-- ── Check-in banner — dùng todayAttendance (Map) ── -->
        <%-- Map keys: check_in_time, check_out_time (null nếu chưa có) --%>
        <div class="checkin-banner">
            <div>
                <h3>Chấm công hôm nay</h3>
                <c:choose>
                    <c:when test="${not empty todayAttendance.check_in_time}">
                        <p>Đã check-in lúc <strong>${todayAttendance.check_in_time}</strong>
                            <c:if test="${not empty todayAttendance.check_out_time}">
                                · Check-out lúc <strong>${todayAttendance.check_out_time}</strong>
                            </c:if>
                        </p>
                    </c:when>
                    <c:otherwise>
                        <p>Bạn chưa check-in hôm nay</p>
                    </c:otherwise>
                </c:choose>
            </div>

            <c:choose>
                <c:when test="${empty todayAttendance.check_in_time}">
                    <a href="${pageContext.request.contextPath}/attendance/checkin" class="btn-checkin">
                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        Check-in ngay
                    </a>
                </c:when>
                <c:when test="${empty todayAttendance.check_out_time}">
                    <a href="${pageContext.request.contextPath}/attendance/checkout" class="btn-checkin">
                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        Check-out
                    </a>
                </c:when>
                <c:otherwise>
          <span style="background:rgba(255,255,255,.2);padding:9px 18px;border-radius:9px;font-size:13px;font-weight:600;">
            ✓ Hoàn thành hôm nay
          </span>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- ── Stat cards — dùng stats (EmployeeStatsDto) ── -->
        <div class="stats-grid mb-24">

            <div class="stat-card">
                <div>
                    <p class="stat-label">Công tháng này</p>
                    <p class="stat-value">${stats.workDays}</p>
                </div>
                <div class="stat-icon icon-blue">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/>
                        <line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>
                    </svg>
                </div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-label">Phép còn lại</p>
                    <p class="stat-value">
                        <fmt:formatNumber value="${stats.leaveRemain}" maxFractionDigits="1"/> ngày
                    </p>
                </div>
                <div class="stat-icon icon-green">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                        <polyline points="14 2 14 8 20 8"/>
                    </svg>
                </div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-label">Lương dự kiến</p>
                    <%-- Dùng method getEstimatedSalaryFormatted() từ EmployeeStatsDto --%>
                    <p class="stat-value">${stats.estimatedSalaryFormatted}</p>
                </div>
                <div class="stat-icon icon-purple">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="12" y1="1" x2="12" y2="23"/>
                        <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
                    </svg>
                </div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-label">Giờ làm tuần</p>
                    <p class="stat-value">
                        <fmt:formatNumber value="${stats.weekHours}" maxFractionDigits="1"/>h
                    </p>
                </div>
                <div class="stat-icon icon-orange">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
                    </svg>
                </div>
            </div>

        </div>

        <!-- ── Recent leave requests — dùng myRecentLeaves (List<Map>) ── -->
        <%-- Map keys: leave_type, start_date, end_date, reason, status --%>
        <div class="card mb-24">
            <div class="card-header">
                <span class="card-title">Đơn nghỉ phép gần đây</span>
                <a href="${pageContext.request.contextPath}/leave/create" class="btn btn-primary btn-sm">Tạo đơn mới</a>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty myRecentLeaves}">
                        <c:forEach var="req" items="${myRecentLeaves}">
                            <div class="leave-row">
                                <div class="leave-info">
                                    <h4>
                                            ${req.leave_type}
                                        <c:choose>
                                            <c:when test="${req.status == 'approved'}">
                                                <span class="badge badge-green" style="margin-left:8px;">Đã duyệt</span>
                                            </c:when>
                                            <c:when test="${req.status == 'pending'}">
                                                <span class="badge badge-orange" style="margin-left:8px;">Chờ duyệt</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-red" style="margin-left:8px;">Từ chối</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </h4>
                                    <p>
                                        Ngày: ${req.start_date}
                                        <c:if test="${req.start_date != req.end_date}"> – ${req.end_date}</c:if>
                                        · Lý do: ${req.reason}
                                    </p>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted text-sm">Bạn chưa có đơn nghỉ phép nào.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

    </main>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
</body>
</html>
