<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Chấm Công – HRMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/attendance.css"/>
</head>
<body>
<div class="main-layout">
    <%@ include file="../../common/sidebar.jsp" %>

    <main class="content-area">

        <!-- ══ Page header ══ -->
        <div class="page-header">
            <div>
                <h1>Chấm Công</h1>
                <p class="subtitle">Theo dõi giờ giấc và ngày công trong tháng</p>
            </div>

            <div class="header-actions">
                <c:if test="${canViewSystemStatistics}">
                    <a class="btn btn-primary attendance-action"
                       href="${pageContext.request.contextPath}/cham-cong/thong-ke?month=${currentMonth}&year=${currentYear}">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <rect x="3" y="3" width="7" height="7"></rect>
                            <rect x="14" y="3" width="7" height="7"></rect>
                            <rect x="3" y="14" width="7" height="7"></rect>
                            <rect x="14" y="14" width="7" height="7"></rect>
                        </svg>
                        Thống kê hệ thống
                    </a>
                </c:if>
                <form method="get" action="${pageContext.request.contextPath}/cham-cong" class="filter-bar">
                    <select name="month" onchange="this.form.submit()">
                        <c:forEach var="m" begin="1" end="12">
                            <option value="${m}" ${m == currentMonth ? 'selected' : ''}>Tháng <c:out value="${m}"/></option>
                        </c:forEach>
                    </select>
                    <div class="divider"></div>
                    <select name="year" onchange="this.form.submit()">
                        <c:forEach var="y" begin="2024" end="2026">
                            <option value="${y}" ${y == currentYear ? 'selected' : ''}><c:out value="${y}"/></option>
                        </c:forEach>
                    </select>
                </form>

                <c:if test="${canImportAttendance}">
                    <form id="import-form"
                          method="post"
                          action="${pageContext.request.contextPath}/cham-cong"
                          enctype="multipart/form-data">
                        <input type="hidden" name="action" value="stageImport"/>
                        <input type="hidden" name="month" value="${currentMonth}"/>
                        <input type="hidden" name="year" value="${currentYear}"/>
                        <input id="attendance-file"
                               class="file-input"
                               type="file"
                               name="attendanceFile"
                               accept=".xlsx"
                               hidden
                               onchange="if (this.files.length > 0) { this.form.submit(); }"/>
                        <button type="button"
                                class="btn btn-outline attendance-action"
                                title="Cột hỗ trợ: ID nhân viên, Mã nhân viên, Ngày chấm công, Giờ vào, Giờ ra, Trạng thái, Ghi chú"
                                onclick="document.getElementById('attendance-file').click()">
                            &#8593; Nhập Excel
                        </button>
                    </form>
                    <c:if test="${not empty sessionScope.pendingAttendanceFileName}">
                        <form method="post" action="${pageContext.request.contextPath}/cham-cong">
                            <input type="hidden" name="action" value="commitImport"/>
                            <input type="hidden" name="month" value="${currentMonth}"/>
                            <input type="hidden" name="year" value="${currentYear}"/>
                            <button type="submit" class="btn btn-success attendance-action">
                                Insert dữ liệu
                            </button>
                        </form>
                    </c:if>
                </c:if>
            </div>
        </div>

        <c:if test="${canImportAttendance}">
            <div class="import-format-hint">
                File .xlsx bắt buộc có <strong>ID nhân viên hoặc Mã nhân viên</strong> và
                <strong>Ngày chấm công</strong>; hỗ trợ thêm Giờ vào, Giờ ra, Trạng thái, Ghi chú.
                Trạng thái dùng: Đủ công, Đi muộn, Về sớm, Vắng mặt, Ngày nghỉ, Nghỉ lễ,
                Nghỉ phép hoặc Tăng ca.
                <c:if test="${not empty sessionScope.pendingAttendanceFileName}">
                    <span class="pending-file">
                        File đang chờ insert:
                        <strong><c:out value="${sessionScope.pendingAttendanceFileName}"/></strong>
                    </span>
                </c:if>
            </div>
        </c:if>

        <c:if test="${not empty sessionScope.flash_success}">
            <div class="flash success"><c:out value="${sessionScope.flash_success}"/></div>
            <c:remove var="flash_success" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.flash_error}">
            <div class="flash error"><c:out value="${sessionScope.flash_error}"/></div>
            <c:remove var="flash_error" scope="session"/>
        </c:if>

        <!-- ══ Stats strip ══ -->
        <div class="stats-strip" id="stats-strip"></div>

        <!-- ══ Calendar card ══ -->
        <div class="calendar-container">

            <div class="calendar-header">
                <div class="cal-nav">
                    <button class="btn-icon" onclick="prevMonth()" title="Tháng trước">&#8249;</button>
                    <button class="btn-icon" onclick="nextMonth()" title="Tháng sau">&#8250;</button>
                </div>
                <h2 class="calendar-title" id="calendar-title">Tháng ${currentMonth} / ${currentYear}</h2>
                <div style="width:76px"></div>
            </div>

            <!-- Filter chips -->
            <div class="filter-chips" id="filter-chips"></div>

            <!-- Calendar grid -->
            <div class="calendar-grid" id="calendar-grid"></div>

            <!-- Legend -->
            <div class="calendar-legend">
                <div class="legend-item"><div class="legend-dot present"></div> Đủ công</div>
                <div class="legend-item"><div class="legend-dot late"></div> Đi muộn / Về sớm</div>
                <div class="legend-item"><div class="legend-dot absent"></div> Vắng mặt</div>
                <div class="legend-item"><div class="legend-dot leave"></div> Nghỉ phép</div>
                <div class="legend-item"><div class="legend-dot weekend"></div> Ngày nghỉ / Lễ</div>
            </div>
        </div>

    </main>
