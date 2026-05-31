<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Quản lý Bảo hiểm</title>

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>

    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"/>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/user-list.css"/>

    <style>
        .insurance-rate-grid {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 12px;
            margin-bottom: 12px;
        }
        .insurance-rate-input {
            display: flex;
            flex-direction: column;
        }
        .insurance-rate-input label {
            font-size: 12px;
            color: var(--text-sub);
            margin-bottom: 4px;
            font-weight: 600;
        }
        .insurance-rate-input input {
            padding: 8px;
            border: 1px solid var(--border);
            border-radius: 4px;
            font-size: 14px;
        }
        .insurance-summary {
            background: #f8fafc;
            padding: 12px;
            border-radius: 6px;
            margin-top: 12px;
            border-left: 3px solid var(--indigo);
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            margin-bottom: 8px;
        }
        .summary-row:last-child {
            margin-bottom: 0;
            border-top: 1px solid var(--border);
            padding-top: 8px;
            font-weight: 600;
            color: var(--indigo-text);
        }
    </style>
</head>

<body>

<jsp:include page="/WEB-INF/common/sidebar.jsp" />

<div class="main-wrapper">
    <div class="page-content">

        <script>
            window.contextPath = '${pageContext.request.contextPath}';
            window.actionUrl = '${pageContext.request.contextPath}/admin/insurance/action';
        </script>

        <%-- Flash Messages --%>
        <c:if test="${not empty sessionScope.flash_success}">
            <div class="flash success">
                <i class="fa-solid fa-circle-check"></i>
                ${sessionScope.flash_success}
            </div>
            <c:remove var="flash_success" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.flash_error}">
            <div class="flash error">
                <i class="fa-solid fa-circle-exclamation"></i>
                ${sessionScope.flash_error}
            </div>
            <c:remove var="flash_error" scope="session"/>
        </c:if>

        <%-- Page Header --%>
        <div class="page-header">
            <div>
                <h1 class="page-title">Quản lý Bảo hiểm</h1>
                <p class="page-sub">
                    Xin chào, ${sessionScope.fullName}
                </p>
            </div>
        </div>

        <%-- Stats Cards --%>
        <div class="stats-grid">

            <div class="stat-card">
                <div class="stat-label">Tổng bảo hiểm</div>
                <div class="stat-value total">
                    ${stats.totalInsurances}
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-label">Đang áp dụng</div>
                <div class="stat-value active">
                    ${stats.activeInsurances}
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-label">Đã dừng</div>
                <div class="stat-value inactive">
                    ${stats.inactiveInsurances}
                </div>
            </div>

        </div>

        <%-- Insurance Rate Config Table --%>
        <div class="section-header" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
            <div>
                <h2 style="font-size:16px; font-weight:700; color:var(--text-main); margin:0;">
                    <i class="fa-solid fa-sliders" style="color:var(--indigo); margin-right:8px;"></i>
                    Cấu hình tỷ lệ đóng bảo hiểm
                </h2>
                <p style="font-size:13px; color:var(--text-sub); margin:4px 0 0;">
                    Tỷ lệ % trích từ lương của người lao động và phần đóng góp của doanh nghiệp
                </p>
            </div>
            <button type="button"
                    class="btn-primary"
                    onclick="openModal('createRateModal')">
                <i class="fa-solid fa-plus"></i>
                Thêm loại bảo hiểm
            </button>
        </div>

        <div class="table-wrapper">
            <table id="rateTable">
                <thead>
                <tr>
                    <th>#</th>
                    <th>Loại bảo hiểm</th>
                    <th>Mã</th>
                    <th style="text-align:center;">NLĐ đóng (%)<br><small style="font-weight:400;color:var(--text-sub);">Trừ vào lương</small></th>
                    <th style="text-align:center;">DN đóng (%)<br><small style="font-weight:400;color:var(--text-sub);">Chi phí doanh nghiệp</small></th>
                    <th style="text-align:center;">Tổng (%)</th>
                    <th>Ghi chú</th>
                    <th>Trạng thái</th>
                    <th>Hành động</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${not empty insuranceRates}">
                        <c:forEach var="rate" items="${insuranceRates}" varStatus="loop">
                            <tr id="rate-row-${rate.id}">
                                <td>${loop.count}</td>
                                <td style="font-weight:600;">${rate.name}</td>
                                <td><span class="badge badge-active" style="font-size:11px;">${rate.code}</span></td>
                                <td style="text-align:center;">
                                    <span class="rate-display employee-rate" id="emp-rate-${rate.id}"
                                          style="display:inline-block; background:#eef2ff; color:#4f46e5; padding:4px 12px; border-radius:20px; font-weight:700; font-size:14px;">
                                        ${rate.employeeRate}%
                                    </span>
                                    <input type="number" class="rate-input" id="emp-input-${rate.id}"
                                           value="${rate.employeeRate}" step="0.1" min="0" max="100"
                                           style="display:none; width:80px; padding:6px 8px; border:2px solid var(--indigo); border-radius:6px; font-size:14px; text-align:center;"
                                           onchange="updateTotal(${rate.id})">
                                </td>
                                <td style="text-align:center;">
                                    <span class="rate-display employer-rate" id="emp2-rate-${rate.id}"
                                          style="display:inline-block; background:#f0fdf4; color:#16a34a; padding:4px 12px; border-radius:20px; font-weight:700; font-size:14px;">
                                        ${rate.employerRate}%
                                    </span>
                                    <input type="number" class="rate-input" id="emp2-input-${rate.id}"
                                           value="${rate.employerRate}" step="0.1" min="0" max="100"
                                           style="display:none; width:80px; padding:6px 8px; border:2px solid #16a34a; border-radius:6px; font-size:14px; text-align:center;"
                                           onchange="updateTotal(${rate.id})">
                                </td>
                                <td style="text-align:center;">
                                    <span id="total-rate-${rate.id}"
                                          style="font-weight:700; color:var(--text-main);">
                                        <fmt:formatNumber value="${rate.employeeRate + rate.employerRate}" maxFractionDigits="1"/>%
                                    </span>
                                </td>
                                <td style="color:var(--text-sub); font-size:13px;">${rate.note}</td>
                                <td>
                                    <%-- Toggle trạng thái --%>
                                    <button type="button"
                                            class="badge ${rate.active ? 'badge-active' : 'badge-inactive'}"
                                            onclick="confirmToggleRate(${rate.id}, ${rate.active})"
                                            title="Nhấn để đổi trạng thái"
                                            style="cursor:pointer; border:none; font-size:12px; font-weight:600; border-radius:20px; padding:4px 12px;">
                                        <c:choose>
                                            <c:when test="${rate.active}">Đang áp dụng</c:when>
                                            <c:otherwise>Đã dừng</c:otherwise>
                                        </c:choose>
                                    </button>
                                </td>
                                <td>
                                    <%-- Edit inline button --%>
                                    <button type="button" class="btn-icon btn-edit-rate" id="edit-btn-${rate.id}"
                                            onclick="toggleEditRate(${rate.id})" title="Chỉnh sửa tỷ lệ">
                                        <i class="fa-solid fa-pen"></i>
                                    </button>
                                    <%-- Save button (hidden initially) --%>
                                    <button type="button" class="btn-icon" id="save-btn-${rate.id}"
                                            onclick="saveRate(${rate.id})" title="Lưu"
                                            style="display:none; background:#eef2ff; color:var(--indigo);">
                                        <i class="fa-solid fa-check"></i>
                                    </button>
                                    <%-- Cancel button (hidden initially) --%>
                                    <button type="button" class="btn-icon" id="cancel-btn-${rate.id}"
                                            onclick="cancelEditRate(${rate.id})" title="Hủy"
                                            style="display:none;">
                                        <i class="fa-solid fa-xmark"></i>
                                    </button>
                                    <%-- Delete button --%>
                                    <button type="button" class="btn-icon"
                                            onclick="confirmDeleteRate(${rate.id}, '${rate.name}')" title="Xóa">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <%-- Default rows if no data --%>
                        <tr>
                            <td colspan="9" style="text-align:center; padding:48px 32px; color:var(--text-sub);">
                                <i class="fa-solid fa-shield-halved" style="font-size:36px; margin-bottom:12px; opacity:0.3; display:block;"></i>
                                <p style="margin:0; font-size:14px;">Chưa có cấu hình tỷ lệ bảo hiểm nào.</p>
                                <p style="margin:8px 0 0; font-size:13px;">Nhấn <strong>Thêm loại bảo hiểm</strong> để bắt đầu.</p>
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>

        <%-- Info note --%>
        <div style="margin-top:12px; padding:12px 16px; background:#fffbeb; border:1px solid #fde68a; border-radius:8px; font-size:13px; color:#92400e; display:flex; gap:10px; align-items:flex-start;">
            <i class="fa-solid fa-circle-info" style="margin-top:2px; flex-shrink:0;"></i>
            <span>
                Tỷ lệ trên áp dụng theo quy định hiện hành của Bộ LĐ-TB&XH. Khi thay đổi tỷ lệ, hệ thống sẽ tự động tính lại số tiền bảo hiểm cho tất cả nhân viên trong kỳ lương tiếp theo.
            </span>
        </div>

        <%-- =============== Add Insurance Rate Modal =============== --%>
        <div class="modal-overlay" id="createRateModal">
            <div class="modal modal-wide">
                <div class="modal-title">
                    <i class="fa-solid fa-shield-halved"></i>
                    Thêm loại bảo hiểm mới
                </div>

                <form method="post"
                      action="${pageContext.request.contextPath}/admin/insurance/action"
                      id="createRateForm">

                    <input type="hidden" name="action" value="createRate">

                    <div class="form-grid">
                        <div class="form-row">
                            <label for="rateName">Tên loại bảo hiểm <span style="color:red">*</span></label>
                            <input type="text" id="rateName" name="name"
                                   placeholder="VD: Bảo hiểm xã hội" required>
                        </div>
                        <div class="form-row">
                            <label for="rateCode">Mã viết tắt <span style="color:red">*</span></label>
                            <input type="text" id="rateCode" name="code"
                                   placeholder="VD: BHXH" maxlength="10" required
                                   style="text-transform:uppercase;">
                        </div>
                    </div>

                    <div style="margin-bottom:16px;">
                        <p style="font-size:13px; font-weight:600; color:var(--text-main); margin:0 0 12px;">
                            Tỷ lệ đóng góp
                        </p>
                        <div class="insurance-rate-grid">
                            <div class="insurance-rate-input">
                                <label for="newEmpRate">
                                    <i class="fa-solid fa-user" style="color:var(--indigo);"></i>
                                    Người lao động (%)
                                </label>
                                <input type="number" id="newEmpRate" name="employeeRate"
                                       value="0" step="0.1" min="0" max="100" required
                                       onchange="previewNewTotal()">
                            </div>
                            <div class="insurance-rate-input">
                                <label for="newEmpRate2">
                                    <i class="fa-solid fa-building" style="color:#16a34a;"></i>
                                    Doanh nghiệp (%)
                                </label>
                                <input type="number" id="newEmpRate2" name="employerRate"
                                       value="0" step="0.1" min="0" max="100" required
                                       onchange="previewNewTotal()">
                            </div>
                            <div class="insurance-rate-input">
                                <label>Tổng tỷ lệ (%)</label>
                                <div style="padding:8px 12px; background:#f8fafc; border:1px solid var(--border); border-radius:4px; font-size:14px; font-weight:700; color:var(--text-main);">
                                    <span id="newTotalPreview">0.0</span>%
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="form-row">
                        <label for="rateNote">Ghi chú / Cơ sở pháp lý</label>
                        <input type="text" id="rateNote" name="note"
                               placeholder="VD: Theo Luật BHXH 2014, sửa đổi 2019">
                    </div>

                    <div class="form-row">
                        <label for="rateIsActive">Trạng thái</label>
                        <select id="rateIsActive" name="isActive">
                            <option value="1">Đang áp dụng</option>
                            <option value="0">Tạm dừng</option>
                        </select>
                    </div>

                    <div class="modal-actions">
                        <button type="button" class="btn-cancel"
                                onclick="closeModal('createRateModal')">Hủy</button>
                        <button type="submit" class="btn-primary">
                            <i class="fa-solid fa-check"></i> Thêm loại bảo hiểm
                        </button>
                    </div>

                </form>
            </div>
        </div>
        <%-- =============== End Add Insurance Rate Modal =============== --%>

        <%-- Hidden forms for server actions --%>
        <form id="updateRateForm" method="post"
              action="${pageContext.request.contextPath}/admin/insurance/action"
              style="display:none">
            <input type="hidden" name="action" value="updateRate">
            <input type="hidden" name="id" id="updateRateId">
            <input type="hidden" name="employeeRate" id="updateEmpRate">
            <input type="hidden" name="employerRate" id="updateEmpRate2">
        </form>

        <form id="deleteRateForm" method="post"
              action="${pageContext.request.contextPath}/admin/insurance/action"
              style="display:none">
            <input type="hidden" name="action" value="deleteRate">
            <input type="hidden" name="id" id="deleteRateId">
        </form>

        <%-- Hidden form: toggle trạng thái loại bảo hiểm --%>
        <form id="toggleRateForm" method="post"
              action="${pageContext.request.contextPath}/admin/insurance/action"
              style="display:none">
            <input type="hidden" name="action" value="toggleRate">
            <input type="hidden" name="id"       id="toggleRateId">
            <input type="hidden" name="isActive"  id="toggleRateIsActive">
        </form>

    </div>
