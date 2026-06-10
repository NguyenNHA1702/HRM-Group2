<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <title>Chi Tiết Bảng Lương T${payroll.month}/${payroll.year} | HRMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
    <style>
        .page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; }
        .page-title { font-size: 24px; font-weight: 700; color: var(--text); display: flex; align-items: center; gap: 12px; }
        .subtitle { color: #64748b; font-size: 14px; margin-top: 6px; }
        
        .btn { padding: 10px 18px; border-radius: 8px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; border: none; font-size: 14px; }
        .btn-outline { background: #fff; border: 1px solid #cbd5e1; color: #475569; }
        .btn-outline:hover { background: #f8fafc; }
        .btn-success { background: #10b981; color: #fff; }
        .btn-success:hover { background: #059669; }
        
        .summary-cards { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }
        .card { background: #fff; padding: 24px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; }
        .card-title { font-size: 13px; color: #64748b; font-weight: 600; text-transform: uppercase; margin-bottom: 8px; }
        .card-value { font-size: 24px; font-weight: 700; color: #0f172a; }
        
        table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        th { background: #f8fafc; padding: 14px; text-align: left; font-weight: 600; font-size: 12px; color: #475569; border-bottom: 1px solid #e2e8f0; white-space: nowrap; }
        td { padding: 14px; font-size: 13px; color: #1e293b; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
        tr:hover td { background: #f8fafc; }
        
        .text-right { text-align: right; }
        .text-green { color: #16a34a; font-weight: 600; }
        .text-red { color: #dc2626; font-weight: 600; }
        .text-primary { color: #4f46e5; font-weight: 700; font-size: 14px; }
    </style>
</head>
<body>
    <div class="main-layout">
        <%@include file="/WEB-INF/common/sidebar.jsp" %>
        
        <main class="content-area">
            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        Bảng Lương Tháng ${payroll.month}/${payroll.year}
                        <c:if test="${payroll.status == 'DRAFT'}"><span style="background: #fef3c7; color: #b45309; padding: 4px 10px; border-radius: 99px; font-size: 12px;">BẢN NHÁP</span></c:if>
                        <c:if test="${payroll.status == 'APPROVED'}"><span style="background: #dbeafe; color: #1d4ed8; padding: 4px 10px; border-radius: 99px; font-size: 12px;">ĐÃ CHỐT</span></c:if>
                        <c:if test="${payroll.status == 'PAID'}"><span style="background: #dcfce3; color: #166534; padding: 4px 10px; border-radius: 99px; font-size: 12px;">ĐÃ CHI TRẢ</span></c:if>
                    </h1>
                    <div class="subtitle">
                        Tạo ngày <fmt:formatDate value="${payroll.createdAt}" pattern="dd/MM/yyyy HH:mm"/> bởi ${payroll.createdByName}
                        <c:if test="${not empty payroll.approvedByName}">
                            | Duyệt bởi: <strong>${payroll.approvedByName}</strong> (<fmt:formatDate value="${payroll.approvedAt}" pattern="dd/MM/yyyy HH:mm"/>)
                        </c:if>
                        <c:if test="${not empty payroll.paidByName}">
                            | Xác nhận chi bởi: <strong>${payroll.paidByName}</strong> (<fmt:formatDate value="${payroll.paidAt}" pattern="dd/MM/yyyy HH:mm"/>)
                        </c:if>
                        <c:if test="${payroll.status == 'APPROVED' || payroll.status == 'PAID'}">
                            <span style="margin-left: 12px; color: #ef4444; font-weight: 600; display: inline-flex; align-items: center; gap: 4px;" title="Bảng lương đã chốt và không thể chỉnh sửa">
                                <i class="fa-solid fa-lock"></i> Chế độ Chỉ Đọc (Read-Only)
                            </span>
                        </c:if>
                    </div>
                </div>
                <div style="display: flex; gap: 12px;">
                    <a href="${pageContext.request.contextPath}/admin/payrolls" class="btn btn-outline">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại
                    </a>
                    <c:if test="${payroll.status == 'DRAFT' && sessionScope.roleGroup == 'ADMIN'}">
                        <form action="${pageContext.request.contextPath}/admin/payroll/approve" method="post" style="margin: 0;">
                            <input type="hidden" name="id" value="${payroll.id}">
                            <input type="hidden" name="status" value="APPROVED">
                            <button type="submit" class="btn btn-success" onclick="return confirm('Bạn có chắc chắn muốn duyệt bảng lương này?');">
                                <i class="fa-solid fa-check"></i> Duyệt Bảng Lương
                            </button>
                        </form>
                    </c:if>
                    <c:if test="${payroll.status == 'APPROVED' && sessionScope.roleGroup == 'ADMIN'}">
                        <form action="${pageContext.request.contextPath}/admin/payroll/approve" method="post" style="margin: 0;">
                            <input type="hidden" name="id" value="${payroll.id}">
                            <input type="hidden" name="status" value="PAID">
                            <button type="submit" class="btn btn-primary" onclick="return confirm('Xác nhận đã chi trả thành công bảng lương này?');">
                                <i class="fa-solid fa-money-bill-wave"></i> Xác Nhận Chi Trả
                            </button>
                        </form>
                    </c:if>
                </div>
            </div>
            
            <div class="summary-cards">
                <div class="card">
                    <div class="card-title">Tổng Nhân Viên</div>
                    <div class="card-value">${payroll.totalEmployees}</div>
                </div>
                <div class="card">
                    <div class="card-title">Tổng Lương Thực Nhận (Net)</div>
                    <div class="card-value"><fmt:formatNumber value="${payroll.totalAmount}" pattern="#,##0"/> đ</div>
                </div>
                <!-- Additional summary cards could be calculated and displayed here -->
            </div>

            <div style="overflow-x: auto;">
                <table>
                    <thead>
                        <tr>
                            <th>Mã NV</th>
                            <th>Họ Tên</th>
                            <th>Phòng Ban</th>
                            <th class="text-right">Lương Cơ Bản</th>
                            <th class="text-right">Phụ Cấp (+)</th>
                            <th class="text-right">BHXH 8% (-)</th>
                            <th class="text-right">BHYT 1.5% (-)</th>
                            <th class="text-right">BHTN 1% (-)</th>
                            <th class="text-right">Nghỉ KL (-)</th>
                            <th class="text-right">Khấu Trừ Khác (-)</th>
                            <th class="text-right">Thực Nhận (NET)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${details}" var="d">
                            <tr>
                                <td><strong>${d.employeeCode}</strong></td>
                                <td>${d.employeeName}</td>
                                <td>${d.departmentName != null ? d.departmentName : '---'}</td>
                                <td class="text-right"><fmt:formatNumber value="${d.basicSalary}" pattern="#,##0"/></td>
                                <td class="text-right text-green">+<fmt:formatNumber value="${d.allowanceAmount}" pattern="#,##0"/></td>
                                <td class="text-right text-red">-<fmt:formatNumber value="${d.insuranceDeduction * 8 / 10.5}" pattern="#,##0"/></td>
                                <td class="text-right text-red">-<fmt:formatNumber value="${d.insuranceDeduction * 1.5 / 10.5}" pattern="#,##0"/></td>
                                <td class="text-right text-red">-<fmt:formatNumber value="${d.insuranceDeduction * 1 / 10.5}" pattern="#,##0"/></td>
                                <td class="text-right text-red">-<fmt:formatNumber value="${d.unpaidLeaveDeduction}" pattern="#,##0"/></td>
                                <td class="text-right text-red">-<fmt:formatNumber value="${d.taxDeduction}" pattern="#,##0"/></td>
                                <td class="text-right text-primary"><fmt:formatNumber value="${d.netSalary}" pattern="#,##0"/> đ</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</body>
</html>
