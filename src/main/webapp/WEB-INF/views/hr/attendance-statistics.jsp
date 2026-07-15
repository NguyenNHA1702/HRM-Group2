<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Trạng thái khóa chấm công phòng ban – HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/attendance.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/attendance-statistics.css"/>
</head>
<body>
<div class="main-layout">
    <%@ include file="../../common/sidebar.jsp" %>

    <main class="content-area">
        <div class="page-header statistics-page-header" style="margin-bottom:24px;">
            <div>
                <h1>Trạng thái khóa chấm công phòng ban</h1>
                <p class="subtitle">
                    Xem danh sách các phòng ban đã khóa hay chưa khóa chấm công trong tháng <c:out value="${currentMonth}"/>/<c:out value="${currentYear}"/>
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

        <section class="statistics-table-card">
            <div class="statistics-table-header">
                <div>
                    <h2>Chi tiết theo phòng ban</h2>
                    <p>Trạng thái khóa chấm công của từng bộ phận.</p>
                </div>
                <label class="statistics-search">
                    <svg viewBox="0 0 24 24" aria-hidden="true" style="width:16px; height:16px; opacity:0.6; margin-right:6px;">
                        <circle cx="11" cy="11" r="7" stroke="currentColor" stroke-width="2" fill="none"></circle>
                        <line x1="16" y1="16" x2="21" y2="21" stroke="currentColor" stroke-width="2"></line>
                    </svg>
                    <input id="statistics-search-input"
                           type="search"
                           placeholder="Tìm tên phòng ban hoặc trưởng phòng..."/>
                </label>
            </div>

            <div class="statistics-table-wrap">
                <table class="statistics-table" id="attendance-statistics-table">
                    <thead>
                    <tr>
                        <th style="width: 80px;">STT</th>
                        <th>Tên phòng ban</th>
                        <th>Trưởng phòng</th>
                        <th class="number-column" style="text-align: right; width: 220px; padding-right: 24px;">Trạng thái khóa bộ phận</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="dept" items="${departmentLockStatuses}" varStatus="loop">
                        <tr class="statistics-row">
                            <td><c:out value="${loop.index + 1}"/></td>
                            <td class="employee-name">
                                <strong><c:out value="${dept.departmentName}"/></strong>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty dept.managerName}">
                                        <c:out value="${dept.managerName}"/>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color:var(--muted); font-style:italic;">Chưa chỉ định trưởng phòng</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="number-column" style="text-align: right; padding-right: 24px;">
                                <c:choose>
                                    <c:when test="${dept.isLocked}">
                                        <span style="color: #991b1b; background: #fee2e2; padding: 4px 12px; border-radius: 99px; font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px;">
                                            🔒 Đã khóa
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color: #166534; background: #dcfce7; padding: 4px 12px; border-radius: 99px; font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px;">
                                            🔓 Chưa khóa
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty departmentLockStatuses}">
                        <tr>
                            <td colspan="4" class="statistics-empty" style="text-align:center; padding:40px 0; color:var(--muted);">
                                Chưa có phòng ban nào hoạt động.
                            </td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
            <div id="statistics-no-result" class="statistics-empty" style="text-align:center; padding:40px 0; color:var(--muted);" hidden>
                Không tìm thấy phòng ban phù hợp.
            </div>
        </section>
    </main>
</div>

<script>
    document.getElementById('statistics-search-input').addEventListener('input', function(e) {
        const q = e.target.value.toLowerCase().trim();
        const rows = document.querySelectorAll('.statistics-row');
        let hasResult = false;
        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            if (text.includes(q)) {
                row.style.display = '';
                hasResult = true;
            } else {
                row.style.display = 'none';
            }
        });
        document.getElementById('statistics-no-result').hidden = hasResult;
    });
</script>
</body>
</html>
