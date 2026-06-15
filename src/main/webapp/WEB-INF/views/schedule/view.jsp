<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Quản lý Lịch Làm Việc | HRMS</title>
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

        .toolbar { background: var(--white); border-radius: var(--radius); padding: 20px; border: 1px solid var(--border); margin-bottom: 24px; box-shadow: var(--shadow-sm); }
        .filter-form { display: flex; flex-wrap: wrap; gap: 14px; align-items: flex-end; }
        .form-group-filter { display: flex; flex-direction: column; gap: 6px; }
        .form-group-filter label { font-size: 12px; font-weight: 600; color: var(--text-2); }
        .form-control-filter { padding: 9px 14px; border: 1px solid var(--border); border-radius: 8px; font-size: 13.5px; outline: none; background: #fff; min-width: 160px; height: 39px; color: var(--text); }
        .form-control-filter:focus { border-color: var(--brand); box-shadow: 0 0 0 3px rgba(79,70,229,.1); }
        .search-input-wrapper { position: relative; min-width: 220px; }
        .search-input-wrapper input { padding-left: 36px; width: 100%; }
        .search-input-wrapper svg { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); width: 16px; height: 16px; color: var(--muted); }
        
        .btn { display: inline-flex; align-items: center; gap: 8px; padding: 9px 16px; font-size: 13.5px; font-weight: 600; border-radius: 8px; cursor: pointer; border: 1px solid transparent; transition: all .15s; font-family: inherit; height: 39px; text-decoration: none; }
        .btn-brand { background: var(--brand); color: #fff; }
        .btn-brand:hover { background: var(--brand-dark); }
        .btn-secondary { background: #f1f5f9; border-color: var(--border); color: var(--text); }
        .btn-secondary:hover { background: #e2e8f0; }

        .table-card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--border); box-shadow: var(--shadow-sm); overflow: hidden; }
        .schedule-table { width: 100%; border-collapse: collapse; text-align: left; }
        .schedule-table th { padding: 16px 20px; background: #f8fafc; border-bottom: 1px solid var(--border); font-size: 13px; font-weight: 600; color: var(--text-2); }
        .schedule-table td { padding: 16px 20px; border-bottom: 1px solid var(--border); font-size: 13.5px; color: var(--text); vertical-align: middle; }
        .schedule-table tr:last-child td { border-bottom: none; }
        .schedule-table tr:hover td { background: #fafafb; }

        .employee-profile { display: flex; align-items: center; gap: 12px; }
        .emp-avatar { width: 38px; height: 38px; border-radius: 50%; background: var(--brand-light); color: var(--brand); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px; border: 1px solid rgba(79,70,229,.12); text-transform: uppercase; }
        .emp-info .name { font-weight: 600; color: var(--text); }
        .emp-info .code { font-size: 12px; color: var(--muted); margin-top: 1px; }

        .shift-badge { display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 600; text-transform: uppercase; }
        .shift-badge.administrative { background: var(--brand-light); color: var(--brand); }
        .shift-badge.morning { background: var(--blue-light); color: var(--blue); }
        .shift-badge.afternoon { background: var(--purple-light); color: var(--purple); }
        .shift-badge.night { background: var(--orange-light); color: var(--orange); }
        .time-badge { font-family: monospace; background: #f1f5f9; color: var(--text-2); padding: 3px 8px; border-radius: 6px; font-size: 12px; font-weight: 600; }

        .action-btns { display: flex; gap: 6px; }
        .action-btn { width: 32px; height: 32px; border-radius: 6px; border: 1px solid var(--border); background: #fff; display: flex; align-items: center; justify-content: center; color: var(--text-2); cursor: pointer; transition: all .15s; }
        .action-btn:hover { background: #f8fafc; }
        .action-btn.edit:hover { border-color: var(--blue); color: var(--blue); }
        .action-btn.delete:hover { border-color: var(--red); color: var(--red); }
        .action-btn svg { width: 14px; height: 14px; fill: none; stroke: currentColor; stroke-width: 2; }

        .pagination-container { display: flex; justify-content: space-between; align-items: center; padding: 18px 20px; background: #fff; font-size: 13.5px; color: var(--muted); border-top: 1px solid var(--border); }
        .pagination { display: flex; gap: 6px; list-style: none; }
        .page-item a { display: flex; align-items: center; justify-content: center; min-width: 32px; height: 32px; padding: 0 8px; border: 1px solid var(--border); border-radius: 6px; color: var(--text); text-decoration: none; transition: all .15s; font-weight: 500; }
        .page-item.active a { background: var(--brand); color: #fff; border-color: var(--brand); }
        .page-item.disabled a { opacity: 0.5; cursor: not-allowed; background: #f8fafc; pointer-events: none; }
        .page-item a:hover:not(.active) { background: #f1f5f9; border-color: #cbd5e1; }

        .flash { display: flex; align-items: center; gap: 10px; padding: 14px 18px; border-radius: 10px; margin-bottom: 24px; font-size: 13.5px; font-weight: 500; border: 1px solid transparent; }
        .flash.success { background: var(--green-light); color: #166534; border-color: rgba(34,197,94,.2); }
        .flash.error { background: var(--red-light); color: #b91c1c; border-color: rgba(239,68,68,.2); }
        
        .modal-overlay { position: fixed; inset: 0; background: rgba(15,23,42,0.4); display: none; align-items: center; justify-content: center; z-index: 1000; padding: 20px; backdrop-filter: blur(4px); }
        .modal-overlay.open { display: flex; }
        .modal { background: #fff; border-radius: 16px; padding: 28px; width: 440px; max-width: 100%; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04); }
        .modal-title { font-size: 18px; font-weight: 700; margin-bottom: 12px; display: flex; align-items: center; gap: 10px; color: var(--text); }
        .modal-desc { font-size: 14px; color: var(--text-2); margin-bottom: 24px; line-height: 1.5; }
        .modal-actions { display: flex; justify-content: flex-end; gap: 10px; }
        .modal-btn { padding: 9px 18px; font-size: 13.5px; font-weight: 600; border-radius: 8px; cursor: pointer; border: 1px solid transparent; }
        .modal-btn-cancel { background: #f1f5f9; border-color: var(--border); color: var(--text-2); }
        .modal-btn-confirm { background: var(--red); color: #fff; }
        .modal-btn-confirm:hover { background: #dc2626; }
    </style>
</head>
<body>
<div class="main-layout">
    <jsp:include page="/WEB-INF/common/sidebar.jsp" />

    <main class="content-area">
        <div class="page-header">
            <div>
                <h1>Lịch Làm Việc Nhân Viên</h1>
                <p class="subtitle">Xem, quản lý và phân công lịch làm việc cho nhân viên</p>
            </div>
            <div class="page-header-right">
                <a href="${pageContext.request.contextPath}/schedule/assign" class="btn btn-brand">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                    Phân lịch mới
                </a>
            </div>
        </div>

        <%-- Flash Message Alerts --%>
        <c:if test="${not empty sessionScope.flash_success}">
            <div class="flash success">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                <span>${sessionScope.flash_success}</span>
            </div>
            <c:remove var="flash_success" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.flash_error}">
            <div class="flash error">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                <span>${sessionScope.flash_error}</span>
            </div>
            <c:remove var="flash_error" scope="session" />
        </c:if>

        <!-- Stats Grid -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-info">
                    <h3>${statTotalEmployees}</h3>
                    <p>Tổng số nhân sự</p>
                </div>
                <div class="stat-icon primary">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <h3>${statAssignedShifts}</h3>
                    <p>Lịch đã phân công</p>
                </div>
                <div class="stat-icon success">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <h3>${statPendingRequests}</h3>
                    <p>Đơn nghỉ chờ duyệt</p>
                </div>
                <div class="stat-icon warning">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <h3>${statOvertimeHours}h</h3>
                    <p>Số giờ làm thêm dự kiến</p>
                </div>
                <div class="stat-icon purple">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                </div>
            </div>
        </div>

        <!-- Filters Form Toolbar -->
        <div class="toolbar">
            <form action="${pageContext.request.contextPath}/schedule/view" method="GET" class="filter-form">
                <div class="form-group-filter search-box search-input-wrapper">
                    <label for="keyword">Tìm kiếm</label>
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><circle cx="11" cy="11" r="8" stroke-width="2"></circle><line x1="21" y1="21" x2="16.65" y2="16.65" stroke-width="2"></line></svg>
                    <input type="text" id="keyword" name="keyword" class="form-control-filter" placeholder="Mã NV, Tên nhân viên..." value="${keyword}" />
                </div>
                
                <div class="form-group-filter">
                    <label for="departmentId">Phòng ban</label>
                    <select name="departmentId" id="departmentId" class="form-control-filter">
                        <option value="">Tất cả phòng ban</option>
                        <c:forEach var="d" items="${departments}">
                            <option value="${d.id}" ${departmentId eq d.id ? 'selected' : ''}>${d.name}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group-filter">
                    <label for="workShiftId">Ca làm việc</label>
                    <select name="workShiftId" id="workShiftId" class="form-control-filter">
                        <option value="">Tất cả ca làm</option>
                        <c:forEach var="s" items="${workShifts}">
                            <option value="${s.id}" ${workShiftId eq s.id ? 'selected' : ''}>${s.name}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group-filter">
                    <label for="startDate">Từ ngày</label>
                    <input type="date" name="startDate" id="startDate" class="form-control-filter" value="${startDate}" />
                </div>

                <div class="form-group-filter">
                    <label for="endDate">Đến ngày</label>
                    <input type="date" name="endDate" id="endDate" class="form-control-filter" value="${endDate}" />
                </div>

                <div class="filter-btn-group" style="display:flex; gap:8px;">
                    <button type="submit" class="btn btn-brand">Tìm kiếm</button>
                    <a href="${pageContext.request.contextPath}/schedule/view" class="btn btn-secondary">Đặt lại</a>
                </div>
            </form>
        </div>

        <!-- Schedules Table Card -->
        <div class="table-card">
            <table class="schedule-table">
                <thead>
                    <tr>
                        <th>Nhân viên</th>
                        <th>Phòng ban</th>
                        <th>Ca làm việc</th>
                        <th>Thời gian</th>
                        <th>Ngày làm việc</th>
                        <th>Ghi chú</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty schedules}">
                            <c:forEach var="s" items="${schedules}">
                                <tr>
                                    <td>
                                        <div class="employee-profile">
                                            <div class="emp-avatar">
                                                <c:out value="${s.employeeName.substring(0, 2)}" />
                                            </div>
                                            <div class="emp-info">
                                                <div class="name">${s.employeeName}</div>
                                                <div class="code">${s.employeeCode}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span style="font-weight: 500;">${s.departmentName != null ? s.departmentName : '—'}</span>
                                    </td>
                                    <td>
                                        <c:set var="badgeClass" value="administrative" />
                                        <c:if test="${s.workShiftId == 2}"><c:set var="badgeClass" value="morning" /></c:if>
                                        <c:if test="${s.workShiftId == 3}"><c:set var="badgeClass" value="afternoon" /></c:if>
                                        <c:if test="${s.workShiftId == 4}"><c:set var="badgeClass" value="night" /></c:if>
                                        
                                        <span class="shift-badge ${badgeClass}">${s.workShiftName}</span>
                                    </td>
                                    <td>
                                        <span class="time-badge">${s.formattedStartTime} - ${s.formattedEndTime}</span>
                                    </td>
                                    <td>
                                        <span style="font-weight: 600; color: var(--text-2);">
                                            <fmt:formatDate value="${s.scheduleDate}" pattern="dd/MM/yyyy" />
                                        </span>
                                    </td>
                                    <td style="color: var(--muted); font-size: 13px; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                        ${not empty s.notes ? s.notes : '—'}
                                    </td>
                                    <td>
                                        <div class="action-btns">
                                            <a href="${pageContext.request.contextPath}/schedule/update?id=${s.id}" class="action-btn edit" title="Chỉnh sửa">
                                                <svg xmlns="http://www.w3.org/2000/svg"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                            </a>
                                            <button class="action-btn delete" onclick="confirmDelete(${s.id})" title="Xóa lịch làm">
                                                <svg xmlns="http://www.w3.org/2000/svg"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 40px; color: var(--muted);">
                                    Không tìm thấy dữ liệu phân công lịch làm việc phù hợp.
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>

            <!-- Pagination Container -->
            <c:if var="hasRecords" test="${totalRecords > 0}">
                <div class="pagination-container">
                    <div>
                        Hiển thị từ <b>${(page - 1) * pageSize + 1}</b> đến <b>${page * pageSize > totalRecords ? totalRecords : page * pageSize}</b> trong tổng số <b>${totalRecords}</b> kết quả
                    </div>
                    <ul class="pagination">
                        <!-- Prev page button -->
                        <li class="page-item ${page == 1 ? 'disabled' : ''}">
                            <a href="${pageContext.request.contextPath}/schedule/view?keyword=${keyword}&departmentId=${departmentId}&workShiftId=${workShiftId}&startDate=${startDate}&endDate=${endDate}&page=${page - 1}&pageSize=${pageSize}">
                                &lsaquo;
                            </a>
                        </li>
                        
                        <!-- Page numbers -->
                        <c:forEach var="p" begin="1" end="${totalPages}">
                            <li class="page-item ${page == p ? 'active' : ''}">
                                <a href="${pageContext.request.contextPath}/schedule/view?keyword=${keyword}&departmentId=${departmentId}&workShiftId=${workShiftId}&startDate=${startDate}&endDate=${endDate}&page=${p}&pageSize=${pageSize}">
                                    ${p}
                                </a>
                            </li>
                        </c:forEach>

                        <!-- Next page button -->
                        <li class="page-item ${page == totalPages ? 'disabled' : ''}">
                            <a href="${pageContext.request.contextPath}/schedule/view?keyword=${keyword}&departmentId=${departmentId}&workShiftId=${workShiftId}&startDate=${startDate}&endDate=${endDate}&page=${page + 1}&pageSize=${pageSize}">
                                &rsaquo;
                            </a>
                        </li>
                    </ul>
                </div>
            </c:if>
        </div>
    </main>
</div>

<!-- Modal confirm delete schedule -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal">
        <div class="modal-title">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--red)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
            Xác nhận xóa lịch làm
        </div>
        <div class="modal-desc">
            Bạn có chắc chắn muốn xóa phân công lịch làm việc này không? Dữ liệu chấm công liên quan có thể bị ảnh hưởng. Hành động này không thể hoàn tác.
        </div>
        <div class="modal-actions">
            <button class="modal-btn modal-btn-cancel" onclick="closeDeleteModal()">Hủy bỏ</button>
            <form id="deleteForm" method="POST" style="margin: 0;">
                <button type="submit" class="modal-btn modal-btn-confirm">Xác nhận xóa</button>
            </form>
        </div>
    </div>
</div>

<script>
    function confirmDelete(id) {
        const overlay = document.getElementById('deleteModal');
        const form = document.getElementById('deleteForm');
        form.action = '${pageContext.request.contextPath}/schedule/delete?id=' + id;
        overlay.classList.add('open');
    }

    function closeDeleteModal() {
        const overlay = document.getElementById('deleteModal');
        overlay.classList.remove('open');
    }

    // Close modal when clicking outside
    window.onclick = function(event) {
        const overlay = document.getElementById('deleteModal');
        if (event.target === overlay) {
            closeDeleteModal();
        }
    }
</script>
</body>
</html>
