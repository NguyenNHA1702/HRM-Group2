<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Danh Sách Bảng Lương | HRMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css" />
    <style>
        .page-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; border-bottom:1px solid #e2e8f0; padding-bottom:16px; }
        .page-title-group .page-title { font-size:24px; font-weight:700; color:var(--text); margin:0; text-transform:uppercase; }
        .page-title-group .page-subtitle { font-size:13px; color:#64748b; margin-top:4px; }
        .header-actions { display:flex; gap:12px; }
        .btn { padding:10px 18px; border-radius:8px; font-weight:600; cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:8px; border:none; font-size:14px; }
        .btn-primary { background:#4f46e5; color:#fff; }
        .btn-primary:hover { background:#4338ca; }
        .btn-outline { background:transparent; border:1px solid #cbd5e1; color:#475569; }
        .btn-outline:hover { background:#f8fafc; color:#0f172a; }
        .btn-sm { padding:6px 12px; font-size:13px; }

        .badge { padding:4px 12px; border-radius:20px; font-size:12px; font-weight:600; display:inline-block; }
        .badge-yellow { background:#fef3c7; color:#92400e; }
        .badge-blue { background:#dbeafe; color:#1e40af; }
        .badge-green { background:#d1fae5; color:#065f46; }
        .badge-gray { background:#f1f5f9; color:#475569; }

        .filter-bar { display:flex; gap:16px; align-items:center; margin-bottom:24px; padding:16px; background:#f8fafc; border-radius:12px; border:1px solid #e2e8f0; flex-wrap:wrap; }
        .filter-bar select, .filter-bar input { padding:8px 12px; border-radius:8px; border:1px solid #cbd5e1; font-size:14px; }
        .filter-bar label { font-weight:600; font-size:13px; color:#475569; }

        .data-table { width:100%; border-collapse:collapse; font-size:14px; }
        .data-table th { background:#f8fafc; padding:12px 16px; text-align:left; font-weight:600; color:#475569; border-bottom:2px solid #e2e8f0; }
        .data-table td { padding:12px 16px; border-bottom:1px solid #f1f5f9; color:#334155; }
        .data-table tr:hover { background:#f8fafc; }
        .data-table .text-right { text-align:right; }
        .data-table .text-center { text-align:center; }
        .amount { font-family:'Roboto Mono',monospace; font-weight:600; }

        .card { background:#fff; border:1px solid #e2e8f0; border-radius:12px; overflow:hidden; }
        .card-body { padding:0; }

        .pagination { display:flex; justify-content:center; gap:8px; margin-top:20px; }
        .pagination a, .pagination span { padding:8px 14px; border-radius:8px; border:1px solid #e2e8f0; text-decoration:none; color:#475569; font-size:14px; }
        .pagination .active { background:#4f46e5; color:#fff; border-color:#4f46e5; }

        .alert { padding:12px 16px; border-radius:8px; margin-bottom:16px; font-size:14px; }
        .alert-success { background:#d1fae5; color:#065f46; border:1px solid #6ee7b7; }
        .alert-error { background:#fee2e2; color:#991b1b; border:1px solid #fca5a5; }
        .alert-warning { background:#fef3c7; color:#92400e; border:1px solid #fcd34d; }

        .generate-section { background:#fff; border:1px solid #e2e8f0; border-radius:12px; padding:20px; margin-bottom:24px; display:flex; align-items:center; gap:16px; flex-wrap:wrap; }
        .generate-section select { padding:8px 12px; border-radius:8px; border:1px solid #cbd5e1; }
    </style>
</head>
<body>
<div class="main-layout">
    <jsp:include page="/WEB-INF/common/sidebar.jsp" />
    <main class="content-area">

            <!-- Alerts -->
            <c:if test="${not empty sessionScope.flash_success}">
                <div class="alert alert-success"><i class="fas fa-check-circle"></i> <c:out value="${sessionScope.flash_success}"/></div>
                <c:remove var="flash_success" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.flash_error}">
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <c:out value="${sessionScope.flash_error}"/></div>
                <c:remove var="flash_error" scope="session"/>
            </c:if>
            <c:if test="${param.success == 'generated'}">
                <div class="alert alert-success"><i class="fas fa-check-circle"></i> Tạo bảng lương thành công!</div>
            </c:if>
            <c:if test="${param.error == 'already_approved'}">
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Bảng lương đã được duyệt, không thể tạo lại.</div>
            </c:if>
            <c:if test="${param.error == 'no_attendance'}">
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Thiếu bảng công nhân viên. Vui lòng kiểm tra chấm công.</div>
            </c:if>
            <c:if test="${param.error == 'generate_failed'}">
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Tạo bảng lương thất bại.</div>
            </c:if>

            <!-- Header -->
            <div class="page-header">
                <div class="page-title-group">
                    <h1 class="page-title"><i class="fas fa-money-bill-wave"></i> Quản Lý Bảng Lương</h1>
                    <p class="page-subtitle">Quản lý bảng lương theo tháng, lọc theo phòng ban</p>
                </div>
                <div class="header-actions">
                    <c:if test="${roleGroup == 'HR' || roleGroup == 'ADMIN'}">
                        <a href="${pageContext.request.contextPath}/admin/position-allowances" class="btn btn-outline btn-sm">
                            <i class="fas fa-cog"></i> Cấu hình phụ cấp
                        </a>
                    </c:if>
                </div>
            </div>

            <!-- Generate Payroll Section (HR only) -->
            <c:if test="${roleGroup == 'HR' || roleGroup == 'ADMIN'}">
                <div class="generate-section">
                    <i class="fas fa-calculator" style="font-size:24px; color:#4f46e5;"></i>
                    <span style="font-weight:600;">Tạo bảng lương mới:</span>
                    <form action="${pageContext.request.contextPath}/admin/payroll/generate" method="post" style="display:flex; gap:8px; align-items:center;">
                        <select name="month">
                            <c:forEach var="m" begin="1" end="12">
                                <option value="${m}" ${m == currentMonth ? 'selected' : ''}>Tháng ${m}</option>
                            </c:forEach>
                        </select>
                        <select name="year">
                            <c:forEach var="y" begin="2024" end="2027">
                                <option value="${y}" ${y == currentYear ? 'selected' : ''}>${y}</option>
                            </c:forEach>
                        </select>
                        <button type="submit" class="btn btn-primary btn-sm" onclick="return confirm('Tạo bảng lương? Hệ thống sẽ tính lương từ hợp đồng và phụ cấp theo chức vụ.')">
                            <i class="fas fa-play"></i> Tạo bảng lương
                        </button>
                        <button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById('bonusModal').style.display='flex';" style="margin-left:auto; border-color:#10b981; color:#10b981;">
                            <i class="fas fa-gift"></i> Nhập Thưởng
                        </button>
                    </form>
                </div>
            </c:if>

            <!-- Filter -->
            <div class="filter-bar">
                <form action="${pageContext.request.contextPath}/admin/payrolls" method="get" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap;">
                    <label>Năm:</label>
                    <select name="year" onchange="this.form.submit()">
                        <c:forEach var="y" begin="2024" end="2027">
                            <option value="${y}" ${y == selectedYear ? 'selected' : ''}>${y}</option>
                        </c:forEach>
                    </select>
                    <label>Tìm kiếm:</label>
                    <input type="text" name="search" value="${searchKeyword}" placeholder="Tháng, trạng thái..." />
                    <button type="submit" class="btn btn-sm btn-outline"><i class="fas fa-search"></i></button>
                </form>
            </div>

            <!-- Table -->
            <div class="card">
                <div class="card-body">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Kỳ lương</th>
                                <th class="text-center">Trạng thái</th>
                                <th class="text-center">Số NV</th>
                                <th class="text-right">Tổng tiền</th>
                                <th>Người tạo</th>
                                <th class="text-center">Thời gian tạo</th>
                                <th>Manager xác nhận</th>
                                <th>HR chốt</th>
                                <th class="text-center">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${payrolls}">
                                <tr>
                                    <td><strong>Tháng ${p.month}/${p.year}</strong></td>
                                    <td class="text-center"><span class="badge ${p.statusBadgeClass}">${p.statusLabel}</span></td>
                                    <td class="text-center">${p.totalEmployees}</td>
                                    <td class="text-right amount"><fmt:formatNumber value="${p.totalAmount}" pattern="#,##0" /> đ</td>
                                    <td>${p.createdByName}</td>
                                    <td class="text-center">
                                        <fmt:formatDate value="${p.createdAt}" pattern="dd/MM/yyyy HH:mm" timeZone="UTC" />
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.managerConfirmedByName != null}">${p.managerConfirmedByName}</c:when>
                                            <c:otherwise><span style="color:#94a3b8;">—</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:if test="${p.hrConfirmedByName != null}">${p.hrConfirmedByName}</c:if>
                                        <c:if test="${p.hrConfirmedByName == null}"><span style="color:#94a3b8;">—</span></c:if>
                                    </td>
                                    <td class="text-center">
                                        <a href="${pageContext.request.contextPath}/admin/payroll/detail?id=${p.id}" class="btn btn-outline btn-sm">
                                            <i class="fas fa-eye"></i> Chi tiết
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty payrolls}">
                                <tr><td colspan="8" class="text-center" style="padding:40px; color:#94a3b8;">Chưa có bảng lương nào.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 0}">
                <div class="pagination">
                    <c:forEach var="i" begin="1" end="${totalPages}">
                        <a href="${pageContext.request.contextPath}/admin/payrolls?year=${selectedYear}&search=${searchKeyword}&page=${i}"
                           class="${i == currentPage ? 'active' : ''}">${i}</a>
                    </c:forEach>
                </div>
            </c:if>

        </div>
    </main>
</div>

<!-- Modal Nhập Thưởng -->
<div id="bonusModal" class="modal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(15,23,42,0.6); align-items:center; justify-content:center; z-index:1000; padding:16px;">
    <div class="modal-content" style="background:#fff; width:100%; max-width:400px; border-radius:16px; overflow:hidden; box-shadow:0 20px 25px -5px rgba(0,0,0,0.1), 0 8px 10px -6px rgba(0,0,0,0.1); display:flex; flex-direction:column;">
        <div class="modal-header" style="padding:16px 20px; border-bottom:1px solid #e2e8f0; display:flex; justify-content:space-between; align-items:center; background:#f8fafc;">
            <h3 style="margin:0; font-size:18px; color:#0f172a;"><i class="fas fa-gift" style="color:#10b981; margin-right:8px;"></i>Nhập Thưởng</h3>
            <button onclick="document.getElementById('bonusModal').style.display='none';" style="background:transparent; border:none; font-size:20px; color:#94a3b8; cursor:pointer;">&times;</button>
        </div>
        <div class="modal-body" style="padding:20px;">
            <form action="${pageContext.request.contextPath}/admin/payroll/bonus/save" method="post">
                <div style="margin-bottom:16px;">
                    <label style="display:block; font-size:14px; font-weight:600; color:#475569; margin-bottom:8px;">Tháng / Năm</label>
                    <div style="display:flex; gap:8px;">
                        <select name="month" style="flex:1; padding:10px 12px; border:1px solid #cbd5e1; border-radius:8px; outline:none;">
                            <c:forEach var="m" begin="1" end="12">
                                <option value="${m}" ${m == currentMonth ? 'selected' : ''}>Tháng ${m}</option>
                            </c:forEach>
                        </select>
                        <select name="year" style="flex:1; padding:10px 12px; border:1px solid #cbd5e1; border-radius:8px; outline:none;">
                            <c:forEach var="y" begin="2024" end="2027">
                                <option value="${y}" ${y == currentYear ? 'selected' : ''}>${y}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div style="margin-bottom:16px;">
                    <label style="display:block; font-size:14px; font-weight:600; color:#475569; margin-bottom:8px;">Nhân viên</label>
                    <select name="employeeId" required style="width:100%; padding:10px 12px; border:1px solid #cbd5e1; border-radius:8px; outline:none;">
                        <option value="">-- Chọn nhân viên --</option>
                        <c:forEach var="emp" items="${employeeList}">
                            <option value="${emp.employeeId}">[${emp.employeeCode}] ${emp.fullName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div style="margin-bottom:16px;">
                    <label style="display:block; font-size:14px; font-weight:600; color:#475569; margin-bottom:8px;">Số tiền thưởng (VNĐ)</label>
                    <input type="number" name="amount" required min="1000" style="width:100%; padding:10px 12px; border:1px solid #cbd5e1; border-radius:8px; outline:none;" placeholder="VD: 500000" />
                </div>
                <div style="margin-bottom:20px;">
                    <label style="display:block; font-size:14px; font-weight:600; color:#475569; margin-bottom:8px;">Ghi chú / Lý do</label>
                    <input type="text" name="note" required style="width:100%; padding:10px 12px; border:1px solid #cbd5e1; border-radius:8px; outline:none;" placeholder="VD: Thưởng dự án ABC" />
                </div>
                <button type="submit" class="btn btn-primary" style="width:100%; justify-content:center; padding:12px; font-size:15px; background:#10b981;">Lưu Thưởng</button>
            </form>
        </div>
    </div>
</div>

<script>
    window.onclick = function(event) {
        var modal = document.getElementById('bonusModal');
        if (event.target == modal) {
            modal.style.display = "none";
        }
    }
</script>

</body>
</html>