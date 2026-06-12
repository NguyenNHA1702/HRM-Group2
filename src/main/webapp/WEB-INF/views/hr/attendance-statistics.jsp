<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Thống kê chấm công – HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/attendance.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/attendance-statistics.css"/>
</head>
<body>
<div class="main-layout">
    <%@ include file="../../common/sidebar.jsp" %>

    <main class="content-area">
        <div class="page-header statistics-page-header">
            <div>
                <h1>Thống kê chấm công toàn hệ thống</h1>
                <p class="subtitle">
                    Tổng hợp dữ liệu của <c:out value="${statistics.totalEmployees}"/> nhân viên
                    trong tháng <c:out value="${currentMonth}"/>/<c:out value="${currentYear}"/>
                </p>
            </div>

            <div class="header-actions">
                <form method="get"
                      action="${pageContext.request.contextPath}/cham-cong/thong-ke"
                      class="filter-bar">
                    <select name="month" onchange="this.form.submit()">
                        <c:forEach var="m" begin="1" end="12">
                            <option value="${m}" ${m == currentMonth ? 'selected' : ''}>
                                Tháng <c:out value="${m}"/>
                            </option>
                        </c:forEach>
                    </select>
                    <div class="divider"></div>
                    <select name="year" onchange="this.form.submit()">
                        <c:forEach var="y" begin="2024" end="2026">
                            <option value="${y}" ${y == currentYear ? 'selected' : ''}>
                                <c:out value="${y}"/>
                            </option>
                        </c:forEach>
                    </select>
                </form>
                <a class="btn btn-outline attendance-action statistics-back"
                   href="${pageContext.request.contextPath}/cham-cong?month=${currentMonth}&year=${currentYear}">
                    &#8592; Quay lại lịch
                </a>
            </div>
        </div>

        <div class="stats-strip system-stats-strip">
            <div class="stat-card">
                <div>
                    <div class="stat-label">Ngày công</div>
                    <div class="stat-value">
                        <c:out value="${statistics.workDays}"/>
                        <span class="stat-total">/ <c:out value="${statistics.expectedWorkDays}"/></span>
                    </div>
                    <div class="stat-sub">tổng ngày có mặt</div>
                </div>
                <div class="stat-icon present">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <rect x="5" y="4" width="14" height="17" rx="2"></rect>
                        <path d="M9 4V2h6v2"></path>
                        <path d="M8 9h8M8 13h8M8 17h5"></path>
                    </svg>
                </div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Đi muộn</div>
                    <div class="stat-value"><c:out value="${statistics.lateCount}"/></div>
                    <div class="stat-sub">lần trong tháng</div>
                </div>
                <div class="stat-icon late">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <circle cx="12" cy="13" r="8"></circle>
                        <path d="M12 9v5l3 2M9 2h6M12 5V2"></path>
                    </svg>
                </div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Vắng mặt</div>
                    <div class="stat-value"><c:out value="${statistics.absentCount}"/></div>
                    <div class="stat-sub">ngày không lý do</div>
                </div>
                <div class="stat-icon absent">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <circle cx="12" cy="12" r="9"></circle>
                        <path d="M6 6l12 12"></path>
                    </svg>
                </div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Nghỉ phép</div>
                    <div class="stat-value"><c:out value="${statistics.leaveCount}"/></div>
                    <div class="stat-sub">ngày đã ghi nhận</div>
                </div>
                <div class="stat-icon leave">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <rect x="3" y="5" width="18" height="16" rx="2"></rect>
                        <path d="M16 3v4M8 3v4M3 10h18M8 15l2 2 5-5"></path>
                    </svg>
                </div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Tăng ca (OT)</div>
                    <div class="stat-value">
                        <c:out value="${statistics.overtimeHoursFormatted}"/>
                    </div>
                    <div class="stat-sub">tổng giờ tháng này</div>
                </div>
                <div class="stat-icon ot">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path d="M13 2L5 14h7l-1 8 8-12h-7l1-8z"></path>
                    </svg>
                </div>
            </div>
        </div>

        <section class="statistics-table-card">
            <div class="statistics-table-header">
                <div>
                    <h2>Chi tiết theo nhân viên</h2>
                    <p>Dữ liệu được tổng hợp từ bảng chấm công đã import.</p>
                </div>
                <label class="statistics-search">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <circle cx="11" cy="11" r="7"></circle>
                        <path d="M20 20l-4-4"></path>
                    </svg>
                    <input id="statistics-search-input"
                           type="search"
                           placeholder="Tìm mã, tên hoặc phòng ban..."/>
                </label>
            </div>

            <div class="statistics-table-wrap">
                <table class="statistics-table" id="attendance-statistics-table">
                    <thead>
                    <tr>
                        <th>STT</th>
                        <th>Mã nhân viên</th>
                        <th>Họ và tên</th>
                        <th>Phòng ban</th>
                        <th class="number-column">Ngày công</th>
                        <th class="number-column">Đi muộn</th>
                        <th class="number-column">Về sớm</th>
                        <th class="number-column">Vắng mặt</th>
                        <th class="number-column">Nghỉ phép</th>
                        <th class="number-column">Tăng ca</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="employee" items="${statistics.employees}" varStatus="loop">
                        <tr class="statistics-row">
                            <td><c:out value="${loop.index + 1}"/></td>
                            <td>
                                <span class="employee-code">
                                    <c:out value="${employee.employeeCode}"/>
                                </span>
                            </td>
                            <td class="employee-name"><c:out value="${employee.fullName}"/></td>
                            <td><c:out value="${employee.departmentName}"/></td>
                            <td class="number-column work-days">
                                <c:out value="${employee.workDays}"/>
                            </td>
                            <td class="number-column status-late">
                                <c:out value="${employee.lateCount}"/>
                            </td>
                            <td class="number-column status-early">
                                <c:out value="${employee.earlyLeaveCount}"/>
                            </td>
                            <td class="number-column status-absent">
                                <c:out value="${employee.absentCount}"/>
                            </td>
                            <td class="number-column status-leave">
                                <c:out value="${employee.leaveCount}"/>
                            </td>
                            <td class="number-column overtime-value">
                                <c:out value="${employee.overtimeHoursFormatted}"/>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty statistics.employees}">
                        <tr>
                            <td colspan="10" class="statistics-empty">
                                Chưa có nhân viên để thống kê.
                            </td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
            <div id="statistics-no-result" class="statistics-empty" hidden>
                Không tìm thấy nhân viên phù hợp.
            </div>
        </section>
    </main>
</div>

<script src="${pageContext.request.contextPath}/assets/js/attendance-statistics.js?v=20260612-1"></script>
</body>
</html>
