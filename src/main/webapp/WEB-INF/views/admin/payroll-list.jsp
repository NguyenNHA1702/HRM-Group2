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
                    }

                    .page-title {
                        font-size: 24px;
                        font-weight: 700;
                        color: var(--text);
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

                    .btn-sm {
                        padding: 6px 12px;
                        font-size: 13px;
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

                    table {
                        width: 100%;
                        border-collapse: collapse;
                        background: #fff;
                        border-radius: 12px;
                        overflow: hidden;
                        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
                        margin-top: 16px;
                    }

                    th {
                        background: #f8fafc;
                        padding: 16px;
                        text-align: left;
                        font-weight: 600;
                        font-size: 13px;
                        color: #475569;
                        border-bottom: 1px solid #e2e8f0;
                    }

                    td {
                        padding: 16px;
                        font-size: 14px;
                        color: #1e293b;
                        border-bottom: 1px solid #f1f5f9;
                        vertical-align: middle;
                    }

                    tr:hover td {
                        background: #f8fafc;
                    }

                    .badge {
                        padding: 4px 10px;
                        border-radius: 99px;
                        font-size: 12px;
                        font-weight: 600;
                    }

                    .badge-draft {
                        background: #fef3c7;
                        color: #b45309;
                    }

                    .badge-approved {
                        background: #dbeafe;
                        color: #1d4ed8;
                    }

                    .badge-paid {
                        background: #d1fae5;
                        color: #047857;
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
                    }
                </style>
            </head>

            <body>
                <div class="main-layout">
                    <%@include file="/WEB-INF/common/sidebar.jsp" %>

                        <main class="content-area">
                            <div class="page-header">
                                <h1 class="page-title">Quản Lý Bảng Lương</h1>
                                <c:if test="${sessionScope.roleGroup == 'HR' || sessionScope.roleGroup == 'ADMIN'}">
                                    <button class="btn btn-primary" onclick="openGenerateModal()">
                                        <i class="fa-solid fa-calculator"></i> Tính Lương Tháng Mới
                                    </button>
                                </c:if>
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

                            <c:choose>
                                <c:when test="${empty payrolls}">
                                    <div class="empty-state">
                                        <i class="fa-solid fa-file-invoice-dollar"></i>
                                        <h3>Chưa có bảng lương nào</h3>
                                        <p style="color: #64748b; margin-top: 8px;">Nhấn nút Tính Lương Tháng Mới để bắt
                                            đầu tạo bảng lương.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Kỳ Lương</th>
                                                <th>Trạng Thái</th>
                                                <th>Số Nhân Viên</th>
                                                <th>Tổng Tiền</th>
                                                <th>Người Tạo</th>
                                                <th>Ngày Tạo</th>
                                                <th>Hành Động</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${payrolls}" var="p">
                                                <tr>
                                                    <td>
                                                        <strong>Tháng ${p.month}/${p.year}</strong>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${p.status == 'DRAFT'}"><span
                                                                    class="badge badge-draft">BẢN NHÁP</span></c:when>
                                                            <c:when test="${p.status == 'APPROVED'}"><span
                                                                    class="badge badge-approved">ĐÃ DUYỆT</span>
                                                            </c:when>
                                                            <c:when test="${p.status == 'PAID'}"><span
                                                                    class="badge badge-paid">ĐÃ CHI TRẢ</span></c:when>
                                                        </c:choose>
                                                    </td>
                                                    <td>${p.totalEmployees} NV</td>
                                                    <td style="font-weight: 600; color: #0f172a;">
                                                        <fmt:formatNumber value="${p.totalAmount}" pattern="#,##0" /> đ
                                                    </td>
                                                    <td>
                                                        <div>${p.createdByName}</div>
                                                        <c:if test="${not empty p.approvedByName}">
                                                            <div style="font-size: 0.8rem; color: #4338ca; margin-top: 4px;" title="Người duyệt bảng lương">
                                                                <i class="fa-solid fa-user-check"></i> Duyệt: ${p.approvedByName}
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${not empty p.paidByName}">
                                                            <div style="font-size: 0.8rem; color: #16a34a; margin-top: 2px;" title="Người xác nhận chi trả">
                                                                <i class="fa-solid fa-hand-holding-dollar"></i> Chi: ${p.paidByName}
                                                            </div>
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <div><fmt:formatDate value="${p.createdAt}" pattern="dd/MM/yyyy HH:mm" /></div>
                                                        <c:if test="${not empty p.approvedAt}">
                                                            <div style="font-size: 0.8rem; color: #64748b; margin-top: 4px;">
                                                                <fmt:formatDate value="${p.approvedAt}" pattern="dd/MM/yyyy HH:mm" />
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${not empty p.paidAt}">
                                                            <div style="font-size: 0.8rem; color: #64748b; margin-top: 2px;">
                                                                <fmt:formatDate value="${p.paidAt}" pattern="dd/MM/yyyy HH:mm" />
                                                            </div>
                                                        </c:if>
                                                    </td>
                                                    <td style="display: flex; gap: 8px;">
                                                        <a href="${pageContext.request.contextPath}/admin/payroll/detail?id=${p.id}"
                                                            class="btn btn-sm btn-outline">
                                                            <i class="fa-solid fa-eye"></i> Xem Chi Tiết
                                                        </a>
                                                        <c:if test="${p.status == 'DRAFT'}">
                                                            <form action="${pageContext.request.contextPath}/admin/payroll/generate" method="post" style="margin: 0;">
                                                                <input type="hidden" name="month" value="${p.month}">
                                                                <input type="hidden" name="year" value="${p.year}">
                                                                <button type="submit" class="btn btn-sm btn-outline" style="color: #b45309; border-color: #fcd34d;" title="Tính lại dựa trên dữ liệu mới" onclick="return confirm('Bạn có chắc chắn muốn xóa bản nháp cũ và tính lại bảng lương tháng này?');">
                                                                    <i class="fa-solid fa-rotate-right"></i> Tính Lại
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                        <c:if test="${p.status == 'DRAFT' && sessionScope.roleGroup == 'ADMIN'}">
                                                            <form action="${pageContext.request.contextPath}/admin/payroll/approve" method="post" style="margin: 0;">
                                                                <input type="hidden" name="id" value="${p.id}">
                                                                <input type="hidden" name="status" value="APPROVED">
                                                                <button type="submit" class="btn btn-sm" style="background: #10b981; color: white; border: none; font-weight: 600;" onclick="return confirm('Bạn có chắc chắn muốn duyệt bảng lương này?');">
                                                                    <i class="fa-solid fa-check"></i> Duyệt
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                        <c:if test="${p.status == 'APPROVED' && sessionScope.roleGroup == 'ADMIN'}">
                                                            <form action="${pageContext.request.contextPath}/admin/payroll/approve" method="post" style="margin: 0;">
                                                                <input type="hidden" name="id" value="${p.id}">
                                                                <input type="hidden" name="status" value="PAID">
                                                                <button type="submit" class="btn btn-sm" style="background: #3b82f6; color: white; border: none; font-weight: 600;" onclick="return confirm('Xác nhận đã chi trả bảng lương này?');">
                                                                    <i class="fa-solid fa-money-bill-wave"></i> Chi Trả
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
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