</div>

<script>
    // ── Modal helpers ──────────────────────────────────────────
    function openModal(id)  { document.getElementById(id).style.display = 'flex'; }
    function closeModal(id) { document.getElementById(id).style.display = 'none'; }

    document.querySelectorAll('.modal-overlay').forEach(m => {
        m.addEventListener('click', e => { if (e.target === m) m.style.display = 'none'; });
    });

    // ── Preview total in Add modal ─────────────────────────────
    function previewNewTotal() {
        const emp  = parseFloat(document.getElementById('newEmpRate').value)  || 0;
        const emp2 = parseFloat(document.getElementById('newEmpRate2').value) || 0;
        document.getElementById('newTotalPreview').textContent = (emp + emp2).toFixed(1);
    }

    // ── Inline edit toggle ─────────────────────────────────────
    function toggleEditRate(id) {
        // Show inputs, hide display spans, show save/cancel
        document.getElementById('emp-rate-'   + id).style.display = 'none';
        document.getElementById('emp2-rate-'  + id).style.display = 'none';
        document.getElementById('emp-input-'  + id).style.display = 'inline-block';
        document.getElementById('emp2-input-' + id).style.display = 'inline-block';
        document.getElementById('edit-btn-'   + id).style.display = 'none';
        document.getElementById('save-btn-'   + id).style.display = 'inline-flex';
        document.getElementById('cancel-btn-' + id).style.display = 'inline-flex';
        document.getElementById('emp-input-'  + id).focus();
    }

    function cancelEditRate(id) {
        // Restore original display value from the span text
        const empOrig  = document.getElementById('emp-rate-'  + id).textContent.replace('%','').trim();
        const emp2Orig = document.getElementById('emp2-rate-' + id).textContent.replace('%','').trim();
        document.getElementById('emp-input-'  + id).value = empOrig;
        document.getElementById('emp2-input-' + id).value = emp2Orig;
        restoreDisplayMode(id);
    }

    function restoreDisplayMode(id) {
        document.getElementById('emp-rate-'   + id).style.display = 'inline-block';
        document.getElementById('emp2-rate-'  + id).style.display = 'inline-block';
        document.getElementById('emp-input-'  + id).style.display = 'none';
        document.getElementById('emp2-input-' + id).style.display = 'none';
        document.getElementById('edit-btn-'   + id).style.display = 'inline-flex';
        document.getElementById('save-btn-'   + id).style.display = 'none';
        document.getElementById('cancel-btn-' + id).style.display = 'none';
    }

    function updateTotal(id) {
        const emp  = parseFloat(document.getElementById('emp-input-'  + id).value) || 0;
        const emp2 = parseFloat(document.getElementById('emp2-input-' + id).value) || 0;
        document.getElementById('total-rate-' + id).textContent = (emp + emp2).toFixed(1) + '%';
    }

    function saveRate(id) {
        const emp  = parseFloat(document.getElementById('emp-input-'  + id).value);
        const emp2 = parseFloat(document.getElementById('emp2-input-' + id).value);

        if (isNaN(emp) || isNaN(emp2) || emp < 0 || emp2 < 0 || emp > 100 || emp2 > 100) {
            alert('Tỷ lệ phải là số từ 0 đến 100!');
            return;
        }

        // Update display spans
        document.getElementById('emp-rate-'  + id).textContent = emp.toFixed(1) + '%';
        document.getElementById('emp2-rate-' + id).textContent = emp2.toFixed(1) + '%';

        // Submit hidden form
        document.getElementById('updateRateId').value   = id;
        document.getElementById('updateEmpRate').value  = emp;
        document.getElementById('updateEmpRate2').value = emp2;
        document.getElementById('updateRateForm').submit();
    }

    // ── Toggle trạng thái loại bảo hiểm ───────────────────────
    function confirmToggleRate(id, currentActive) {
        const newActive = !currentActive;
        const label     = newActive ? 'Đang áp dụng' : 'Đã dừng';
        if (!confirm('Bạn có chắc muốn đổi trạng thái thành "' + label + '"?')) return;
        document.getElementById('toggleRateId').value      = id;
        document.getElementById('toggleRateIsActive').value = newActive ? '1' : '0';
        document.getElementById('toggleRateForm').submit();
    }

    // ── Delete ─────────────────────────────────────────────────
    function confirmDeleteRate(id, name) {
        if (confirm('Bạn có chắc muốn xóa loại bảo hiểm "' + name + '"?\nThao tác này không thể hoàn tác.')) {
            document.getElementById('deleteRateId').value = id;
            document.getElementById('deleteRateForm').submit();
        }
    }
</script>

</body>
</html>
