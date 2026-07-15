<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <fmt:setLocale value="vi_VN" />

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
                        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
                    }

                    th,
                    td {
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

                    .badge-draft {
                        background: #fef3c7;
                        color: #d97706;
                    }

                    .badge-approved {
                        background: #e0e7ff;
                        color: #4338ca;
                    }

                    .badge-paid {
                        background: #dcfce7;
                        color: #16a34a;
                    }

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
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                        background: rgba(0, 0, 0, 0.5);
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
                        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
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

                    .val-plus {
                        color: #16a34a;
                    }

                    .val-minus {
                        color: #ef4444;
                    }

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

                    /* NEW PAYSLIP UI CSS */
                    .payslip-container {
                        padding: 30px 40px;
                        background: #fff;
                        color: #1e293b;
                        font-family: 'Segoe UI', Arial, sans-serif;
                        max-height: 80vh;
                        overflow-y: auto;
                    }
                    .payslip-header {
                        border-bottom: 2px solid #e2e8f0;
                        padding-bottom: 15px;
                        margin-bottom: 20px;
                    }
                    .payslip-header h1 {
                        font-size: 28px;
                        font-weight: 800;
                        margin: 0 0 5px 0;
                        color: #4f46e5;
                        text-transform: uppercase;
                        letter-spacing: -0.5px;
                    }
                    .payslip-header p {
                        font-size: 16px;
                        font-weight: 600;
                        color: #64748b;
                        margin: 0;
                        text-transform: uppercase;
                    }
                    
                    .emp-info-grid {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 15px 40px;
                        margin-bottom: 25px;
                    }
                    .emp-info-row {
                        display: flex;
                        justify-content: space-between;
                        border-bottom: 1px solid #e2e8f0;
                        padding-bottom: 6px;
                        margin-top: 12px;
                    }
                    .emp-info-row:first-child {
                        margin-top: 0;
                    }
                    .emp-info-label {
                        color: #64748b;
                        font-size: 13px;
                        text-transform: uppercase;
                    }
                    .emp-info-value {
                        font-weight: 600;
                        font-size: 14px;
                        color: #0f172a;
                    }
                    
                    .details-grid {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 30px;
                        margin-bottom: 30px;
                    }
                    .payslip-col-header {
                        background: #f8fafc;
                        color: #475569;
                        padding: 10px 15px;
                        font-weight: 600;
                        font-size: 14px;
                        text-transform: uppercase;
                        margin-bottom: 10px;
                        border-radius: 6px;
                        border: 1px solid #e2e8f0;
                    }
                    .payslip-col-header.deduction {
                        background: #f8fafc;
                        color: #475569;
                        border: 1px solid #e2e8f0;
                    }
                    .payslip-row {
                        display: flex;
                        justify-content: space-between;
                        padding: 10px 5px;
                        border-bottom: 1px dashed #cbd5e1;
                        font-size: 14px;
                    }
                    .payslip-row .val-minus {
                        color: #ef4444;
                        font-weight: 600;
                    }
                    .payslip-total-row {
                        display: flex;
                        justify-content: space-between;
                        padding: 12px 5px;
                        font-weight: 700;
                        font-size: 16px;
                        color: #0f172a;
                        text-transform: uppercase;
                        border-top: 2px solid #e2e8f0;
                        margin-top: 4px;
                    }
                    .payslip-total-row .val-minus {
                        color: #ef4444;
                    }
                    
                    .net-pay-box {
                        border: 2px solid #cbd5e1;
                        border-radius: 12px;
                        background: #f8fafc;
                        padding: 20px 30px;
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        margin-bottom: 30px;
                        position: relative;
                        overflow: hidden;
                    }
                    .net-pay-bg {
                        position: absolute;
                        font-size: 120px;
                        color: #e2e8f0;
                        left: 20px;
                        top: 50%;
                        transform: translateY(-50%);
                        z-index: 1;
                        font-weight: 800;
                        font-family: serif;
                        opacity: 0.5;
                    }
                    .net-pay-content {
                        position: relative;
                        z-index: 2;
                        display: flex;
                        justify-content: space-between;
                        width: 100%;
                        align-items: center;
                    }
                    .net-pay-label {
                        font-weight: 700;
                        color: #475569;
                        font-size: 14px;
                        letter-spacing: 1px;
                    }
                    .net-pay-words {
                        font-style: italic;
                        color: #64748b;
                        font-size: 13px;
                        margin-top: 4px;
                    }
                    .net-pay-amount {
                        font-size: 32px;
                        font-weight: 900;
                        color: #4f46e5;
                    }
                    .net-pay-currency {
                        font-size: 16px;
                        font-weight: 700;
                        color: #4f46e5;
                    }
                    
                    .payslip-footer-notes {
                        display: flex;
                        justify-content: space-between;
                        font-size: 12px;
                        color: #64748b;
                    }
                    .payslip-footer-notes .note {
                        font-style: italic;
                        max-width: 60%;
                    }
                    .payslip-footer-notes .date {
                        text-transform: uppercase;
                        font-weight: 500;
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
                                    <div
                                        style="background: #fff; padding: 40px; text-align: center; border-radius: 12px; color: #64748b; border: 1px solid #e2e8f0;">
                                        <i class="fa-solid fa-receipt"
                                            style="font-size: 48px; margin-bottom: 16px; color: #cbd5e1;"></i>
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
                                                            <i class="fa-regular fa-calendar"
                                                                style="color: #64748b;"></i>
                                                            Tháng ${d.month} / ${d.year}
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${d.status == 'DRAFT'}"><span
                                                                    class="badge badge-draft">BẢN NHÁP</span></c:when>
                                                            <c:when test="${d.status == 'APPROVED'}"><span
                                                                    class="badge badge-approved">ĐÃ CHỐT</span></c:when>
                                                            <c:when test="${d.status == 'PAID'}"><span
                                                                    class="badge badge-paid">ĐÃ CHI TRẢ</span></c:when>
                                                        </c:choose>
                                                    </td>
                                                    <td style="text-align: right; font-weight: 500;">
                                                        <fmt:formatNumber value="${d.basicSalary}" pattern="#,##0" /> đ
                                                    </td>
                                                    <td style="text-align: right; font-weight: 500; color: #16a34a;">
                                                        +
                                                        <fmt:formatNumber value="${d.allowanceAmount}"
                                                            pattern="#,##0" /> đ
                                                    </td>
                                                    <td style="text-align: right; font-weight: 500; color: #ef4444;">
                                                        -
                                                        <fmt:formatNumber
                                                            value="${d.insuranceDeduction + d.taxDeduction + d.unpaidLeaveDeduction}"
                                                            pattern="#,##0" /> đ
                                                    </td>
                                                    <td style="text-align: right; font-weight: 600; color: #0f172a;">
                                                        <fmt:formatNumber value="${d.netSalary}" pattern="#,##0" /> đ
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <button type="button" class="btn btn-sm btn-outline"
                                                            onclick="openPayslipModal(${d.id}, '${d.status}', '${d.month}/${d.year}', ${d.basicSalary}, ${d.allowanceAmount}, ${d.insuranceDeduction}, ${d.taxDeduction}, ${d.unpaidLeaveDeduction}, ${d.netSalary}, ${d.standardDays}, ${d.actualWorkedDays})">
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

                <!-- MOCKUP STYLE PAYSLIP MODAL -->
                <div class="modal" id="payslipModal">
                    <div class="modal-content" style="width: 850px; max-width: 95%;">
                        <div class="modal-header" style="background: #f8fafc; padding: 12px 24px;">
                            <h3 class="modal-title" style="font-size: 16px;">Chi Tiết Phiếu Lương</h3>
                            <div style="display: flex; gap: 10px;">
                                <a href="#" id="btnDownloadPdf" class="btn btn-sm"
                                    style="background: #ef4444; color: white; display: none; text-decoration: none;">
                                    <i class="fa-solid fa-file-pdf"></i> Download PDF
                                </a>
                                <button class="btn-close" onclick="closePayslipModal()"><i
                                        class="fa-solid fa-xmark"></i></button>
                            </div>
                        </div>
                        
                        <div class="payslip-container">
                            <div class="payslip-header">
                                <h1>PHIẾU LƯƠNG NHÂN VIÊN</h1>
                                <p>KỲ LƯƠNG: THÁNG <span id="mPeriod"></span></p>
                            </div>
                            
                            <div class="emp-info-grid">
                                <div>
                                    <div class="emp-info-row">
                                        <span class="emp-info-label">HỌ VÀ TÊN:</span>
                                        <span class="emp-info-value">${sessionScope.user.fullName != null ? sessionScope.user.fullName : 'NGUYỄN VĂN AN'}</span>
                                    </div>
                                    <div class="emp-info-row">
                                        <span class="emp-info-label">MÃ NHÂN VIÊN:</span>
                                        <span class="emp-info-value">NV${sessionScope.user.id != null ? String.format("%03d", sessionScope.user.id) : '001'}</span>
                                    </div>
                                    <div class="emp-info-row">
                                        <span class="emp-info-label">PHÒNG BAN:</span>
                                        <span class="emp-info-value">${sessionScope.user.departmentName != null ? sessionScope.user.departmentName : 'Phòng Công Nghệ'}</span>
                                    </div>
                                </div>
                                <div>
                                    <div class="emp-info-row">
                                        <span class="emp-info-label">VỊ TRÍ:</span>
                                        <span class="emp-info-value">${sessionScope.user.positionName != null ? sessionScope.user.positionName : 'Senior Developer'}</span>
                                    </div>
                                    <div class="emp-info-row">
                                        <span class="emp-info-label">NGÀY CÔNG CHUẨN:</span>
                                        <span class="emp-info-value" id="mStandardDays">0</span>
                                    </div>
                                    <div class="emp-info-row">
                                        <span class="emp-info-label">NGÀY CÔNG THỰC TẾ:</span>
                                        <span class="emp-info-value" id="mActualDays">0</span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="details-grid">
                                <div>
                                    <div class="payslip-col-header">CÁC KHOẢN THU NHẬP</div>
                                    <div class="payslip-row">
                                        <span>Lương cơ bản</span>
                                        <span id="mBasic">0</span>
                                    </div>
                                    <div class="payslip-row">
                                        <span>Phụ cấp / Thưởng</span>
                                        <span id="mAllow">0</span>
                                    </div>
                                    
                                    <div style="height: 145px;"></div>
                                    
                                    <div class="payslip-total-row">
                                        <span>TỔNG THU NHẬP</span>
                                        <span id="mTotalIncome">0</span>
                                    </div>
                                </div>
                                
                                <div>
                                    <div class="payslip-col-header deduction">CÁC KHOẢN KHẤU TRỪ</div>
                                    <div class="payslip-row">
                                        <span>BHXH (8%)</span>
                                        <span class="val-minus" id="mBhxh">-0</span>
                                    </div>
                                    <div class="payslip-row">
                                        <span>BHYT (1.5%)</span>
                                        <span class="val-minus" id="mBhyt">-0</span>
                                    </div>
                                    <div class="payslip-row">
                                        <span>BHTN (1%)</span>
                                        <span class="val-minus" id="mBhtn">-0</span>
                                    </div>
                                    <div class="payslip-row">
                                        <span>Thuế TNCN</span>
                                        <span class="val-minus" id="mTax">-0</span>
                                    </div>
                                    <div class="payslip-row">
                                        <span>Nghỉ không phép</span>
                                        <span class="val-minus" id="mUnpaid">-0</span>
                                    </div>
                                    <div class="payslip-row">
                                        <span>Tạm ứng lương</span>
                                        <span class="val-minus">-0</span>
                                    </div>
                                    
                                    <div class="payslip-total-row">
                                        <span>TỔNG KHẤU TRỪ</span>
                                        <span class="val-minus" id="mTotalDeduct">-0</span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="net-pay-box">
                                <div class="net-pay-bg">$</div>
                                <div class="net-pay-content">
                                    <div>
                                        <div class="net-pay-label">SỐ TIỀN THỰC NHẬN</div>
                                        <div class="net-pay-words">Số tiền được tính dựa trên công và các khoản phụ cấp, khấu trừ.</div>
                                    </div>
                                    <div>
                                        <span class="net-pay-amount" id="mNet">0</span>
                                        <span class="net-pay-currency"> VNĐ</span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="payslip-footer-notes">
                                <div class="note">* Mọi thắc mắc về phiếu lương vui lòng phản hồi với phòng Nhân sự trong vòng 48h kể từ khi nhận được phiếu này.</div>
                                <div class="date" id="mIssueDate">NGÀY PHÁT HÀNH: --/--/----</div>
                            </div>
                        </div>
                    </div>
                </div>

                <script>
                    function formatVND(amount) {
                        return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
                    }

                    function formatNumberOnly(amount) {
                        return new Intl.NumberFormat('vi-VN').format(amount);
                    }

                    function openPayslipModal(id, status, period, basic, allow, ins, tax, unpaid, net, stdDays, actDays) {
                        document.getElementById('mPeriod').innerText = period;
                        document.getElementById('mStandardDays').innerText = stdDays;
                        document.getElementById('mActualDays').innerText = actDays;
                        document.getElementById('mBasic').innerText = formatNumberOnly(basic);
                        document.getElementById('mAllow').innerText = formatNumberOnly(allow);
                        
                        document.getElementById('mBhxh').innerText = '-' + formatNumberOnly(ins * 8 / 10.5);
                        document.getElementById('mBhyt').innerText = '-' + formatNumberOnly(ins * 1.5 / 10.5);
                        document.getElementById('mBhtn').innerText = '-' + formatNumberOnly(ins * 1 / 10.5);
                        document.getElementById('mTax').innerText = '-' + formatNumberOnly(tax);
                        document.getElementById('mUnpaid').innerText = '-' + formatNumberOnly(unpaid);
                        
                        let totalIncome = basic + allow;
                        let totalDeduct = ins + tax + unpaid;
                        document.getElementById('mTotalIncome').innerText = formatNumberOnly(totalIncome);
                        document.getElementById('mTotalDeduct').innerText = '-' + formatNumberOnly(totalDeduct);

                        document.getElementById('mNet').innerText = formatNumberOnly(net);
                        
                        let today = new Date();
                        document.getElementById('mIssueDate').innerText = 'NGÀY PHÁT HÀNH: ' + today.toLocaleDateString('en-GB');

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
                    window.onclick = function (event) {
                        var modal = document.getElementById('payslipModal');
                        if (event.target == modal) {
                            closePayslipModal();
                        }
                    }
                </script>
            </body>

            </html>