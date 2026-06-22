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
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 16px;
        }

        .page-title-group .page-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--text);
            margin: 0;
            text-transform: uppercase;
        }

        .page-title-group .page-subtitle {
            font-size: 13px;
            color: #64748b;
            margin-top: 4px;
            text-transform: uppercase;
        }

        .header-actions {
            display: flex;
            gap: 12px;
        }

        .btn {
            padding: 10px 18px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: none;
            font-size: 14px;
        }

        .btn-primary {
            background: #4f46e5;
            color: #fff;
        }

        .btn-primary:hover {
            background: #4338ca;
        }

        .btn-outline {
            background: transparent;
            border: 1px solid #cbd5e1;
            color: #475569;
        }

        .btn-outline:hover {
            background: #f8fafc;
            color: #0f172a;
        }
        
        .btn-sm {
            padding: 6px 12px;
            font-size: 13px;
        }

        /* Summary Cards */
        .summary-cards {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
            margin-bottom: 24px;
            padding-bottom: 24px;
            border-bottom: 1px solid #e2e8f0;
        }

        .summary-card {
            background: #fff;
            border: 1px solid #cbd5e1;
            border-radius: 12px;
            padding: 20px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        }

        .summary-card-title {
            font-size: 12px;
            color: #64748b;
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 8px;
        }

        .summary-card-value {
            font-size: 24px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 8px;
        }

        .summary-card-sub {
            font-size: 13px;
            color: #10b981;
            font-weight: 600;
        }
        .summary-card-sub.warning { color: #f59e0b; }
        .summary-card-sub.danger { color: #ef4444; }

        .summary-icon {
            position: absolute;
            right: 20px;
            bottom: 20px;
            font-size: 64px;
            color: #f1f5f9;
            z-index: 0;
            opacity: 0.8;
        }

        /* Filter Section */
        .filter-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            padding-bottom: 24px;
            border-bottom: 1px solid #e2e8f0;
        }

        .filter-group {
            display: flex;
            gap: 16px;
            align-items: center;
        }

        .filter-select {
            padding: 10px 16px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            color: #1e293b;
            background: #fff;
            outline: none;
            cursor: pointer;
        }

        .filter-search {
            position: relative;
            width: 250px;
        }

        .filter-search input {
            width: 100%;
            padding: 10px 16px 10px 36px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 14px;
            outline: none;
            box-sizing: border-box;
        }
        
        .filter-search input:focus {
            border-color: #4f46e5;
        }

        .filter-search i {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
        }

        .filter-info {
            font-size: 13px;
            color: #64748b;
            font-weight: 600;
            text-transform: uppercase;
        }

        /* Payroll List Layout (Cards) */
        .payroll-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .payroll-card {
            background: #fff;
            border: 1px solid #cbd5e1;
            border-radius: 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 24px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        }
        
        .payroll-card:hover {
            border-color: #94a3b8;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }

        .payroll-card-left {
            display: flex;
            gap: 20px;
            align-items: center;
        }

        .month-badge {
            background: #1e293b;
            color: #fff;
            width: 60px;
            height: 60px;
            border-radius: 8px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .month-badge span.label {
            font-size: 10px;
            text-transform: uppercase;
            font-weight: 600;
            opacity: 0.8;
        }

        .month-badge span.value {
            font-size: 20px;
            font-weight: 700;
            line-height: 1;
            margin-top: 2px;
        }

        .payroll-info h3 {
            margin: 0 0 4px 0;
            font-size: 18px;
            color: #0f172a;
        }

        .payroll-meta {
            font-size: 13px;
            color: #64748b;
            display: flex;
            gap: 16px;
        }

        .payroll-card-right {
            display: flex;
            align-items: center;
            gap: 40px;
        }

        .total-amount {
            text-align: right;
        }

        .total-amount-label {
            font-size: 12px;
            color: #64748b;
            text-transform: uppercase;
            margin-bottom: 4px;
            font-weight: 600;
        }

        .total-amount-value {
            font-size: 18px;
            font-weight: 700;
            color: #0f172a;
        }

        .card-actions {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 10px;
        }

        .status-badge {
            padding: 4px 12px;
            font-size: 12px;
            font-weight: 600;
            border: 1px solid transparent;
            border-radius: 4px;
            text-transform: uppercase;
        }

        .status-badge.draft {
            color: #b45309;
            border-color: #fcd34d;
            background: #fef3c7;
        }

        .status-badge.approved {
            color: #1d4ed8;
            border-color: #93c5fd;
            background: #dbeafe;
        }

        .status-badge.paid {
            color: #047857;
            border-color: #6ee7b7;
            background: #d1fae5;
        }

        .action-buttons {
            display: flex;
            gap: 8px;
        }
        
        .action-buttons form {
            margin: 0;
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 32px;
        }

        .page-item {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            color: #475569;
            font-weight: 600;
            text-decoration: none;
            font-size: 14px;
            transition: all 0.2s;
        }

        .page-item:hover {
            background: #f8fafc;
            color: #0f172a;
        }

        .page-item.active {
            background: #4f46e5;
            border-color: #4f46e5;
            color: #fff;
        }

        .page-item.disabled {
            opacity: 0.5;
            cursor: not-allowed;
            pointer-events: none;
        }

        .empty-state {
            text-align: center;
            padding: 40px;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        }

        .empty-state i {
            font-size: 48px;
            color: #cbd5e1;
            margin-bottom: 16px;
        }

        /* Modal */
        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.5);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 100;
        }

        .modal-overlay.open {
            display: flex;
        }

        .modal {
            background: #fff;
            padding: 32px;
            border-radius: 16px;
            width: 400px;
        }

        .form-group {
            margin-bottom: 16px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            font-size: 14px;
        }

        .form-group input {
            width: 100%;
            padding: 10px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            box-sizing: border-box;
        }
        
        .form-group input:focus {
            border-color: #4f46e5;
            outline: none;
        }
    </style>
</head>

<body>
    <div class="main-layout">
        <%@include file="/WEB-INF/common/sidebar.jsp" %>

            <main class="content-area">
                <div class="page-header">
                    <div class="page-title-group">
                        <h1 class="page-title">QUẢN LÝ LƯƠNG</h1>
                        <div class="page-subtitle">QUẢN LÝ CÁC KỲ LƯƠNG, CẤU HÌNH VÀ BÁO CÁO CHI PHÍ NHÂN SỰ</div>
                    </div>
                    <div class="header-actions">
                        <button class="btn btn-outline">
                            <i class="fa-solid fa-gear"></i> Cấu hình lương
                        </button>
                        <c:if test="${sessionScope.roleGroup == 'HR' || sessionScope.roleGroup == 'ADMIN'}">
                            <button class="btn btn-primary" onclick="openGenerateModal()">
                                <i class="fa-solid fa-plus"></i> Tạo kỳ lương mới
                            </button>
                        </c:if>
                    </div>
                </div>

                <c:if test="${param.success == 'generated'}">
                    <div
                        style="background: #d1fae5; color: #047857; padding: 16px; border-radius: 8px; margin-bottom: 24px;">
                        <i class="fa-solid fa-check-circle"></i> Đã tạo bảng lương thành công!
                    </div>
                </c:if>
                <c:if test="${param.error == 'already_approved'}">
                    <div
                        style="background: #fee2e2; color: #b91c1c; padding: 16px; border-radius: 8px; margin-bottom: 24px;">
                        <i class="fa-solid fa-exclamation-circle"></i> Kỳ lương tháng này đã được Duyệt hoặc Chi trả. Không thể tính lại!
                    </div>
                </c:if>
                <c:if test="${param.error == 'generate_failed'}">
                    <div
                        style="background: #fee2e2; color: #b91c1c; padding: 16px; border-radius: 8px; margin-bottom: 24px;">
                        <i class="fa-solid fa-exclamation-circle"></i> Có lỗi xảy ra khi tạo bảng lương. Vui lòng kiểm tra lại cấu hình công hoặc bảo hiểm.
                    </div>
                </c:if>
                <c:if test="${param.error == 'no_attendance'}">
                    <div
                        style="background: #fee2e2; color: #b91c1c; padding: 16px; border-radius: 8px; margin-bottom: 24px;">
                        <i class="fa-solid fa-exclamation-circle"></i> Không thể tính lương vì thiếu dữ liệu bảng công của một số nhân viên.
                    </div>
                </c:if>

                <!-- Summary Cards -->
                <div class="summary-cards">
                    <div class="summary-card">
                        <div class="summary-card-title">TỔNG CHI LƯƠNG (YTD ${currentYear})</div>
                        <div class="summary-card-value"><fmt:formatNumber value="${ytdAmount}" pattern="#,##0" /> đ</div>
                        <div class="summary-card-sub">
                            <c:choose>
                                <c:when test="${ytdAmount > 0}">Đã cập nhật dữ liệu năm nay</c:when>
                                <c:otherwise>Chưa có chi trả</c:otherwise>
                            </c:choose>
                        </div>
                        <i class="fa-solid fa-dollar-sign summary-icon"></i>
                    </div>
                    <div class="summary-card">
                        <div class="summary-card-title">KỲ LƯƠNG HIỆN TẠI</div>
                        <div class="summary-card-value">Tháng <fmt:formatNumber value="${currentMonth}" pattern="00" />/${currentYear}</div>
                        <c:choose>
                            <c:when test="${empty currentPayroll || currentPayroll.status == 'DRAFT'}">
                                <div class="summary-card-sub warning">Đang trong quá trình tính</div>
                            </c:when>
                            <c:when test="${currentPayroll.status == 'APPROVED' || currentPayroll.status == 'PAID'}">
                                <div class="summary-card-sub">Đã hoàn thành</div>
                            </c:when>
                        </c:choose>
                        <i class="fa-regular fa-clock summary-icon"></i>
                    </div>
                    <div class="summary-card">
                        <div class="summary-card-title">YÊU CẦU GIẢI TRÌNH LƯƠNG</div>
                        <div class="summary-card-value">0 yêu cầu</div>
                        <div class="summary-card-sub danger">Cần xử lý ngay</div>
                        <i class="fa-solid fa-circle-exclamation summary-icon"></i>
                    </div>
                </div>

                <!-- Filter Section -->
                <form action="${pageContext.request.contextPath}/admin/payrolls" method="GET" class="filter-section" id="filterForm">
                    <div class="filter-group">
                        <select name="year" class="filter-select" onchange="document.getElementById('filterForm').submit()">
                            <c:forEach var="y" begin="${currentYear - 3}" end="${currentYear + 1}">
                                <option value="${y}" ${selectedYear == y ? 'selected' : ''}>NĂM: ${y}</option>
                            </c:forEach>
                        </select>
                        <div class="filter-search">
                            <i class="fa-solid fa-search"></i>
                            <input type="text" name="search" placeholder="Tìm kỳ lương..." value="${searchKeyword}">
                        </div>
                        <button type="submit" style="display: none;">Submit</button>
                    </div>
                    <div class="filter-info">
                        HIỂN THỊ CÁC KỲ LƯƠNG TRONG NĂM ${selectedYear}
                    </div>
                </form>

                <!-- Payroll List -->
                <c:choose>
                    <c:when test="${empty payrolls}">
                        <div class="empty-state">
                            <i class="fa-solid fa-file-invoice-dollar"></i>
                            <h3>Không tìm thấy kỳ lương nào</h3>
                            <p style="color: #64748b; margin-top: 8px;">Nhấn nút Tạo Kỳ Lương Mới để bắt đầu tạo bảng lương.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="payroll-list">
                            <c:forEach items="${payrolls}" var="p">
                                <div class="payroll-card">
                                    <div class="payroll-card-left">
                                        <div class="month-badge">
                                            <span class="label">Tháng</span>
                                            <span class="value"><fmt:formatNumber value="${p.month}" pattern="00" /></span>
                                        </div>
                                        <div class="payroll-info">
                                            <h3>Kỳ lương tháng <fmt:formatNumber value="${p.month}" pattern="00" />/${p.year}</h3>
                                            <div class="payroll-meta">
                                                <span>Nhân viên: <strong>${p.totalEmployees}</strong></span>
                                                <span>Cập nhật: <strong><fmt:formatDate value="${p.updatedAt}" pattern="dd/MM/yyyy" /></strong></span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="payroll-card-right">
                                        <div class="total-amount">
                                            <div class="total-amount-label">TỔNG CHI TRẢ</div>
                                            <div class="total-amount-value">
                                                <c:choose>
                                                    <c:when test="${p.status == 'DRAFT'}">Tính toán dự kiến</c:when>
                                                    <c:otherwise><fmt:formatNumber value="${p.totalAmount}" pattern="#,##0" /> đ</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <div class="card-actions">
                                            <c:choose>
                                                <c:when test="${p.status == 'DRAFT'}">
                                                    <div class="status-badge draft">CHƯA CHỐT</div>
                                                </c:when>
                                                <c:when test="${p.status == 'APPROVED'}">
                                                    <div class="status-badge approved">ĐÃ CHỐT</div>
                                                </c:when>
                                                <c:when test="${p.status == 'PAID'}">
                                                    <div class="status-badge paid">ĐÃ CHI TRẢ</div>
                                                </c:when>
                                            </c:choose>
                                            <div class="action-buttons">
                                                <a href="${pageContext.request.contextPath}/admin/payroll/detail?id=${p.id}" class="btn btn-outline btn-sm">
                                                    <i class="fa-solid fa-eye"></i> Xem chi tiết
                                                </a>
                                                <c:if test="${p.status == 'DRAFT'}">
                                                    <form action="${pageContext.request.contextPath}/admin/payroll/generate" method="post" style="margin: 0;">
                                                        <input type="hidden" name="month" value="${p.month}">
                                                        <input type="hidden" name="year" value="${p.year}">
                                                        <button type="submit" class="btn btn-outline btn-sm" style="color: #b45309; border-color: #fcd34d;" title="Tính lại dựa trên dữ liệu mới" onclick="return confirm('Tính lại bảng lương tháng này?');">
                                                            <i class="fa-solid fa-rotate-right"></i> Tính Lại
                                                        </button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${p.status == 'DRAFT' && sessionScope.roleGroup == 'ADMIN'}">
                                                    <form action="${pageContext.request.contextPath}/admin/payroll/approve" method="post">
                                                        <input type="hidden" name="id" value="${p.id}">
                                                        <input type="hidden" name="status" value="APPROVED">
                                                        <button type="submit" class="btn btn-primary btn-sm" onclick="return confirm('Bạn có chắc chắn muốn chốt bảng lương này?');">
                                                            <i class="fa-solid fa-check"></i> Chốt lương
                                                        </button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${p.status == 'APPROVED' && sessionScope.roleGroup == 'ADMIN'}">
                                                    <form action="${pageContext.request.contextPath}/admin/payroll/approve" method="post" style="margin: 0;">
                                                        <input type="hidden" name="id" value="${p.id}">
                                                        <input type="hidden" name="status" value="PAID">
                                                        <button type="submit" class="btn btn-primary btn-sm" style="background: #3b82f6; border-color: #3b82f6;" onclick="return confirm('Xác nhận đã chi trả bảng lương này?');">
                                                            <i class="fa-solid fa-money-bill-wave"></i> Chi Trả
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                        
                        <!-- Pagination -->
                        <c:if test="${totalPages > 1}">
                            <div class="pagination">
                                <a href="?page=${currentPage - 1}&year=${selectedYear}&search=${searchKeyword}" class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <i class="fa-solid fa-chevron-left"></i>
                                </a>
                                <c:forEach var="i" begin="1" end="${totalPages}">
                                    <a href="?page=${i}&year=${selectedYear}&search=${searchKeyword}" class="page-item ${currentPage == i ? 'active' : ''}">
                                        ${i}
                                    </a>
                                </c:forEach>
                                <a href="?page=${currentPage + 1}&year=${selectedYear}&search=${searchKeyword}" class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <i class="fa-solid fa-chevron-right"></i>
                                </a>
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </main>
    </div>

    <!-- Modal Generate Payroll -->
    <div class="modal-overlay" id="generateModal">
        <div class="modal">
            <h2 style="margin-top: 0; font-size: 18px; margin-bottom: 12px;">Tạo Bảng Lương Mới</h2>
            <div style="font-size: 0.8rem; color: #64748b; margin-bottom: 20px; line-height: 1.4; background: #f8fafc; padding: 12px; border-radius: 8px; border-left: 3px solid #4f46e5;">
                <i class="fa-solid fa-circle-info" style="color: #4f46e5; margin-right: 4px;"></i>
                <strong>Nguyên tắc:</strong> Mỗi tháng chỉ có duy nhất 1 bảng lương (One payroll per month).
                Nếu bảng lương cũ ở trạng thái <em>Bản Nháp</em>, hệ thống sẽ tính lại và ghi đè. 
                Nếu đã <em>Duyệt</em> hoặc <em>Chi trả</em>, hệ thống sẽ chặn không cho phép tính lại.
            </div>
            <form action="${pageContext.request.contextPath}/admin/payroll/generate" method="post">
                <div class="form-group">
                    <label>Tháng</label>
                    <input type="number" name="month" min="1" max="12" required
                        value="<%= java.time.LocalDate.now().getMonthValue() %>">
                </div>
                <div class="form-group">
                    <label>Năm</label>
                    <input type="number" name="year" min="2000" max="2100" required
                        value="<%= java.time.LocalDate.now().getYear() %>">
                </div>
                <div style="display: flex; gap: 10px; margin-top: 24px; justify-content: flex-end;">
                    <button type="button" class="btn btn-outline"
                        onclick="closeGenerateModal()">Hủy</button>
                    <button type="submit" class="btn btn-primary">Tính Toán Ngay</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openGenerateModal() {
            document.getElementById('generateModal').classList.add('open');
        }
        function closeGenerateModal() {
            document.getElementById('generateModal').classList.remove('open');
        }
    </script>
</body>

</html>