<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Quản lý Hợp đồng</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/departments.css">
    <style>
        .contract-row:hover { background-color: #f8fafc; }
        .btn-icon { background: none; border: none; outline: none; padding: 4px 6px; border-radius: 6px; transition: background 0.15s; cursor: pointer; }
        .btn-icon:hover { background-color: #f1f5f9; }
        .badge-status { padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 500; }
        .badge-active { background-color: #e6f4ea; color: #137333; }
        .badge-expired { background-color: #f1f3f4; color: #5f6368; }
        .badge-terminated { background-color: #fce8e6; color: #c5221f; }
        .salary-cell { font-family: 'Segoe UI', monospace; font-weight: 600; color: #1a73e8; }
        .modal-content { border-radius: 12px; }
        .form-control, .custom-select { border-radius: 6px; }
    </style>
</head>
<body style="background-color: #f8f9fa;">
<div class="d-flex">
    <%@ include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="container-fluid p-4">
        <%-- ═══ HEADER ═══ --%>
        <div class="mb-4">
            <h2 class="font-weight-bold text-dark" style="font-size: 28px; letter-spacing: -0.5px;">Quản lý Hợp đồng Lao động</h2>
            <p class="text-muted" style="font-size: 14px;">Xin chào, <c:out value="${not empty sessionScope.fullName ? sessionScope.fullName : 'Hệ thống'}" /></p>
        </div>

        <%-- ═══ ALERT ═══ --%>
        <div id="alertContainer"></div>

        <%-- ═══ ACTION BUTTON ═══ --%>
        <div class="mb-4">
            <button type="button" class="btn text-white px-4 py-2"
                    style="background-color: #6366f1; border-radius: 8px; font-weight: 500; border: none; box-shadow: 0 4px 6px -1px rgba(99, 102, 241, 0.2);"
                    onclick="openCreateModal()">
                + Tạo hợp đồng mới
            </button>
        </div>

        <%-- ═══ FILTER BAR ═══ --%>
        <div class="card border-0 shadow-sm mb-4 p-3" style="border-radius: 12px; background: white;">
            <div class="row align-items-center">
                <div class="col-md-5 search-box-container">
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#a0aec0" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="11" cy="11" r="8"></circle>
                                    <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                </svg>
                            </span>
                        </div>
                        <input type="text" id="searchKeyword" class="form-control form-control-search"
                               placeholder="Tìm kiếm theo mã NV, họ tên hoặc số HĐ..."
                               style="height: calc(1.5em + .75rem + 10px);" oninput="onFilterChange()">
                    </div>
                </div>
                <div class="col-md-3 mt-2 mt-md-0">
                    <select id="filterType" class="form-control filter-select" onchange="onFilterChange()">
                        <option value="">Tất cả loại HĐ</option>
                        <option value="1">Thử việc</option>
                        <option value="2">Chính thức 1 năm</option>
                        <option value="3">Không thời hạn</option>
                        <option value="4">Thời vụ</option>
                    </select>
                </div>
                <div class="col-md-4 mt-2 mt-md-0">
                    <select id="filterStatus" class="form-control filter-select" onchange="onFilterChange()">
                        <option value="">Tất cả trạng thái</option>
                        <option value="1">Active</option>
                        <option value="2">Expired</option>
                        <option value="3">Terminated</option>
                    </select>
                </div>
            </div>
        </div>

        <%-- ═══ DATA TABLE ═══ --%>
        <div class="card border-0 shadow-sm mb-4" style="border-radius: 12px; overflow: hidden;">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" style="background: white;" id="contractTable">
                    <thead style="background-color: #fafafa; border-bottom: 2px solid #f0f0f0;">
                    <tr>
                        <th class="text-secondary font-weight-bold text-uppercase px-4 py-3" style="font-size: 11px; border: none; width: 60px;">ID</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none; width: 100px;">Mã NV</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none;">Họ Tên</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none;">Phòng Ban</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none; width: 120px;">Số HĐ</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none; width: 130px;">Loại HĐ</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none; width: 180px;">Thời hạn</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none; width: 130px;">Lương cứng</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none; width: 110px;">Trạng thái</th>
                        <th class="text-secondary font-weight-bold text-uppercase text-center px-4 py-3" style="font-size: 11px; border: none; width: 130px;">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody style="font-size: 14px; color: #4a5568;">
                    <c:forEach var="c" items="${contracts}">
                        <tr class="contract-row"
                            data-empcode="${c.employeeCode != null ? c.employeeCode.toLowerCase() : ''}"
                            data-empname="${c.employeeFullName != null ? c.employeeFullName.toLowerCase() : ''}"
                            data-contractnumber="${c.contractNumber != null ? c.contractNumber.toLowerCase() : ''}"
                            data-type="${c.contractType}"
                            data-status="${c.status}"
                            style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                            <td class="px-4 text-muted">${c.id}</td>
                            <td><span class="font-weight-bold text-dark" style="letter-spacing: 0.5px;">${c.employeeCode}</span></td>
                            <td class="font-weight-normal text-dark">${c.employeeFullName}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty c.departmentName}">
                                        <span class="badge badge-light text-secondary border px-2 py-1" style="border-radius: 6px; font-weight: 500; background-color: #f8f9fa;">${c.departmentName}</span>
                                    </c:when>
                                    <c:otherwise><span class="text-muted" style="font-size: 13px;">-</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="font-weight-bold" style="color: #6366f1;">${c.contractNumber}</td>
                            <td>
                                <span class="badge badge-light border px-2 py-1" style="border-radius: 6px; font-weight: 500; background-color: #eff6ff; color: #1d4ed8; font-size: 12px;">${c.contractTypeLabel}</span>
                            </td>
                            <td style="font-size: 13px;">
                                <fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/>
                                <span class="text-muted mx-1">→</span>
                                <c:choose>
                                    <c:when test="${not empty c.endDate}"><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></c:when>
                                    <c:otherwise><span class="text-success font-weight-bold">Vô thời hạn</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="salary-cell"><fmt:formatNumber value="${c.baseSalary}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.status == 1}"><span class="badge badge-status badge-active">Active</span></c:when>
                                    <c:when test="${c.status == 2}"><span class="badge badge-status badge-expired">Expired</span></c:when>
                                    <c:when test="${c.status == 3}"><span class="badge badge-status badge-terminated">Terminated</span></c:when>
                                    <c:otherwise><span class="badge badge-status badge-expired">N/A</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center px-3">
                                <%-- Xem File Hợp đồng --%>
                                <button class="btn-icon" title="Xem file hợp đồng"
                                        data-fileurl="${c.fileUrl}"
                                        onclick="openFileView(this)">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#4e73df" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                        <circle cx="12" cy="12" r="3"></circle>
                                    </svg>
                                </button>
                                <%-- Renew (only if Active AND not Indefinite type) --%>
                                <c:if test="${c.status == 1 && c.contractType != 3}">
                                    <button class="btn-icon" title="Gia hạn hợp đồng"
                                            data-id="${c.id}" data-employeeid="${c.employeeId}"
                                            data-empname="${c.employeeFullName}" data-contractnumber="${c.contractNumber}"
                                            data-type="${c.contractType}" data-salary="${c.baseSalary}"
                                            onclick="openRenewModal(this)">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#059669" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <polyline points="23 4 23 10 17 10"></polyline>
                                            <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"></path>
                                        </svg>
                                    </button>
                                </c:if>
                                <%-- Terminate (only if Active) --%>
                                <c:if test="${c.status == 1}">
                                    <button class="btn-icon" title="Chấm dứt hợp đồng"
                                            data-id="${c.id}" data-contractnumber="${c.contractNumber}"
                                            data-empname="${c.employeeFullName}"
                                            onclick="openTerminateModal(this)">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <circle cx="12" cy="12" r="10"></circle>
                                            <line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line>
                                        </svg>
                                    </button>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <tr id="noDataRow" style="display: none;">
                        <td colspan="10" class="text-center text-muted py-4" style="background: white;">Không tìm thấy hợp đồng nào phù hợp với bộ lọc!</td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <%-- ═══ PAGINATION ═══ --%>
            <div class="card-footer d-flex justify-content-between align-middle border-0 py-3" style="background: white; border-top: 1px solid #f1f5f9 !important;">
                <div class="text-muted" id="paginationInfo" style="font-size: 14px;"></div>
                <nav aria-label="Page navigation">
                    <ul class="pagination pagination-sm mb-0" id="paginationControls"></ul>
                </nav>
            </div>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════════════════ --%>
<%-- MODAL: TẠO HỢP ĐỒNG MỚI / GIA HẠN                                          --%>
<%-- ══════════════════════════════════════════════════════════════════════════════ --%>
<div class="modal fade" id="contractModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title font-weight-bold text-dark" id="contractModalTitle" style="font-size: 20px;">Tạo hợp đồng mới</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="outline: none;">
                    <span aria-hidden="true" style="font-size: 24px;">&times;</span>
                </button>
            </div>
            <div class="modal-body py-3">
                <input type="hidden" id="modalAction" value="create">
                <input type="hidden" id="oldContractId" value="">

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group mb-3">
                            <label class="text-dark font-weight-500" style="font-size: 14px;" for="employeeCodeInput">Mã NV / Tên nhân viên <span class="text-danger">*</span></label>
                            <input type="text" id="employeeCodeInput" class="form-control" list="employeeOptions"
                                   placeholder="Gõ mã NV hoặc tên để tìm..." autocomplete="off"
                                   style="padding: 10px;" required>
                            <datalist id="employeeOptions"></datalist>
                            <input type="hidden" id="employeeId" name="employeeId">
                            <small id="employeeHint" class="text-muted" style="font-size: 12px; display: none;"></small>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group mb-3">
                            <label class="text-dark font-weight-500" style="font-size: 14px;">Số hợp đồng <span class="text-danger">*</span></label>
                            <input type="text" id="formContractNumber" class="form-control" style="padding: 10px;" placeholder="VD: HD-2026-001" required>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group mb-3">
                            <label class="text-dark font-weight-500" style="font-size: 14px;">Loại hợp đồng <span class="text-danger">*</span></label>
                            <select id="formContractType" class="form-control" style="padding: 8px 12px;">
                                <option value="1">Thử việc</option>
                                <option value="2">Chính thức 1 năm</option>
                                <option value="3">Không thời hạn</option>
                                <option value="4">Thời vụ</option>
                            </select>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group mb-3">
                            <label class="text-dark font-weight-500" style="font-size: 14px;" for="salaryScaleSelect">Bậc lương cơ bản <span class="text-danger">*</span></label>
                            <select id="salaryScaleSelect" name="salaryScaleId" class="form-control" style="padding: 8px 12px;" required>
                                <option value="">-- Chọn bậc lương & mức lương --</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group mb-3">
                            <label class="text-dark font-weight-500" style="font-size: 14px;">Ngày bắt đầu <span class="text-danger">*</span></label>
                            <input type="date" id="formStartDate" class="form-control" style="padding: 10px;" required>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group mb-3">
                            <label class="text-dark font-weight-500" style="font-size: 14px;">Ngày kết thúc <small class="text-muted">(để trống nếu không thời hạn)</small></label>
                            <input type="date" id="formEndDate" class="form-control" style="padding: 10px;">
                        </div>
                    </div>
                </div>
                <div class="form-group mb-2">
                    <label class="text-dark font-weight-500" style="font-size: 14px;">Ghi chú</label>
                    <textarea id="formDescription" class="form-control" rows="2" style="border-radius: 6px;"></textarea>
                </div>
                <div class="form-group mb-2">
                    <label class="text-dark font-weight-500" style="font-size: 14px;">File hợp đồng scan <span class="text-danger">*</span> <small class="text-muted">(PDF, JPG, JPEG, PNG)</small></label>
                    <input type="file" id="formContractFile" class="form-control-file" accept=".pdf,.jpg,.jpeg,.png" style="padding: 8px;">
                </div>
            </div>
            <div class="modal-footer border-top-0 pt-0">
                <button type="button" class="btn btn-light px-4" data-dismiss="modal" style="border-radius: 6px; font-weight: 500;">Hủy</button>
                <button type="button" class="btn text-white px-4" id="btnSubmitContract"
                        style="background-color: #6366f1; border-radius: 6px; font-weight: 500;"
                        onclick="submitContract()">Lưu hợp đồng</button>
            </div>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════════════════ --%>
<%-- MODAL: CHẤM DỨT HỢP ĐỒNG                                                    --%>
<%-- ══════════════════════════════════════════════════════════════════════════════ --%>
<div class="modal fade" id="terminateModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title font-weight-bold" style="font-size: 18px; color: #dc2626;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mr-1" style="vertical-align: -3px;">
                        <circle cx="12" cy="12" r="10"></circle>
                        <line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line>
                    </svg>
                    Chấm dứt hợp đồng
                </h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="outline: none;">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body py-3">
                <input type="hidden" id="terminateContractId" value="">
                <p class="mb-3" style="font-size: 14px; color: #4a5568;">
                    Bạn đang chấm dứt hợp đồng <strong id="terminateContractLabel"></strong> của <strong id="terminateEmpName"></strong>.
                </p>
                <div class="form-group mb-3">
                    <label class="text-dark font-weight-500" style="font-size: 14px;">Lý do chấm dứt</label>
                    <textarea id="terminateReason" class="form-control" rows="3" style="border-radius: 6px;" placeholder="Nhập lý do chấm dứt hợp đồng..."></textarea>
                </div>
            </div>
            <div class="modal-footer border-top-0 pt-0">
                <button type="button" class="btn btn-light px-3" data-dismiss="modal" style="border-radius: 6px; font-weight: 500;">Hủy</button>
                <button type="button" class="btn text-white px-3"
                        style="background-color: #dc2626; border-radius: 6px; font-weight: 500;"
                        onclick="submitTerminate()">Xác nhận chấm dứt</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
<script>const CTX = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/assets/js/contracts.js"></script>
</body>
</html>
