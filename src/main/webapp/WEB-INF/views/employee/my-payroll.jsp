<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<fmt:setLocale value="vi_VN"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Sử Lương Của Tôi | HRMS</title>
    
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
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        }

        th, td {
            padding: 16px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
            color: #1e293b;
            font-size: 14px;
        }

        th {
            background-color: #f8fafc;
            font-weight: 600;
            color: #475569;
            text-transform: uppercase;
            font-size: 13px;
            letter-spacing: 0.05em;
        }

        tr:last-child td {
            border-bottom: none;
        }

        .badge {
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .badge-draft { background: #fef3c7; color: #d97706; }
        .badge-approved { background: #e0e7ff; color: #4338ca; }
        .badge-paid { background: #dcfce7; color: #16a34a; }

        .payroll-period {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 600;
        }

        /* MODAL CSS (Standard Style) */
        .modal {
            display: none;
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5);
            align-items: center;
            justify-content: center;
            z-index: 1000;
        }
        
        .modal.active {
            display: flex;
        }

        .modal-content {
            background: #fff;
            border-radius: 12px;
            width: 500px;
            max-width: 90%;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        }

        .modal-header {
            padding: 16px 24px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-title {
            font-size: 18px;
            font-weight: 600;
            margin: 0;
            color: #0f172a;
        }

        .btn-close {
            background: none;
            border: none;
            font-size: 20px;
            cursor: pointer;
            color: #64748b;
        }

        .modal-body {
            padding: 24px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px dashed #e2e8f0;
        }
        .detail-row:last-child {
            border-bottom: none;
        }

        .detail-label {
            color: #475569;
            font-weight: 500;
        }

        .detail-value {
            font-weight: 600;
            color: #0f172a;
        }

        .val-plus { color: #16a34a; }
        .val-minus { color: #ef4444; }
        
        .total-row {
            margin-top: 16px;
            padding-top: 16px;
            border-top: 2px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .total-label {
            font-size: 16px;
            font-weight: 600;
            color: #0f172a;
        }

        .total-value {
            font-size: 20px;
            font-weight: 700;
            color: #4f46e5;
        }

        .modal-footer {
            padding: 16px 24px;
            background: #f8fafc;
            text-align: right;
            border-top: 1px solid #e2e8f0;
            border-radius: 0 0 12px 12px;
        }
    </style>
</head>
<body>
    <div class="main-layout">
        <%@include file="/WEB-INF/common/sidebar.jsp" %>

        <main class="content-area">
            <div class="page-header">
                <h1 class="page-title">Lịch Sử Lương Của Tôi</h1>
            </div>

            <c:choose>
                <c:when test="${empty details}">
                    <div style="background: #fff; padding: 40px; text-align: center; border-radius: 12px; color: #64748b; border: 1px solid #e2e8f0;">
                        <i class="fa-solid fa-receipt" style="font-size: 48px; margin-bottom: 16px; color: #cbd5e1;"></i>
                        <h3>Chưa có dữ liệu lương</h3>
                        <p>Hệ thống chưa ghi nhận kỳ lương nào của bạn.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                            <tr>
                                <th>Kỳ Lương</th>
                                <th>Trạng Thái</th>
                                <th style="text-align: right;">Lương Cơ Bản</th>
                                <th style="text-align: right;">Phụ Cấp</th>
                                <th style="text-align: right;">Khấu Trừ</th>
                                <th style="text-align: right;">Thực Lãnh</th>
                                <th style="text-align: center;">Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="d" items="${details}">
                                <tr>
                                    <td>
                                        <div class="payroll-period">
                                            <i class="fa-regular fa-calendar" style="color: #64748b;"></i>
                                            Tháng ${d.month} / ${d.year}
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${d.status == 'DRAFT'}"><span class="badge badge-draft">BẢN NHÁP</span></c:when>
                                            <c:when test="${d.status == 'APPROVED'}"><span class="badge badge-approved">ĐÃ CHỐT</span></c:when>
                                            <c:when test="${d.status == 'PAID'}"><span class="badge badge-paid">ĐÃ CHI TRẢ</span></c:when>
                                        </c:choose>
                                    </td>
                                    <td style="text-align: right; font-weight: 500;">
                                        <fmt:formatNumber value="${d.basicSalary}" pattern="#,##0"/> đ
                                    </td>
                                    <td style="text-align: right; font-weight: 500; color: #16a34a;">
                                        + <fmt:formatNumber value="${d.allowanceAmount}" pattern="#,##0"/> đ
                                    </td>
                                    <td style="text-align: right; font-weight: 500; color: #ef4444;">
                                        - <fmt:formatNumber value="${d.insuranceDeduction + d.taxDeduction + d.unpaidLeaveDeduction}" pattern="#,##0"/> đ
                                    </td>
                                    <td style="text-align: right; font-weight: 600; color: #0f172a;">
                                        <fmt:formatNumber value="${d.netSalary}" pattern="#,##0"/> đ
                                    </td>
                                    <td style="text-align: center;">
                                        <button type="button" class="btn btn-sm btn-outline" 
                                            onclick="openPayslipModal(${d.id}, '${d.status}', '${d.month}/${d.year}', ${d.basicSalary}, ${d.allowanceAmount}, ${d.insuranceDeduction}, ${d.taxDeduction}, ${d.unpaidLeaveDeduction}, ${d.netSalary})">
                                            <i class="fa-solid fa-eye"></i> Xem Chi Tiết
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </main>
    </div>

    <!-- STANDARD MODAL -->
    <div class="modal" id="payslipModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">Chi Tiết Phiếu Lương Tháng <span id="mPeriod"></span></h3>
                <button class="btn-close" onclick="closePayslipModal()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="modal-body">
                <div class="detail-row">
                    <span class="detail-label">Lương Cơ Bản</span>
                    <span class="detail-value" id="mBasic">0 đ</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Tổng Phụ Cấp</span>
                    <span class="detail-value val-plus" id="mAllow">+ 0 đ</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">BHXH (8%)</span>
                    <span class="detail-value val-minus" id="mBhxh">- 0 đ</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">BHYT (1.5%)</span>
                    <span class="detail-value val-minus" id="mBhyt">- 0 đ</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">BHTN (1%)</span>
                    <span class="detail-value val-minus" id="mBhtn">- 0 đ</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Khấu Trừ Khác</span>
                    <span class="detail-value val-minus" id="mTax">- 0 đ</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Nghỉ Không Phép (Trừ)</span>
                    <span class="detail-value val-minus" id="mUnpaid">- 0 đ</span>
                </div>
                
                <div class="total-row">
                    <span class="total-label">Thực Lãnh</span>
                    <span class="total-value" id="mNet">0 đ</span>
                </div>
            </div>
            <div class="modal-footer" style="display: flex; justify-content: flex-end; gap: 12px;">
                <a href="#" id="btnDownloadPdf" class="btn" style="background: #ef4444; color: white; display: none; text-decoration: none;">
                    <i class="fa-solid fa-file-pdf"></i> Download PDF
                </a>
                <button class="btn btn-outline" onclick="closePayslipModal()">Đóng</button>
            </div>
        </div>
    </div>

    <script>
        function formatVND(amount) {
            return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
        }

        function openPayslipModal(id, status, period, basic, allow, ins, tax, unpaid, net) {
            document.getElementById('mPeriod').innerText = period;
            document.getElementById('mBasic').innerText = formatVND(basic);
            document.getElementById('mAllow').innerText = '+ ' + formatVND(allow);
            document.getElementById('mBhxh').innerText = '- ' + formatVND(ins * 8 / 10.5);
            document.getElementById('mBhyt').innerText = '- ' + formatVND(ins * 1.5 / 10.5);
            document.getElementById('mBhtn').innerText = '- ' + formatVND(ins * 1 / 10.5);
            document.getElementById('mTax').innerText = '- ' + formatVND(tax);
            document.getElementById('mUnpaid').innerText = '- ' + formatVND(unpaid);
            document.getElementById('mNet').innerText = formatVND(net);

            var pdfBtn = document.getElementById('btnDownloadPdf');
            if (status === 'APPROVED' || status === 'PAID') {
                pdfBtn.style.display = 'inline-flex';
                pdfBtn.href = '${pageContext.request.contextPath}/luong/export-pdf?detailId=' + id;
            } else {
                pdfBtn.style.display = 'none';
                pdfBtn.href = '#';
            }

            document.getElementById('payslipModal').classList.add('active');
        }

        function closePayslipModal() {
            document.getElementById('payslipModal').classList.remove('active');
        }

        // Close when clicking outside
        window.onclick = function(event) {
            var modal = document.getElementById('payslipModal');
            if (event.target == modal) {
                closePayslipModal();
            }
        }
    </script>
</body>
</html>