</div>

<!-- ══ Modal ══ -->
<div id="editModal" class="modal" role="dialog" aria-modal="true" aria-labelledby="modal-heading">
    <div class="modal-content">

        <div class="modal-header">
            <div>
                <h3 id="modal-heading">Chi tiết chấm công</h3>
                <div class="modal-date-sub" id="modal-date">—</div>
            </div>
            <button class="modal-close" onclick="closeModal()" aria-label="Đóng">&times;</button>
        </div>

        <div class="modal-body">
            <div id="quick-action-bar" style="display:none"></div>

            <div class="current-values">
                <div class="cv-item">
                    <div class="cv-label">Giờ vào ghi nhận</div>
                    <div class="cv-val" id="cv-checkin">—</div>
                </div>
                <div class="cv-item">
                    <div class="cv-label">Giờ ra ghi nhận</div>
                    <div class="cv-val" id="cv-checkout">—</div>
                </div>
            </div>

            <form id="explanation-form"
                  class="explanation-form"
                  method="post"
                  action="${pageContext.request.contextPath}/cham-cong">
                <input type="hidden" name="action" value="submitExplanation"/>
                <input type="hidden" name="month" value="${currentMonth}"/>
                <input type="hidden" name="year" value="${currentYear}"/>
                <input type="hidden" name="date" id="explanation-date"/>
                <div class="form-group">
                    <label for="explanation-reason">Nội dung giải trình</label>
                    <textarea id="explanation-reason"
                              name="reason"
                              maxlength="1000"
                              required
                              placeholder="Nhập lý do thiếu hoặc sai dữ liệu chấm công..."></textarea>
                </div>
                <button type="submit" class="btn-primary">Gửi giải trình</button>
            </form>

        </div>

        <div class="modal-footer">
            <button type="button" class="btn-secondary" onclick="closeModal()">Đóng</button>
        </div>

    </div>
</div>

<!-- ══ Scripts: external FIRST, then inline data ══ -->
<script src="${pageContext.request.contextPath}/assets/js/attendance.js?v=20260611-5"></script>
<script>
    /*
     * attendance.js đã đăng ký DOMContentLoaded listener.
     * initCalendar() lưu data vào window._attendanceBootData;
     * listener đó sẽ gọi _boot() sau khi DOM ready.
     * Nếu DOM đã ready (script defer), _boot() chạy ngay lập tức.
     *
     * LƯU Ý: KHÔNG khai báo lại biến attendanceData ở đây vì attendance.js
     * đã dùng `let attendanceData` ở module scope – sẽ gây SyntaxError.
     * Truyền mảng literal trực tiếp vào initCalendar().
     */
    initCalendar(${currentMonth}, ${currentYear}, ${attendanceJson});
</script>
</body>
</html>
