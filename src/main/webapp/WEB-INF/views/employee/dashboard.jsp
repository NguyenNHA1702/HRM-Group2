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

        <c:if test="${stats.pendingRequests > 0}">
            <div style="background:linear-gradient(135deg, #f59e0b, #d97706); color:#fff; padding:16px 20px; border-radius:12px; margin-bottom:24px; display:flex; align-items:center; gap:12px;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:24px; height:24px; flex-shrink:0;"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                <div>
                    <p style="margin:0; font-weight:600;">Bạn có ${stats.pendingRequests} đơn đang chờ duyệt</p>
                    <p style="margin:4px 0 0; opacity:0.9; font-size:13px;">Bao gồm đơn nghỉ phép và giải trình chấm công chưa được phê duyệt.</p>
                </div>
            </div>
        </c:if>

        <div style="display:flex; gap:12px; margin-bottom:24px; flex-wrap:wrap;">
            <a href="${pageContext.request.contextPath}/nghi-phep/tao" style="display:inline-flex; align-items:center; gap:8px; background:#4f46e5; color:#fff; padding:10px 20px; border-radius:8px; text-decoration:none; font-size:14px; font-weight:500;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:18px; height:18px;"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                Tạo đơn nghỉ phép
            </a>
            <a href="${pageContext.request.contextPath}/cham-cong" style="display:inline-flex; align-items:center; gap:8px; background:#0ea5e9; color:#fff; padding:10px 20px; border-radius:8px; text-decoration:none; font-size:14px; font-weight:500;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:18px; height:18px;"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                Xem chấm công
            </a>
            <a href="${pageContext.request.contextPath}/luong" style="display:inline-flex; align-items:center; gap:8px; background:#10b981; color:#fff; padding:10px 20px; border-radius:8px; text-decoration:none; font-size:14px; font-weight:500;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:18px; height:18px;"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                Xem bảng lương
            </a>
        </div>

        <div class="stats-grid mb-24">
            <div class="stat-card">
                <div>
                    <p class="stat-label">Công tháng này</p>
                    <p class="stat-value">${stats.workDays} ngày</p>
                </div>
                <div class="stat-icon icon-blue">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                </div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-label">Phép còn lại</p>
                    <p class="stat-value"><fmt:formatNumber value="${stats.leaveRemain}" maxFractionDigits="1"/> ngày</p>
                </div>
                <div class="stat-icon icon-green">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                </div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-label">Lương dự kiến</p>
                    <p class="stat-value">${stats.estimatedSalaryFormatted}</p>
                </div>
                <div class="stat-icon icon-purple">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                </div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-label">Đơn chờ duyệt</p>
                    <p class="stat-value">${stats.pendingRequests}</p>
                </div>
                <div class="stat-icon icon-orange">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                </div>
            </div>
        </div>

        <div class="card mb-24">
            <div class="card-header"><span class="card-title">Đơn nghỉ phép gần đây</span></div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty myRecentLeaves}">
                        <c:forEach var="req" items="${myRecentLeaves}">
                            <div class="leave-row" style="padding:12px 0; border-bottom:1px solid #f1f5f9;">
                                <div class="leave-info">
                                    <h4 style="margin:0 0 4px 0;">
                                            ${req['leave_type']}
                                        <c:choose>
                                            <c:when test="${req['status'] == 'APPROVED'}">
                                                <span class="badge badge-green" style="background:#dcfce7; color:#15803d; margin-left:8px; padding:2px 6px; border-radius:4px; font-size:11px;">Đã duyệt</span>
                                            </c:when>
                                            <c:when test="${req['status'] == 'PENDING'}">
                                                <span class="badge badge-orange" style="background:#fef3c7; color:#b45309; margin-left:8px; padding:2px 6px; border-radius:4px; font-size:11px;">Chờ duyệt</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-red" style="background:#fee2e2; color:#b91c1c; margin-left:8px; padding:2px 6px; border-radius:4px; font-size:11px;">Từ chối</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </h4>
                                    <p style="margin:0; color:#64748b; font-size:13px;">
                                        Từ ngày: ${req['start_date']} <c:if test="${req['start_date'] != req['end_date']}"> đến ${req['end_date']}</c:if> · Lý do: ${req['reason']}
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