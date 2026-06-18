<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Cập nhật Lịch Làm Việc | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
    <style>
        .grid-container { display: grid; grid-template-columns: 1fr 360px; gap: 24px; align-items: start; }
        @media (max-width: 992px) { .grid-container { grid-template-columns: 1fr; } }

        .form-card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--border); box-shadow: var(--shadow-sm); padding: 28px; }
        .form-title { font-size: 16px; font-weight: 700; margin-bottom: 20px; color: var(--text); border-bottom: 1px solid var(--border); padding-bottom: 12px; }

        .form-group { margin-bottom: 20px; }
        .form-group label { display:block; font-size:13px; font-weight:600; color:var(--text); margin-bottom:6px; }
        .form-control { width:100%; padding:10px 14px; border:1px solid var(--border); border-radius:9px; font-size:14px; font-family:inherit; transition:all .15s; outline:none; background:#fff; color:var(--text); }
        .form-control:focus { border-color:var(--brand); box-shadow:0 0 0 3px rgba(79,70,229,.12); }
        .form-control:disabled { background: #f8fafc; color: var(--muted); cursor: not-allowed; }

        .form-row { display: flex; gap: 16px; }
        .form-row .form-group { flex: 1; }

        .alert-warning-custom { background: var(--orange-light); border: 1px solid rgba(245,158,11,0.24); border-radius: 10px; padding: 16px; margin-bottom: 24px; display: flex; gap: 12px; align-items: flex-start; }
        .alert-warning-custom svg { width: 20px; height: 20px; color: var(--orange); shrink: 0; margin-top: 1px; }
        .alert-warning-custom div h4 { font-size: 14px; font-weight: 700; color: #854d0e; margin-bottom: 4px; }
        .alert-warning-custom div p { font-size: 13px; color: #a16207; line-height: 1.45; }

        .btn { display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 10px 20px; font-size: 14px; font-weight: 600; border-radius: 9px; cursor: pointer; border: 1px solid transparent; transition: all .15s; font-family: inherit; text-decoration: none; }
        .btn-brand { background: var(--brand); color: #fff; }
        .btn-brand:hover { background: var(--brand-dark); }
        .btn-secondary { background: #f1f5f9; border-color: var(--border); color: var(--text-2); }
        .btn-secondary:hover { background: #e2e8f0; }

        .timeline-card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--border); box-shadow: var(--shadow-sm); padding: 24px; }
        .timeline { position: relative; padding-left: 24px; list-style: none; margin-top: 16px; }
        .timeline::before { content: ""; position: absolute; left: 7px; top: 8px; bottom: 8px; width: 2px; background: var(--border); }
        .timeline-item { position: relative; margin-bottom: 24px; }
        .timeline-item:last-child { margin-bottom: 0; }
        .timeline-marker { position: absolute; left: -24px; top: 4px; width: 16px; height: 16px; border-radius: 50%; background: #fff; border: 3px solid var(--brand); }
        .timeline-item.old .timeline-marker { border-color: var(--muted); }
        .timeline-content { padding-left: 6px; }
        .timeline-time { font-size: 11px; color: var(--muted); font-weight: 600; margin-bottom: 4px; text-transform: uppercase; }
        .timeline-title { font-weight: 700; font-size: 13.5px; color: var(--text); }
        .timeline-desc { font-size: 13px; color: var(--text-2); margin-top: 3px; line-height: 1.4; }

        /* Modal styling */
        .modal-overlay { position: fixed; inset: 0; background: rgba(15,23,42,0.4); display: none; align-items: center; justify-content: center; z-index: 1000; padding: 20px; backdrop-filter: blur(4px); }
        .modal-overlay.open { display: flex; }
        .modal { background: #fff; border-radius: 16px; padding: 28px; width: 460px; max-width: 100%; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04); }
        .modal-title { font-size: 18px; font-weight: 700; margin-bottom: 12px; display: flex; align-items: center; gap: 10px; color: var(--text); }
        .modal-desc { font-size: 14px; color: var(--text-2); margin-bottom: 24px; line-height: 1.5; }
        .modal-actions { display: flex; justify-content: flex-end; gap: 10px; }
        .modal-btn { padding: 9px 18px; font-size: 13.5px; font-weight: 600; border-radius: 8px; cursor: pointer; border: 1px solid transparent; }
        .modal-btn-cancel { background: #f1f5f9; border-color: var(--border); color: var(--text-2); }
        .modal-btn-confirm { background: var(--brand); color: #fff; }
        .modal-btn-confirm:hover { background: var(--brand-dark); }
    </style>
</head>
<body>
<div class="main-layout">
    <jsp:include page="/WEB-INF/common/sidebar.jsp" />

    <main class="content-area">
        <div class="page-header">
            <div>
                <h1>Cập Nhật Lịch Làm Việc</h1>
                <p class="subtitle">Chỉnh sửa chi tiết ca làm việc cho nhân viên</p>
            </div>
            <div class="page-header-right">
                <a href="${pageContext.request.contextPath}/schedule/view" class="btn btn-secondary">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
                    Quay lại danh sách
                </a>
            </div>
        </div>

        <div class="grid-container">
            <!-- Form Card -->
            <div class="form-card">
                <div class="alert-warning-custom">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                    <div>
                        <h4>Cảnh báo thay đổi ca làm</h4>
                        <p>Việc cập nhật lịch có thể ảnh hưởng đến kết quả chấm công hiện tại và lịch trực luân phiên của các nhân sự liên quan. Hãy đảm bảo bạn đã thông báo trước cho nhân sự.</p>
                    </div>
                </div>

                <div class="form-title">Chỉnh sửa thông tin phân công</div>

                <form action="${pageContext.request.contextPath}/schedule/update" method="POST" id="updateForm" onsubmit="showConfirmModal(event)">
                    <!-- Hidden inputs to supply ID and employee details -->
                    <input type="hidden" name="id" value="${schedule.id}" />
                    <input type="hidden" name="employeeId" value="${schedule.employeeId}" />

                    <div class="form-row">
                        <div class="form-group">
                            <label>Nhân viên</label>
                            <input type="text" class="form-control" value="${schedule.employeeName} (${schedule.employeeCode})" disabled />
                        </div>
                        <div class="form-group">
                            <label>Phòng ban</label>
                            <input type="text" class="form-control" value="${schedule.departmentName != null ? schedule.departmentName : '—'}" disabled />
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="scheduleDate">Ngày làm việc *</label>
                            <input type="date" name="scheduleDate" id="scheduleDate" class="form-control" required value="${schedule.scheduleDate}" />
                        </div>

                        <div class="form-group">
                            <label for="workShiftId">Ca làm việc *</label>
                            <select name="workShiftId" id="workShiftId" class="form-control" required>
                                <c:forEach var="s" items="${workShifts}">
                                    <option value="${s.id}" ${schedule.workShiftId == s.id ? 'selected' : ''}>
                                        ${s.name} (${s.startTime.toString().substring(0,5)} - ${s.endTime.toString().substring(0,5)})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="notes">Ghi chú công việc</label>
                        <textarea name="notes" id="notes" class="form-control" rows="3" placeholder="Ghi chú nhiệm vụ cho ca này...">${schedule.notes}</textarea>
                    </div>

                    <div class="form-group">
                        <label for="changeReason">Lý do thay đổi ca *</label>
                        <input type="text" name="changeReason" id="changeReason" class="form-control" required placeholder="Ví dụ: Đổi ca trực thay đồng nghiệp, Tăng ca đột xuất..." />
                    </div>

                    <div style="display: flex; gap: 12px; margin-top: 28px;">
                        <button type="submit" class="btn btn-brand">Cập nhật lịch</button>
                        <a href="${pageContext.request.contextPath}/schedule/view" class="btn btn-secondary">Hủy bỏ</a>
                    </div>
                </form>
            </div>

            <!-- Change History Timeline -->
            <div class="timeline-card">
                <div class="form-title" style="margin-bottom: 12px; border: none; padding: 0;">Lịch sử thay đổi</div>
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
                                        <div class="timeline-title">
                                            Thay đổi bởi: <span style="color: var(--brand);">${h.changedBy}</span>
                                        </div>
                                        <div class="timeline-desc">
                                            Lịch ngày: <b><fmt:formatDate value="${h.scheduleDate}" pattern="dd/MM/yyyy" /></b><br>
                                            Chuyển: <b>${h.oldShiftName}</b> &rarr; <b>${h.newShiftName}</b><br>
                                            Lý do: <i>"${h.changeReason}"</i>
                                        </div>
                                    </div>
                                </li>
                            </c:forEach>
                        </ul>
                    </c:when>
                    <c:otherwise>
                        <div style="text-align: center; padding: 24px; color: var(--muted); font-size: 13px;">
                            Chưa ghi nhận lịch sử thay đổi nào cho nhân viên này.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</div>

<!-- Modal Confirmation -->
<div class="modal-overlay" id="confirmModal">
    <div class="modal">
        <div class="modal-title">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--brand)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 16 12 12 8 12"></polyline><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
            Xác nhận cập nhật lịch làm
        </div>
        <div class="modal-desc">
            Hệ thống sẽ lưu lại lý do và ghi nhận lịch sử điều chỉnh lịch này. Bạn có chắc chắn muốn áp dụng thay đổi này không?
        </div>
        <div class="modal-actions">
            <button class="modal-btn modal-btn-cancel" onclick="closeConfirmModal()">Hủy</button>
            <button class="modal-btn modal-btn-confirm" onclick="submitForm()">Lưu thay đổi</button>
        </div>
    </div>
</div>

<script>
    function showConfirmModal(event) {
        event.preventDefault();
        const overlay = document.getElementById('confirmModal');
        overlay.classList.add('open');
    }

    function closeConfirmModal() {
        const overlay = document.getElementById('confirmModal');
        overlay.classList.remove('open');
    }

    function submitForm() {
        document.getElementById('updateForm').submit();
    }

    // Close modal when clicking outside
    window.onclick = function(event) {
        const overlay = document.getElementById('confirmModal');
        if (event.target === overlay) {
            closeConfirmModal();
        }
    }
</script>
</body>
</html>
