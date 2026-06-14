<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Lịch Làm Việc Của Tôi | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
    <style>
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 28px; }
        .stat-card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--border); padding: 20px; display: flex; align-items: center; justify-content: space-between; box-shadow: var(--shadow-sm); }
        .stat-info h3 { font-size: 24px; font-weight: 700; color: var(--text); margin-bottom: 4px; }
        .stat-info p { font-size: 13px; color: var(--muted); font-weight: 500; }
        .stat-icon { width: 46px; height: 46px; border-radius: 10px; display: flex; align-items: center; justify-content: center; }
        .stat-icon.primary { background: var(--brand-light); color: var(--brand); }
        .stat-icon.success { background: var(--green-light); color: var(--green); }
        .stat-icon.warning { background: var(--orange-light); color: var(--orange); }
        .stat-icon.purple { background: var(--purple-light); color: var(--purple); }
        .stat-icon svg { width: 22px; height: 22px; stroke: currentColor; fill: none; stroke-width: 2; }

        .calendar-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; background: var(--white); border: 1px solid var(--border); border-radius: var(--radius); padding: 16px 20px; box-shadow: var(--shadow-sm); }
        .month-selector { display: flex; align-items: center; gap: 12px; }
        .month-input { padding: 8px 12px; border: 1px solid var(--border); border-radius: 8px; font-size: 14px; font-weight: 600; outline: none; color: var(--text); }
        .month-input:focus { border-color: var(--brand); }

        .schedule-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 16px; margin-bottom: 32px; }
        .schedule-day-card { background: var(--white); border: 1px solid var(--border); border-radius: var(--radius); padding: 18px; box-shadow: var(--shadow-sm); transition: transform 0.2s, border-color 0.2s; cursor: pointer; position: relative; overflow: hidden; }
        .schedule-day-card:hover { transform: translateY(-3px); border-color: var(--brand); }
        .schedule-day-card::before { content: ""; position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: var(--muted); }
        .schedule-day-card.has-shift::before { background: var(--brand); }
        .schedule-day-card.morning::before { background: var(--blue); }
        .schedule-day-card.afternoon::before { background: var(--purple); }
        .schedule-day-card.night::before { background: var(--orange); }

        .card-date { font-weight: 700; font-size: 15px; color: var(--text); display: flex; align-items: center; justify-content: space-between; }
        .card-day-name { font-size: 11px; text-transform: uppercase; color: var(--muted); letter-spacing: 0.5px; margin-top: 2px; }
        .card-shift { font-weight: 600; font-size: 13.5px; margin-top: 14px; display: flex; align-items: center; gap: 8px; }
        .card-shift-time { font-family: monospace; font-size: 12.5px; color: var(--text-2); margin-top: 4px; display: block; }
        .card-notes { font-size: 12px; color: var(--muted); margin-top: 10px; border-top: 1px solid #f1f5f9; padding-top: 8px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        /* History side-by-side or listing */
        .history-card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--border); padding: 24px; box-shadow: var(--shadow-sm); }
        .history-title { font-size: 16px; font-weight: 700; margin-bottom: 20px; color: var(--text); border-bottom: 1px solid var(--border); padding-bottom: 12px; }

        .timeline { position: relative; padding-left: 24px; list-style: none; }
        .timeline::before { content: ""; position: absolute; left: 7px; top: 8px; bottom: 8px; width: 2px; background: var(--border); }
        .timeline-item { position: relative; margin-bottom: 20px; }
        .timeline-item:last-child { margin-bottom: 0; }
        .timeline-marker { position: absolute; left: -24px; top: 4px; width: 16px; height: 16px; border-radius: 50%; background: #fff; border: 3px solid var(--brand); }
        .timeline-content { padding-left: 6px; }
        .timeline-time { font-size: 11px; color: var(--muted); font-weight: 600; margin-bottom: 4px; }
        .timeline-desc { font-size: 13px; color: var(--text-2); line-height: 1.4; }

        /* Detail Modal styling */
        .modal-overlay { position: fixed; inset: 0; background: rgba(15,23,42,0.4); display: none; align-items: center; justify-content: center; z-index: 1000; padding: 20px; backdrop-filter: blur(4px); }
        .modal-overlay.open { display: flex; }
        .modal { background: #fff; border-radius: 16px; padding: 28px; width: 440px; max-width: 100%; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04); }
        .modal-title { font-size: 18px; font-weight: 700; margin-bottom: 16px; display: flex; align-items: center; gap: 10px; color: var(--text); }
        .modal-body-list { display: flex; flex-direction: column; gap: 14px; margin-bottom: 24px; }
        .modal-row { display: flex; justify-content: space-between; font-size: 13.5px; border-bottom: 1px dashed var(--border); padding-bottom: 8px; }
        .modal-row:last-child { border-bottom: none; }
        .modal-label { color: var(--muted); font-weight: 500; }
        .modal-val { color: var(--text); font-weight: 600; text-align: right; }
        .modal-btn-close { padding: 9px 18px; font-size: 13.5px; font-weight: 600; border-radius: 8px; cursor: pointer; border: 1px solid var(--border); background: #f1f5f9; color: var(--text-2); display: block; width: 100%; text-align: center; }
    </style>
</head>
<body>
<div class="main-layout">
    <jsp:include page="/WEB-INF/common/sidebar.jsp" />

    <main class="content-area">
        <div class="page-header">
            <div>
                <h1>Lịch Làm Việc Của Tôi</h1>
                <p class="subtitle">Theo dõi lịch trình phân công, ca làm và số ngày công trong tháng</p>
            </div>
        </div>

        <!-- Personal Stats Grid -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-info">
                    <h3>${totalWorkingDays} ngày</h3>
                    <p>Tổng số ca phân công</p>
                </div>
                <div class="stat-icon primary">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <h3>${overtimeHours}h</h3>
                    <p>Làm thêm giờ tháng này</p>
                </div>
                <div class="stat-icon purple">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <h3>${attendanceRate}%</h3>
                    <p>Tỷ lệ đi làm chuẩn chỉ</p>
                </div>
                <div class="stat-icon success">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                </div>
            </div>
        </div>

        <!-- Month Selector Header -->
        <div class="calendar-header">
            <div style="font-weight: 700; font-size: 15px; color: var(--text);">
                Lịch làm việc chi tiết
            </div>
            <div class="month-selector">
                <label for="yearMonthSelect" style="font-size: 12px; font-weight: 600; color: var(--text-2);">Chọn tháng:</label>
                <input type="month" id="yearMonthSelect" class="month-input" value="${yearMonth}" onchange="changeMonth(this.value)" />
            </div>
        </div>

        <!-- Schedule Cards Grid -->
        <div class="schedule-grid">
            <c:choose>
                <c:when test="${not empty mySchedules}">
                    <c:forEach var="s" items="${mySchedules}">
                        <!-- Determine class based on workShiftId -->
                        <c:set var="shiftClass" value="has-shift" />
                        <c:if test="${s.workShiftId == 2}"><c:set var="shiftClass" value="morning" /></c:if>
                        <c:if test="${s.workShiftId == 3}"><c:set var="shiftClass" value="afternoon" /></c:if>
                        <c:if test="${s.workShiftId == 4}"><c:set var="shiftClass" value="night" /></c:if>

                        <div class="schedule-day-card ${shiftClass}" onclick="showDetailModal('${s.workShiftName}', '${s.formattedStartTime} - ${s.formattedEndTime}', '<fmt:formatDate value="${s.scheduleDate}" pattern="dd/MM/yyyy" />', '${s.notes}')">
                            <div class="card-date">
                                <span><fmt:formatDate value="${s.scheduleDate}" pattern="dd 'Tháng' MM" /></span>
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--muted)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
                            </div>
                            <div class="card-day-name">Lịch phân công</div>
                            <div class="card-shift">
                                <span style="color: var(--text);">${s.workShiftName}</span>
                            </div>
                            <span class="card-shift-time">${s.formattedStartTime} - ${s.formattedEndTime}</span>
                            <div class="card-notes">
                                ${not empty s.notes ? s.notes : 'Không có ghi chú.'}
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px; background: var(--white); border-radius: var(--radius); border: 1px solid var(--border); color: var(--muted);">
                        <svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-bottom: 12px; opacity: 0.5;"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        <div>Không có lịch làm việc được phân công trong tháng này.</div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Timeline of updates for employee transparency -->
        <div class="history-card">
            <div class="history-title">Nhật ký điều chỉnh ca trực gần đây</div>
            <c:choose>
                <c:when test="${not empty history}">
                    <ul class="timeline">
                        <c:forEach var="h" items="${history}">
                            <li class="timeline-item">
                                <span class="timeline-marker"></span>
                                <div class="timeline-content">
                                    <div class="timeline-time">
                                        <fmt:formatDate value="${h.changedAt}" pattern="dd/MM/yyyy HH:mm" />
                                    </div>
                                    <div class="timeline-desc">
                                        Ca ngày <b><fmt:formatDate value="${h.scheduleDate}" pattern="dd/MM/yyyy" /></b> đã được điều chỉnh từ <b>${h.oldShiftName}</b> thành <b>${h.newShiftName}</b> bởi Quản lý/Nhân sự. <br/>
                                        <i>Lý do điều chỉnh: "${h.changeReason}"</i>
                                    </div>
                                </div>
                            </li>
                        </c:forEach>
                    </ul>
                </c:when>
                <c:otherwise>
                    <div style="text-align: center; padding: 20px; color: var(--muted); font-size: 13px;">
                        Không có điều chỉnh lịch làm việc nào được ghi nhận gần đây.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

<!-- Details Modal -->
<div class="modal-overlay" id="detailModal">
    <div class="modal">
        <div class="modal-title">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--brand)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
            Chi tiết ca làm việc
        </div>
        <div class="modal-body-list">
            <div class="modal-row">
                <span class="modal-label">Ngày làm việc:</span>
                <span class="modal-val" id="modalDate"></span>
            </div>
            <div class="modal-row">
                <span class="modal-label">Ca làm việc:</span>
                <span class="modal-val" id="modalShiftName"></span>
            </div>
            <div class="modal-row">
                <span class="modal-label">Thời gian:</span>
                <span class="modal-val" id="modalTime"></span>
            </div>
            <div class="modal-row">
                <span class="modal-label">Ghi chú / Nhiệm vụ:</span>
                <span class="modal-val" id="modalNotes" style="font-weight: normal; color: var(--text-2); max-width: 240px;"></span>
            </div>
        </div>
        <button class="modal-btn-close" onclick="closeDetailModal()">Đóng lại</button>
    </div>
</div>

<script>
    function changeMonth(val) {
        window.location.href = '${pageContext.request.contextPath}/schedule/employee?yearMonth=' + val;
    }

    function showDetailModal(name, time, date, notes) {
        document.getElementById('modalDate').textContent = date;
        document.getElementById('modalShiftName').textContent = name;
        document.getElementById('modalTime').textContent = time;
        document.getElementById('modalNotes').textContent = notes || 'Không có ghi chú thêm.';
        
        const overlay = document.getElementById('detailModal');
        overlay.classList.add('open');
    }

    function closeDetailModal() {
        const overlay = document.getElementById('detailModal');
        overlay.classList.remove('open');
    }

    // Close modal when clicking outside
    window.onclick = function(event) {
        const overlay = document.getElementById('detailModal');
        if (event.target === overlay) {
            closeDetailModal();
        }
    }
</script>
</body>
</html>
