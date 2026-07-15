<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Lương Phòng Ban | HRMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css" />
    <style>
        .page-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; border-bottom:1px solid #e2e8f0; padding-bottom:16px; }
        .page-title-group .page-title { font-size:22px; font-weight:700; color:var(--text); margin:0; }
        .page-title-group .page-subtitle { font-size:13px; color:#64748b; margin-top:4px; }
        
        .summary-cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 24px; }
        .card { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid #f1f5f9; position: relative; overflow: hidden; }
        .card::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 4px; }
        .card-fund::before { background: #10b981; }
        .card-headcount::before { background: #3b82f6; }
        .card-average::before { background: #8b5cf6; }
        
        .card-title { font-size: 13px; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; }
        .card-value { font-size: 28px; font-weight: 700; color: #0f172a; }
        .card-icon { position: absolute; right: 20px; top: 50%; transform: translateY(-50%); font-size: 48px; opacity: 0.05; }
        .card-fund .card-icon { color: #10b981; }
        .card-headcount .card-icon { color: #3b82f6; }
        .card-average .card-icon { color: #8b5cf6; }

        .filter-bar { background:#f8fafc; padding:16px; border-radius:10px; margin-bottom:24px; border:1px solid #e2e8f0; display:flex; gap:16px; align-items:center; }
        .filter-bar select { padding:8px 12px; border:1px solid #cbd5e1; border-radius:6px; background:#fff; font-size:14px; color:#334155; flex:1; max-width:300px; outline:none; }
        .filter-bar select:focus { border-color:#3b82f6; box-shadow:0 0 0 3px rgba(59,130,246,0.1); }
        .btn { padding:8px 16px; border-radius:6px; font-weight:500; cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:8px; border:none; font-size:14px; background:#3b82f6; color:#fff; transition:all 0.2s; }
        .btn:hover { background:#2563eb; }

        .table-container { background:#fff; border-radius:12px; box-shadow:0 1px 3px 0 rgba(0,0,0,0.1), 0 1px 2px 0 rgba(0,0,0,0.06); overflow:hidden; border:1px solid #e2e8f0; }
        .data-table { width:100%; border-collapse:collapse; }
        .data-table th { background:#f8fafc; padding:12px 16px; text-align:left; font-size:12px; font-weight:600; color:#475569; text-transform:uppercase; letter-spacing:0.5px; border-bottom:1px solid #e2e8f0; }
        .data-table td { padding:14px 16px; border-bottom:1px solid #f1f5f9; font-size:14px; color:#334155; vertical-align:middle; }
        .data-table tr:hover { background:#f8fafc; }
        
        .currency { font-weight:600; color:#0f172a; font-family:monospace; font-size:15px; }
        .currency.positive { color:#059669; }
        .currency.negative { color:#dc2626; }

        .btn-icon { background:transparent; border:none; color:#64748b; cursor:pointer; padding:8px; border-radius:6px; transition:all 0.2s; }
        .btn-icon:hover { background:#f1f5f9; color:#4f46e5; }
        
        .badge { padding:6px 14px; border-radius:20px; font-size:12px; font-weight:600; display:inline-flex; align-items: center; gap: 6px; }
        .badge-yellow { background:#fef3c7; color:#92400e; border: 1px solid #fde68a; }
        .badge-green { background:#d1fae5; color:#065f46; border: 1px solid #a7f3d0; }
        .badge-blue { background:#dbeafe; color:#1e3a8a; border: 1px solid #bfdbfe; }
        
        .btn-approve { padding:8px 16px; border-radius:8px; font-weight:600; cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:8px; border:none; font-size:13px; background:#10b981; color:#fff; transition: all 0.2s; box-shadow: 0 2px 4px rgba(16, 185, 129, 0.2); }
        .btn-approve:hover { background:#059669; transform: translateY(-1px); box-shadow: 0 4px 6px rgba(16, 185, 129, 0.3); }

        .empty-state { text-align: center; padding: 60px 20px; color: #64748b; }
        .empty-state i { font-size: 48px; color: #cbd5e1; margin-bottom: 16px; }
        .empty-state h3 { font-size: 18px; font-weight: 600; color: #334155; margin: 0 0 8px 0; }
        .empty-state p { margin: 0; font-size: 14px; }
        
        /* Modal Styles */
        .modal { display:none; position:fixed; z-index:1000; left:0; top:0; width:100%; height:100%; overflow:auto; background-color:rgba(0,0,0,0.4); backdrop-filter:blur(4px); }
        .modal-content { background-color:#fff; margin:5% auto; border-radius:12px; box-shadow:0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04); width:90%; max-width:600px; animation:modalSlideIn 0.3s ease-out; }
        @keyframes modalSlideIn { from { transform:translateY(-20px); opacity:0; } to { transform:translateY(0); opacity:1; } }
        .modal-header { padding:20px 24px; border-bottom:1px solid #e2e8f0; display:flex; justify-content:space-between; align-items:center; }
        .modal-title { margin:0; font-size:18px; font-weight:600; color:#0f172a; }
        .close { color:#94a3b8; font-size:24px; font-weight:bold; cursor:pointer; transition:color 0.2s; line-height:1; }
        .close:hover { color:#0f172a; }
        .modal-body { padding:24px; }
        .info-grid { display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-bottom:24px; background:#f8fafc; padding:16px; border-radius:8px; border:1px solid #e2e8f0; }
        .info-item { display:flex; flex-direction:column; gap:4px; }
        .info-label { font-size:12px; color:#64748b; font-weight:600; text-transform:uppercase; letter-spacing:0.5px; }
        .info-value { font-size:14px; color:#0f172a; font-weight:500; }
        .salary-breakdown { border:1px solid #e2e8f0; border-radius:8px; overflow:hidden; }
        .breakdown-row { display:flex; justify-content:space-between; padding:12px 16px; border-bottom:1px solid #e2e8f0; }
        .breakdown-row:last-child { border-bottom:none; }
        .breakdown-row.total { background:#f8fafc; font-weight:700; color:#0f172a; font-size:16px; }
        .modal-footer { padding:16px 24px; border-top:1px solid #e2e8f0; display:flex; justify-content:flex-end; }
        .btn-secondary { background:#f1f5f9; color:#475569; padding:8px 16px; border-radius:6px; font-weight:500; border:none; cursor:pointer; transition:all 0.2s; }
        .btn-secondary:hover { background:#e2e8f0; color:#0f172a; }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/common/sidebar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div class="page-title-group">
                <h1 class="page-title">Quỹ Lương Phòng Ban</h1>
                <p class="page-subtitle">Tổng quan ngân sách và chi tiết lương từng nhân sự trong phòng ban</p>
            </div>
            
            <c:if test="${not empty selectedPayroll}">
                <div class="header-actions">
                    <c:choose>
                        <c:when test="${selectedPayroll.status eq 'DRAFT'}">
                            <span class="badge badge-yellow"><i class="fas fa-edit"></i> Bản nháp - Chờ duyệt</span>
                            <form action="${pageContext.request.contextPath}/manager/department-payroll/approve" method="post" style="margin:0;">
                                <input type="hidden" name="payrollId" value="${selectedPayroll.id}">
                                <button type="submit" class="btn-approve" onclick="return confirm('Bạn xác nhận duyệt bảng lương tháng ${selectedPayroll.month}/${selectedPayroll.year} của phòng ban? Sau khi duyệt sẽ chuyển sang HR xử lý.')">
                                    <i class="fas fa-check-circle"></i> Duyệt Bảng Lương
                                </button>
                            </form>
                        </c:when>
                        <c:when test="${selectedPayroll.status eq 'MANAGER_CONFIRMED'}">
                            <span class="badge badge-blue"><i class="fas fa-user-check"></i> Đã duyệt (Chờ HR chốt)</span>
                        </c:when>
                        <c:when test="${selectedPayroll.status eq 'HR_FINALIZED'}">
                            <span class="badge badge-green"><i class="fas fa-check-double"></i> Đã chốt</span>
                        </c:when>
                    </c:choose>
                </div>
            </c:if>
        </div>

        <c:if test="${param.success eq 'approved'}">
            <div style="background:#d1fae5; color:#065f46; padding:12px 16px; border-radius:8px; margin-bottom:20px; font-weight:500;">
                <i class="fas fa-check-circle" style="margin-right:8px;"></i> Duyệt bảng lương thành công!
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div style="background:#fee2e2; color:#991b1b; padding:12px 16px; border-radius:8px; margin-bottom:20px; font-weight:500;">
                <i class="fas fa-exclamation-circle" style="margin-right:8px;"></i> Có lỗi xảy ra: ${param.error}
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty payrolls}">
                <div class="table-container empty-state">
                    <i class="fas fa-folder-open"></i>
                    <h3>Chưa có dữ liệu bảng lương</h3>
                    <p>Hiện tại hệ thống chưa có bảng lương nào được tạo cho phòng ban của bạn.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="filter-bar">
                    <form action="${pageContext.request.contextPath}/manager/department-payroll" method="get" style="display:flex; width:100%; gap:16px;">
                        <select name="payrollId" onchange="this.form.submit()">
                            <c:forEach var="p" items="${payrolls}">
                                <option value="${p.id}" ${selectedPayroll != null && p.id == selectedPayroll.id ? 'selected' : ''}>
                                    Tháng ${p.month}/${p.year} - ${p.status eq 'DRAFT' ? 'Bản Nháp' : (p.status eq 'MANAGER_CONFIRMED' ? 'Đã duyệt' : 'Đã chốt')}
                                </option>
                            </c:forEach>
                        </select>
                        <button type="submit" class="btn"><i class="fas fa-filter"></i> Xem báo cáo</button>
                    </form>
                </div>

                <c:if test="${not empty details}">
                    <div class="summary-cards">
                        <div class="card card-fund">
                            <i class="fas fa-coins card-icon"></i>
                            <div class="card-title">Tổng Quỹ Lương (Thực nhận)</div>
                            <div class="card-value"><fmt:formatNumber value="${totalFund}" type="number" maxFractionDigits="0"/> đ</div>
                        </div>
                        <div class="card card-headcount">
                            <i class="fas fa-users card-icon"></i>
                            <div class="card-title">Số Lượng Nhân Sự</div>
                            <div class="card-value">${headcount} người</div>
                        </div>
                        <div class="card card-average">
                            <i class="fas fa-chart-pie card-icon"></i>
                            <div class="card-title">Lương Trung Bình / Người</div>
                            <div class="card-value"><fmt:formatNumber value="${averageSalary}" type="number" maxFractionDigits="0"/> đ</div>
                        </div>
                    </div>

                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>MNV</th>
                                    <th>Họ và Tên</th>
                                    <th>Ngày Công</th>
                                    <th style="text-align:right">Lương Cơ Bản</th>
                                    <th style="text-align:right">Tổng Phụ Cấp</th>
                                    <th style="text-align:right">Khấu Trừ</th>
                                    <th style="text-align:right">Thực Nhận</th>
                                    <th style="text-align:center">Chi Tiết</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="d" items="${details}">
                                    <tr>
                                        <td style="font-weight:600; color:#4f46e5;">EMP${d.employeeId}</td>
                                        <td>
                                            <div style="font-weight:600;">${d.employeeName}</div>
                                            <div style="font-size:12px; color:#64748b;">${d.positionName}</div>
                                        </td>
                                        <td>${d.actualWorkedDays} ngày</td>
                                        <td style="text-align:right" class="currency"><fmt:formatNumber value="${d.basicSalary}" type="number" maxFractionDigits="0"/></td>
                                        <td style="text-align:right" class="currency positive">+<fmt:formatNumber value="${d.allowanceAmount}" type="number" maxFractionDigits="0"/></td>
                                        <td style="text-align:right" class="currency negative">-<fmt:formatNumber value="${d.insuranceDeduction}" type="number" maxFractionDigits="0"/></td>
                                        <td style="text-align:right; font-size:16px;" class="currency positive"><fmt:formatNumber value="${d.netSalary}" type="number" maxFractionDigits="0"/> đ</td>
                                        <td style="text-align:center">
                                            <button class="btn-icon" onclick="viewSalaryDetail(this)"
                                                data-emp-id="EMP${d.employeeId}"
                                                data-emp-name="${d.employeeName}"
                                                data-position="${d.positionName}"
                                                data-dept="${selectedPayroll.month}/${selectedPayroll.year}"
                                                data-working-days="${d.actualWorkedDays}"
                                                data-basic="${d.basicSalary}"
                                                data-total-allowance="${d.allowanceAmount}"
                                                data-overtime="${d.overtimePay}"
                                                data-total-deduction="${d.insuranceDeduction}"
                                                data-net="${d.netSalary}">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>
            </c:otherwise>
        </c:choose>

        <!-- Modal Detail -->
        <div id="salaryModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2 class="modal-title">Chi Tiết Lương <span id="modalEmpName" style="color:#3b82f6;"></span></h2>
                    <span class="close" onclick="closeModal()">&times;</span>
                </div>
                <div class="modal-body">
                    <div class="info-grid">
                        <div class="info-item">
                            <span class="info-label">Kỳ Lương</span>
                            <span class="info-value" id="modalPeriod"></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Mã Nhân Viên</span>
                            <span class="info-value" id="modalEmpId"></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Vị Trí</span>
                            <span class="info-value" id="modalPosition"></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Ngày Công Thực Tế</span>
                            <span class="info-value"><span id="modalDays"></span> ngày</span>
                        </div>
                    </div>
                    
                    <div class="salary-breakdown">
                        <div class="breakdown-row">
                            <span style="color:#475569;">Lương Cơ Bản</span>
                            <span class="currency" id="modalBasic"></span>
                        </div>
                        <div class="breakdown-row">
                            <span style="color:#475569;">Tổng Phụ Cấp</span>
                            <span class="currency positive">+<span id="modalAllowance"></span></span>
                        </div>
                        <div class="breakdown-row">
                            <span style="color:#475569;">Lương Tăng Ca</span>
                            <span class="currency positive">+<span id="modalOvertime"></span></span>
                        </div>
                        <div class="breakdown-row">
                            <span style="color:#475569;">Tổng Khấu Trừ (Thuế, BH)</span>
                            <span class="currency negative">-<span id="modalDeduction"></span></span>
                        </div>
                        <div class="breakdown-row total">
                            <span>Thực Nhận</span>
                            <span class="currency positive" id="modalNet"></span>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn-secondary" onclick="closeModal()">Đóng</button>
                </div>
            </div>
        </div>
    </main>

    <script>
        function formatVND(amount) {
            return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
        }

        function viewSalaryDetail(btn) {
            document.getElementById('modalEmpName').textContent = btn.dataset.empName;
            document.getElementById('modalPeriod').textContent = 'Tháng ' + btn.dataset.dept;
            document.getElementById('modalEmpId').textContent = btn.dataset.empId;
            document.getElementById('modalPosition').textContent = btn.dataset.position;
            document.getElementById('modalDays').textContent = btn.dataset.workingDays;
            
            document.getElementById('modalBasic').textContent = formatVND(btn.dataset.basic);
            document.getElementById('modalAllowance').textContent = formatVND(btn.dataset.totalAllowance);
            document.getElementById('modalOvertime').textContent = formatVND(btn.dataset.overtime);
            document.getElementById('modalDeduction').textContent = formatVND(btn.dataset.totalDeduction);
            document.getElementById('modalNet').textContent = formatVND(btn.dataset.net);
            
            document.getElementById('salaryModal').style.display = 'block';
        }

        function closeModal() {
            document.getElementById('salaryModal').style.display = 'none';
        }

        window.onclick = function(event) {
            var modal = document.getElementById('salaryModal');
            if (event.target == modal) {
                modal.style.display = "none";
            }
        }
    </script>
</body>
</html>