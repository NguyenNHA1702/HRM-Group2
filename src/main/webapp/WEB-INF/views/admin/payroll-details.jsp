<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Chi Tiết Bảng Lương | HRMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css" />
    <style>
        .page-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; border-bottom:1px solid #e2e8f0; padding-bottom:16px; }
        .page-title-group .page-title { font-size:22px; font-weight:700; color:var(--text); margin:0; }
        .page-title-group .page-subtitle { font-size:13px; color:#64748b; margin-top:4px; }
        .header-actions { display:flex; gap:12px; align-items:center; }
        .btn { padding:10px 18px; border-radius:8px; font-weight:600; cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:8px; border:none; font-size:14px; }
        .btn-primary { background:#4f46e5; color:#fff; }
        .btn-primary:hover { background:#4338ca; }
        .btn-success { background:#059669; color:#fff; }
        .btn-success:hover { background:#047857; }
        .btn-warning { background:#d97706; color:#fff; }
        .btn-warning:hover { background:#b45309; }
        .btn-outline { background:transparent; border:1px solid #cbd5e1; color:#475569; }
        .btn-outline:hover { background:#f8fafc; }
        .btn-sm { padding:6px 12px; font-size:13px; }

        /* Status badges */
        .badge { padding:4px 12px; border-radius:20px; font-size:12px; font-weight:600; display:inline-block; }
        .badge-yellow { background:#fef3c7; color:#92400e; }
        .badge-blue { background:#dbeafe; color:#1e40af; }
        .badge-green { background:#d1fae5; color:#065f46; }
        .badge-gray { background:#f1f5f9; color:#475569; }

        /* Filter bar */
        .filter-bar { display:flex; gap:16px; align-items:center; margin-bottom:24px; padding:16px; background:#f8fafc; border-radius:12px; border:1px solid #e2e8f0; }
        .filter-bar label { font-weight:600; font-size:13px; color:#475569; }
        .filter-bar select { padding:8px 12px; border-radius:8px; border:1px solid #cbd5e1; font-size:14px; min-width:200px; }

        /* Payroll info card */
        .payroll-info { display:grid; grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); gap:16px; margin-bottom:24px; }
        .info-card { background:#fff; border:1px solid #e2e8f0; border-radius:12px; padding:16px; }
        .info-card .label { font-size:12px; color:#64748b; text-transform:uppercase; font-weight:600; margin-bottom:4px; }
        .info-card .value { font-size:18px; font-weight:700; color:#0f172a; }

        /* 3 Blocks layout */
        .blocks-container { display:flex; flex-direction:column; gap:24px; }
        .payroll-block { background:#fff; border:1px solid #e2e8f0; border-radius:12px; overflow:hidden; }
        .block-header { padding:16px 20px; border-bottom:1px solid #e2e8f0; display:flex; align-items:center; gap:12px; }
        .block-header .block-icon { width:36px; height:36px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:16px; color:#fff; }
        .block-header .block-title { font-size:16px; font-weight:700; color:#0f172a; }
        .block-header .block-subtitle { font-size:12px; color:#64748b; }
        .block-1 .block-icon { background:linear-gradient(135deg, #3b82f6, #1d4ed8); }
        .block-2 .block-icon { background:linear-gradient(135deg, #8b5cf6, #6d28d9); }
        .block-3 .block-icon { background:linear-gradient(135deg, #10b981, #059669); }

        /* Table styles */
        .data-table { width:100%; border-collapse:collapse; font-size:13px; }
        .data-table th { background:#f8fafc; padding:10px 14px; text-align:left; font-weight:600; color:#475569; border-bottom:2px solid #e2e8f0; white-space:nowrap; }
        .data-table td { padding:10px 14px; border-bottom:1px solid #f1f5f9; color:#334155; }
        .data-table tr:hover { background:#f8fafc; }
        .data-table .text-right { text-align:right; }
        .data-table .text-center { text-align:center; }
        .data-table .amount { font-family:'Roboto Mono', monospace; font-weight:600; }
        .data-table .amount-positive { color:#059669; }
        .data-table .amount-negative { color:#dc2626; }

        /* Approval flow */
        .approval-flow { display:flex; align-items:center; gap:8px; margin-bottom:24px; padding:16px; background:#f8fafc; border-radius:12px; border:1px solid #e2e8f0; flex-wrap:wrap; }
        .flow-step { padding:8px 16px; border-radius:20px; font-size:13px; font-weight:600; }
        .flow-step.active { background:#4f46e5; color:#fff; }
        .flow-step.done { background:#d1fae5; color:#065f46; }
        .flow-step.pending { background:#f1f5f9; color:#94a3b8; }
        .flow-arrow { color:#94a3b8; font-size:16px; }

        /* Summary row */
        .summary-row { background:#f0f9ff !important; font-weight:700; }
        .summary-row td { border-top:2px solid #3b82f6; }

        /* Responsive */
        .table-wrapper { overflow-x:auto; }

        /* Alert */
        .alert { padding:12px 16px; border-radius:8px; margin-bottom:16px; font-size:14px; }
        .alert-success { background:#d1fae5; color:#065f46; border:1px solid #6ee7b7; }
        .alert-error { background:#fee2e2; color:#991b1b; border:1px solid #fca5a5; }

        /* Pagination */
        .pagination-container { display: flex; justify-content: flex-end; align-items: center; padding: 16px; gap: 8px; border-top: 1px solid #e2e8f0; background: #fff; border-bottom-left-radius: 12px; border-bottom-right-radius: 12px;}
        .page-btn { padding: 6px 12px; border: 1px solid #cbd5e1; background: #fff; color: #475569; border-radius: 6px; cursor: pointer; font-size: 13px; font-weight: 600; transition: all 0.2s; }
        .page-btn:hover { background: #f8fafc; border-color: #94a3b8; }
        .page-btn.active { background: #4f46e5; color: #fff; border-color: #4f46e5; }
        .page-info { font-size: 13px; color: #64748b; margin-right: 16px; }
    </style>
</head>
<body>
<div class="main-layout">
    <jsp:include page="/WEB-INF/common/sidebar.jsp" />
    <main class="content-area">

            <!-- Success/Error messages -->
            <c:if test="${param.success != null}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i>
                    <c:choose>
                        <c:when test="${param.success == 'confirmed'}">Manager đã xác nhận bảng lương thành công!</c:when>
                        <c:when test="${param.success == 'finalized'}">HR đã chốt lương thành công!</c:when>
                        <c:otherwise>Thao tác thành công!</c:otherwise>
                    </c:choose>
                </div>
            </c:if>
            <c:if test="${param.error != null}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    <c:choose>
                        <c:when test="${param.error == 'approve_failed'}">Không thể duyệt bảng lương. Kiểm tra trạng thái hiện tại.</c:when>
                        <c:otherwise>Có lỗi xảy ra.</c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <!-- Header -->
            <div class="page-header">
                <div class="page-title-group">
                    <h1 class="page-title">Bảng Lương Tháng ${payroll.month}/${payroll.year}</h1>
                    <p class="page-subtitle">
                        <span class="badge ${payroll.statusBadgeClass}">${payroll.statusLabel}</span>
                        &nbsp; ${payroll.totalEmployees} nhân viên
                    </p>
                </div>
                <div class="header-actions">
                    <a href="${pageContext.request.contextPath}/admin/payrolls" class="btn btn-outline btn-sm">
                        <i class="fas fa-arrow-left"></i> Quay lại
                    </a>

                    <!-- Approval buttons based on role and status -->
                    <c:if test="${payroll.status == 'DRAFT' && roleGroup == 'MANAGER'}">
                        <form action="${pageContext.request.contextPath}/admin/payroll/approve" method="post" style="display:inline;">
                            <input type="hidden" name="id" value="${payroll.id}" />
                            <input type="hidden" name="status" value="MANAGER_CONFIRMED" />
                            <button type="submit" class="btn btn-warning btn-sm" onclick="return confirm('Xác nhận bảng lương cho phòng ban?')">
                                <i class="fas fa-check"></i> Xác nhận (Manager)
                            </button>
                        </form>
                    </c:if>
                    <c:if test="${(payroll.status == 'DRAFT' || payroll.status == 'MANAGER_CONFIRMED') && roleGroup == 'HR'}">
                        <form action="${pageContext.request.contextPath}/admin/payroll/approve" method="post" style="display:inline;">
                            <input type="hidden" name="id" value="${payroll.id}" />
                            <input type="hidden" name="status" value="HR_FINALIZED" />
                            <button type="submit" class="btn btn-success btn-sm" onclick="return confirm('Chốt lương tháng ${payroll.month}/${payroll.year}? Sau khi chốt không thể thay đổi.')">
                                <i class="fas fa-lock"></i> Chốt lương (HR)
                            </button>
                        </form>
                    </c:if>
                </div>
            </div>

            <!-- Approval Flow Visual -->
            <div class="approval-flow">
                <span class="flow-step ${payroll.status == 'DRAFT' ? 'active' : 'done'}">
                    <i class="fas fa-file-alt"></i> Bản nháp
                </span>
                <i class="fas fa-arrow-right flow-arrow"></i>
                <span class="flow-step ${payroll.status == 'MANAGER_CONFIRMED' ? 'active' : (payroll.status == 'HR_FINALIZED' ? 'done' : 'pending')}">
                    <i class="fas fa-user-tie"></i> Manager xác nhận
                    <c:if test="${payroll.managerConfirmedByName != null}">
                        <small style="display:block;font-weight:400;font-size:11px;">${payroll.managerConfirmedByName}</small>
                    </c:if>
                </span>
                <i class="fas fa-arrow-right flow-arrow"></i>
                <span class="flow-step ${payroll.status == 'HR_FINALIZED' ? 'active done' : 'pending'}">
                    <i class="fas fa-check-double"></i> HR chốt lương
                    <c:if test="${payroll.hrConfirmedByName != null}">
                        <small style="display:block;font-weight:400;font-size:11px;">${payroll.hrConfirmedByName}</small>
                    </c:if>
                </span>
            </div>

            <!-- Department Filter & Search -->
            <div class="filter-bar">
                <label><i class="fas fa-building"></i> Phòng ban:</label>
                <select id="deptFilter" onchange="filterByDept()">
                    <option value="">-- Tất cả phòng ban --</option>
                    <c:forEach var="dept" items="${departments}">
                        <option value="${dept.id}" ${selectedDepartmentId == dept.id ? 'selected' : ''}>${dept.name}</option>
                    </c:forEach>
                </select>

                <div style="margin-left: auto; display: flex; align-items: center; gap: 8px;">
                    <label><i class="fas fa-search"></i> Tìm kiếm:</label>
                    <input type="text" id="empSearch" placeholder="Nhập Mã hoặc Tên nhân viên..." style="padding:8px 12px; border-radius:8px; border:1px solid #cbd5e1; font-size:14px; min-width: 250px;">
                </div>
            </div>

            <!-- ============ SINGLE COMPREHENSIVE TABLE ============ -->
            <div class="payroll-block">
                <div class="table-wrapper" style="overflow-x: auto; padding: 0;">
                    <table class="data-table" style="min-width: 2200px;">
                        <thead>
                            <!-- Header Row 1: Grouping -->
                            <tr style="background: #f1f5f9;">
                                <th colspan="4" class="text-center" style="border-right: 2px solid #cbd5e1; color: #334155;"><i class="fas fa-info-circle"></i> THÔNG TIN CHUNG</th>
                                <th colspan="7" class="text-center" style="border-right: 2px solid #cbd5e1; color: #1d4ed8; background: #eff6ff;"><i class="fas fa-calendar-check"></i> NGÀY CÔNG & LƯƠNG CƠ BẢN</th>
                                <th colspan="5" class="text-center" style="border-right: 2px solid #cbd5e1; color: #6d28d9; background: #f5f3ff;"><i class="fas fa-hand-holding-usd"></i> PHỤ CẤP & BẢO HIỂM</th>
                                <th colspan="5" class="text-center" style="border-right: 2px solid #cbd5e1; color: #d97706; background: #fffbeb;"><i class="fas fa-clock"></i> THU NHẬP BỔ SUNG</th>
                                <th colspan="4" class="text-center" style="color: #059669; background: #ecfdf5;"><i class="fas fa-money-bill-wave"></i> THUẾ & LƯƠNG THỰC NHẬN</th>
                            </tr>
                            <!-- Header Row 2: Columns -->
                            <tr>
                                <!-- General Info -->
                                <th>Mã NV</th>
                                <th>Họ và tên</th>
                                <th>Phòng ban</th>
                                <th style="border-right: 2px solid #cbd5e1;">Chức vụ</th>
                                
                                <!-- Block 1 -->
                                <th class="text-right">Lương CB (HĐ)</th>
                                <th class="text-center">Ngày chuẩn</th>
                                <th class="text-center">Thực tế</th>
                                <th class="text-center">Nghỉ phép</th>
                                <th class="text-center">Nghỉ ốm</th>
                                <th class="text-center">Nghỉ KL</th>
                                <th class="text-right" style="border-right: 2px solid #cbd5e1;">Khấu trừ NKL</th>

                                <!-- Block 2 -->
                                <th class="text-right">Phụ cấp</th>
                                <th class="text-right">BHXH</th>
                                <th class="text-right">BHYT</th>
                                <th class="text-right">BHTN</th>
                                <th class="text-right" style="border-right: 2px solid #cbd5e1;">Tổng BH</th>

                                <!-- Block 3: Thu nhập bổ sung -->
                                <th class="text-center">Số giờ TC</th>
                                <th class="text-right">Tiền tăng ca</th>
                                <th class="text-right">Tiền ngày lễ</th>
                                <th class="text-right">Thưởng</th>
                                <th class="text-right" style="border-right: 2px solid #cbd5e1;">Tổng bổ sung</th>

                                <!-- Block 4 -->
                                <th class="text-right">Lương trước thuế</th>
                                <th class="text-right">Thuế TNCN</th>
                                <th class="text-right" style="font-size:15px; font-weight: 700;">THỰC NHẬN</th>
                                <th class="text-center">Chi tiết</th>
                            </tr>
                        </thead>
                        <tbody id="payrollTableBody">
                            <c:set var="totalGross" value="0" />
                            <c:set var="totalTax" value="0" />
                            <c:set var="totalNet" value="0" />
                            <c:set var="totalOTHours" value="0" />
                            <c:set var="totalOT" value="0" />
                            <c:set var="totalHolidayPay" value="0" />
                            <c:set var="totalBonus" value="0" />
                            <c:forEach var="d" items="${details}">
                                <c:set var="totalGross" value="${totalGross + d.grossSalary}" />
                                <c:set var="totalTax" value="${totalTax + d.taxDeduction}" />
                                <c:set var="totalNet" value="${totalNet + d.netSalary}" />
                                <c:set var="totalOTHours" value="${totalOTHours + d.overtimeWeekdayHours + d.overtimeWeekendHours + d.overtimeHolidayHours}" />
                                <c:set var="totalOT" value="${totalOT + d.overtimePay}" />
                                <c:set var="totalHolidayPay" value="${totalHolidayPay + d.holidayWorkPay}" />
                                <c:set var="totalBonus" value="${totalBonus + d.bonusAmount}" />
                                <tr class="employee-row">
                                    <!-- General -->
                                    <td><strong>${d.employeeCode}</strong></td>
                                    <td>${d.employeeName}</td>
                                    <td>${d.departmentName}</td>
                                    <td style="border-right: 2px solid #e2e8f0;">${d.positionName}</td>

                                    <!-- Block 1 -->
                                    <td class="text-right amount"><fmt:formatNumber value="${d.basicSalary}" pattern="#,##0" /></td>
                                    <td class="text-center">${d.standardDays}</td>
                                    <td class="text-center">${d.actualWorkedDays}</td>
                                    <td class="text-center">${d.paidLeaveDays}</td>
                                    <td class="text-center">${d.sickLeaveDays}</td>
                                    <td class="text-center">${d.unpaidLeaveDays}</td>
                                    <td class="text-right amount amount-negative" style="border-right: 2px solid #e2e8f0;">
                                        <c:if test="${d.unpaidLeaveDeduction > 0}">-</c:if><fmt:formatNumber value="${d.unpaidLeaveDeduction}" pattern="#,##0" />
                                    </td>

                                    <!-- Block 2 -->
                                    <td class="text-right amount amount-positive">+<fmt:formatNumber value="${d.allowanceAmount}" pattern="#,##0" /></td>
                                    <td class="text-right amount amount-negative">-<fmt:formatNumber value="${d.bhxhDeduction}" pattern="#,##0" /></td>
                                    <td class="text-right amount amount-negative">-<fmt:formatNumber value="${d.bhytDeduction}" pattern="#,##0" /></td>
                                    <td class="text-right amount amount-negative">-<fmt:formatNumber value="${d.bhtnDeduction}" pattern="#,##0" /></td>
                                    <td class="text-right amount amount-negative" style="border-right: 2px solid #e2e8f0;">
                                        -<fmt:formatNumber value="${d.insuranceDeduction}" pattern="#,##0" />
                                    </td>

                                    <!-- Block 3: Thu nhập bổ sung -->
                                    <td class="text-center amount amount-positive">
                                        <c:if test="${(d.overtimeWeekdayHours + d.overtimeWeekendHours + d.overtimeHolidayHours) > 0}">
                                            <fmt:formatNumber value="${d.overtimeWeekdayHours + d.overtimeWeekendHours + d.overtimeHolidayHours}" pattern="#,##0.#" />h
                                        </c:if>
                                    </td>
                                    <td class="text-right amount amount-positive">
                                        <c:if test="${d.overtimePay > 0}">+</c:if><fmt:formatNumber value="${d.overtimePay}" pattern="#,##0" />
                                    </td>
                                    <td class="text-right amount amount-positive">
                                        <c:if test="${d.holidayWorkPay > 0}">+</c:if><fmt:formatNumber value="${d.holidayWorkPay}" pattern="#,##0" />
                                    </td>
                                    <td class="text-right amount amount-positive">
                                        <c:if test="${d.bonusAmount > 0}">+</c:if><fmt:formatNumber value="${d.bonusAmount}" pattern="#,##0" />
                                    </td>
                                    <td class="text-right amount amount-positive" style="border-right: 2px solid #e2e8f0; font-weight:700;">
                                        +<fmt:formatNumber value="${d.overtimePay + d.holidayWorkPay + d.bonusAmount}" pattern="#,##0" />
                                    </td>

                                    <!-- Block 4 -->
                                    <td class="text-right amount"><fmt:formatNumber value="${d.grossSalary}" pattern="#,##0" /></td>
                                    <td class="text-right amount amount-negative">
                                        <c:if test="${d.taxDeduction > 0}">-</c:if><fmt:formatNumber value="${d.taxDeduction}" pattern="#,##0" />
                                    </td>
                                    <td class="text-right amount" style="font-size:15px; font-weight:800; color:#059669;">
                                        <fmt:formatNumber value="${d.netSalary}" pattern="#,##0" /> đ
                                    </td>
                                    <td class="text-center">
                                        <button onclick="viewDetail(${d.id})" class="btn btn-outline btn-sm" style="padding: 4px 8px; font-size: 12px; border-radius: 6px;">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>

                            <!-- Summary row -->
                            <tr class="summary-row">
                                <td colspan="16" class="text-right" style="border-right: 2px solid #cbd5e1; font-size: 14px;">
                                    <strong>TỔNG CỘNG (${payroll.totalEmployees} nhân viên)</strong>
                                </td>
                                <td class="text-center amount amount-positive"><c:if test="${totalOTHours > 0}"><fmt:formatNumber value="${totalOTHours}" pattern="#,##0.#" />h</c:if></td>
                                <td class="text-right amount amount-positive"><fmt:formatNumber value="${totalOT}" pattern="#,##0" /></td>
                                <td class="text-right amount amount-positive"><fmt:formatNumber value="${totalHolidayPay}" pattern="#,##0" /></td>
                                <td class="text-right amount amount-positive"><fmt:formatNumber value="${totalBonus}" pattern="#,##0" /></td>
                                <td class="text-right amount amount-positive" style="border-right: 2px solid #cbd5e1;"><fmt:formatNumber value="${totalOT + totalHolidayPay + totalBonus}" pattern="#,##0" /></td>
                                <td class="text-right amount"><fmt:formatNumber value="${totalGross}" pattern="#,##0" /></td>
                                <td class="text-right amount amount-negative"><fmt:formatNumber value="${totalTax}" pattern="#,##0" /></td>
                                <td class="text-right amount" style="font-size:16px; color:#059669;">
                                    <fmt:formatNumber value="${totalNet}" pattern="#,##0" /> đ
                                </td>
                                <td></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="pagination-container" id="paginationControls"></div>
            </div>

        </div>
    </main>
</div>

<script>
function filterByDept() {
    var deptId = document.getElementById('deptFilter').value;
    var url = '${pageContext.request.contextPath}/admin/payroll/detail?id=${payroll.id}';
    if (deptId) url += '&departmentId=' + deptId;
    window.location.href = url;
}

document.addEventListener("DOMContentLoaded", function() {
    const rowsPerPage = 5;
    const tableBody = document.getElementById("payrollTableBody");
    const allRows = Array.from(tableBody.querySelectorAll("tr.employee-row"));
    const paginationControls = document.getElementById("paginationControls");
    const searchInput = document.getElementById("empSearch");
    
    let filteredRows = allRows;

    function renderPagination() {
        paginationControls.innerHTML = "";
        const totalPages = Math.max(1, Math.ceil(filteredRows.length / rowsPerPage));
        
        // Info text
        const info = document.createElement("div");
        info.className = "page-info";
        info.innerText = "Hiển thị " + rowsPerPage + " dòng / trang (Tổng: " + filteredRows.length + " NV)";
        paginationControls.appendChild(info);

        // Page buttons
        for (let i = 1; i <= totalPages; i++) {
            const btn = document.createElement("button");
            btn.className = "page-btn";
            btn.innerText = i;
            btn.dataset.page = i;
            btn.onclick = function() { showPage(i); };
            paginationControls.appendChild(btn);
        }
        
        paginationControls.style.display = "flex";
        showPage(1);
    }

    function showPage(page) {
        // Hide all rows first
        allRows.forEach(row => row.style.display = "none");
        
        // Show only the filtered rows for the current page
        const startIndex = (page - 1) * rowsPerPage;
        const endIndex = page * rowsPerPage;
        for (let i = startIndex; i < endIndex && i < filteredRows.length; i++) {
            filteredRows[i].style.display = "";
        }
        
        // Update active class on buttons
        const buttons = paginationControls.querySelectorAll(".page-btn");
        buttons.forEach(btn => {
            if (parseInt(btn.dataset.page) === page) {
                btn.classList.add("active");
            } else {
                btn.classList.remove("active");
            }
        });
    }

    // Filter event listener
    searchInput.addEventListener("input", function() {
        const keyword = searchInput.value.toLowerCase().trim();
        if (!keyword) {
            filteredRows = allRows;
        } else {
            filteredRows = allRows.filter(row => {
                const empCode = row.cells[0].innerText.toLowerCase();
                const empName = row.cells[1].innerText.toLowerCase();
                return empCode.includes(keyword) || empName.includes(keyword);
            });
        }
        renderPagination();
    });

    // Initialize
    renderPagination();
});
</script>
<!-- Modal Chi tiết Bảng Lương -->
<div class="modal fade" id="payrollDetailModal" tabindex="-1" style="display: none; background: rgba(0,0,0,0.5); position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 1050; overflow-y: auto;">
    <div class="modal-dialog" style="max-width: 600px; margin: 30px auto; background: #fff; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); padding: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 16px; margin-bottom: 20px;">
            <h4 style="margin: 0; font-size: 18px; color: #1e293b; display: flex; align-items: center; gap: 8px;">
                <i class="fas fa-file-invoice-dollar" style="color: #4f46e5;"></i>
                Chi tiết Bảng lương
            </h4>
            <button type="button" onclick="document.getElementById('payrollDetailModal').style.display='none'" style="background: none; border: none; font-size: 20px; cursor: pointer; color: #64748b;">&times;</button>
        </div>
        
        <div id="payrollDetailContent" style="display: flex; flex-direction: column; gap: 16px;">
            <div style="text-align: center; color: #64748b;">Đang tải...</div>
        </div>
        
        <div style="margin-top: 24px; text-align: right;">
            <button onclick="document.getElementById('payrollDetailModal').style.display='none'" class="btn btn-outline" style="padding: 8px 16px; border-radius: 8px; border: 1px solid #cbd5e1; background: #fff; cursor: pointer;">Đóng</button>
        </div>
    </div>
</div>

<script>
function viewDetail(detailId) {
    document.getElementById('payrollDetailModal').style.display = 'block';
    const contentDiv = document.getElementById('payrollDetailContent');
    contentDiv.innerHTML = '<div style="text-align: center; color: #64748b;"><i class="fas fa-spinner fa-spin"></i> Đang tải dữ liệu...</div>';
    
    fetch('${pageContext.request.contextPath}/api/payroll-detail?detailId=' + detailId)
        .then(res => res.json())
        .then(data => {
            if (data.error) {
                contentDiv.innerHTML = '<div style="color: red; text-align: center;">' + data.error + '</div>';
                return;
            }
            
            const d = data.detail;
            const alws = data.allowances || [];
            
            const formatMoney = (val) => new Intl.NumberFormat('vi-VN').format(val) + ' đ';
            const formatHours = (val) => (val > 0 ? val + 'h' : '0');
            
            let html = '';
            
            // 1. Phụ cấp
            html += '<div style="background: #f8fafc; padding: 12px 16px; border-radius: 8px; border: 1px solid #e2e8f0;">';
            html += '<div style="font-weight: 600; color: #334155; margin-bottom: 8px;"><i class="fas fa-hand-holding-usd" style="color: #6d28d9; width: 20px;"></i> Chi tiết Phụ cấp</div>';
            if (alws.length > 0) {
                html += '<ul style="margin:0; padding-left: 20px; color: #475569; font-size: 14px;">';
                alws.forEach(a => {
                    html += '<li style="margin-bottom: 4px; display: flex; justify-content: space-between;"><span>' + a.name + '</span> <strong>' + formatMoney(a.amount) + '</strong></li>';
                });
                html += '<li style="margin-top: 8px; padding-top: 8px; border-top: 1px dashed #cbd5e1; display: flex; justify-content: space-between; font-weight: 600; color: #0f172a;"><span>Tổng cộng</span> <span>' + formatMoney(d.allowanceAmount) + '</span></li>';
                html += '</ul>';
            } else {
                html += '<div style="color: #64748b; font-size: 14px; font-style: italic;">Không có phụ cấp</div>';
            }
            html += '</div>';
            
            // 2. Tăng ca
            html += '<div style="background: #f8fafc; padding: 12px 16px; border-radius: 8px; border: 1px solid #e2e8f0;">';
            html += '<div style="font-weight: 600; color: #334155; margin-bottom: 8px;"><i class="fas fa-clock" style="color: #ea580c; width: 20px;"></i> Chi tiết Tăng ca</div>';
            
            const hourlyRate = d.standardDays > 0 ? (d.basicSalary / d.standardDays / 8.0) : 0;
            const weekdayMoney = d.overtimeWeekdayHours * hourlyRate * 1.5;
            const weekendMoney = d.overtimeWeekendHours * hourlyRate * 2.0;
            // Dùng phép trừ để tránh sai số do hệ số ngày lễ khác nhau
            const holidayMoney = Math.max(0, d.overtimePay - weekdayMoney - weekendMoney);

            html += '<ul style="margin:0; padding-left: 20px; color: #475569; font-size: 14px;">';
            html += '<li style="margin-bottom: 4px; display: flex; justify-content: space-between;"><span>Ngày thường (' + formatHours(d.overtimeWeekdayHours) + ')</span> <strong>+' + formatMoney(weekdayMoney) + '</strong></li>';
            html += '<li style="margin-bottom: 4px; display: flex; justify-content: space-between;"><span>Cuối tuần (' + formatHours(d.overtimeWeekendHours) + ')</span> <strong>+' + formatMoney(weekendMoney) + '</strong></li>';
            html += '<li style="margin-bottom: 4px; display: flex; justify-content: space-between;"><span>Ngày lễ (' + formatHours(d.overtimeHolidayHours) + ')</span> <strong>+' + formatMoney(holidayMoney) + '</strong></li>';
            html += '<li style="margin-top: 8px; padding-top: 8px; border-top: 1px dashed #cbd5e1; display: flex; justify-content: space-between; font-weight: 600; color: #0f172a;"><span>Tổng tiền Tăng ca</span> <span style="color:#16a34a">' + formatMoney(d.overtimePay) + '</span></li>';
            html += '</ul>';
            html += '</div>';
            
            // 3. Làm ngày lễ
            if (d.holidayWorkDays > 0 || d.holidayWorkPay > 0) {
                html += '<div style="background: #f8fafc; padding: 12px 16px; border-radius: 8px; border: 1px solid #e2e8f0;">';
                html += '<div style="font-weight: 600; color: #334155; margin-bottom: 8px;"><i class="fas fa-calendar-star" style="color: #d946ef; width: 20px;"></i> Lương làm ngày lễ</div>';
                
                const hd = data.holidayDetails || [];
                if (hd.length > 0) {
                    html += '<ul style="margin:0 0 8px 0; padding-left: 20px; color: #475569; font-size: 14px;">';
                    hd.forEach(h => {
                        html += '<li style="margin-bottom: 4px; display: flex; justify-content: space-between;"><span>' + h.name + ' (' + h.date + ')</span> <strong>x' + h.coefficient.toFixed(1) + '</strong></li>';
                    });
                    html += '</ul>';
                }
                
                html += '<div style="font-size: 14px; color: #475569; display: flex; justify-content: space-between; border-top: 1px dashed #cbd5e1; padding-top: 8px;"><span>Tổng hệ số quy đổi: ' + d.holidayWorkDays.toFixed(1) + ' ngày</span> <strong style="color:#16a34a">' + formatMoney(d.holidayWorkPay) + '</strong></div>';
                html += '</div>';
            }
            
            // 4. Khen thưởng
            if (d.bonusAmount > 0 || d.bonusNote) {
                html += '<div style="background: #f8fafc; padding: 12px 16px; border-radius: 8px; border: 1px solid #e2e8f0;">';
                html += '<div style="font-weight: 600; color: #334155; margin-bottom: 8px;"><i class="fas fa-gift" style="color: #f59e0b; width: 20px;"></i> Khen thưởng</div>';
                html += '<div style="font-size: 14px; color: #475569; display: flex; justify-content: space-between;"><span>Thưởng:</span> <strong style="color:#16a34a">' + formatMoney(d.bonusAmount) + '</strong></div>';
                if (d.bonusNote) {
                    html += '<div style="font-size: 13px; color: #64748b; margin-top: 4px; font-style: italic;">Lý do: ' + d.bonusNote + '</div>';
                }
                html += '</div>';
            }
            
            contentDiv.innerHTML = html;
        })
        .catch(err => {
            contentDiv.innerHTML = '<div style="color: red; text-align: center;">Đã xảy ra lỗi khi tải dữ liệu.</div>';
            console.error(err);
        });
}
</script>
</body>
</html>
