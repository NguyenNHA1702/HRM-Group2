<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Chốt Công Theo Phòng Ban | HRMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css" />
    <style>
        .page-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; border-bottom:1px solid #e2e8f0; padding-bottom:16px; }
        .page-title { font-size:22px; font-weight:700; color:var(--text); margin:0; }
        .page-subtitle { font-size:13px; color:#64748b; margin-top:4px; }
        .btn { padding:10px 18px; border-radius:8px; font-weight:600; cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:8px; border:none; font-size:14px; }
        .btn-primary { background:#4f46e5; color:#fff; }
        .btn-success { background:#059669; color:#fff; }
        .btn-danger { background:#dc2626; color:#fff; }
        .btn-outline { background:transparent; border:1px solid #cbd5e1; color:#475569; }
        .btn-sm { padding:6px 12px; font-size:13px; }

        .filter-bar { display:flex; gap:16px; align-items:center; margin-bottom:24px; padding:16px; background:#f8fafc; border-radius:12px; border:1px solid #e2e8f0; }
        .filter-bar select { padding:8px 12px; border-radius:8px; border:1px solid #cbd5e1; font-size:14px; }
        .filter-bar label { font-weight:600; font-size:13px; color:#475569; }

        .dept-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(320px, 1fr)); gap:16px; }
        .dept-card { background:#fff; border:1px solid #e2e8f0; border-radius:12px; padding:20px; transition:box-shadow .2s; }
        .dept-card:hover { box-shadow:0 4px 12px rgba(0,0,0,.08); }
        .dept-card .dept-name { font-size:16px; font-weight:700; color:#0f172a; margin-bottom:8px; }
        .dept-card .dept-status { display:flex; align-items:center; gap:8px; margin-bottom:16px; }

        .status-dot { width:12px; height:12px; border-radius:50%; display:inline-block; }
        .status-locked { background:#059669; }
        .status-unlocked { background:#f59e0b; }

        .status-text-locked { color:#059669; font-weight:600; font-size:14px; }
        .status-text-unlocked { color:#f59e0b; font-weight:600; font-size:14px; }

        .alert { padding:12px 16px; border-radius:8px; margin-bottom:16px; font-size:14px; }
        .alert-success { background:#d1fae5; color:#065f46; border:1px solid #6ee7b7; }
        .alert-error { background:#fee2e2; color:#991b1b; border:1px solid #fca5a5; }

        .summary-bar { display:flex; gap:24px; margin-bottom:24px; }
        .summary-card { background:#fff; border:1px solid #e2e8f0; border-radius:12px; padding:16px 24px; flex:1; }
        .summary-card .label { font-size:12px; color:#64748b; text-transform:uppercase; font-weight:600; }
        .summary-card .value { font-size:28px; font-weight:700; color:#0f172a; }
        .summary-card .value.green { color:#059669; }
        .summary-card .value.yellow { color:#f59e0b; }
    </style>
</head>
<body>
<div class="main-layout">
    <jsp:include page="/WEB-INF/common/sidebar.jsp" />
    <main class="content-area">

            <c:if test="${param.success != null}">
                <div class="alert alert-success"><i class="fas fa-check-circle"></i> Thao tác thành công!</div>
            </c:if>
            <c:if test="${param.error != null}">
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Có lỗi xảy ra.</div>
            </c:if>

            <div class="page-header">
                <div>
                    <h1 class="page-title"><i class="fas fa-lock"></i> Chốt Công Theo Phòng Ban</h1>
                    <p class="page-subtitle">Manager chốt công phòng ban mình → HR kiểm tra tổng quan → Tạo bảng lương</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/payrolls" class="btn btn-outline btn-sm">
                    <i class="fas fa-arrow-left"></i> Quay lại Bảng lương
                </a>
            </div>

            <!-- Month/Year filter -->
            <div class="filter-bar">
                <form action="${pageContext.request.contextPath}/admin/attendance/lock" method="get" style="display:flex; gap:12px; align-items:center;">
                    <label>Tháng:</label>
                    <select name="month">
                        <c:forEach var="m" begin="1" end="12">
                            <option value="${m}" ${m == selectedMonth ? 'selected' : ''}>Tháng ${m}</option>
                        </c:forEach>
                    </select>
                    <label>Năm:</label>
                    <select name="year">
                        <c:forEach var="y" begin="2024" end="2027">
                            <option value="${y}" ${y == selectedYear ? 'selected' : ''}>${y}</option>
                        </c:forEach>
                    </select>
                    <button type="submit" class="btn btn-sm btn-outline"><i class="fas fa-filter"></i> Lọc</button>
                </form>
            </div>

            <!-- Summary -->
            <c:set var="lockedCount" value="${lockedDeptIds.size()}" />
            <c:set var="totalDepts" value="${departments.size()}" />
            <c:set var="unlockedCount" value="${totalDepts - lockedCount}" />
            <div class="summary-bar">
                <div class="summary-card">
                    <div class="label">Tổng phòng ban</div>
                    <div class="value">${totalDepts}</div>
                </div>
                <div class="summary-card">
                    <div class="label">Đã chốt công</div>
                    <div class="value green">${lockedCount}</div>
                </div>
                <div class="summary-card">
                    <div class="label">Chưa chốt</div>
                    <div class="value yellow">${unlockedCount}</div>
                </div>
            </div>

            <!-- Department cards -->
            <div class="dept-grid">
                <c:forEach var="dept" items="${departments}">
                    <c:set var="isLocked" value="${lockedDeptIds.contains(dept.id)}" />
                    <div class="dept-card">
                        <div class="dept-name"><i class="fas fa-building"></i> ${dept.name}</div>
                        <div class="dept-status">
                            <span class="status-dot ${isLocked ? 'status-locked' : 'status-unlocked'}"></span>
                            <span class="${isLocked ? 'status-text-locked' : 'status-text-unlocked'}">
                                ${isLocked ? 'Đã chốt công' : 'Chưa chốt công'}
                            </span>
                        </div>
                        <form action="${pageContext.request.contextPath}/admin/attendance/lock" method="post">
                            <input type="hidden" name="month" value="${selectedMonth}" />
                            <input type="hidden" name="year" value="${selectedYear}" />
                            <input type="hidden" name="departmentId" value="${dept.id}" />
                            <c:choose>
                                <c:when test="${isLocked}">
                                    <input type="hidden" name="action" value="unlock" />
                                    <button type="submit" class="btn btn-danger btn-sm"
                                            onclick="return confirm('Mở khóa chấm công phòng ${dept.name}?')">
                                        <i class="fas fa-unlock"></i> Mở khóa
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <input type="hidden" name="action" value="lock" />
                                    <button type="submit" class="btn btn-success btn-sm"
                                            onclick="return confirm('Chốt công phòng ${dept.name} tháng ${selectedMonth}/${selectedYear}?')">
                                        <i class="fas fa-lock"></i> Chốt công
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </form>
                    </div>
                </c:forEach>
            </div>

        </div>
    </main>
</div>
</body>
</html>
