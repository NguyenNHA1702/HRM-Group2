<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhân Viên Phòng Ban | HRMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css" />
    <style>
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 16px;
        }
        .page-title-group .page-title {
            font-size: 22px;
            font-weight: 700;
            color: #0f172a;
            margin: 0;
        }
        .page-title-group .page-subtitle {
            font-size: 13px;
            color: #64748b;
            margin-top: 4px;
        }
        
        .summary-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-bottom: 24px;
        }
        .card {
            background: #ffffff;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: 1px solid #f1f5f9;
            position: relative;
            overflow: hidden;
        }
        .card::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
        }
        .card-total::before { background: #4f46e5; }
        .card-active::before { background: #10b981; }
        .card-inactive::before { background: #f59e0b; }
        
        .card-title {
            font-size: 12px;
            color: #64748b;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }
        .card-value {
            font-size: 28px;
            font-weight: 700;
            color: #0f172a;
        }
        .card-icon {
            position: absolute;
            right: 20px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 40px;
            opacity: 0.1;
        }
        .card-total .card-icon { color: #4f46e5; }
        .card-active .card-icon { color: #10b981; }
        .card-inactive .card-icon { color: #f59e0b; }

        .filter-bar {
            background: #f8fafc;
            padding: 16px;
            border-radius: 12px;
            margin-bottom: 24px;
            border: 1px solid #e2e8f0;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            align-items: center;
        }
        .filter-group {
            display: flex;
            align-items: center;
            gap: 8px;
            flex: 1;
            min-width: 200px;
        }
        .search-input {
            width: 100%;
            padding: 9px 14px 9px 36px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            background: #ffffff;
            font-size: 14px;
            color: #334155;
            outline: none;
            transition: all 0.2s;
        }
        .search-wrapper {
            position: relative;
            flex: 2;
            min-width: 250px;
        }
        .search-wrapper i {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
        }
        .search-input:focus, .filter-select:focus {
            border-color: #4f46e5;
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }
        .filter-select {
            padding: 9px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            background: #ffffff;
            font-size: 14px;
            color: #334155;
            outline: none;
            min-width: 160px;
        }
        .btn-filter {
            padding: 9px 18px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: none;
            font-size: 14px;
            background: #4f46e5;
            color: #ffffff;
            transition: all 0.2s;
        }
        .btn-filter:hover {
            background: #4338ca;
        }
        .btn-reset {
            padding: 9px 16px;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border: 1px solid #cbd5e1;
            font-size: 14px;
            background: #ffffff;
            color: #64748b;
            transition: all 0.2s;
        }
        .btn-reset:hover {
            background: #f1f5f9;
            color: #334155;
        }

        .table-container {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 1px 3px 0 rgba(0,0,0,0.1), 0 1px 2px 0 rgba(0,0,0,0.06);
            overflow: hidden;
            border: 1px solid #e2e8f0;
        }
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }
        .data-table th {
            background: #f8fafc;
            padding: 14px 16px;
            text-align: left;
            font-size: 12px;
            font-weight: 600;
            color: #475569;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid #e2e8f0;
        }
        .data-table td {
            padding: 14px 16px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 14px;
            color: #334155;
            vertical-align: middle;
        }
        .data-table tr:hover {
            background: #f8fafc;
        }
        
        .employee-info-cell {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .avatar-circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #6366f1;
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 15px;
            flex-shrink: 0;
        }
        .emp-name-box {
            display: flex;
            flex-direction: column;
        }
        .emp-full-name {
            font-weight: 600;
            color: #0f172a;
        }
        .emp-email {
            font-size: 12px;
            color: #64748b;
        }

        .code-badge {
            font-family: monospace;
            font-size: 13px;
            font-weight: 600;
            padding: 3px 8px;
            background: #f1f5f9;
            color: #475569;
            border-radius: 6px;
            border: 1px solid #e2e8f0;
        }

        .status-badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .status-badge.active {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }
        .status-badge.inactive {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .btn-view-detail {
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 500;
            background: #f1f5f9;
            color: #4f46e5;
            border: 1px solid #e2e8f0;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .btn-view-detail:hover {
            background: #4f46e5;
            color: #ffffff;
            border-color: #4f46e5;
        }

        .pagination {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 20px;
            background: #ffffff;
            border-top: 1px solid #e2e8f0;
        }
        .pagination-info {
            font-size: 13px;
            color: #64748b;
        }
        .pagination-pages {
            display: flex;
            gap: 6px;
        }
        .page-link {
            padding: 6px 12px;
            border-radius: 6px;
            border: 1px solid #cbd5e1;
            font-size: 13px;
            color: #334155;
            text-decoration: none;
            transition: all 0.15s;
        }
        .page-link:hover {
            background: #f1f5f9;
        }
        .page-link.active {
            background: #4f46e5;
            color: #ffffff;
            border-color: #4f46e5;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #64748b;
        }
        .empty-state i {
            font-size: 48px;
            color: #cbd5e1;
            margin-bottom: 16px;
        }
        .empty-state h3 {
            font-size: 18px;
            font-weight: 600;
            color: #334155;
            margin: 0 0 8px 0;
        }

        /* Modal styling */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(15, 23, 42, 0.5);
            backdrop-filter: blur(4px);
            z-index: 999;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .modal-container {
            background: #ffffff;
            border-radius: 16px;
            max-width: 600px;
            width: 100%;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            overflow: hidden;
            animation: modalFadeIn 0.25s ease-out;
        }
        @keyframes modalFadeIn {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
        }
        .modal-header {
            padding: 20px 24px;
            background: #f8fafc;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .modal-title {
            font-size: 18px;
            font-weight: 700;
            color: #0f172a;
            margin: 0;
        }
        .modal-close {
            background: none;
            border: none;
            font-size: 20px;
            color: #64748b;
            cursor: pointer;
        }
        .modal-body {
            padding: 24px;
            max-height: 75vh;
            overflow-y: auto;
        }
        .detail-row {
            display: flex;
            padding: 10px 0;
            border-bottom: 1px solid #f1f5f9;
        }
        .detail-label {
            width: 160px;
            font-size: 13px;
            font-weight: 600;
            color: #64748b;
        }
        .detail-value {
            flex: 1;
            font-size: 14px;
            color: #0f172a;
        }
    </style>
</head>
<body>
    <div class="main-layout">
        <%@ include file="/WEB-INF/common/sidebar.jsp" %>
        
        <main class="content-area">

            <div class="page-header">
                <div class="page-title-group">
                    <h1 class="page-title">Nhân Viên Phòng Ban</h1>
                    <div class="page-subtitle">
                        <c:choose>
                            <c:when test="${not empty departmentName}">
                                Quản lý danh sách nhân viên thuộc <strong>${departmentName}</strong>
                            </c:when>
                            <c:otherwise>
                                Quản lý danh sách nhân viên phòng ban
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <c:choose>
                <c:when test="${noDepartment}">
                    <div class="card empty-state">
                        <i class="fa-solid fa-building-circle-exclamation"></i>
                        <h3>Chưa có phòng ban quản lý</h3>
                        <p>Tài khoản của bạn hiện tại chưa được gán làm Quản lý cho phòng ban nào trong hệ thống.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Stat Cards -->
                    <div class="summary-cards">
                        <div class="card card-total">
                            <div class="card-title">Tổng số nhân viên</div>
                            <div class="card-value">${stats.totalUsers}</div>
                            <i class="fa-solid fa-users card-icon"></i>
                        </div>
                        <div class="card card-active">
                            <div class="card-title">Đang làm việc (Active)</div>
                            <div class="card-value">${stats.activeUsers}</div>
                            <i class="fa-solid fa-user-check card-icon"></i>
                        </div>
                        <div class="card card-inactive">
                            <div class="card-title">Tạm dừng / Nghỉ (Inactive)</div>
                            <div class="card-value">${stats.inactiveUsers}</div>
                            <i class="fa-solid fa-user-clock card-icon"></i>
                        </div>
                    </div>

                    <!-- Filter Bar -->
                    <form method="GET" action="${pageContext.request.contextPath}/nhan-vien" class="filter-bar">
                        <div class="search-wrapper">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <input type="text" name="keyword" class="search-input" 
                                   placeholder="Tìm kiếm theo mã, họ tên hoặc email..." 
                                   value="${filterKeyword}" />
                        </div>
                        
                        <select name="positionId" class="filter-select">
                            <option value="">-- Tất cả chức vụ --</option>
                            <c:forEach items="${positions}" var="pos">
                                <option value="${pos.id}" ${filterPositionId eq pos.id ? 'selected' : ''}>
                                    ${pos.name}
                                </option>
                            </c:forEach>
                        </select>

                        <select name="status" class="filter-select">
                            <option value="">-- Tất cả trạng thái --</option>
                            <option value="ACTIVE" ${filterStatus eq 'ACTIVE' ? 'selected' : ''}>Active (Đang làm việc)</option>
                            <option value="INACTIVE" ${filterStatus eq 'INACTIVE' ? 'selected' : ''}>Inactive (Tạm dừng/Nghỉ)</option>
                        </select>

                        <button type="submit" class="btn-filter">
                            <i class="fa-solid fa-filter"></i> Lọc
                        </button>
                        
                        <a href="${pageContext.request.contextPath}/nhan-vien" class="btn-reset">
                            <i class="fa-solid fa-rotate-left"></i> Đặt lại
                        </a>
                    </form>

                    <!-- Table -->
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>STT</th>
                                    <th>Mã NV</th>
                                    <th>Nhân viên</th>
                                    <th>Chức vụ</th>
                                    <th>Số điện thoại</th>
                                    <th>Trạng thái</th>
                                    <th style="text-align: center;">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty employees}">
                                        <tr>
                                            <td colspan="7">
                                                <div class="empty-state">
                                                    <i class="fa-solid fa-users-slash"></i>
                                                    <h3>Không tìm thấy nhân viên nào</h3>
                                                    <p>Không có dữ liệu nhân viên thỏa mãn điều kiện lọc.</p>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach items="${employees}" var="emp" varStatus="loop">
                                            <tr>
                                                <td>${(page - 1) * pageSize + loop.index + 1}</td>
                                                <td>
                                                    <span class="code-badge">${not empty emp.employeeCode ? emp.employeeCode : 'EMP-N/A'}</span>
                                                </td>
                                                <td>
                                                    <div class="employee-info-cell">
                                                        <div class="avatar-circle">
                                                            <c:out value="${emp.fullName.substring(0,1).toUpperCase()}" />
                                                        </div>
                                                        <div class="emp-name-box">
                                                            <span class="emp-full-name"><c:out value="${emp.fullName}" /></span>
                                                            <span class="emp-email"><c:out value="${emp.workEmail}" /></span>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td><c:out value="${not empty emp.positionName ? emp.positionName : 'Chưa phân công'}" /></td>
                                                <td><c:out value="${not empty emp.phone ? emp.phone : 'N/A'}" /></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${emp.status eq 'ACTIVE'}">
                                                            <span class="status-badge active"><i class="fa-solid fa-circle-check"></i> Active</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-badge inactive"><i class="fa-solid fa-circle-xmark"></i> Inactive</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="text-align: center;">
                                                    <button type="button" class="btn-view-detail" 
                                                            onclick="openDetailModal(
                                                                '<c:out value="${emp.employeeCode}" />',
                                                                '<c:out value="${emp.fullName}" />',
                                                                '<c:out value="${emp.workEmail}" />',
                                                                '<c:out value="${emp.personalEmail}" />',
                                                                '<c:out value="${emp.phone}" />',
                                                                '<c:out value="${emp.departmentName}" />',
                                                                '<c:out value="${emp.positionName}" />',
                                                                '<c:out value="${emp.dateOfBirth}" />',
                                                                '<c:out value="${emp.gender}" />',
                                                                '<c:out value="${emp.status}" />'
                                                            )">
                                                        <i class="fa-solid fa-eye"></i> Chi tiết
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>

                        <!-- Pagination -->
                        <c:if test="${totalPages > 1}">
                            <div class="pagination">
                                <div class="pagination-info">
                                    Hiển thị trang <strong>${page}</strong> / <strong>${totalPages}</strong> (Tổng <strong>${totalRecords}</strong> nhân viên)
                                </div>
                                <div class="pagination-pages">
                                    <c:if test="${page > 1}">
                                        <a href="${pageContext.request.contextPath}/nhan-vien?page=${page - 1}&keyword=${filterKeyword}&positionId=${filterPositionId}&status=${filterStatus}" class="page-link">
                                            <i class="fa-solid fa-chevron-left"></i>
                                        </a>
                                    </c:if>

                                    <c:forEach begin="1" end="${totalPages}" var="p">
                                        <a href="${pageContext.request.contextPath}/nhan-vien?page=${p}&keyword=${filterKeyword}&positionId=${filterPositionId}&status=${filterStatus}" 
                                           class="page-link ${p eq page ? 'active' : ''}">
                                            ${p}
                                        </a>
                                    </c:forEach>

                                    <c:if test="${page < totalPages}">
                                        <a href="${pageContext.request.contextPath}/nhan-vien?page=${page + 1}&keyword=${filterKeyword}&positionId=${filterPositionId}&status=${filterStatus}" class="page-link">
                                            <i class="fa-solid fa-chevron-right"></i>
                                        </a>
                                    </c:if>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>
    </div>


    <!-- Employee Detail Modal -->
    <div id="detailModal" class="modal-overlay" onclick="closeModalOnOutsideClick(event)">
        <div class="modal-container">
            <div class="modal-header">
                <h3 class="modal-title"><i class="fa-solid fa-id-card" style="color:#4f46e5; margin-right:8px;"></i> Hồ sơ nhân viên</h3>
                <button type="button" class="modal-close" onclick="closeDetailModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="detail-row">
                    <div class="detail-label">Mã Nhân Viên:</div>
                    <div class="detail-value" id="modalEmpCode"></div>
                </div>
                <div class="detail-row">
                    <div class="detail-label">Họ và Tên:</div>
                    <div class="detail-value" id="modalFullName" style="font-weight:600;"></div>
                </div>
                <div class="detail-row">
                    <div class="detail-label">Email Công Việc:</div>
                    <div class="detail-value" id="modalWorkEmail"></div>
                </div>
                <div class="detail-row">
                    <div class="detail-label">Email Cá Nhân:</div>
                    <div class="detail-value" id="modalPersonalEmail"></div>
                </div>
                <div class="detail-row">
                    <div class="detail-label">Số Điện Thoại:</div>
                    <div class="detail-value" id="modalPhone"></div>
                </div>
                <div class="detail-row">
                    <div class="detail-label">Phòng Ban:</div>
                    <div class="detail-value" id="modalDepartment"></div>
                </div>
                <div class="detail-row">
                    <div class="detail-label">Chức Vụ:</div>
                    <div class="detail-value" id="modalPosition"></div>
                </div>
                <div class="detail-row">
                    <div class="detail-label">Ngày Sinh:</div>
                    <div class="detail-value" id="modalDob"></div>
                </div>
                <div class="detail-row">
                    <div class="detail-label">Giới Tính:</div>
                    <div class="detail-value" id="modalGender"></div>
                </div>
                <div class="detail-row">
                    <div class="detail-label">Trạng Thái:</div>
                    <div class="detail-value" id="modalStatus"></div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function openDetailModal(code, name, workEmail, personalEmail, phone, dept, pos, dob, gender, status) {
            document.getElementById('modalEmpCode').innerText = code || 'N/A';
            document.getElementById('modalFullName').innerText = name || 'N/A';
            document.getElementById('modalWorkEmail').innerText = workEmail || 'N/A';
            document.getElementById('modalPersonalEmail').innerText = personalEmail || 'N/A';
            document.getElementById('modalPhone').innerText = phone || 'N/A';
            document.getElementById('modalDepartment').innerText = dept || 'N/A';
            document.getElementById('modalPosition').innerText = pos || 'N/A';
            document.getElementById('modalDob').innerText = dob || 'N/A';
            document.getElementById('modalGender').innerText = gender || 'N/A';
            document.getElementById('modalStatus').innerText = (status === 'ACTIVE') ? 'Đang làm việc (Active)' : 'Tạm dừng/Nghỉ (Inactive)';
            
            document.getElementById('detailModal').style.display = 'flex';
        }

        function closeDetailModal() {
            document.getElementById('detailModal').style.display = 'none';
        }

        function closeModalOnOutsideClick(event) {
            if (event.target.id === 'detailModal') {
                closeDetailModal();
            }
        }
    </script>
</body>
</html>
