<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Phân Lịch Làm Việc | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
    <style>
        .grid-container { display: grid; grid-template-columns: 1fr 340px; gap: 24px; align-items: start; }
        @media (max-width: 992px) { .grid-container { grid-template-columns: 1fr; } }
        
        .form-card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--border); box-shadow: var(--shadow-sm); padding: 28px; }
        .form-title { font-size: 16px; font-weight: 700; margin-bottom: 20px; color: var(--text); border-bottom: 1px solid var(--border); padding-bottom: 12px; }
        
        .form-group { margin-bottom: 20px; }
        .form-group label { display:block; font-size:13px; font-weight:600; color:var(--text); margin-bottom:6px; }
        .form-control { width:100%; padding:10px 14px; border:1px solid var(--border); border-radius:9px; font-size:14px; font-family:inherit; transition:all .15s; outline:none; background:#fff; color:var(--text); }
        .form-control:focus { border-color:var(--brand); box-shadow:0 0 0 3px rgba(79,70,229,.12); }
        .form-control::placeholder { color: var(--muted); }
        
        .form-row { display: flex; gap: 16px; }
        .form-row .form-group { flex: 1; }
        
        .btn { display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 10px 20px; font-size: 14px; font-weight: 600; border-radius: 9px; cursor: pointer; border: 1px solid transparent; transition: all .15s; font-family: inherit; text-decoration: none; }
        .btn-brand { background: var(--brand); color: #fff; }
        .btn-brand:hover { background: var(--brand-dark); }
        .btn-secondary { background: #f1f5f9; border-color: var(--border); color: var(--text-2); }
        .btn-secondary:hover { background: #e2e8f0; }

        .preview-card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--border); box-shadow: var(--shadow-sm); padding: 24px; position: sticky; top: 24px; }
        .preview-header { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; }
        .preview-avatar { width: 48px; height: 48px; border-radius: 50%; background: var(--brand-light); color: var(--brand); display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: 700; border: 1px solid rgba(79,70,229,.1); text-transform: uppercase; }
        .preview-name { font-weight: 700; font-size: 15px; color: var(--text); }
        .preview-code { font-size: 12px; color: var(--muted); margin-top: 1px; }

        .info-list { display: flex; flex-direction: column; gap: 12px; }
        .info-item { display: flex; justify-content: space-between; font-size: 13px; border-bottom: 1px dashed var(--border); padding-bottom: 8px; }
        .info-item:last-child { border-bottom: none; padding-bottom: 0; }
        .info-label { color: var(--muted); font-weight: 500; }
        .info-val { color: var(--text); font-weight: 600; text-align: right; }

        .no-preview { text-align: center; padding: 40px 20px; color: var(--muted); border: 2px dashed var(--border); border-radius: var(--radius); background: #fafafb; }
        .no-preview svg { width: 40px; height: 40px; color: var(--muted); opacity: 0.6; margin-bottom: 12px; }
    </style>
</head>
<body>
<div class="main-layout">
    <jsp:include page="/WEB-INF/common/sidebar.jsp" />

    <main class="content-area">
        <div class="page-header">
            <div>
                <h1>Phân Công Lịch Làm Việc</h1>
                <p class="subtitle">Thiết lập ngày và ca làm việc cho nhân viên trong hệ thống</p>
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
                <div class="form-title">Thông tin phân công</div>
                
                <form action="${pageContext.request.contextPath}/schedule/assign" method="POST" id="assignForm">
                    <div class="form-group">
                        <label for="employeeId">Chọn nhân viên *</label>
                        <select name="employeeId" id="employeeId" class="form-control" required onchange="previewEmployee(this.value)">
                            <option value="">-- Chọn nhân viên từ danh sách --</option>
                            <c:forEach var="e" items="${employees}">
                                <option value="${e.employeeId}" ${selectedEmployee.employeeId == e.employeeId ? 'selected' : ''}>
                                    ${e.fullName} (${e.employeeCode})
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="scheduleDate">Ngày làm việc *</label>
                            <input type="date" name="scheduleDate" id="scheduleDate" class="form-control" required value="2026-06-10" />
                        </div>

                        <div class="form-group">
                            <label for="workShiftId">Ca làm việc *</label>
                            <select name="workShiftId" id="workShiftId" class="form-control" required>
                                <option value="">-- Chọn ca làm việc --</option>
                                <c:forEach var="s" items="${workShifts}">
                                    <option value="${s.id}">${s.name} (${s.startTime.toString().substring(0,5)} - ${s.endTime.toString().substring(0,5)})</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="notes">Ghi chú công việc / Hướng dẫn thêm</label>
                        <textarea name="notes" id="notes" class="form-control" rows="4" placeholder="Nhập ghi chú hoặc nhiệm vụ cụ thể cho ca làm việc này (nếu có)..."></textarea>
                    </div>

                    <div style="display: flex; gap: 12px; margin-top: 28px;">
                        <button type="submit" class="btn btn-brand">Xác nhận phân lịch</button>
                        <button type="reset" class="btn btn-secondary">Đặt lại</button>
                    </div>
                </form>
            </div>

            <!-- Preview Sidebar -->
            <div>
                <c:choose>
                    <c:when test="${not empty selectedEmployee}">
                        <div class="preview-card">
                            <div class="form-title" style="margin-bottom:16px; border:none; padding:0;">Hồ sơ nhân sự</div>
                            <div class="preview-header">
                                <div class="preview-avatar">
                                    <c:out value="${selectedEmployee.fullName.substring(0, 2)}" />
                                </div>
                                <div>
                                    <div class="preview-name">${selectedEmployee.fullName}</div>
                                    <div class="preview-code">${selectedEmployee.employeeCode}</div>
                                </div>
                            </div>
                            <div class="info-list">
                                <div class="info-item">
                                    <span class="info-label">Phòng ban:</span>
                                    <span class="info-val">${selectedEmployee.departmentName != null ? selectedEmployee.departmentName : '—'}</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Chức vụ:</span>
                                    <span class="info-val">${selectedEmployee.positionName != null ? selectedEmployee.positionName : '—'}</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Vai trò:</span>
                                    <span class="info-val">${selectedEmployee.roleName != null ? selectedEmployee.roleName : '—'}</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Email công việc:</span>
                                    <span class="info-val" style="font-size:12px; word-break: break-all;">${selectedEmployee.workEmail}</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Số điện thoại:</span>
                                    <span class="info-val">${selectedEmployee.phone != null ? selectedEmployee.phone : '—'}</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Giới tính:</span>
                                    <span class="info-val">${selectedEmployee.gender != null ? selectedEmployee.gender : '—'}</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Trạng thái tài khoản:</span>
                                    <span class="info-val" style="color: ${selectedEmployee.active ? 'var(--green)' : 'var(--red)'};">
                                        ${selectedEmployee.active ? 'Hoạt động' : 'Tạm khóa'}
                                    </span>
                                </div>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="no-preview">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
                            <div>Chưa có thông tin xem trước</div>
                            <p style="font-size: 12px; margin-top: 6px; line-height: 1.4;">Vui lòng chọn nhân viên ở danh sách bên cạnh để xem trước hồ sơ.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</div>

<script>
    function previewEmployee(val) {
        if (val) {
            window.location.href = '${pageContext.request.contextPath}/schedule/assign?employeeId=' + val;
        } else {
            window.location.href = '${pageContext.request.contextPath}/schedule/assign';
        }
    }
</script>
</body>
</html>
